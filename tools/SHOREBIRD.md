# Shorebird Helper Script

Hướng dẫn sử dụng `tools/shorebird.sh` — script wrapper cho `shorebird release` và `shorebird patch` của project **co_caro_flame**.

Script này gói toàn bộ flag thường dùng (đặc biệt là `--no-tree-shake-icons` để asset hash luôn match giữa release và patch), tự đọc version từ `pubspec.yaml`, hỗ trợ chạy Android, iOS hoặc cả hai trong 1 lệnh.

---

## 1. Yêu cầu (Prerequisites)

Trước khi chạy script, máy bạn phải có sẵn:

- **Shorebird CLI** đã cài. Kiểm tra: `shorebird --version`. Cài tại https://docs.shorebird.dev/getting-started/
- **Flutter SDK** đã cài và `flutter doctor` không còn lỗi nghiêm trọng.
- **Đã login Shorebird**: `shorebird login` (chỉ làm 1 lần / 1 máy).
- File `shorebird.yaml` tồn tại ở root project (đã có sẵn — chứa `app_id`).
- File `pubspec.yaml` có đúng `version: x.y.z+build`.
- **Build iOS**: bắt buộc chạy trên **macOS** có Xcode + Apple Developer signing setup đầy đủ.
- **Build Android**: cần JDK + Android SDK + keystore (đã setup trong `android/key.properties`).

---

## 2. Cấu trúc lệnh

```text
./tools/shorebird.sh [action] [platform] [version]
```

| Tham số    | Giá trị hợp lệ                          | Mô tả                                          |
|------------|------------------------------------------|------------------------------------------------|
| `action`   | `release` \| `patch` \| `help`           | Hành động muốn thực hiện                       |
| `platform` | `android` \| `ios` \| `both`             | Nền tảng đích                                  |
| `version`  | `x.y.z+build` (ví dụ `1.0.8+2`)          | Chỉ dùng cho `patch`. Bỏ trống → đọc từ pubspec |

Không truyền argument nào → script chạy ở **menu tương tác**.

---

## 3. Các mode sử dụng

### 3.1 Menu tương tác (lần đầu nên dùng cái này)

```bash
./tools/shorebird.sh
```

Script sẽ in ra menu, bạn chọn số tương ứng:

```text
1) Release Android
2) Release iOS
3) Release BOTH (Android + iOS)
4) Patch   Android
5) Patch   iOS
6) Patch   BOTH (Android + iOS)
q) Quit
```

Với patch, script hỏi thêm release version (mặc định = pubspec) và track (stable / staging / beta).

### 3.2 Release (build bản mới upload store)

```bash
# Chỉ Android — output là AAB
./tools/shorebird.sh release android

# Chỉ iOS — output là IPA
./tools/shorebird.sh release ios

# Cả hai (Android build trước, iOS build sau)
./tools/shorebird.sh release both
```

Lệnh thực tế được Shorebird chạy ngầm:
```bash
shorebird release android -- --no-tree-shake-icons
shorebird release ios     -- --no-tree-shake-icons
```

Sau khi build xong → upload AAB lên Play Console, IPA lên App Store Connect như bình thường.

### 3.3 Patch (deliver code mới qua over-the-air)

```bash
# Patch theo version hiện tại trong pubspec.yaml
./tools/shorebird.sh patch ios
./tools/shorebird.sh patch android
./tools/shorebird.sh patch both

# Patch cho 1 version cụ thể (override)
./tools/shorebird.sh patch ios 1.0.8+2
./tools/shorebird.sh patch both 1.0.7+5
```

Lệnh thực tế:
```bash
shorebird patch ios --release-version=1.0.8+2 -- --no-tree-shake-icons
```

> ⚠️ **Patch chỉ chạy trên đúng release version đã build.** Patch cho `1.0.8+2` không apply lên thiết bị đang chạy `1.0.8+3`. Phải build release mới rồi patch tiếp.

