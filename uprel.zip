#!/bin/bash
echo -e " UPLOAD RELEASE GITHUB VIA TERMUX"
read -p" Token github : " token
read -p" File name (misal.zip) : " name
read -p" Github name : " gh
read -p" Repository : " repo
read -p" Id Realase : " idreals
curl -X POST \
    -H "Authorization: token $token" \
    -H "Content-Type: application/zip" \
    --data-binary "@$name" \
    "https://uploads.github.com/repos/$gh/$repo/releases/$idreals/assets?name=$name"