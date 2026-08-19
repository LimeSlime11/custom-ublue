#!/usr/bin/env bash
set -euo pipefail

flatpak remote-add --if-not-exists \
    --system \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

flatpaks=(
    org.mozilla.firefox
    org.kde.kate
    org.libreoffice.LibreOffice
)

for app in "${flatpaks[@]}"; do
    flatpak install --system -y flathub "$app"
done