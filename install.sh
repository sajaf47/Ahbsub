#!/usr/bin/env bash
# ============================================================
# AHB Sub Page - PasarGuard installer
#   install : bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/install.sh)
#   remove  : bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/install.sh) uninstall
# ============================================================
set -euo pipefail

REPO="${AHB_REPO:-OWNER/REPO}"
BRANCH="${AHB_BRANCH:-main}"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}/index.html"

PG_DIR="${PG_DIR:-/opt/pasarguard}"
ENV_FILE="${PG_ENV:-$PG_DIR/.env}"
TPL_ROOT="${PG_TEMPLATES:-/var/lib/pasarguard/templates}"
TPL_REL="subscription/ahb.html"
TPL_FILE="$TPL_ROOT/$TPL_REL"

c_ok="\033[1;32m"; c_err="\033[1;31m"; c_inf="\033[1;36m"; c_off="\033[0m"
ok()  { echo -e "${c_ok}[+]${c_off} $*"; }
inf() { echo -e "${c_inf}[*]${c_off} $*"; }
die() { echo -e "${c_err}[!]${c_off} $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Run as root (sudo)."
[ -f "$ENV_FILE" ]   || die "PasarGuard .env not found at $ENV_FILE (set PG_ENV=/path/.env)."

# set or replace KEY="VALUE" in the .env (also un-comments a commented line)
set_env() {
  local key="$1" val="$2"
  if grep -Eq "^[#[:space:]]*${key}=" "$ENV_FILE"; then
    sed -i -E "s|^[#[:space:]]*${key}=.*|${key}=\"${val}\"|" "$ENV_FILE"
  else
    echo "${key}=\"${val}\"" >> "$ENV_FILE"
  fi
}

restart_panel() {
  if command -v pasarguard >/dev/null 2>&1; then
    inf "Restarting PasarGuard..."
    pasarguard restart || echo "restart failed - run 'pasarguard restart' manually."
  else
    inf "Run 'pasarguard restart' to apply."
  fi
}

if [ "${1:-install}" = "uninstall" ]; then
  rm -f "$TPL_FILE"
  if [ -f "$ENV_FILE.ahb.bak" ]; then
    cp -f "$ENV_FILE.ahb.bak" "$ENV_FILE"
    ok ".env restored from backup."
  else
    sed -i -E "s|^SUBSCRIPTION_PAGE_TEMPLATE=.*|# SUBSCRIPTION_PAGE_TEMPLATE=\"subscription/index.html\"|" "$ENV_FILE"
  fi
  ok "AHB sub page removed."
  restart_panel
  exit 0
fi

[ "$REPO" != "OWNER/REPO" ] || die "Set AHB_REPO=owner/repo (or edit REPO in this script)."

inf "Downloading template..."
mkdir -p "$(dirname "$TPL_FILE")"
tmp="$(mktemp)"
curl -fsSL "$RAW" -o "$tmp" || die "Download failed: $RAW"
grep -q "__SUB__" "$tmp" || die "Downloaded file is not the AHB template."
install -m 0644 "$tmp" "$TPL_FILE"
rm -f "$tmp"
ok "Template saved: $TPL_FILE"

[ -f "$ENV_FILE.ahb.bak" ] || cp -f "$ENV_FILE" "$ENV_FILE.ahb.bak"
set_env CUSTOM_TEMPLATES_DIRECTORY "${TPL_ROOT}/"
set_env SUBSCRIPTION_PAGE_TEMPLATE "$TPL_REL"
ok ".env updated (backup: $ENV_FILE.ahb.bak)"

restart_panel
ok "Done. Open any user's subscription link in a browser."
