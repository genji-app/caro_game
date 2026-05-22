# Hướng dẫn dùng `convert_to_package.sh`

Script bash để convert **s88-flutter** (Flutter app) thành một **Flutter package** có thể nhúng vào một app Flutter khác.

> Đây là tài liệu sử dụng script. README chính của dự án (mô tả app s88) ở [`README.md`](README.md).

---

## Mục đích

Khi bạn cần dùng lại logic/UI của s88-flutter trong một app Flutter khác — thay vì copy-paste code, bạn chạy script này để sinh ra một bản package "sạch" (đã strip native folders, đã expose public API) ở folder mới. Sau đó host app chỉ cần thêm vào `pubspec.yaml`:

```yaml
dependencies:
  sun_sports:
    path: ../sun_sports_package
```

## Yêu cầu trước khi chạy

- macOS hoặc Linux với `bash`
- `rsync` (có sẵn trên macOS, hoặc `apt install rsync` trên Linux)
- `perl` (có sẵn trên mọi macOS/Linux)
- Source directory hợp lệ (chứa `pubspec.yaml`)
- Quyền ghi vào thư mục target

Không cần Dart/Flutter SDK để chạy script — script chỉ thao tác file. SDK chỉ cần khi chạy `flutter pub get` ở folder kết quả.

## Cú pháp

```bash
bash convert_to_package.sh [--env=prod|staging] [--verify] [SOURCE_DIR] [TARGET_DIR]
```

Tham số đặt ở đâu cũng được — flag có thể nằm trước, giữa, hoặc sau positional args.

### Bảng tham số

| Tham số          | Bắt buộc | Mặc định                                                  | Ý nghĩa                                                                       |
| ---------------- | -------- | --------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `--env=<value>`  | Không    | _(không lock)_                                            | Đổi default `APP_ENV` trong package. Giá trị hợp lệ: `prod`, `staging`        |
| `--verify`       | Không    | _(off)_                                                   | Sau khi convert, chạy `flutter pub get` → `dart format lib/ example/lib/` → `flutter analyze`. Format toàn bộ package, rồi báo lỗi nếu output có vấn đề. Cần `flutter` trên PATH. |
| `--no-verify`    | Không    | _(default)_                                               | Tắt verify (rõ ràng — vì đang là default)                                     |
| `--fix`          | Không    | _(off)_                                                   | Chạy thêm `dart fix --apply lib/` trong bước verify (implies `--verify`). **Opt-in** vì `dart fix` đôi khi sinh code không compile. Nên review diff sau khi dùng. |
| `--strict`       | Không    | _(off)_                                                   | Verify fail trên **warning + info** chứ không chỉ error (implies `--verify`). Default là lenient vì hầu hết warning/info là pre-existing trong source — không nên block convert. |
| `SOURCE_DIR`     | Không    | `/Users/admin/Documents/projects/s88-flutter`             | Đường dẫn s88-flutter gốc                                                     |
| `TARGET_DIR`     | Không    | `/Users/admin/Documents/projects/sun_sports_package`      | Folder output (sẽ **tự động bị xóa** nếu đã tồn tại — không hỏi confirm)      |
| `-h`, `--help`   | Không    | —                                                         | In comment header của script                                                  |

## Ví dụ

### 1. Convert nhanh nhất (dùng toàn bộ default)

```bash
cd /Users/admin/Documents/projects/s88-flutter
bash convert_to_package.sh
```

Output ra `/Users/admin/Documents/projects/sun_sports_package`, default `APP_ENV` vẫn là `staging`.

### 2. Lock default `APP_ENV` sang `prod`

```bash
bash convert_to_package.sh --env=prod
```

Khi host build mà không truyền `--dart-define=APP_ENV=...`, package sẽ chạy ở chế độ `prod`. Host vẫn override được:

```bash
flutter run --dart-define=APP_ENV=staging   # override sang staging tạm thời
```

### 3. Output ra folder tùy ý

```bash
bash convert_to_package.sh \
  /Users/admin/Documents/projects/s88-flutter \
  ~/Desktop/sun_sports_package
```

### 4. Kết hợp tất cả

```bash
bash convert_to_package.sh --env=prod \
  /Users/admin/Documents/projects/s88-flutter \
  ~/Desktop/sun_sports_package
```

### 5. Convert kèm verify (chạy `flutter pub get` + `analyze`)

```bash
bash convert_to_package.sh --verify
```

Hoặc kết hợp:

```bash
bash convert_to_package.sh --env=prod --verify
```

