#!/bin/bash

export PATH="$PATH:/home/rafaelhugo/flutter/bin"

echo "========================================="
echo "Iniciando Flutter (Modo PRODUÇÃO/TESTE)"
echo "Conectando ao backend remoto: 10.94.0.83:8290"
echo "========================================="
cd /home/rafaelhugo/projetosMPPB/app_mppb_flutter

export GTK_IM_MODULE=
export XMODIFIERS=
export QT_IM_MODULE=

# Inicia o flutter injetando a URL de produção pública (DNS seguro). 
# Não precisamos subir o backend Spring Boot porque ele já está no Docker de produção.
flutter run --dart-define=API_URL=https://aplicativo-api.mppb.mp.br
