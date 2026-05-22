#!/usr/bin/env python3
"""
ensure_info_plist.py — verify & auto-patch ios/Runner/Info.plist.

Đảm bảo Info.plist chứa các key bắt buộc cho project caro:

  - CFBundleURLTypes
      Cần cho terminate_restart plugin: cho phép iOS reopen app qua URL
      scheme sau khi plugin terminate process. Thiếu key này thì
      restart(terminate=true) fail silently → Shorebird patch không apply.

  - UIRequiresFullScreen = true
      App buộc fullscreen, không bị multitask split-view trên iPad.

  - UISupportedInterfaceOrientations            (iPhone)
  - UISupportedInterfaceOrientations~ipad       (iPad)
      Cả hai phải support 4 hướng: Portrait, PortraitUpsideDown,
      LandscapeLeft, LandscapeRight.

Hành vi:
  • Nếu thiếu hoặc sai → tự thêm/cập nhật, backup gốc ra Info.plist.bak.
  • Nếu đủ → in OK, không sửa.
  • Exit code 0 ở mọi trường hợp thành công, != 0 nếu lỗi.

Usage:
    python3 scripts/ensure_info_plist.py ios/Runner/Info.plist
"""

from __future__ import annotations

import plistlib
import shutil
import sys
from pathlib import Path

REQUIRED_ORIENTATIONS = [
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
    "UIInterfaceOrientationPortrait",
    "UIInterfaceOrientationPortraitUpsideDown",
]

# CFBundleURLTypes entry yêu cầu cho terminate_restart
EXPECTED_URL_TYPE = {
    "CFBundleTypeRole": "Editor",
    "CFBundleURLName": "$(PRODUCT_BUNDLE_IDENTIFIER)",
    "CFBundleURLSchemes": ["$(PRODUCT_BUNDLE_IDENTIFIER)"],
}


def has_required_url_type(url_types) -> bool:
    """True nếu trong CFBundleURLTypes đã có entry chứa scheme
    $(PRODUCT_BUNDLE_IDENTIFIER)."""
    if not isinstance(url_types, list):
        return False
    for entry in url_types:
        if not isinstance(entry, dict):
            continue
        schemes = entry.get("CFBundleURLSchemes")
        if isinstance(schemes, list) and "$(PRODUCT_BUNDLE_IDENTIFIER)" in schemes:
            return True
    return False


def ensure_orientations(plist: dict, key: str, label: str, changes: list[str]) -> None:
    current = plist.get(key)
    if not isinstance(current, list):
        plist[key] = list(REQUIRED_ORIENTATIONS)
        changes.append(f"thêm {label} (4 hướng đầy đủ)")
        return
    missing = [o for o in REQUIRED_ORIENTATIONS if o not in current]
    if missing:
        plist[key] = list(current) + missing
        changes.append(f"bổ sung vào {label}: {', '.join(missing)}")


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("Usage: ensure_info_plist.py <path-to-Info.plist>", file=sys.stderr)
        return 2

    plist_path = Path(argv[1])
    if not plist_path.is_file():
        print(f"[plist] Không tìm thấy file: {plist_path}", file=sys.stderr)
        return 1

    try:
        with plist_path.open("rb") as f:
            plist = plistlib.load(f)
    except Exception as e:  # noqa: BLE001
        print(f"[plist] Đọc Info.plist thất bại: {e}", file=sys.stderr)
        return 1

    if not isinstance(plist, dict):
        print("[plist] Root của Info.plist không phải dict.", file=sys.stderr)
        return 1

    changes: list[str] = []

    # 1) CFBundleURLTypes
    url_types = plist.get("CFBundleURLTypes")
    if not has_required_url_type(url_types):
        url_types_list = list(url_types) if isinstance(url_types, list) else []
        url_types_list.append(
            {
                "CFBundleTypeRole": EXPECTED_URL_TYPE["CFBundleTypeRole"],
                "CFBundleURLName": EXPECTED_URL_TYPE["CFBundleURLName"],
                "CFBundleURLSchemes": list(EXPECTED_URL_TYPE["CFBundleURLSchemes"]),
            }
        )
        plist["CFBundleURLTypes"] = url_types_list
        changes.append("thêm CFBundleURLTypes (terminate_restart)")

    # 2) UIRequiresFullScreen = true
    if plist.get("UIRequiresFullScreen") is not True:
        plist["UIRequiresFullScreen"] = True
        changes.append("đặt UIRequiresFullScreen = true")

    # 3) Orientations
    ensure_orientations(
        plist,
        "UISupportedInterfaceOrientations",
        "UISupportedInterfaceOrientations (iPhone)",
        changes,
    )
    ensure_orientations(
        plist,
        "UISupportedInterfaceOrientations~ipad",
        "UISupportedInterfaceOrientations~ipad",
        changes,
    )

    if not changes:
        print("[plist] OK — Info.plist đã đủ các key bắt buộc, không sửa gì.")
        return 0

    # Backup + ghi lại
    backup = plist_path.with_suffix(plist_path.suffix + ".bak")
    try:
        shutil.copy2(plist_path, backup)
    except Exception as e:  # noqa: BLE001
        print(f"[plist] Backup thất bại: {e}", file=sys.stderr)
        return 1

    try:
        with plist_path.open("wb") as f:
            plistlib.dump(plist, f, sort_keys=True)
    except Exception as e:  # noqa: BLE001
        # rollback
        shutil.copy2(backup, plist_path)
        print(f"[plist] Ghi Info.plist thất bại, đã rollback: {e}", file=sys.stderr)
        return 1

    print("[plist] Đã cập nhật Info.plist (backup tại {}).".format(backup.name))
    for c in changes:
        print(f"        • {c}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
