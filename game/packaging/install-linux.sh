#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
set -eu

if [ "$(uname -s)" != Linux ] || [ "$(uname -m)" != x86_64 ]; then
    echo "Este paquete requiere Linux x86_64." >&2
    exit 1
fi
if [ "$(id -u)" -eq 0 ]; then
    echo "Ejecuta este instalador desde tu cuenta, sin sudo." >&2
    exit 1
fi

data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
case "$data_home" in
    /*) ;;
    *) data_home="$HOME/.local/share" ;;
esac
app_dir="$data_home/sis-inf"
menu_file="$data_home/applications/sis-inf.desktop"
files='SIS-INF.x86_64 SIS-INF.pck sis-inf.png LICENSE GODOT-NOTICES.txt LEEME.md fni_osm.json'

if [ -L "$app_dir" ]; then
    echo "La carpeta de instalación es un enlace simbólico: $app_dir" >&2
    exit 1
fi

case "$#:$*" in
    1:--uninstall)
        for name in $files install.sh; do
            rm -f -- "$app_dir/$name"
        done
        rm -f -- "$menu_file"
        rmdir -- "$app_dir" 2>/dev/null || :
        echo "SIS-INF desinstalado. Se conservan las partidas."
        exit 0
        ;;
    0:) ;;
    *)
        echo "Uso: sh install.sh [--uninstall]" >&2
        exit 2
        ;;
esac

source_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
if [ "$source_dir" = "$app_dir" ]; then
    echo "Para actualizar, ejecuta el instalador de la nueva descarga." >&2
    exit 1
fi
for name in $files; do
    if [ ! -f "$source_dir/$name" ]; then
        echo "Falta $name. Extrae el paquete completo antes de instalar." >&2
        exit 1
    fi
done

mkdir -p -- "$app_dir" "$data_home/applications"
for name in $files install.sh; do
    case "$name" in
        SIS-INF.x86_64|install.sh) mode=755 ;;
        *) mode=644 ;;
    esac
    install -m "$mode" -- "$source_dir/$name" "$app_dir/$name"
done

# Desktop Entry applies a second level of escaping to the quoted Exec field.
exec_path=$(printf '%s' "$app_dir/SIS-INF.x86_64" | sed -e 's/\\/\\\\\\\\/g' -e 's/["`$]/\\\\&/g' -e 's/%/%%/g')
icon_path=$(printf '%s' "$app_dir/sis-inf.png" | sed -e 's/\\/\\\\/g')
entry=$(mktemp "$data_home/applications/.sis-inf.XXXXXX")
trap 'rm -f -- "$entry"' EXIT
printf '%s\n' '[Desktop Entry]' 'Type=Application' 'Name=SIS-INF' \
    "Exec=\"$exec_path\"" "Icon=$icon_path" 'Categories=Game;Education;' \
    'Terminal=false' > "$entry"
chmod 644 "$entry"
mv -fT -- "$entry" "$menu_file"
echo "SIS-INF instalado. Ábrelo desde el menú de aplicaciones."
