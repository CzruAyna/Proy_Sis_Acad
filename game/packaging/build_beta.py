# SPDX-License-Identifier: GPL-3.0-or-later
"""Export SIS-INF and build the desktop packages in an ignored directory."""

import argparse
import hashlib
import platform
import re
import shutil
import subprocess
import tarfile
import tempfile
import zipfile
from pathlib import Path


PACKAGING = Path(__file__).resolve().parent
GAME = PACKAGING.parent
ROOT = GAME.parent
OUTPUT = GAME / "build" / "beta"
BRAND = GAME / "assets" / "branding"
TARGETS = {
    "windows": ("Windows Desktop", "SIS-INF.exe"),
    "linux": ("Linux Desktop", "SIS-INF.x86_64"),
    "macos": ("macOS Desktop", "SIS-INF-macOS.zip"),
}


def tool(command):
    resolved = shutil.which(command)
    if not resolved:
        raise ValueError(f"No se encontró la herramienta: {command}")
    return Path(resolved).resolve()


def run(*command):
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            encoding="utf-8", errors="replace", check=False)
    errors = [line for line in result.stdout.splitlines() if "ERROR:" in line]
    if result.returncode or errors:
        detail = "\n".join(result.stdout.splitlines()[-25:])
        raise ValueError(f"{command[0]} falló ({result.returncode}).\n{detail}")
    return result.stdout.strip()


def notices(godot, stage, version):
    run(godot, "--headless", "--path", GAME, "--log-file", stage / "notices.log",
        "--script", "res://tools/write_engine_notices.gd", "--", stage / "GODOT-NOTICES.txt")
    shutil.copyfile(ROOT / "LICENSE", stage / "LICENSE")
    shutil.copyfile(GAME / "assets/cartography/fni_osm.json", stage / "fni_osm.json")
    instructions = (PACKAGING / "LEEME.md").read_text(encoding="utf-8")
    (stage / "LEEME.md").write_text(instructions.replace("@VERSION@", version), encoding="utf-8")
    return ["LICENSE", "GODOT-NOTICES.txt", "LEEME.md", "fni_osm.json"]


def windows_package(stage, stem, version, nsis):
    license_file = next((folder / "COPYING" for folder in [nsis.parent, nsis.parent.parent]
                         if (folder / "COPYING").is_file()), None)
    if license_file is None:
        raise ValueError("Falta el archivo COPYING junto al compilador NSIS.")
    shutil.copyfile(license_file, stage / "NSIS-NOTICE.txt")
    output = stage / f"{stem}-Windows-x64-Setup.exe"
    options = "/" if platform.system() == "Windows" else "-"
    run(nsis, f"{options}INPUTCHARSET", "UTF8", f"{options}DVERSION={version}",
        f"{options}DPAYLOAD={stage}", f"{options}DOUTPUT={output}",
        f"{options}DICON={BRAND / 'sis_inf_pixel.ico'}", PACKAGING / "windows.nsi")
    return output


def linux_package(stage, stem, names):
    shutil.copyfile(BRAND / "sis_inf_pixel.png", stage / "sis-inf.png")
    script = (PACKAGING / "install-linux.sh").read_text(encoding="utf-8")
    (stage / "install.sh").write_text(script, encoding="utf-8", newline="\n")
    output = stage / f"{stem}-Linux-x86_64.tar.gz"
    executable = {"SIS-INF.x86_64", "install.sh"}
    with tarfile.open(output, "w:gz", compresslevel=6) as archive:
        for name in ["SIS-INF.x86_64", "SIS-INF.pck", "sis-inf.png", "install.sh", *names]:
            path = stage / name
            info = archive.gettarinfo(str(path), arcname=f"{stem}/{name}")
            info.mode = 0o755 if name in executable else 0o644
            info.uid = info.gid = 0
            info.uname = info.gname = ""
            with path.open("rb") as data:
                archive.addfile(info, data)
    return output