---

## 4. Biến môi trường (Environment variables)

### `TRACK` — đẩy patch lên track tuỳ chọn

Mặc định Shorebird gửi patch tới track `stable` (tất cả user). Để test trước:

```bash
# Đẩy patch lên staging — chỉ device dùng `shorebird preview --track staging` mới nhận
TRACK=staging ./tools/shorebird.sh patch ios 1.0.8+2

# Beta track
TRACK=beta ./tools/shorebird.sh patch both
```

Track value hợp lệ: `stable`, `staging`, `beta`, hoặc custom track bạn đã tạo trên console.

### `STAGED_ROLLOUT` — rollout từ từ theo %

Chỉ áp dụng cho `patch`. Giá trị `1..100`:

```bash
# Chỉ rollout 20% user trước, monitor crash, sau đó promote 100% từ console
STAGED_ROLLOUT=20 ./tools/shorebird.sh patch android 1.0.8+2
```

### `EXTRA_ARGS` — thêm flag cho `flutter build`

Mọi flag truyền qua `EXTRA_ARGS` được forward thẳng cho `flutter build` (sau `--`):

```bash
# Obfuscate + tách symbol để upload crash reporter
EXTRA_ARGS="--obfuscate --split-debug-info=build/symbols" \
  ./tools/shorebird.sh release both

# Build flavor cụ thể (nếu có)
EXTRA_ARGS="--flavor production" ./tools/shorebird.sh release ios
```

Có thể combine nhiều biến:

```bash
TRACK=staging STAGED_ROLLOUT=10 EXTRA_ARGS="--obfuscate" \
  ./tools/shorebird.sh patch ios 1.0.8+2
```

---

## 5. Workflow điển hình

### Workflow A — Release version mới lên store

1. Bump version trong `pubspec.yaml` (ví dụ `1.0.8+2` → `1.0.9+1`).
2. Commit + tag git.
3. Release Android + iOS:
   ```bash
   ./tools/shorebird.sh release both
   ```
4. Upload AAB lên Play Console, IPA lên App Store Connect.
5. Sau khi review pass → user update từ store về `1.0.9+1`.

### Workflow B — Hotfix nhanh bằng patch (không cần qua store)

User đang dùng `1.0.8+2` trên store. Bạn fix bug Dart code (không động native code):

1. Sửa code, **không bump version** trong pubspec.
2. Đẩy patch lên staging trước:
   ```bash
   TRACK=staging ./tools/shorebird.sh patch both 1.0.8+2
   ```
3. Test bằng `shorebird preview --track staging --release-version 1.0.8+2`.
4. Ổn rồi → promote lên stable, có thể rollout từ từ:
   ```bash
   STAGED_ROLLOUT=20 ./tools/shorebird.sh patch both 1.0.8+2
   ```
5. Theo dõi crash 1-2 tiếng, nếu OK lên console promote 100%.

### Workflow C — CI / CD

Script có exit code chuẩn (`0` thành công, `≠0` lỗi), dùng được trong CI:

```yaml
# Ví dụ GitHub Actions step
- name: Shorebird patch iOS
  env:
    TRACK: stable
    STAGED_ROLLOUT: 50
  run: ./tools/shorebird.sh patch ios 1.0.8+2
```

---

## 6. Troubleshooting

