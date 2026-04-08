#!/usr/bin/env bash
set -euo pipefail

# Stable hot-reload run mode:
# - fixed vm-service/dds ports (avoid reconnect race)
# - one flutter run session per terminal
# - optional device id as first arg
#
# Usage:
#   bash tools/dev_hot.sh
#   bash tools/dev_hot.sh <device-id>

DEVICE_ID="${1:-}"
VM_PORT="${VM_PORT:-51111}"
DDS_PORT="${DDS_PORT:-51112}"

echo "[dev_hot] killing stale flutter toolchain processes..."
pkill -f "flutter_tools|dart:vmservice|frontend_server" >/dev/null 2>&1 || true

echo "[dev_hot] flutter pub get..."
flutter pub get

CMD=(
  flutter run
  --hot
  --resident
  --host-vmservice-port "$VM_PORT"
  --dds-port "$DDS_PORT"
)

if [[ -n "$DEVICE_ID" ]]; then
  CMD+=( -d "$DEVICE_ID" )
fi

echo "[dev_hot] starting: ${CMD[*]}"
exec "${CMD[@]}"
