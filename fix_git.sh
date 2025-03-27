#!/bin/bash

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