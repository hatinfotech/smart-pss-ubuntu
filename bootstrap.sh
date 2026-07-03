#!/usr/bin/env bash
# Tải và chạy toàn bộ quy trình cài SmartPSS Lite chỉ với 1 lệnh, không cần
# cài git/git-lfs hay clone tay trước:
#
#   curl -fsSL https://raw.githubusercontent.com/hatinfotech/smart-pss-ubuntu/main/bootstrap.sh | bash
#
set -euo pipefail

REPO_URL="https://github.com/hatinfotech/smart-pss-ubuntu.git"
TARGET_DIR="$HOME/smart-pss-ubuntu"

echo "==> Kiểm tra và cài git, git-lfs..."
MISSING_PKGS=()
for pkg in git git-lfs; do
    dpkg -s "$pkg" >/dev/null 2>&1 || MISSING_PKGS+=("$pkg")
done
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    sudo apt update
    sudo apt install -y "${MISSING_PKGS[@]}"
fi
git lfs install --skip-repo

if [ -d "$TARGET_DIR/.git" ]; then
    echo "==> Đã có sẵn $TARGET_DIR, cập nhật bản mới nhất..."
    git -C "$TARGET_DIR" pull
    git -C "$TARGET_DIR" lfs pull
else
    echo "==> Clone repo về $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
fi

echo "==> Chạy install.sh..."
cd "$TARGET_DIR"
chmod +x install.sh
./install.sh