| Lỗi                                              | Nguyên nhân & xử lý                                                                                                   |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `Missing required command: shorebird`            | Chưa cài Shorebird CLI. Cài rồi mở terminal mới.                                                                       |
| `pubspec.yaml not found at ...`                  | Chạy script từ chỗ khác. Phải chạy từ root project hoặc dùng đường dẫn đầy đủ.                                          |
| `Patch contains native changes`                   | Bạn sửa file native (iOS/Android), Dependencies, hoặc pubspec. Patch không apply được — phải release version mới.       |
| `Release version not found`                       | Chưa từng release `x.y.z+build` này lên Shorebird. Chạy `shorebird releases list` để xem version đã có.                |
| `Asset diff detected`                             | Asset thay đổi (thêm font/ảnh). Patch sẽ size to. Nếu không cần asset mới → revert. Nếu cố tình → release version mới. |
| Lỗi signing iOS                                   | Vào Xcode → Runner → Signing & Capabilities → chọn đúng team. Hoặc `cd ios && pod install`.                            |
| Patch number không tăng                           | Bình thường nếu patch bị reject (asset diff/native diff). Đọc kỹ log Shorebird.                                         |

Bật log chi tiết của Shorebird khi cần debug sâu:

```bash
shorebird patch ios --release-version=1.0.8+2 --verbose -- --no-tree-shake-icons
```

(Script wrapper chưa expose `--verbose` qua flag — nếu cần, sửa hàm `run_patch` trong `shorebird.sh`.)

---

## 7. FAQ

**Q: Tại sao bắt buộc `--no-tree-shake-icons`?**
A: Vì project release iPA/AAB gốc đã build với flag này. Nếu patch build **không** có flag này → Flutter loại bỏ icon font không dùng → asset hash khác release → Shorebird reject patch hoặc patch chạy lỗi font. Script đã hard-code flag này để tránh sai sót.

**Q: Patch khác Release ở chỗ nào?**
A: **Release** = build full app upload store (user update qua Play Store / App Store). **Patch** = chỉ ship phần Dart code dạng diff, user nhận trong vòng vài giây qua Shorebird khi mở app. Patch không update được native code, asset thêm mới, hay dependency thay đổi.

**Q: Có thể patch cho version cũ không?**
A: Có, miễn version đó còn trên Shorebird console (chưa bị xoá). Truyền `version` qua argument: `./tools/shorebird.sh patch ios 1.0.7+5`.

**Q: Số patch reset theo release không?**
A: Có. Mỗi release version có chuỗi patch riêng `1, 2, 3, ...`. Release mới → đếm lại từ 1.

**Q: Làm sao xem patch hiện đang chạy trên thiết bị?**
A: Code trong app đã có sẵn — mở **Profile screen** sẽ thấy dòng `Version: 1.0.8+2 - Patch 8` (đã implement ở file `lib/s88/features/profile/profile_screen.dart`).

**Q: Xem list patch đã đẩy ở đâu?**
A: Vào https://console.shorebird.dev → chọn app → release → tab Patches.

---

## 8. Cheat sheet (copy & paste)

```bash
# === Release ===
./tools/shorebird.sh release both                            # release Android + iOS
./tools/shorebird.sh release android                         # chỉ Android
./tools/shorebird.sh release ios                             # chỉ iOS

# === Patch ===
./tools/shorebird.sh patch both                              # patch cả 2 cho version pubspec
./tools/shorebird.sh patch ios 1.0.8+2                       # patch iOS cho 1.0.8+2

# === Patch staging (test trước) ===
TRACK=staging ./tools/shorebird.sh patch both 1.0.8+2

# === Patch rollout 20% ===
STAGED_ROLLOUT=20 ./tools/shorebird.sh patch both 1.0.8+2

# === Patch with obfuscation ===
EXTRA_ARGS="--obfuscate --split-debug-info=build/symbols" \
  ./tools/shorebird.sh patch both 1.0.8+2

# === Menu tương tác ===
./tools/shorebird.sh
```

---

## 9. Tài liệu liên quan

- Shorebird docs — Code Push: https://docs.shorebird.dev/code-push/
- Patch command: https://docs.shorebird.dev/code-push/patch/
- Staging patches: https://docs.shorebird.dev/code-push/guides/staging-patches/
- Percentage rollouts: https://docs.shorebird.dev/code-push/guides/percentage-based-rollouts/
- Shorebird console: https://console.shorebird.dev
