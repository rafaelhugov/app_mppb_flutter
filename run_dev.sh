#!/bin/bash

set -u

BACKEND_PID=""
RESTAPI_DIR="/home/rafaelhugo/projetosMPPB/spring-boot/restapi"
BACKEND_DIR="/home/rafaelhugo/projetosMPPB/spring-boot/restapi/mobile-service"
FRONTEND_DIR="/home/rafaelhugo/projetosMPPB/app_mppb_flutter"
BACKEND_LOG="$BACKEND_DIR/backend_log.txt"

cleanup() {
  if [ -n "${BACKEND_PID:-}" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
    kill "$BACKEND_PID" 2>/dev/null
  fi
}

trap cleanup EXIT

export PATH="$PATH:/home/rafaelhugo/flutter/bin"

echo "========================================="
echo "Iniciando o backend mobile-service (LOCAL)"
echo "========================================="
cd "$RESTAPI_DIR" || exit 1

echo "Atualizando restapi-common local..."
mvn -q -pl restapi-common -am install -DskipTests || exit 1

cd "$BACKEND_DIR" || exit 1

# Carrega as variáveis do .env.dev
if [ -f ".env.dev" ]; then
  set -a
  source .env.dev
  set +a
fi

BACKEND_PORT="${PORT:-9003}"
API_URL_LOCAL="http://127.0.0.1:${BACKEND_PORT}"

: > "$BACKEND_LOG"
mvn clean spring-boot:run -Dspring-boot.run.profiles=dev > "$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!

echo "Backend local iniciado com PID $BACKEND_PID"
echo "Aguardando backend responder em $API_URL_LOCAL ..."

BACKEND_READY=false
for i in $(seq 1 60); do
  if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
    echo "========================================="
    echo "Backend encerrou antes de ficar pronto."
    echo "Últimas linhas do log:"
    echo "========================================="
    tail -80 "$BACKEND_LOG"
    exit 1
  fi

  HTTP_CODE=$(curl --silent --output /dev/null --write-out "%{http_code}" --max-time 2 "$API_URL_LOCAL/" || true)
  if [ "$HTTP_CODE" != "000" ]; then
    BACKEND_READY=true
    break
  fi

  sleep 1
done

if [ "$BACKEND_READY" != "true" ]; then
  echo "========================================="
  echo "Backend não respondeu em $API_URL_LOCAL dentro do tempo limite."
  echo "Últimas linhas do log:"
  echo "========================================="
  tail -120 "$BACKEND_LOG"
  exit 1
fi

echo "Backend pronto em $API_URL_LOCAL"

echo "========================================="
echo "Iniciando Flutter (Modo DESENVOLVIMENTO)"
echo "Conectando ao backend local: $API_URL_LOCAL"
echo "========================================="
cd "$FRONTEND_DIR" || exit 1
export GTK_IM_MODULE=
export XMODIFIERS=
export QT_IM_MODULE=

# Inicia o flutter injetando a URL local
flutter run --dart-define=API_URL="$API_URL_LOCAL"
