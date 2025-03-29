#!/bin/bash
#WokszXDStore
#JarzTunnel
#ArtzzyIsBack
akuu="\033[33m"  #yello
merah="\033[1;31m"  #REDTERANG
g='\e[0;32m'
NC='\033[0m'
Green="\e[92;1m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[36m"
z="\033[96m"
FONT="\033[0m"
GREENBG="\033[42;37m"
REDBG="\033[41;37m"
OK="${Green}--->${FONT}"
ERROR="${RED}[ERROR]${FONT}"
bang="\033[1;93m"
GRAY="\e[1;30m"
NC='\e[0m'
purple="\033[1;95m"
red='\e[1;31m'
green='\e[0;32m'
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
IP=$( curl -sS ipinfo.io/ip )
CONFIG_FILE="$HOME/.uprel_config"

# Cek Konfigurasi
if [ ! -f "$CONFIG_FILE" ]; then
echo -e "${akuu}# //============================================="
echo -e "${akuu}# //	Author:	Artzzy"
echo -e "${akuu}# //	Description: Menu Management"
echo -e "${akuu}# //	Email: artzzy@s.id"
echo -e "${akuu}# //    Telegram: https://t.me/artzzyr"
echo -e "${akuu}# //============================================="
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
load
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
load    
    curl -X POST \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/zip" \
        --data-binary "@$FILE_NAME" \
        "https://uploads.github.com/repos/$GH_USER/$REPO/releases/$ID_RELEASE/assets?name=$FILE_NAME"
        
    echo -e "\nUpload selesai!"
}

# Fungsi untuk hapus file
delete_file() {
# Load Konfigurasi
CONFIG_FILE="$HOME/.uprel_config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Konfigurasi belum ditemukan. Silakan jalankan skrip konfigurasi terlebih dahulu."
    exit 1
fi

source "$CONFIG_FILE"

# Pastikan token, user, dan repo telah diset
if [ -z "$TOKEN" ] || [ -z "$GH_USER" ] || [ -z "$REPO" ]; then
    echo "Konfigurasi tidak lengkap! Pastikan Token, Username, dan Repository telah diatur."
    exit 1
fi

# Clone repo jika belum ada
if [ ! -d "$REPO" ]; then
    echo "Meng-clone repository..."
    git clone "https://$TOKEN@github.com/$GH_USER/$REPO.git"
fi

# Masuk ke folder repository
cd "$REPO" || exit

# Tampilkan daftar file
echo "Daftar file/folder di repository:"
ls -1

# Minta input nama file/folder yang ingin dihapus
read -p "Masukkan nama file/folder yang ingin dihapus: " TARGET

# Hapus file/folder
if [ -e "$TARGET" ]; then
    rm -rf "$TARGET"
    git rm -r "$TARGET"
    echo "File/folder '$TARGET' berhasil dihapus."
else
    echo "File/folder '$TARGET' tidak ditemukan."
    exit 1
fi

# Commit dan Push ke repository
git commit -m "Hapus $TARGET dari repository"
git push origin main
load
echo "Perubahan telah di-push ke GitHub."
}

#Fungsi Upload file Repository
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
  git config --global user.email "$email"

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
load
  echo "Semua file telah diunggah ke GitHub!"
}

# Jalankan fungsi

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
load
echo "Semua file telah diunggah ke GitHub!"
}