Script sẽ:
1. Convert như bình thường
2. `cd` vào target, chạy `flutter pub get`
3. **`dart format lib/ example/lib/`** — format toàn bộ `lib/` + `example/lib/` để package giao tới host hoàn toàn nhất quán
4. **`flutter analyze --no-fatal-infos --no-fatal-warnings`** — analyze toàn project nhưng CHỈ fail trên **error** (compile broken). Warning/info được đếm và in ra để bạn biết có bao nhiêu, nhưng không block.
5. **Exit code ≠ 0** nếu pub get hoặc có **error** — phù hợp cho CI

> **Tại sao verify lenient mặc định?**
> Project s88 có `analysis_options.yaml` strict với nhiều lint rule. Phần lớn warning/info trong output là **pre-existing trong source** (vd: `unused_import`, `avoid_print`, `dead_code`...). Convert script không tạo ra chúng — chỉ copy nguyên xi từ source. Block conversion vì những vấn đề này là không hợp lý.
>
> Nếu bạn muốn verify strict (fail trên mọi level):
> ```bash
> bash convert_to_package.sh --strict
> ```

> **Tại sao mặc định KHÔNG chạy `dart fix --apply`?**
> Vì `dart fix` đôi khi sinh code không compile trong các class có constructor phức tạp (nhiều params, hoặc field declared sau constructor). Vài lỗi thực tế đã gặp:
> - `The field 'X' can't be initialized by multiple parameters in the same constructor` (duplicate param do reorder)
> - `All final variables must be initialized` (param bị move khỏi constructor)
>
> Nếu bạn vẫn muốn auto-fix lint, dùng flag `--fix` (opt-in, implies `--verify`):
> ```bash
> bash convert_to_package.sh --fix
> ```
> Sau đó BẮT BUỘC review diff trước khi commit.

Output mẫu khi verify pass (có warning/info nhưng không có error):

```
▸ Verifying generated package (--verify)
▸   → flutter pub get
✓   pub get OK
▸   → dart format lib/ example/lib/
✓   Formatted 287 files (12 changed) in 0.84 seconds.
▸   → flutter analyze (lenient — fail on errors only)
✓   analyze OK (0 errors, 5 warnings, 28 infos — non-fatal; see /tmp/_conv_analyze.log)
✓ Verification passed
```

Output khi có lỗi compile thật (error):

```
▸   → flutter analyze (lenient — fail on errors only)
⚠   analyze REPORTED ERRORS — see below
   error • Undefined name 'foo' • lib/x.dart:42:5 • undefined_identifier
   ...
✗ Verification failed
```

Output mẫu khi analyze báo lỗi:

```
▸   → flutter analyze
⚠   analyze REPORTED ISSUES — see below
   error • undefined identifier 'foo' • lib/sun_sports_init.dart:42
   warning • unused import • lib/sun_sports_root.dart:5
   ...
   full output: /tmp/_conv_analyze.log
✗ Verification failed — package is generated but has issues above
```

## Script làm gì (8 bước)

1. **Validate** — kiểm tra source tồn tại, có `pubspec.yaml`; nếu target đã tồn tại thì **tự động xóa**
2. **Copy** — `rsync` source → target, loại trừ `.git`, `.dart_tool`, `build`, `.idea`, `.vscode`, `SUN88_v2`, `fastlane`, `docs`
3. **Strip app-only** — xóa native folders (`android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`), xóa `lib/main.dart`, `firebase.json`, `Gemfile*`, `Makefile`, `fastlane/`, `test_scroll.html`, `TheCaoTopupView.ts`
4. **Rewrite `pubspec.yaml`** — đổi `description`, giữ nguyên dependencies + 10 local packages dưới `packages/`
5. **Lock env** (nếu có `--env`) — sửa `defaultValue` trong `lib/core/env/app_env.dart`
6. **Generate public API** — tạo 3 file:
   - `lib/sun_sports.dart` — barrel file
   - `lib/sun_sports_init.dart` — `SunSports.init()` thay thế `main()`
   - `lib/sun_sports_root.dart` — `SunSportsApp` widget
7. **Generate `example/`** — host app demo nhỏ chạy được, có debug print kiểm tra env
8. **Generate `README.md`** — checklist thủ công và hướng dẫn dùng package

## Output structure

