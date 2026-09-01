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
NEW_APK_NAME="MPPB+_v${VERSION_CLEAN}.apk"
OUTPUT_DIR="build/app/outputs/flutter-apk"

echo "Versão: $BUILD_NAME"
echo "Build: $BUILD_NUMBER"
echo "Arquivo final: $NEW_APK_NAME"
echo ""

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/MPPB+_v*.apk "$OUTPUT_DIR"/app-release.apk "$OUTPUT_DIR"/app-release.apk.sha1

flutter build apk --release --build-name="$BUILD_NAME" --build-number="$BUILD_NUMBER"

mv "$OUTPUT_DIR/app-release.apk" "$OUTPUT_DIR/$NEW_APK_NAME"
rm -f "$OUTPUT_DIR/app-release.apk.sha1"

echo ""
echo "✅ APK gerado com sucesso!"
echo "O arquivo está pronto em: $OUTPUT_DIR/$NEW_APK_NAME"
