# Shorebird Build & Patch Scripts

Bộ script tự động hoá quy trình **build release** và **patch** Shorebird cho project `co_caro_flame`. Mục tiêu là gói toàn bộ các bước hay sai (kiểm tra Info.plist, flags iOS, version) vào một lệnh duy nhất. **Release và patch là hai lệnh tách rời** — chạy lệnh nào thì chỉ thực hiện đúng lệnh đó.

---

## 1. Tổng quan

Project dùng [Shorebird](https://shorebird.dev) để push code-push (OTA) cho user mà không cần qua review App Store / Play Store mỗi lần fix bug nhỏ. Workflow chuẩn của Shorebird gồm 2 giai đoạn:

| Giai đoạn | Lệnh | Khi nào dùng |
|---|---|---|
| **Release** | `shorebird release <platform>` | Khi đổi version (vd `1.0.8 → 1.0.9`). Tạo bản build mới, upload lên Shorebird, và đó là baseline để patch về sau. Vẫn phải submit binary này lên App Store / Play Store. |
| **Patch**   | `shorebird patch <platform> --release-version=X.Y.Z+B` | Khi đã có release `X.Y.Z+B` đang chạy production, muốn fix bug nhanh. Không cần submit store, user nhận update qua OTA. |

Script này bọc 2 lệnh đó với **pre-flight checks** (đặc biệt cho iOS) và xử lý version mặc định để giảm thao tác tay. Mỗi lần gọi chỉ làm đúng 1 việc — bạn quyết định khi nào release, khi nào patch.

---

## 2. Yêu cầu hệ thống

| Tool | Lý do | Cách kiểm tra |
|---|---|---|
| `shorebird` CLI | Build & patch | `shorebird --version` |
| `python3` (≥ 3.8) | Sửa Info.plist (dùng stdlib `plistlib`) | `python3 --version` |
| `bash` | Run script | macOS có sẵn |
| Xcode + CocoaPods | Cho build iOS | `xcodebuild -version`, `pod --version` |
| Android SDK + JDK | Cho build Android | Tự verify qua `flutter doctor` |

Project có Flutter version pin sẵn ở `/Users/admin/fvm/versions/3.41.6`. Shorebird CLI tự quản lý Flutter version độc lập (không bị ảnh hưởng bởi FVM của project).

---

## 3. Cấu trúc thư mục `scripts/`

```
scripts/
├── README.md                # File này
├── shorebird_build.sh       # Entry point - script chính
└── ensure_info_plist.py     # Helper kiểm tra & vá Info.plist (chỉ chạy khi iOS)
```

Không cần install dependency Python — chỉ dùng stdlib (`plistlib`, `shutil`, `pathlib`, `sys`).

---

## 4. Cách dùng nhanh

```bash
cd /Users/admin/Documents/shorebird/caro/co_caro_v2

# 1) Release iOS với version mặc định (đọc từ pubspec.yaml)
#    Sau khi release xong sẽ tự động patch luôn.
./scripts/shorebird_build.sh release ios

# 2) Release Android, version chỉ định tay
./scripts/shorebird_build.sh release android 1.0.9+3

# 3) Chỉ patch iOS, lấy version từ pubspec.yaml
./scripts/shorebird_build.sh patch ios

# 4) Chỉ patch Android cho một release đã có sẵn
./scripts/shorebird_build.sh patch android 1.0.8+2
```

Nếu là lần đầu chạy, `chmod +x` cả 2 file:

```bash
chmod +x scripts/shorebird_build.sh scripts/ensure_info_plist.py
```

---

## 5. Reference: tham số

```
Usage: shorebird_build.sh <mode> <platform> [version]
```

### `mode` (bắt buộc)

| Giá trị | Hành vi |
|---|---|
| `release` | Chỉ chạy `shorebird release <platform>`. **Không** tự động patch sau đó. |
| `patch`   | Chỉ chạy `shorebird patch <platform> --release-version=...`. Không build release mới. |

Nếu muốn vừa release vừa patch ngay sau đó, gọi script 2 lần riêng:

```bash
./scripts/shorebird_build.sh release ios
./scripts/shorebird_build.sh patch   ios
```

### `platform` (bắt buộc)

| Giá trị | Hành vi đặc thù |
|---|---|
| `ios`     | Chạy verify Info.plist trước khi build. Tự thêm flag `--no-tree-shake-icons` vào flutter args. |
| `android` | Không có pre-flight check. Không thêm flag tree-shake. |

### `version` (tùy chọn)

Định dạng `X.Y.Z+B`, ví dụ `1.0.9+3`:

- `X.Y.Z` là `build-name` (semantic version).
- `B` là `build-number` (số nguyên tăng dần).

Mặc định nếu không truyền, script đọc dòng `version:` trong `pubspec.yaml`. Hiện tại pubspec đang là `1.0.8+2`.

Script regex validate: nếu version sai format thì **fail ngay**, không build.

---

## 6. Workflow chi tiết

```
┌──────────────────────────────────────────────────────────────┐
│  ./scripts/shorebird_build.sh <mode> <platform> [version]    │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
                  ┌──────────────────────┐
                  │   Parse + validate    │
                  │   mode/platform/ver   │
                  └──────────┬───────────┘
                              │
                  ┌──────────▼───────────┐
                  │ Resolve version       │
                  │  - từ arg, hoặc       │
                  │  - đọc pubspec.yaml   │
                  └──────────┬───────────┘
                              │
              platform == ios ┴ platform == android
                ┌────────────▼─────┐    │
                │ ensure_info_plist │    │
                │   .py (auto-fix)  │    │
                └────────────┬─────┘    │
                              │          │
                              ▼          ▼
                  ┌──────────────────────────────┐
                  │  flutter_args =              │
                  │    --build-name=X.Y.Z        │
                  │    --build-number=B          │
                  │    [--no-tree-shake-icons]   │
                  └──────────┬───────────────────┘
                              │
                  ┌──────────▼─────────┐
                  │   mode == ?         │
                  └─────┬─────────┬────┘
                        │         │
                  release          patch
                        │              │
            ┌──────────▼───┐   ┌──────▼─────────────┐
            │ shorebird     │   │ shorebird           │
            │ release       │   │ patch               │
            │ <platform>    │   │ <platform>          │
            │ -- <args>     │   │ --release-version=  │
            │               │   │     X.Y.Z+B         │
            │               │   │ -- <args>           │
            └──────────┬───┘   └──────────┬──────────┘
                        │                   │
                        ▼                   ▼
                       END                 END
```

Hai nhánh độc lập — không tự nối với nhau. Muốn release rồi patch ngay thì gọi script 2 lần.

---

## 7. Pre-flight check Info.plist (chỉ iOS)

Đây là phần quan trọng nhất, vì project dùng plugin `terminate_restart` để force-restart app sau khi Shorebird patch được áp dụng. Nếu Info.plist thiếu key, restart sẽ **fail silently** và patch không có hiệu lực.

### 7.1. Các key bắt buộc

Helper `ensure_info_plist.py` kiểm tra 4 nhóm key sau, **auto-thêm** nếu thiếu:

#### a) `CFBundleURLTypes`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
</array>
```

**Lý do:** `terminate_restart` plugin kill process iOS rồi yêu cầu OS reopen app qua URL scheme. Thiếu key này thì `restart(terminate: true)` rơi vào fallback **widget remount** thay vì process restart thật → Shorebird patch nằm trong bản binary cũ vẫn được load → người dùng không thấy fix.

Helper kiểm tra logic: trong array `CFBundleURLTypes` phải có ít nhất 1 entry mà `CFBundleURLSchemes` chứa `$(PRODUCT_BUNDLE_IDENTIFIER)`. Nếu chưa có thì append entry mới.

#### b) `UIRequiresFullScreen = true`

```xml
<key>UIRequiresFullScreen</key>
<true/>
```

**Lý do:** Bắt app chạy fullscreen, tránh split-view / multitasking trên iPad. Đối với game cờ caro, layout chỉ thiết kế full screen — nếu user kéo split-view sẽ vỡ UI.

#### c) `UISupportedInterfaceOrientations` (iPhone)

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
</array>
```

#### d) `UISupportedInterfaceOrientations~ipad`

Cùng 4 hướng như iPhone, dùng cho iPad.

**Lý do:** Game support cả Portrait và Landscape. Apple lúc submit binary sẽ verify supportedInterfaceOrientations khớp với code; thiếu sẽ bị reject hoặc khoá orientation runtime.

### 7.2. Cơ chế kiểm tra

Helper dùng `plistlib` (stdlib Python) để parse & ghi lại XML plist, **không dùng regex** trên file. Các điểm chính:

- **Idempotent**: chạy nhiều lần đều ra cùng kết quả. Lần 2 sẽ in `OK — không sửa gì`.
- **Backup**: trước khi ghi, copy file gốc sang `Info.plist.bak` cùng thư mục. Nếu ghi fail, rollback.
- **Sort keys**: ghi lại với `sort_keys=True` để giữ thứ tự alphabet như Xcode native.
- **Detection chi tiết**: chỉ thêm **đúng những key/giá trị thiếu**, không ghi đè những gì đã có. Vd hiện tại Info.plist đã có `CFBundleURLTypes` và `~ipad` đúng, helper chỉ đụng vào `UIRequiresFullScreen` và bổ sung 3 hướng còn thiếu cho iPhone.
- **Comments không được preserve**. Nếu Info.plist có comment XML (`<!-- ... -->`), comment sẽ mất sau khi helper ghi lại. (Project hiện tại không có comment trong plist, nên an toàn.)

### 7.3. Output mẫu

Khi có sửa:

```
[plist] Đã cập nhật Info.plist (backup tại Info.plist.bak).
        • đặt UIRequiresFullScreen = true
        • bổ sung vào UISupportedInterfaceOrientations (iPhone): UIInterfaceOrientationLandscapeLeft, UIInterfaceOrientationLandscapeRight, UIInterfaceOrientationPortraitUpsideDown
```

Khi không có gì để sửa:

```
[plist] OK — Info.plist đã đủ các key bắt buộc, không sửa gì.
```

### 7.4. Chạy helper độc lập (không qua build script)

```bash
python3 scripts/ensure_info_plist.py ios/Runner/Info.plist
```

Exit code:
- `0` — thành công (dù có sửa hay không)
- `1` — lỗi đọc/ghi file
- `2` — sai số lượng argument

---

## 8. iOS-specific: `--no-tree-shake-icons`

Mỗi lần build iOS, script tự thêm `--no-tree-shake-icons` vào flutter args. Lý do:

- Project dùng `google_fonts` và một số icon font asset. Tree-shake icon đôi khi loại nhầm glyph được dùng động (vd glyph render từ string code-point), dẫn đến icon mất ở runtime.
- Build CI / store cần determinism — tắt tree-shake để asset luôn full.
- Android không cần flag này vì Android không có vấn đề tương tự với MaterialIcons (Flutter tree-shake chỉ áp dụng cho icon font, và iOS bundle khắt khe hơn).

---

## 9. Version handling

### 9.1. Format chuẩn

`X.Y.Z+B` (tương thích với `version:` field của Dart pubspec):

```yaml
# pubspec.yaml
version: 1.0.8+2
```

- `X` major, `Y` minor, `Z` patch (semver).
- `+B` là `build-number` — phải tăng strictly cho từng release upload Store.

### 9.2. Khi nào bump version

| Hành động | Yêu cầu |
|---|---|
| Hot-fix code-push (chỉ Dart) | Không bump version, chỉ chạy `patch` |
| Đổi native code (Swift / Kotlin / pod / gradle) | Phải bump version → `release` mới |
| Đổi asset bundled (image, font) trong binary | Phải bump version → `release` |
| Submit lên App Store / Play Store | Phải bump `+B` (build-number) ít nhất |

### 9.3. Override version qua CLI

Khi truyền tay version, script sẽ ưu tiên giá trị truyền vào, **không sửa** `pubspec.yaml`. Cẩn thận: nếu version đó chưa tồn tại trên Shorebird (chưa có release nào) mà bạn chạy `patch`, Shorebird sẽ báo lỗi `No release found for version X.Y.Z+B`.

---

## 10. Tách rời release và patch

Script cố tình **không** auto-patch sau release. Lý do:

- **Tách lifecycle**: release sinh ra một binary baseline cần submit App Store / Play Store. Patch là code-push trên top của baseline đó. Hai việc thường xảy ra ở **hai thời điểm khác nhau** — release ngay khi bump version, patch sau đó nhiều ngày / nhiều tuần khi có bug fix.
- **Tránh upload nhầm**: nếu release vừa xong đã patch ngay → bản patch đó nằm trên một release vừa sinh ra, chưa kịp test → user nhận patch chứa cùng bug.
- **Rõ ý định**: mỗi lần gọi script, bạn biết chính xác lệnh đang chạy. Không có magic side-effect.

Workflow thực tế recommend:

```bash
# Ngày 1: bump version, build release, submit store
./scripts/shorebird_build.sh release ios       # → upload IPA mới
# (submit App Store Connect, đợi review)

# Ngày N: phát hiện bug Dart, fix code, ship hot patch
./scripts/shorebird_build.sh patch ios         # → OTA cho user
```

Nếu thực sự muốn chạy chuỗi `release → patch` trong cùng một phiên, gọi 2 lần:

```bash
./scripts/shorebird_build.sh release ios && \
./scripts/shorebird_build.sh patch   ios
```

---

## 11. Troubleshooting

### "shorebird CLI không có trong PATH"
Install Shorebird CLI:
```bash
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | sh
```

### "Version sai format. Mong đợi X.Y.Z+B"
- Đảm bảo có dấu `+` giữa build-name và build-number.
- Tất cả phần đều là số. Vd `1.0.9-beta+3` sẽ fail (không hỗ trợ pre-release tag để giữ tương thích Shorebird).

### "Failed to find release"
Khi patch, Shorebird báo không tìm thấy release version → kiểm tra:
```bash
shorebird releases list
```
- Đảm bảo đã `shorebird release` trước cho version đó.
- Đúng platform: release iOS không patch cho Android.

### Info.plist sau khi script sửa bị mất comment
Helper dùng `plistlib` nên không preserve `<!-- comment -->`. Nếu cần comment, edit tay sau khi script chạy xong. Hoặc rollback từ `Info.plist.bak`:
```bash
mv ios/Runner/Info.plist.bak ios/Runner/Info.plist
```

### Build iOS fail vì `rive_native: pubspec.yaml not found in ios/Pods`
Đây là lỗi setup `rive_native` chưa chạy. Sửa riêng:
```bash
/Users/admin/fvm/versions/3.41.6/bin/dart run rive_native:setup --verbose --platform ios
```
Setup này tạo marker `~/.pub-cache/hosted/pub.dev/rive_native-*/ios/rive_marker_ios_setup_complete`. Lần sau build phase trong Xcode sẽ skip step setup. Khi update Flutter / clear pub-cache có thể phải chạy lại.

### Shorebird patch upload xong nhưng app không nhận update
1. Kiểm tra `auto_update: true` trong `shorebird.yaml` (mặc định là true nếu không set).
2. Force restart app — `terminate_restart` plugin yêu cầu URL scheme đã setup (xem mục 7.1.a).
3. Đảm bảo app đang chạy đúng **release version** mà patch nhắm tới. Patch chỉ áp cho đúng `--release-version`.

---

## 12. Mở rộng

Một số tính năng có thể thêm sau:

- **Flavor support**: Thêm tham số flavor (`prod` / `staging`) và truyền `--flavor` vào shorebird.
- **Dry-run mode**: Flag `--dry-run` để in lệnh sẽ chạy mà không thực thi.
- **Auto bump version**: Thêm option `--bump patch|minor|major` để tự tăng version trong pubspec trước khi build.
- **Slack / Telegram notification**: Sau khi release/patch xong, gửi notification cho team.
- **CI integration**: Convert script thành GitHub Actions workflow.

Nếu cần thêm, mở issue / PR.

---

## 13. Tham khảo

- [Shorebird Docs](https://docs.shorebird.dev)
- [shorebird_code_push (Dart package)](https://pub.dev/packages/shorebird_code_push)
- [terminate_restart (Dart package)](https://pub.dev/packages/terminate_restart)
- [Apple — Info.plist Key Reference](https://developer.apple.com/documentation/bundleresources/information-property-list)
