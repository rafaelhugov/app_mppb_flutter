#!/bin/bash
set -euo pipefail

# Adiciona o Flutter ao PATH
export PATH="$PATH:/home/rafaelhugo/flutter/bin"

echo "========================================="
echo "Iniciando build do APK..."
echo "========================================="

# Vai para o diretório correto caso o script seja chamado de outro lugar
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AMBIENTE="${1:-homolog}"
API_URL_ARGUMENTO="${2:-}"
ADI_REGISTRATION_TOKEN="${3:-${ADI_REGISTRATION_TOKEN:-}}"

case "$AMBIENTE" in
  homolog|homologacao)
    FLAVOR="homolog"
    DEFAULT_API_URL="https://aplicativo-mppb-homolog.mppb.mp.br"
    FIREBASE_ANDROID_APP_ID="1:205396983225:android:a7dce4ef0ae72c9e788a68"
    APK_LABEL="Homolog"
    ;;
  producao|prod)
    FLAVOR="producao"
    DEFAULT_API_URL="https://aplicativo-api.mppb.mp.br"
    FIREBASE_ANDROID_APP_ID="1:205396983225:android:44dd38aa9f796d5f788a68"
    APK_LABEL="Producao"
    ;;
  *)
    echo "❌ Ambiente inválido: $AMBIENTE"
    echo "Use: homolog ou producao"
    exit 1
    ;;
esac

API_URL="${API_URL_ARGUMENTO:-${API_URL:-$DEFAULT_API_URL}}"
ADI_REGISTRATION_FILE="android/app/src/main/assets/adi-registration.properties"

cleanup_adi_registration() {
  if [ -n "$ADI_REGISTRATION_TOKEN" ] && [ -f "$ADI_REGISTRATION_FILE" ]; then
    rm -f "$ADI_REGISTRATION_FILE"
  fi
}
trap cleanup_adi_registration EXIT

PUBSPEC_VERSION="$(grep '^version: ' pubspec.yaml | awk '{print $2}')"

if [ -z "$PUBSPEC_VERSION" ]; then
  echo "❌ Não foi possível ler a versão no pubspec.yaml."
  exit 1
fi

BUILD_NAME="${PUBSPEC_VERSION%%+*}"
BUILD_NUMBER="${PUBSPEC_VERSION#*+}"

if [ "$BUILD_NAME" = "$BUILD_NUMBER" ]; then
  echo "❌ A versão do pubspec.yaml deve estar no formato version: x.y.z+n."
  exit 1
fi

# Incremento automático do build number
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_VERSION="${BUILD_NAME}+${NEW_BUILD_NUMBER}"

# Substitui a versão no pubspec.yaml
sed -i "s/^version: $PUBSPEC_VERSION/version: $NEW_VERSION/" pubspec.yaml
echo "✅ Versão atualizada no pubspec.yaml: $PUBSPEC_VERSION -> $NEW_VERSION"

# Atualiza as variáveis para os próximos passos
BUILD_NUMBER=$NEW_BUILD_NUMBER
VERSION_CLEAN="${NEW_VERSION/+/_}"
NEW_APK_NAME="MPPB+_${APK_LABEL}_v${VERSION_CLEAN}.apk"
OUTPUT_DIR="build/app/outputs/flutter-apk"
FLAVOR_APK="$OUTPUT_DIR/app-${FLAVOR}-release.apk"

echo "Ambiente: $FLAVOR"
echo "API_URL: $API_URL"
if [ -n "$ADI_REGISTRATION_TOKEN" ]; then
  echo "Verificação Play Console: token ADI será incluído no APK"
fi
echo "Versão: $BUILD_NAME"
echo "Build: $BUILD_NUMBER"
echo "Arquivo final: $NEW_APK_NAME"
echo ""

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/MPPB+_"$APK_LABEL"_v*.apk "$FLAVOR_APK" "$FLAVOR_APK.sha1"

if [ -n "$ADI_REGISTRATION_TOKEN" ]; then
  mkdir -p "$(dirname "$ADI_REGISTRATION_FILE")"
  printf '%s' "$ADI_REGISTRATION_TOKEN" > "$ADI_REGISTRATION_FILE"
fi

flutter build apk \
  --release \
  --flavor "$FLAVOR" \
  --dart-define=API_URL="$API_URL" \
  --dart-define=FIREBASE_ANDROID_APP_ID="$FIREBASE_ANDROID_APP_ID" \
  --build-name="$BUILD_NAME" \
  --build-number="$BUILD_NUMBER"

mv "$FLAVOR_APK" "$OUTPUT_DIR/$NEW_APK_NAME"
rm -f "$FLAVOR_APK.sha1"

echo ""
echo "✅ APK gerado com sucesso!"
echo "O arquivo está pronto em: $OUTPUT_DIR/$NEW_APK_NAME"
