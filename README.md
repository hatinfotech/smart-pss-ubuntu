# Cài SmartPSS Lite trên Ubuntu

Đóng gói cài đặt Dahua SmartPSS Lite (thay thế SmartPSS cũ đã ngừng hỗ trợ) chạy qua Wine + DXVK. Đã test ổn định trên Ubuntu 26.04.

## Triển khai trên máy mới

File `.exe` trong `installer/` được lưu qua **Git LFS**. Cần cài `git-lfs` **trước khi clone**, nếu không file tải về sẽ chỉ là pointer text ~130 bytes chứ không phải file thật:

```bash
sudo apt install -y git-lfs
git lfs install
git clone git@github.com:hatinfotech/smart-pss-ubuntu.git
cd smart-pss-ubuntu
./install.sh
```

(Nếu lỡ clone trước khi cài git-lfs, chạy `git lfs pull` trong thư mục repo để tải lại file thật — `install.sh` cũng tự phát hiện và tự chạy bước này giúp bạn.)

Script sẽ tự động:
1. Cài `wine`, `winetricks` (yêu cầu `sudo`, chỉ hỏi nếu chưa có sẵn)
2. Tạo Wine prefix riêng tại `~/.wine-smartpss`
3. Cài VC++ runtime, corefonts, gdiplus, và **DXVK** (bắt buộc — không có DXVK app sẽ treo/nhiễu hình khi click vào khung camera)
4. Chạy bộ cài `installer/SmartPSSLite_*.exe` — **cần thao tác tay** qua wizard hiện lên trên màn hình (chọn ngôn ngữ, Next, Install, Finish)
5. Tạo launcher "SmartPSS Lite" trong menu ứng dụng, tự bật `WINEESYNC`/`WINEFSYNC`

## Lưu ý khi dùng

- **Lần chạy đầu tiên sau khi cài** app sẽ vào thẳng màn hình đăng nhập thay vì màn hình đăng ký tài khoản. Tắt app rồi mở lại (qua launcher) để vào đúng màn hình đăng ký username/password.
- Camera đăng ký qua P2P Cloud (không cùng LAN) cần Internet ra ngoài ổn định tới server Dahua; nếu mạng chặn/lag quốc tế thì các camera đó sẽ không load được dù local vẫn chạy bình thường.

## Nguồn installer

`installer/SmartPSSLite_V1.003.0000006.0.R.240517.exe` tải từ trang hỗ trợ kỹ thuật chính thức của Dahua Technology North America (dahuawiki.com). Muốn cập nhật bản mới hơn, thay file `.exe` trong thư mục `installer/` (script tự nhận file `SmartPSSLite_*.exe` mới nhất theo tên).
