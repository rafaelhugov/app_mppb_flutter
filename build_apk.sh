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
VERSION_CLEAN="${PUBSPEC_VERSION/+/_}"
NEW_APK_NAME="MPPB+_v${VERSION_CLEAN}.apk"
OUTPUT_DIR="build/app/outputs/flutter-apk"

if [ "$BUILD_NAME" = "$BUILD_NUMBER" ]; then
  echo "❌ A versão do pubspec.yaml deve estar no formato version: x.y.z+n."
  exit 1
fi

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
