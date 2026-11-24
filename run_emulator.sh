#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# run_emulator.sh - Inicia o emulador Android (MPPB+) com GPU estavel no Linux
# Uso:
#   ./run_emulator.sh              # Inicia Pixel_9 (ou primeiro AVD disponivel)
#   ./run_emulator.sh Pixel_9      # Inicia um AVD especifico
#   ./run_emulator.sh --list       # Lista os AVDs disponiveis
# ==============================================================================

SDK_DIR="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}"
EMULATOR_BIN="$SDK_DIR/emulator/emulator"
ADB_BIN="$SDK_DIR/platform-tools/adb"

if [[ ! -x "$EMULATOR_BIN" ]]; then
  echo "❌ Binário do emulator não encontrado em: $EMULATOR_BIN"
  echo "   Defina ANDROID_SDK_ROOT ou ANDROID_HOME corretamente."
  exit 1
fi

if [[ ! -x "$ADB_BIN" ]]; then
  echo "❌ Binário do adb não encontrado em: $ADB_BIN"
  exit 1
fi

mapfile -t AVDS < <("$EMULATOR_BIN" -list-avds 2>/dev/null || true)

if [[ ${#AVDS[@]} -eq 0 ]]; then
  echo "❌ Nenhum AVD encontrado. Crie um dispositivo virtual no Android Studio."
  exit 1
fi

if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
  echo "📱 AVDs disponíveis:"
  printf '  - %s\n' "${AVDS[@]}"
  exit 0
fi

TARGET_AVD="${1:-}"
if [[ -z "$TARGET_AVD" ]]; then
  for avd in "${AVDS[@]}"; do
    if [[ "$avd" == "Pixel_9" ]]; then
      TARGET_AVD="$avd"
      break
    fi
  done
  TARGET_AVD="${TARGET_AVD:-${AVDS[0]}}"
fi

AVD_EXISTS=false
for avd in "${AVDS[@]}"; do
  if [[ "$avd" == "$TARGET_AVD" ]]; then
    AVD_EXISTS=true
    break
  fi
done

if [[ "$AVD_EXISTS" != true ]]; then
  echo "❌ AVD '$TARGET_AVD' não encontrado. Disponíveis:"
  printf '  - %s\n' "${AVDS[@]}"
  exit 1
fi

RUNNING_EMU=$("$ADB_BIN" devices | awk '/^emulator-/{print $1; exit}')
if [[ -n "$RUNNING_EMU" ]]; then
  echo "✅ Emulador já está em execução: $RUNNING_EMU"
  exit 0
fi

LOG_FILE="/tmp/mppb_emulator_${TARGET_AVD}.log"
echo "🚀 Iniciando emulador Android '$TARGET_AVD' (GPU swiftshader_indirect)..."
echo "📄 Log: $LOG_FILE"

nohup "$EMULATOR_BIN" \
  -avd "$TARGET_AVD" \
  -no-audio \
  -no-snapshot \
  -gpu swiftshader_indirect \
  >"$LOG_FILE" 2>&1 &

EMU_PID=$!

echo "⏳ Aguardando o boot completo do Android (PID $EMU_PID)..."
"$ADB_BIN" wait-for-device

for _ in $(seq 1 90); do
  if ! kill -0 "$EMU_PID" 2>/dev/null; then
    echo "❌ O emulador encerrou inesperadamente. Veja o log em: $LOG_FILE"
    tail -n 20 "$LOG_FILE" || true
    exit 1
  fi

  BOOT_COMPLETED=$("$ADB_BIN" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)
  if [[ "$BOOT_COMPLETED" == "1" ]]; then
    DEVICE_ID=$("$ADB_BIN" devices | awk '/^emulator-/{print $1; exit}')
    echo "✅ Emulador pronto! Dispositivo: ${DEVICE_ID:-emulator}"
    exit 0
  fi
  sleep 2
done

echo "⚠️ Tempo limite aguardando boot completo, mas o processo continua ativo (PID $EMU_PID)."
echo "   Acompanhe em: $LOG_FILE"
