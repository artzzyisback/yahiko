#!/bin/bash

CONFIG_FILE="$HOME/.uprel_config"

# Cek apakah file konfigurasi sudah ada
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Konfigurasi belum ditemukan. Silakan isi data berikut:"
    read -p "GitHub Token: " TOKEN
    read -p "GitHub Username: " GH_USER
    read -p "Repository Name: " REPO
    read -p "Email Github: " email

    # Simpan ke file konfigurasi
    echo "TOKEN=$TOKEN" > "$CONFIG_FILE"
    echo "GH_USER=$GH_USER" >> "$CONFIG_FILE"
    echo "REPO=$REPO" >> "$CONFIG_FILE"

    echo "Konfigurasi tersimpan di $CONFIG_FILE."
else
    # Load konfigurasi
    source "$CONFIG_FILE"
fi

# Fungsi untuk mendapatkan ID Release terbaru
get_release_id() {
    ID_RELEASE=$(curl -s -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$GH_USER/$REPO/releases" | jq '.[0].id')

    if [[ "$ID_RELEASE" == "null" || -z "$ID_RELEASE" ]]; then
        echo "Gagal mendapatkan ID Release. Pastikan repo memiliki release!"
        exit 1
    fi

    echo "ID Release terbaru: $ID_RELEASE"
    
    # Simpan ID Release ke konfigurasi
    echo "ID_RELEASE=$ID_RELEASE" >> "$CONFIG_FILE"
}

# Fungsi untuk upload file
upload_file() {
    if [ -z "$ID_RELEASE" ]; then
        echo "ID Release belum diset. Mengambil ID Release terbaru..."
        get_release_id
    fi

    read -p "Masukkan nama file (misal.zip): " FILE_NAME

    curl -X POST \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/zip" \
        --data-binary "@$FILE_NAME" \
        "https://uploads.github.com/repos/$GH_USER/$REPO/releases/$ID_RELEASE/assets?name=$FILE_NAME"

    echo -e "\nUpload selesai!"
}

# Fungsi untuk hapus file
    delete_file() {
  if [ -z "$ID_RELEASE" ]; then
    echo "ID Release belum diset. Mengambil ID Release terbaru..."
    get_release_id
  fi

  read -p "Masukkan nama file yang ingin dihapus: " FILE_NAME

  # Cari ID asset dari file yang ingin dihapus
  ASSET_ID=$(curl -s -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$GH_USER/$REPO/releases/$ID_RELEASE/assets" | \
    jq -r ".[] | select(.name == \"$FILE_NAME\") | .id")

  if [ -z "$ASSET_ID" ] || [ "$ASSET_ID" == "null" ]; then
    echo "File tidak ditemukan di release!"
    return
  fi

  # Hapus asset dari release dan ambil status respons HTTP
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
    -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$GH_USER/$REPO/releases/$ID_RELEASE/assets/$ASSET_ID")

  case "$HTTP_STATUS" in
    204) echo "File $FILE_NAME telah dihapus!" ;;
    404) echo "Gagal menghapus! File atau release tidak ditemukan." ;;
    401|403) echo "Gagal menghapus! Token tidak valid atau tidak memiliki izin." ;;
    *) echo "Gagal menghapus file! Status: $HTTP_STATUS" ;;
  esac
}

#Fungsi Upload file Repository
#!/bin/bash
upload_all_files() {
  if [ -z "$TOKEN" ] || [ -z "$GH_USER" ] || [ -z "$REPO" ]; then
    echo "Token, Username, atau Repository belum diset!"
    return 1
  fi

  # Nama branch utama (ubah jika berbeda)
  BRANCH="main"

  # Dapatkan tanggal & waktu untuk commit message
  COMMIT_MSG="Auto-upload on $(date '+%Y-%m-%d %H:%M:%S')"

  # Konfigurasi Git
  git config --global user.name "$GH_USER"
  git config --global user.email "putrakullbanget@gmail.com"

  # Inisialisasi Git jika belum ada
  if [ ! -d ".git" ]; then
    git init
    git remote add origin "https://$TOKEN@github.com/$GH_USER/$REPO.git"
    git checkout -b "$BRANCH"
  else
    git remote set-url origin "https://$TOKEN@github.com/$GH_USER/$REPO.git"
  fi

  # Tambahkan semua file & lakukan commit
  git add .
  git commit -m "$COMMIT_MSG"

  # Pastikan branch sudah dibuat di GitHub sebelum push
  git branch -M "$BRANCH"

  # Push ke GitHub dengan opsi --force jika perlu
  git push -u origin "$BRANCH" --force

  echo "Semua file telah diunggah ke GitHub!"
}

# Jalankan fungsi
upload_all_files

fix_git() {
# Pastikan branch utama adalah "main"
git branch -M main

# Tambahkan semua perubahan ke dalam commit
git add .

# Buat commit dengan pesan
git commit -m "Initial commit"

# Pastikan remote repository sudah benar
git remote remove origin 2>/dev/null
git remote add origin https://github.com/$GH_USER/$REPO.git

# Push ke repository GitHub
git push -u origin main
}

# Menu utama
while true; do
    clear
    echo "=== MENU ==="
    echo "1. Cek ID Release"
    echo "2. Upload File ke Release"
    echo "3. Upload File ke Repository"
    echo "4. Fix Git (kalo gagal)"
#    echo "3. Hapus File di Release"
    echo "5. Keluar"
    read -p "Pilih menu [1-3]: " CHOICE

    case $CHOICE in
        1) get_release_id ;;
        2) upload_file ;;
#        3) delete_file ;;
        3) upload_all_files ;;
        4) fix_git ;;
        5) exit 0 ;;
        *) echo "Pilihan tidak valid!" ;;
    esac

    read -p "Tekan Enter untuk kembali ke menu..."
done