def macos_package(stage, stem, app_archive, names):
    output = stage / f"{stem}-macOS-Universal.zip"
    app_archive.replace(output)
    with zipfile.ZipFile(output, "a", zipfile.ZIP_DEFLATED) as archive:
        for name in names:
            archive.write(stage / name, name)
    return output


def source_package(stage, stem):
    files = [ROOT / name for name in ("AGENTS.md", "LICENSE", "REGLAS_USUARIO.txt",
                                     ".gitattributes", ".gitignore")]
    files.extend(GAME / name for name in ("project.godot", "export_presets.cfg", "README.md"))
    directories = [GAME / name for name in ("assets", "packaging", "scenes", "scripts", "tests", "tools")]
    directories.append(ROOT / "docs")
    for directory in directories:
        for path in directory.rglob("*"):
            if not any(part.startswith(".") or part == "__pycache__"
                       for part in path.relative_to(directory).parts):
                files.append(path)
    output = stage / f"{stem}-Fuentes.zip"
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(files):
            if path.is_file() and path.resolve().is_relative_to(ROOT):
                name = path.relative_to(ROOT).as_posix()
                archive.write(path, f"{stem}/{name}")
    return output


def promote(output):
    final_path = OUTPUT / output.name
    # On Windows, files created inside a private TemporaryDirectory can
    # retain its restricted ACL when renamed into the download folder.
    temporary = OUTPUT / f".{output.parent.name}-{output.name}.tmp"
    try:
        shutil.copyfile(output, temporary)
        temporary.replace(final_path)
    finally:
        temporary.unlink(missing_ok=True)
    return final_path


def build(args):
    if not re.fullmatch(r"\d+\.\d+\.\d+(?:-beta\.\d+)?", args.version):
        raise ValueError("Usa una versión como 0.1.0-beta.1.")
    target = args.target
    if target == "auto":
        target = {"Windows": "windows", "Linux": "linux", "Darwin": "macos"}.get(platform.system())
        if not target:
            raise ValueError("Sistema de compilación no reconocido. Indica --target.")
    targets = TARGETS if target == "all" else [target]
    godot = tool(args.godot)
    engine_version = run(godot, "--version")
    if not engine_version.startswith("4.7.2.stable"):
        raise ValueError(f"Se requiere Godot 4.7.2 estable. Versión encontrada: {engine_version}")
    nsis = tool(args.nsis) if "windows" in targets else None
    stem = f"SIS-INF-{args.version}"
    OUTPUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="beta-", dir=OUTPUT.parent) as directory:
        stage = Path(directory)
        names = notices(godot, stage, args.version)
        outputs = []
        for current in targets:
            print(f"Exportando {current}...", flush=True)
            preset, name = TARGETS[current]
            exported = stage / name
            run(godot, "--headless", "--path", GAME, "--log-file", stage / f"{current}.log",
                "--export-release", preset, exported)
            if current == "windows":
                output = windows_package(stage, stem, args.version, nsis)
            elif current == "linux":
                output = linux_package(stage, stem, names)
            else:
                output = macos_package(stage, stem, exported, names)
            outputs.append(output)
        outputs.append(source_package(stage, stem))
        checksums = stage / f"{stem}-SHA256SUMS.txt"
        lines = []
        for output in outputs:
            with output.open("rb") as data:
                digest = hashlib.file_digest(data, "sha256").hexdigest()
            lines.append(f"{digest}  {output.name}\n")
        checksums.write_text("".join(lines), encoding="ascii", newline="\n")
        for output in [*outputs, checksums]:
            print(promote(output), flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", default="0.1.0-beta.1")
    parser.add_argument("--target", default="auto", choices=["auto", "all", *TARGETS])
    parser.add_argument("--godot", default="godot")
    parser.add_argument("--nsis", default="makensis")
    args = parser.parse_args()
    try:
        build(args)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"{error}\n")


if __name__ == "__main__":
    main()
