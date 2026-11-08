#!/bin/bash

# Diretório base do script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Configuração de PATH para Flutter
if [ -d "$HOME/development/flutter/bin" ]; then
  export PATH="$HOME/development/flutter/bin:$PATH"
fi
export PATH="$PATH:/home/rafaelhugo/flutter/bin"

echo "========================================="
echo "Iniciando Flutter (Modo PRODUÇÃO)"
echo "Backend: https://aplicativo-api.mppb.mp.br"
echo "========================================="

export GTK_IM_MODULE=
export XMODIFIERS=
export QT_IM_MODULE=

EXTRA_ARGS=("$@")

# No macOS, garante que o Simulador esteja aberto e selecionado se nenhum dispositivo foi especificado
if [[ "$(uname -s)" == "Darwin" ]]; then
  open -a Simulator 2>/dev/null || true
  
  # Se o usuário não passou flag de dispositivo (-d / --device-id), define o simulador iOS padrão
  HAS_DEVICE_ARG=false
  for arg in "$@"; do
    if [[ "$arg" == "-d" || "$arg" == "--device-id" ]]; then
      HAS_DEVICE_ARG=true
      break
    fi
  done

  if [ "$HAS_DEVICE_ARG" = false ]; then
    BOOTED_SIM="$(xcrun simctl list devices 2>/dev/null | grep '(Booted)' | head -n 1 | sed -E 's/[^(]*\(([A-F0-9-]+)\).*/\1/' || true)"
    if [ -n "$BOOTED_SIM" ]; then
      EXTRA_ARGS=("-d" "$BOOTED_SIM" "${EXTRA_ARGS[@]}")
    elif xcrun simctl list devices available 2>/dev/null | grep -q "iPhone 17"; then
      EXTRA_ARGS=("-d" "iPhone 17" "${EXTRA_ARGS[@]}")
    else
      EXTRA_ARGS=("-d" "iPhone 16 Pro" "${EXTRA_ARGS[@]}")
    fi
  fi
fi

# Inicia o flutter injetando a URL de produção pública (DNS seguro).
flutter run --dart-define=API_URL=https://aplicativo-api.mppb.mp.br "${EXTRA_ARGS[@]}"
