#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP="cinnamon"
BOOT_ISO=""
RELEASEVER="$(rpm -E %fedora 2>/dev/null || true)"
RESULT_DIR="$ROOT_DIR/out"

usage() {
  cat <<'EOF'
CarsonOS-Fedora ISO builder

Usage:
  ./build-iso.sh [options]

Options:
  --desktop NAME       cinnamon (default), kde, xfce, gnome, hyprland
  --boot-iso PATH      Fedora boot/netinstall ISO for the target release
  --releasever VERSION Fedora release version (defaults to host release)
  --result-dir PATH    Output directory (default: ./out)
  --help               Show this help

Example:
  ./build-iso.sh --desktop cinnamon --boot-iso ~/Downloads/Fedora-netinst.iso
EOF
}

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
info() { printf '==> %s\n' "$*"; }

while (($#)); do
  case "$1" in
    --desktop)
      (($# >= 2)) || die "--desktop requires a value"
      DESKTOP="$2"; shift 2 ;;
    --boot-iso)
      (($# >= 2)) || die "--boot-iso requires a path"
      BOOT_ISO="$2"; shift 2 ;;
    --releasever)
      (($# >= 2)) || die "--releasever requires a value"
      RELEASEVER="$2"; shift 2 ;;
    --result-dir)
      (($# >= 2)) || die "--result-dir requires a path"
      RESULT_DIR="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown option: $1 (use --help)" ;;
  esac
done

case "$DESKTOP" in
  cinnamon|kde|xfce|gnome|hyprland) ;;
  *) die "Unsupported desktop '$DESKTOP'. Choose cinnamon, kde, xfce, gnome, or hyprland." ;;
esac

[[ -n "$BOOT_ISO" ]] || die "Pass a Fedora boot/netinstall ISO with --boot-iso."
[[ -f "$BOOT_ISO" ]] || die "Boot ISO not found: $BOOT_ISO"
[[ -n "$RELEASEVER" && "$RELEASEVER" != "%fedora" ]] || die "Could not determine Fedora release. Pass --releasever VERSION."

for cmd in livemedia-creator ksflatten sudo; do
  command -v "$cmd" >/dev/null 2>&1 || die "Missing '$cmd'. Install lorax-lmc-novirt and pykickstart (plus Fedora kickstart packages)."
done

if [[ ! -r /etc/fedora-release ]]; then
  die "Run this builder on a Fedora host matching the target release."
fi

KICKSTART="$ROOT_DIR/kickstarts/$DESKTOP.ks"
[[ -f "$KICKSTART" ]] || die "Kickstart profile not found: $KICKSTART"

mkdir -p "$RESULT_DIR"
RESULT_DIR="$(cd "$RESULT_DIR" && pwd)"
FLAT_KS="$RESULT_DIR/carsonos-fedora-$DESKTOP-flat.ks"
ISO_NAME="CarsonOS-Fedora-$DESKTOP-$RELEASEVER-x86_64.iso"
VOLID="CARSONOS_FEDORA"

info "Desktop: $DESKTOP"
info "Fedora release: $RELEASEVER"
info "Boot media: $BOOT_ISO"
info "Flattening Kickstart profile..."
ksflatten --config="$KICKSTART" --output="$FLAT_KS"

info "Starting virtualized ISO composition..."
info "This can take a while and requires substantial free disk space."
sudo livemedia-creator \
  --make-iso \
  --iso="$BOOT_ISO" \
  --ks="$FLAT_KS" \
  --resultdir="$RESULT_DIR" \
  --project="CarsonOS-Fedora" \
  --releasever="$RELEASEVER" \
  --volid="$VOLID" \
  --iso-name="$ISO_NAME"

info "Build command completed. Check $RESULT_DIR for the ISO and Anaconda logs."
