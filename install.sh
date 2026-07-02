#!/usr/bin/env bash
# Cài đặt Dahua SmartPSS Lite trên Ubuntu qua Wine + DXVK.
# Đã test hoạt động ổn định trên Ubuntu 26.04, Wine 10.0, DXVK 3.0, Intel UHD Graphics 630.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_EXE="$(ls "$SCRIPT_DIR"/installer/SmartPSSLite_*.exe 2>/dev/null | head -1)"
export WINEPREFIX="$HOME/.wine-smartpss"

if [ -z "$INSTALLER_EXE" ]; then
    echo "Không tìm thấy file cài đặt trong $SCRIPT_DIR/installer/" >&2
    exit 1
fi

echo "==> Kiểm tra và cài gói hệ thống cần thiết (wine, winetricks)..."
MISSING_PKGS=()
for pkg in wine winetricks; do
    dpkg -s "$pkg" >/dev/null 2>&1 || MISSING_PKGS+=("$pkg")
done
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y "${MISSING_PKGS[@]}" wine32 wine64
fi

echo "==> Tạo Wine prefix riêng cho SmartPSS tại $WINEPREFIX..."
if [ ! -d "$WINEPREFIX" ]; then
    WINEARCH=win64 wineboot --init
fi

echo "==> Cài thư viện Windows runtime cần thiết + DXVK (bắt buộc, tránh treo/nhiễu hình khi click vào camera)..."
winetricks -q vcrun2013 vcrun2015 corefonts gdiplus dxvk

echo "==> Chạy bộ cài SmartPSS Lite (làm theo wizard hiện ra trên màn hình: chọn ngôn ngữ, Next, Install, Finish)..."
wine "$INSTALLER_EXE"

INSTALL_DIR="$WINEPREFIX/drive_c/Program Files/SmartPSSLite"
if [ ! -f "$INSTALL_DIR/SmartPSSLite.exe" ]; then
    echo "Không thấy SmartPSSLite.exe sau khi cài — có thể wizard chưa hoàn tất. Chạy lại script để cài tiếp." >&2
    exit 1
fi

echo "==> Tạo launcher trên menu ứng dụng..."
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/smartpss-lite.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=SmartPSS Lite
Comment=Dahua Camera Viewer
Exec=env WINEPREFIX=$WINEPREFIX WINEESYNC=1 WINEFSYNC=1 wine "$INSTALL_DIR/SmartPSSLite.exe"
Icon=wine
Terminal=false
Categories=AudioVideo;Video;
EOF
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo ""
echo "==> Cài đặt hoàn tất."
echo "Mở app qua menu ứng dụng: tìm 'SmartPSS Lite'."
echo "Lưu ý: KHÔNG bấm nút maximize (phóng to) cửa sổ — gây méo hình/treo CPU trên Wine. Chỉ resize thủ công bằng cách kéo viền nếu cần."
