#!/bin/bash

# Skrip untuk mengatur RDP pada instance Linux
# Bekerja pada distribusi berbasis Debian/Ubuntu dan CentOS/RHEL

# Fungsi untuk memeriksa root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Jalankan skrip ini sebagai root atau dengan sudo."
        exit 1
    fi
}

# Periksa root
check_root

# Tentukan distribusi Linux
DISTRO=$(grep ^ID= /etc/os-release | cut -d'=' -f2 | tr -d '"')

echo "Distribusi terdeteksi: $DISTRO"

# Instalasi paket untuk Debian/Ubuntu
if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
    echo "Menginstal paket untuk $DISTRO..."
    apt update && apt install -y xfce4 xfce4-goodies xrdp
    systemctl enable xrdp
    systemctl start xrdp

    # Konfigurasi default untuk Xfce
    echo "xfce4-session" >~/.xsession

    # Konfigurasi firewall (jika menggunakan UFW)
    if command -v ufw &>/dev/null; then
        echo "Mengatur firewall..."
        ufw allow 3389/tcp
        ufw reload
    fi
elif [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]]; then
    echo "Menginstal paket untuk $DISTRO..."
    yum groupinstall -y "Server with GUI"
    yum install -y epel-release
    yum install -y xrdp tigervnc-server
    systemctl enable xrdp
    systemctl start xrdp

    # Konfigurasi firewall
    firewall-cmd --permanent --add-port=3389/tcp
    firewall-cmd --reload
else
    echo "Distribusi $DISTRO tidak didukung."
    exit 1
fi

echo "Konfigurasi selesai. Anda dapat mengakses RDP melalui port 3389."
