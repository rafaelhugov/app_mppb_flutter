#!/bin/bash

trap 'kill $BACKEND_PID 2>/dev/null' EXIT

export PATH="$PATH:/home/rafaelhugo/flutter/bin"

echo "========================================="
echo "Iniciando o backend mobile-service (LOCAL)"
echo "========================================="
cd /home/rafaelhugo/projetosMPPB/spring-boot/restapi/mobile-service

# Carrega as variáveis do .env.dev
if [ -f ".env.dev" ]; then
  set -a
  source .env.dev
  set +a
fi

mvn spring-boot:run -Dspring-boot.run.profiles=dev > backend_log.txt 2>&1 &
BACKEND_PID=$!

echo "Backend local iniciado com PID $BACKEND_PID"
echo "Aguardando 10 segundos..."
sleep 10

echo "========================================="
echo "Iniciando Flutter (Modo DESENVOLVIMENTO)"
echo "Conectando ao backend local: 127.0.0.1:8086"
echo "========================================="
cd /home/rafaelhugo/projetosMPPB/app_mppb_flutter
export GTK_IM_MODULE=
export XMODIFIERS=
export QT_IM_MODULE=

# Inicia o flutter injetando a URL local
flutter run --dart-define=API_URL=http://127.0.0.1:8086
