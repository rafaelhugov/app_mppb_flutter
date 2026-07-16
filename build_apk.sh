#!/bin/bash

# Adiciona o Flutter ao PATH
export PATH="$PATH:/home/rafaelhugo/flutter/bin"

echo "========================================="
echo "Iniciando build do APK de teste..."
echo "========================================="

# Vai para o diretório correto caso o script seja chamado de outro lugar
cd /home/rafaelhugo/projetosMPPB/app_mppb_flutter

if [ -n "$1" ]; then
  CUSTOM_VERSION="$1"
else
  # Extrair a versão atual do pubspec.yaml
  DEFAULT_VERSION=$(grep "^version: " pubspec.yaml | awk '{print $2}')
  DEFAULT_VERSION_CLEAN=$(echo $DEFAULT_VERSION | sed 's/+/_/g')
  read -p "Digite a versão para o APK (ex: 1.0.1_2) ou pressione Enter para usar a versão do pubspec ($DEFAULT_VERSION_CLEAN): " CUSTOM_VERSION
fi

if [ -z "$CUSTOM_VERSION" ]; then
  VERSION_CLEAN="$DEFAULT_VERSION_CLEAN"
else
  VERSION_CLEAN="$CUSTOM_VERSION"
fi

# Roda o comando de build
flutter build apk

if [ $? -eq 0 ]; then
  # Cria uma cópia com o nome incluindo a versão
  NEW_APK_NAME="MPPB+_v${VERSION_CLEAN}.apk"
  cp build/app/outputs/flutter-apk/app-release.apk "build/app/outputs/flutter-apk/${NEW_APK_NAME}"

  echo ""
  echo "✅ APK gerado com sucesso!"
  echo "O arquivo está pronto em: build/app/outputs/flutter-apk/${NEW_APK_NAME}"
else
  echo ""
  echo "❌ Falha ao gerar o APK. Verifique os logs acima."
fi
