# Feature Spec: 012 - Carregamento de Imagens via Dio, Remoção de CAPSLOCK e Bolhas Separadas

## Problemas Reportados
1. Imagens recebidas em avisos falhavam no preview (`Toque para abrir a imagem`) e no visualizador (`Falha ao carregar imagem.`) por usarem `Image.network` fora do pipeline autenticado do `Dio` e do cache local (`MensagemMidiaCache`).
2. Ainda havia textos em CAPSLOCK na tela de detalhe e no painel (`NORMAL`, `AVISO`, `IMPORTANTE`, `URGENTE`, `NOVO`, `ENVIADA`, `AGENDADA`, `CANCELADA`).
3. Na tela de detalhe do aviso, texto e anexos estavam juntos em um único card em vez de bolhas separadas estilo WhatsApp.

## Requisitos
1. Carregar thumbnails e imagens completas via `Dio` (`MensagensRepository` + `MensagemMidiaCache`), exibindo `Image.memory` / `Image.file`.
2. Padronizar todas as labels de prioridade, status e badges em Title Case (`Normal`, `Importante`, `Urgente`, `Aviso`, `Novo`, `Enviada`, `Agendada`, `Cancelada`).
3. Separar visualmente a bolha de texto da(s) bolha(s) de anexo na `MensagemDetalhePage`, estilo WhatsApp.