```
sun_sports_package/
├── lib/
│   ├── sun_sports.dart           ← public API barrel (mới)
│   ├── sun_sports_init.dart      ← SunSports.init() (mới)
│   ├── sun_sports_root.dart      ← SunSportsApp widget (mới)
│   ├── app.dart                  ← App widget (giữ nguyên)
│   ├── core/                     ← (giữ nguyên)
│   ├── features/                 ← (giữ nguyên)
│   ├── gen/                      ← (giữ nguyên)
│   └── shared/                   ← (giữ nguyên)
├── packages/                     ← 10 local packages (giữ nguyên)
│   ├── adaptive_overlay/
│   ├── caxilo_config/
│   ├── caxilo_repository/
│   ├── flutter_slider_drawer/
│   ├── fullscreen_guard/
│   ├── game_api_client/
│   ├── game_engine/
│   ├── orientation_guard/
│   ├── sport_socket/
│   └── casino_settings/
├── example/                      ← host app demo (mới)
│   ├── pubspec.yaml
│   └── lib/main.dart
├── assets/                       ← (giữ nguyên)
├── test/                         ← (giữ nguyên)
├── pubspec.yaml                  ← đã rewrite
├── pubspec.lock                  ← (giữ nguyên, sẽ regen khi pub get)
├── analysis_options.yaml         ← (giữ nguyên)
├── build.yaml                    ← (giữ nguyên)
└── README.md                     ← auto-generated guide
```

Lưu ý: không có `android/`, `ios/`, `web/`, `lib/main.dart` — đó là những thứ chỉ có ở Flutter app, không thuộc về library.

## Sau khi convert xong — làm gì tiếp

### Bước 1: Verify package compile được

```bash
cd /Users/admin/Documents/projects/sun_sports_package
flutter pub get
```

Nếu có lỗi dependency (vd: version conflict), xem `pubspec.yaml` và sửa.

### Bước 2: Chạy example để kiểm chứng

```bash
cd example
flutter pub get
flutter run --dart-define=APP_ENV=staging
```

Trong console phải thấy:

```
SunSports starting as: staging
```

Nếu lock với `--env=prod` thì sẽ thấy `prod` khi không truyền dart-define.

> **Mẹo**: nếu chạy script với `--verify`, bước 1 và phần kiểm tra `flutter analyze` đã chạy tự động. Bạn chỉ cần làm bước này khi muốn test runtime thật.

### Bước 3: Đọc README sinh ra

```bash
open /Users/admin/Documents/projects/sun_sports_package/README.md
```

File này có:
- Hướng dẫn import vào host app
- Bảng public API
- Section chi tiết về env variables
- Checklist thủ công (assets, permissions, Hive collision, router ownership, v.v.)

### Bước 4: Tích hợp vào host app

```yaml
# host_app/pubspec.yaml
dependencies:
  sun_sports:
    path: ../sun_sports_package
  flutter_riverpod: ^2.5.1
```

```dart
// host_app/lib/main.dart
import 'package:sun_sports/sun_sports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await SunSports.init();
  runApp(ProviderScope(
    overrides: overrides,
    child: const SunSportsApp(),
  ));
}
```

## Re-run script (chạy lại)

Script idempotent — chạy lại được nhiều lần. Khi target đã tồn tại, script sẽ **tự động xóa** rồi convert lại (không hỏi confirm):

```
⚠ Target /Users/admin/Documents/projects/sun_sports_package already exists — deleting it before convert
✓ Removed existing /Users/admin/Documents/projects/sun_sports_package
```

> **⚠️ Cảnh báo quan trọng**: nếu bạn đã sửa thủ công code trong target sau lần convert trước, lần re-run sẽ **MẤT** toàn bộ những thay đổi đó. Backup trước nếu cần — ví dụ:
> ```bash
> cp -R /Users/admin/Documents/projects/sun_sports_package /Users/admin/Documents/projects/sun_sports_package.bak
> bash convert_to_package.sh
> ```

Để đổi default env, chỉ cần chạy lại với flag khác:

```bash
bash convert_to_package.sh --env=staging   # đổi từ prod về staging
bash convert_to_package.sh --env=prod      # ngược lại
```

## Troubleshooting

### `rsync: command not found`

Script tự fallback sang `cp -R`, nhưng `cp` chậm hơn và không loại trừ chính xác. Cài rsync:

```bash
# macOS — đã có sẵn, nếu thiếu thì cài qua brew
brew install rsync

# Linux
sudo apt install rsync   # Debian/Ubuntu
sudo yum install rsync   # CentOS/RHEL
```

### `Permission denied`

Source hoặc target thuộc user khác. Đổi quyền hoặc chạy với user phù hợp:

```bash
chmod -R u+w /path/to/target
```

### Target đã tồn tại — script có hỏi gì không?

**Không**. Script tự động xóa target rồi convert lại. Nếu cần backup, copy ra chỗ khác trước khi chạy.