# Animasi Loading
load() {
spinner()
{
    local pid=$!
    local delay=0.1
    local spinstr='|/-\|'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

echo "𝙋𝙧𝙤𝙨𝙚𝙨 𝙎𝙚𝙙𝙖𝙣𝙜 𝘽𝙚𝙧𝙟𝙖𝙡𝙖𝙣..."
sleep 3 & spinner
echo "𝙋𝙧𝙤𝙨𝙚𝙨 𝙎𝙚𝙡𝙚𝙨𝙖𝙞....."
}
function shcd(){
clear
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e "        ${g}.::.$NC ${wh}Tools Decrypt SHC${NC} ${g}.::.${NC}"
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e " ${putih} Contoh Sleep : 0.000 - 0.500 ( Sesuaikan yg Cocok) ${NC}"
echo -e " ${putih} File Name ( Nama file yang mau di Decrypt )${NC}"
echo -e " ${putih} Hasil Decrypt Cek di ( ls ) nama file ( core )${NC}"
echo -e " ${bang}────────────────────────────────────────────${NC}"

ulimit -c unlimited
#read -p "   Perizinan File : " izin
read -p "   File Name : " name
read -p "   Sleep Time : " waktu
sleep 0.5
echo -e "   sedang dalam proses "
sleep 0.5 && load
echo -e "   proses sudah selesai "
sleep 0.5
chmod +x ${name}
./${name} & ( sleep ${waktu} && kill -SIGSEGV $! )
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
dec_m
}

kf() {
curl -L -o kf.py "https://github.com/artzzyisback/yahiko/releases/download/1.0/kf.py" >> $CONFIG_FILE
python3 kf.py
}

function bash64d(){
clear
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e "        ${g}.::.$NC ${wh}Tools Decrypt Base64${NC} ${g}.::.${NC}"
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e " ${putih} File Name : Nama file yang mau di dec${NC}"
echo -e " ${putih} Cek file hasil decrypt dengan ls${NC}"
echo -e " ${bang}────────────────────────────────────────────${NC}"
read -p "File-Name : " file
sleep 0.5
echo -e "sedang dalam proses "
sleep 0.5 && load
echo -e "proses sudah selesai "
sleep 0.5
cat ${file} | tr ';' '\n' | grep 'RzE=' | cut -d '"' -f2 | tr ' ' '\n' | rev | base64 -d >> dec
mv dec ${file}
echo -e ""
read -n 1 -s -r -p "Press any key to back on menu"
dec_m
}

gzexed() {
clear
apt install gzexe -y
clear
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e "        ${g}.::.$NC ${wh}Tools Decrypt Gzexe${NC} ${g}.::.${NC}"
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e " ${putih} File Name ( Nama file yang mau di Decrypt )${NC}"
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e " "
read -p "   File Name : " name
sleep 0.5
echo -e "   sedang dalam proses "
sleep 0.5 && load
echo -e "   proses sudah selesai "
sleep 0.5
gzexe -d ${name}
echo ""
rm -rf ${name}~
read -n 1 -s -r -p "Press any key to back on menu"
dec_m
}

bzip2d() {
clear
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e "        ${g}.::.$NC ${wh}Tools Decrypt Bzip2${NC} ${g}.::.${NC}"
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e " ${putih} File Name ( Nama file yang mau di Decrypt )${NC}"
echo -e " ${putih} Output File ( Nama file yang habis di Decrypt )${NC}"    
echo -e " ${bang}────────────────────────────────────────────${NC}"
echo -e " "
read -p "   File Name : " name
read -p "   Output File : " path
sleep 0.5
echo -e "   sedang dalam proses "
sleep 0.5 && load
echo -e "   proses sudah selesai "
sleep 0.5
tail -n +23 ${name} | bzip2 -cd >> ${path}
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
dec_m
}

dec_m() {
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-No such file or directory-0" -d "$dateFromServer"`
red() { echo -e "\\033[32;1m${*}\\033[0m"; }

#intro wak¡
wh="\033[1;37m"
clear
echo -e " ${bang}──────────────────────────────────────${NC}"
echo -e "        ${g}.::.$NC ${wh}Menu Decrypt${NC} ${g}.::.${NC}"
echo -e " ${bang}──────────────────────────────────────${NC}"
echo -e "${bang}╭════════════════════════════════════════╮${NC}"
 echo -e "${bang}│ ${wh}Please select a your Choice    $NC        ${bang}│${NC}"
 echo -e "${bang}╰════════════════════════════════════════╯${NC}"
 echo -e "${bang}╭════════════════════════════════════════╮${NC}"
 echo -e "${bang}│$NC ${z} [ 1 ]  ${wh}DECRYPT SHC      ${NC}"
 echo -e "${bang}│$NC ${z} [ 2 ]  ${wh}DECRYPT BZIP2     ${NC}"
 echo -e "${bang}│$NC ${z} [ 3 ]  ${wh}DECRYPT BASHROOCK     ${NC}"
 echo -e "${bang}│$NC ${z} [ 4 ]  ${wh}DECRYPT/ENC FUSCATOR     ${NC}"
 echo -e "${bang}│$NC ${z} [ 5 ]  ${wh}DECRYPT GZEXE     ${NC}"
 echo -e "${bang}╰════════════════════════════════════════╯${NC}"
                  read -p "Pilih menu [1-6] : " sayang

    case $sayang in
        1) shcd ;;
        2) bzip2d ;;
        3) bash64d ;;
        4) kf ;;
        5) gzexed ;;
        6) exit 0 ;;
        *) echo "Pilihan tidak valid!" ;;
    esac

    read -p "Tekan Enter untuk kembali ke menu..."
dec_m
}


# Menu utama
while true; do
    clear
    echo -e " ${bang}────────────────────────────────────${NC}"
    echo -e "       ${wh}••••• MENU SCRIPT •••••${NC}"
    echo -e " ${bang}────────────────────────────────────${NC}"
    echo -e "${wh}1.${NC} ${z}Cek ID Release${NC}"
    echo -e "${wh}2.${NC} ${z}Upload File ke Release${NC}"
    echo -e "${wh}3.${NC} ${z}Upload File ke Repository${NC}"
    echo -e "${wh}4.${NC} ${z}Delete File di Repository${NC}"
    echo -e "${wh}5.${NC} ${z}Menu Decrypt${NC}"
    echo -e "${wh}6.${NC} ${z}Menu Encrypt${NC}"
    echo -e "${wh}7.${NC} ${z}Keluar${NC}"
    read -p "Pilih menu [1-7] : " CHOICE

    case $CHOICE in
        1) get_release_id ;;
        2) upload_file ;;
        3) upload_all_files ;;
        4) delete_file ;;
        5) dec_m ;;
        6) enc_m ;;
        7) exit 0 ;;
        *) echo "Pilihan tidak valid!" ;;
    esac

    read -p "Tekan Enter untuk kembali ke menu..."
done