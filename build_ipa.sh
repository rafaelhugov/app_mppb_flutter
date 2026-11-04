#!/bin/bash
set -euo pipefail

# Diretório base do script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Configuração de PATH para Flutter
if [ -d "$HOME/development/flutter/bin" ]; then
  export PATH="$HOME/development/flutter/bin:$PATH"
fi
export PATH="$PATH:/home/rafaelhugo/flutter/bin"

echo "========================================="
echo "Iniciando build do IPA (iOS / TestFlight)..."
echo "========================================="

AMBIENTE="${1:-producao}"
API_URL_ARGUMENTO="${2:-}"

case "$AMBIENTE" in
  homolog|homologacao)
    DEFAULT_API_URL="https://aplicativo-mppb-homolog.mppb.mp.br"
    IPA_LABEL="Homolog"
    ;;
  producao|prod)
    DEFAULT_API_URL="https://aplicativo-api.mppb.mp.br"
    IPA_LABEL="Producao"
    ;;
  *)
    echo "❌ Ambiente inválido: $AMBIENTE"
    echo "Use: producao ou homolog"
    exit 1
    ;;
esac

API_URL="${API_URL_ARGUMENTO:-${API_URL:-$DEFAULT_API_URL}}"

PUBSPEC_VERSION="$(grep '^version: ' pubspec.yaml | awk '{print $2}')"

if [ -z "$PUBSPEC_VERSION" ]; then
  echo "❌ Não foi possível ler a versão no pubspec.yaml."
  exit 1
fi

BUILD_NAME="${PUBSPEC_VERSION%%+*}"
BUILD_NUMBER="${PUBSPEC_VERSION#*+}"

echo "Ambiente: $AMBIENTE"
echo "API_URL: $API_URL"
echo "Versão: $BUILD_NAME"
echo "Build: $BUILD_NUMBER"
echo ""

# Garante aps-environment em production para export de Release
if [ -f "ios/Runner/Runner.entitlements" ]; then
  sed -i '' 's|<string>development</string>|<string>production</string>|g' ios/Runner/Runner.entitlements
fi

flutter clean
flutter pub get

echo "🔨 Compilando IPA com perfil MPPB AppStore..."
flutter build ipa \
  --release \
  --export-options-plist=ios/ExportOptions.plist \
  --dart-define=API_URL="$API_URL" \
  --build-name="$BUILD_NAME" \
  --build-number="$BUILD_NUMBER"

echo ""
echo "========================================="
echo "✅ Build do IPA concluído com sucesso!"
echo "Arquivo gerado em: build/ios/ipa/app_mppb_flutter.ipa"
echo "========================================="
