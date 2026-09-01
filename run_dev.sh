#!/bin/bash

set -u

# Último argumento opcional define o ambiente da API de Recursos Humanos.
# Exemplos:
#   ./run_dev.sh -d linux homologacao
#   ./run_dev.sh -d linux producao
#
# Se omitido, usa homologação por segurança.
RH_AMBIENTE="homologacao"
FLUTTER_ARGS=("$@")

if [ "${#FLUTTER_ARGS[@]}" -gt 0 ]; then
  ULTIMO_INDICE=$((${#FLUTTER_ARGS[@]} - 1))
  ULTIMO_ARG="${FLUTTER_ARGS[$ULTIMO_INDICE]}"

  case "$ULTIMO_ARG" in
    producao|homologacao)
      RH_AMBIENTE="$ULTIMO_ARG"
      unset 'FLUTTER_ARGS[$ULTIMO_INDICE]'
      FLUTTER_ARGS=("${FLUTTER_ARGS[@]}")
      ;;
  esac
fi

BACKEND_PID=""
RESTAPI_DIR="/home/rafaelhugo/projetosMPPB/spring-boot/restapi"
BACKEND_DIR="/home/rafaelhugo/projetosMPPB/spring-boot/restapi/mobile-service"
FRONTEND_DIR="/home/rafaelhugo/projetosMPPB/app_mppb_flutter"
BACKEND_LOG="$BACKEND_DIR/target/run-dev/backend.log"

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
mkdir -p "$(dirname "$BACKEND_LOG")"

# Carrega as variáveis do .env.dev
if [ -f ".env.dev" ]; then
  set -a
  source .env.dev
  set +a
fi

export POOL_MAX="${POOL_MAX:-5}"
export POOL_MIN="${POOL_MIN:-1}"

case "$RH_AMBIENTE" in
  producao)
    export MPVIRTUAL_RECURSOS_HUMANOS_BASE_URL="http://10.94.0.253:8080/api"
    export PG_URL="${RH_PROD_PG_URL:-postgresql://10.94.0.11:5432/MPE}"
    if [ -n "${RH_PROD_PG_USERNAME:-}" ]; then
      export PG_USERNAME="$RH_PROD_PG_USERNAME"
    fi
    if [ -n "${RH_PROD_PG_PASSWORD:-}" ]; then
      export PG_PASSWORD="$RH_PROD_PG_PASSWORD"
    fi
    echo "========================================="
    echo "ATENÇÃO: API RH DE PRODUÇÃO"
    echo "RH: $MPVIRTUAL_RECURSOS_HUMANOS_BASE_URL"
    echo "Banco RH: $PG_URL"
    echo "Usuário banco RH: ${PG_USERNAME:-<não informado>}"
    echo "========================================="
    ;;
  homologacao)
    export MPVIRTUAL_RECURSOS_HUMANOS_BASE_URL="http://10.128.4.50:8080/api"
    echo "API RH: HOMOLOGAÇÃO"
    echo "RH: $MPVIRTUAL_RECURSOS_HUMANOS_BASE_URL"
    echo "Banco RH: ${PG_URL:-<não informado>}"
    echo "Usuário banco RH: ${PG_USERNAME:-<não informado>}"
    ;;
  *)
    echo "Ambiente RH inválido: $RH_AMBIENTE"
    echo "Use: producao ou homologacao"
    exit 1
    ;;
esac

BACKEND_PORT="${PORT:-9003}"
API_URL_LOCAL="http://127.0.0.1:${BACKEND_PORT}"

: > "$BACKEND_LOG"
mvn spring-boot:run -Dspring-boot.run.profiles=dev -Dspring-boot.run.arguments="--server.address=0.0.0.0 --server.port=${BACKEND_PORT}" > "$BACKEND_LOG" 2>&1 &
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
API_URL_DART="$API_URL_LOCAL"
FLUTTER_ARGS_TEXT="${FLUTTER_ARGS[*]}"
if [[ "$FLUTTER_ARGS_TEXT" == *"emulator"* || "$FLUTTER_ARGS_TEXT" == *"localhost:"* ]]; then
  echo "Dispositivo/Emulador isolado detectado. Configurando adb reverse para a porta $BACKEND_PORT..."
  
  DEVICE_ID=""
  
  # Extrai o ID do dispositivo
  for ((i=0; i<${#FLUTTER_ARGS[@]}; i++)); do
    if [[ "${FLUTTER_ARGS[$i]}" == "-d" || "${FLUTTER_ARGS[$i]}" == "--device-id" ]]; then
      next=$((i+1))
      if [ "$next" -lt "${#FLUTTER_ARGS[@]}" ]; then
        DEVICE_ID="${FLUTTER_ARGS[$next]}"
      fi
      break
    fi
  done

  if [ -n "$DEVICE_ID" ]; then
    adb -s "$DEVICE_ID" reverse tcp:${BACKEND_PORT} tcp:${BACKEND_PORT} || echo "Aviso: falha ao configurar adb reverse"
  else
    adb reverse tcp:${BACKEND_PORT} tcp:${BACKEND_PORT} || echo "Aviso: falha ao configurar adb reverse"
  fi
fi

# Injeta a URL correta para dentro do Dart e roda o Flutter
flutter run "${FLUTTER_ARGS[@]}" --dart-define=API_URL="$API_URL_DART"
