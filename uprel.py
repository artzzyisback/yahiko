import os
import json
import requests

CONFIG_FILE = os.path.expanduser("~/.uprel_config")

# Cek atau buat file konfigurasi
def load_config():
    if not os.path.isfile(CONFIG_FILE):
        print("Konfigurasi belum ditemukan. Silakan isi data berikut:")
        config = {
            "TOKEN": input("GitHub Token: ").strip(),
            "GH_USER": input("GitHub Username: ").strip(),
            "REPO": input("Repository Name: ").strip()
        }
        save_config(config)
    else:
        with open(CONFIG_FILE, "r") as f:
            config = json.load(f)
    return config

def save_config(config):
    with open(CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=4)
    print(f"Konfigurasi tersimpan di {CONFIG_FILE}.")

# Fungsi untuk mendapatkan ID Release terbaru
def get_release_id(config):
    url = f"https://api.github.com/repos/{config['GH_USER']}/{config['REPO']}/releases"
    headers = {"Authorization": f"token {config['TOKEN']}"}
    response = requests.get(url, headers=headers).json()

    if not response or "message" in response:
        print("Gagal mendapatkan ID Release. Pastikan repo memiliki release!")
        return None

    release_id = response[0]["id"]
    print(f"ID Release terbaru: {release_id}")
    config["ID_RELEASE"] = release_id
    save_config(config)
    return release_id

# Fungsi untuk melihat daftar file yang sudah diupload
def list_uploaded_files(config):
    release_id = config.get("ID_RELEASE") or get_release_id(config)
    if not release_id:
        return

    url = f"https://api.github.com/repos/{config['GH_USER']}/{config['REPO']}/releases/{release_id}/assets"
    headers = {"Authorization": f"token {config['TOKEN']}"}
    response = requests.get(url, headers=headers).json()

    if not response:
        print("Tidak ada file yang diupload.")
    else:
        print("Daftar file yang sudah diupload:")
        for asset in response:
            print(f"- {asset['name']} (ID: {asset['id']})")

# Fungsi untuk upload file ke release
def upload_file(config):
    release_id = config.get("ID_RELEASE") or get_release_id(config)
    if not release_id:
        return

    file_path = input("Masukkan nama file (misal.zip): ").strip()
    if not os.path.isfile(file_path):
        print("File tidak ditemukan!")
        return

    url = f"https://uploads.github.com/repos/{config['GH_USER']}/{config['REPO']}/releases/{release_id}/assets?name={os.path.basename(file_path)}"
    headers = {
        "Authorization": f"token {config['TOKEN']}",
        "Content-Type": "application/zip"
    }

    with open(file_path, "rb") as f:
        response = requests.post(url, headers=headers, data=f).json()

    if "id" in response:
        print(f"File berhasil diupload! Asset ID: {response['id']}")
    else:
        print("Gagal mengupload file:", response)

# Fungsi untuk menghapus file dari release
def delete_file(config):
    release_id = config.get("ID_RELEASE") or get_release_id(config)
    if not release_id:
        return

    list_uploaded_files(config)
    asset_id = input("Masukkan Asset ID yang ingin dihapus: ").strip()
    url = f"https://api.github.com/repos/{config['GH_USER']}/{config['REPO']}/releases/assets/{asset_id}"
    headers = {"Authorization": f"token {config['TOKEN']}"}

    response = requests.delete(url, headers=headers)

    if response.status_code == 204:
        print("File berhasil dihapus!")
    else:
        print("Gagal menghapus file:", response.json())

# Fungsi untuk membuat release baru
def create_release(config):
    url = f"https://api.github.com/repos/{config['GH_USER']}/{config['REPO']}/releases"
    headers = {"Authorization": f"token {config['TOKEN']}"}
    data = {
        "tag_name": input("Masukkan tag release (v1.0, v1.1, dll): ").strip(),
        "name": input("Masukkan nama release: ").strip(),
        "body": input("Deskripsi release: ").strip(),
        "draft": False,
        "prerelease": False
    }

    response = requests.post(url, headers=headers, json=data).json()

    if "id" in response:
        print(f"Release baru berhasil dibuat! ID: {response['id']}")
        config["ID_RELEASE"] = response["id"]
        save_config(config)
    else:
        print("Gagal membuat release:", response)

# Fungsi untuk menghapus release
def delete_release(config):
    release_id = config.get("ID_RELEASE") or get_release_id(config)
    if not release_id:
        return

    url = f"https://api.github.com/repos/{config['GH_USER']}/{config['REPO']}/releases/{release_id}"
    headers = {"Authorization": f"token {config['TOKEN']}"}

    response = requests.delete(url, headers=headers)

    if response.status_code == 204:
        print("Release berhasil dihapus!")
        config.pop("ID_RELEASE", None)
        save_config(config)
    else:
        print("Gagal menghapus release:", response.json())

# Fungsi untuk mengubah konfigurasi
def edit_config():
    config = {
        "TOKEN": input("GitHub Token: ").strip(),
        "GH_USER": input("GitHub Username: ").strip(),
        "REPO": input("Repository Name: ").strip()
    }
    save_config(config)

# Menu utama
def main():
    config = load_config()
    
    while True:
        print("=" * 40)
        print("  GITHUB RELEASE MANAGER - TERMUX")
        print("=" * 40)
        print("1. 🔍 Cek ID Release Terbaru")
        print("2. 📂 Lihat Daftar File yang Sudah Diupload")
        print("3. 📤 Upload File ke Release")
        print("4. 🗑️ Hapus File dari Release")
        print("5. 🆕 Buat Release Baru")
        print("6. ❌ Hapus Release")
        print("7. ⚙️ Ubah Konfigurasi (Token, Repo, Username)")
        print("8. 🚪 Keluar")
        print("=" * 40)

        choice = input("Pilih menu [1-8]: ").strip()

        if choice == "1":
            get_release_id(config)
        elif choice == "2":
            list_uploaded_files(config)
        elif choice == "3":
            upload_file(config)
        elif choice == "4":
            delete_file(config)
        elif choice == "5":
            create_release(config)
        elif choice == "6":
            delete_release(config)
        elif choice == "7":
            edit_config()
        elif choice == "8":
            print("Keluar...")
            break
        else:
            print("Pilihan tidak valid! Silakan coba lagi.")

if __name__ == "__main__":
    main()