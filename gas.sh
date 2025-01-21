#!/bin/bash

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan skrip ini dengan sudo atau sebagai root."
  exit 1
fi

# Update dan instal OpenSSH Server
echo "Memperbarui paket dan menginstal OpenSSH Server..."
if command -v apt >/dev/null 2>&1; then
  apt update && apt install -y openssh-server
elif command -v yum >/dev/null 2>&1; then
  yum install -y openssh-server
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y openssh-server
else
  echo "Paket manajer tidak dikenali. Harap instal OpenSSH secara manual."
  exit 1
fi

# Memulai dan mengaktifkan layanan SSH
echo "Memulai dan mengatur OpenSSH agar berjalan secara otomatis..."
systemctl start sshd
systemctl enable sshd

# Konfigurasi firewall untuk membuka port 22
if command -v ufw >/dev/null 2>&1; then
  echo "Mengatur firewall dengan UFW..."
  ufw allow 22/tcp
  ufw enable
elif command -v firewall-cmd >/dev/null 2>&1; then
  echo "Mengatur firewall dengan firewalld..."
  firewall-cmd --permanent --add-port=22/tcp
  firewall-cmd --reload
else
  echo "Firewall tidak terdeteksi. Harap pastikan port 22 terbuka."
fi

# Menampilkan informasi IP
echo "Konfigurasi selesai. Berikut adalah informasi IP server Anda:"
ip addr show | grep "inet " | awk '{ print $2 }'

echo "Gunakan alamat IP di atas untuk mengakses server ini melalui SSH."
echo "Contoh: ssh username@IP_ADDRESS"
