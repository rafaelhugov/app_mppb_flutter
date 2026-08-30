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

COMMON_JAR="$HOME/.m2/repository/mppb/microservices/restapi-common/1.0.0/restapi-common-1.0.0.jar"
COMMON_CHANGED=false
if [ ! -f "$COMMON_JAR" ] || [ "${FORCE_COMMON_INSTALL:-0}" = "1" ]; then
  COMMON_CHANGED=true
elif find "$RESTAPI_DIR/restapi-common/pom.xml" "$RESTAPI_DIR/restapi-common/src" -newer "$COMMON_JAR" -print -quit | grep -q .; then
  COMMON_CHANGED=true
fi

if [ "$COMMON_CHANGED" = "true" ]; then
  echo "Atualizando restapi-common local para o mobile-service usar as mudanças recentes..."
  if ! mvn -q -f "$RESTAPI_DIR/pom.xml" -pl restapi-common -am -DskipTests install; then
    echo "========================================="
    echo "Falha ao atualizar o restapi-common local."
    echo "O mobile-service depende do artefato instalado no Maven local; sem isso,"
    echo "mudanças em classes comuns como SecurityConfig podem não entrar no backend."
    echo "========================================="
    exit 1
  fi
else
  echo "restapi-common local já está atualizado."
fi

cd "$BACKEND_DIR" || exit 1

# Carrega as variáveis do .env.dev
if [ -f ".env.dev" ]; then
  set -a
  source .env.dev
  set +a
fi

export POOL_MAX="${POOL_MAX:-5}"
export POOL_MIN="${POOL_MIN:-1}"

BACKEND_PORT="${PORT:-9003}"
API_URL_LOCAL="http://127.0.0.1:${BACKEND_PORT}"

: > "$BACKEND_LOG"
mvn spring-boot:run -Dspring-boot.run.profiles=dev > "$BACKEND_LOG" 2>&1 &
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
flutter run "$@" --dart-define=API_URL="$API_URL_LOCAL"