### `--env=prod` không có hiệu lực

Kiểm tra:
1. `cat sun_sports_package/lib/core/env/app_env.dart | grep defaultValue` — phải thấy `defaultValue: 'prod'`
2. Nếu vẫn là `staging`, xem stderr lúc chạy có dòng `⚠ Could not locate defaultValue line` không. Nếu có nghĩa source `app_env.dart` đã thay đổi format, script regex không match.

### `flutter pub get` báo lỗi version conflict trong host

Host app dùng version khác của `flutter_riverpod` / `hive` / `dio` / `freezed_annotation` so với s88. Giải pháp:
1. Mở `sun_sports_package/pubspec.yaml`, copy 4 version pin trên sang host's `pubspec.yaml`
2. Hoặc dùng `dependency_overrides:` trong host's pubspec để force version

### `--verify` báo lỗi nhưng tôi vẫn muốn output

Output đã được sinh ra **trước khi** verify chạy — file vẫn còn trong target. Bạn chỉ cần:
1. Đọc lỗi từ output console hoặc `/tmp/_conv_analyze.log`
2. Sửa source (chủ yếu là `lib/main.dart`)
3. Re-run script (có hoặc không `--verify`)

Hoặc nếu chỉ muốn xem output bất kể lỗi, bỏ flag `--verify`.

### `--verify` báo "flutter not on PATH"

Bạn chưa cài Flutter SDK hoặc chưa thêm vào PATH. Cài Flutter rồi thử lại, hoặc bỏ `--verify` để bỏ qua bước kiểm tra.

### Build runner kêu generated files thiếu

Sau khi convert, chạy lại codegen trong package:

```bash
cd sun_sports_package
dart run build_runner build --delete-conflicting-outputs
```

### `Image.asset` không hiển thị trong host

Asset paths trong package cần prefix `packages/sun_sports/` khi consume từ host. Bên trong package code, thêm `package: 'sun_sports'` vào mọi `Image.asset(...)`. Đây là việc thủ công, script không auto vì rủi ro phá code.

### Hive box bị conflict với host

Box names trong s88 (`deposit_box`, `search_recent_box`, ...) có thể đụng với host. Search `Hive.openBox(` và `Hive.box(` trong `lib/`, rename prefix `sun_sports_`.

## FAQ

### Script có làm thay đổi gì trong source `s88-flutter` không?

**Không.** Script chỉ đọc source và ghi sang target. Source nguyên vẹn.

### Tôi có cần commit script này vào git không?

Có. Script là một phần infrastructure của dự án, nên ở root cùng với `Makefile`, `analysis_options.yaml`. Khi cần re-convert (vd: lên version mới, fix bug), bạn chạy lại.

### Output có cần git riêng không?

Tùy. Có 2 mô hình:
- **Generated artifact**: output không vào git, mỗi lần cần thì convert lại. Phù hợp khi s88 thay đổi nhanh.
- **Separate repo**: tạo git repo riêng cho `sun_sports_package`, commit từng phiên bản convert. Phù hợp khi host app cần pin version cụ thể.

### Tôi muốn host import qua git (không phải path) — làm sao?

Sau khi convert, push folder output lên git repo riêng. Host import:

```yaml
dependencies:
  sun_sports:
    git:
      url: git@github.com:your-org/sun_sports_package.git
      ref: v1.0.0
```

### Script có hỗ trợ Windows không?

Script là bash, nên cần WSL trên Windows. PowerShell native không chạy được. Trên WSL chạy bình thường.

### Convert mất bao lâu?

Trên Mac M1 với rsync: ~5–10 giây cho project size hiện tại (~vài chục MB không tính `.dart_tool`). Phần lâu nhất là `flutter pub get` ở folder kết quả (~30s–1m).

## Phụ lục: các bước thủ công script KHÔNG làm

Script tạo public API và clean structure. Các việc sau cần làm tay (đã list trong README sinh ra):

- Thêm `package: 'sun_sports'` vào mọi `Image.asset(...)` trong `lib/`
- Rename Hive boxes để tránh đụng host
- Copy permissions sang host's `AndroidManifest.xml` / `Info.plist` (INTERNET, camera, mic, network state)
- Setup PiP cho `flutter_in_app_pip` trong host's `MainActivity` / `AppDelegate`
- Refactor `App` widget nếu host muốn own routing (hiện `App` tự own `GoRouter` + `MaterialApp.router`)
- Pin matching versions của `flutter_riverpod`, `hive`, `dio`, `freezed_annotation` trong host

Khi cần hỗ trợ làm các phần này, mở issue/ping team.
