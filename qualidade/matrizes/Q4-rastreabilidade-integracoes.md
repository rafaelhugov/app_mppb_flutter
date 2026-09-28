# Q4 - Rastreabilidade de Integracoes

| Funcionalidade | Q3 contrato | Q4 integracao controlada | Tipo Q4 | Resultado |
| --- | --- | --- | --- | --- |
| Autenticacao/perfil | Contrato de autenticacao preservado | Filtro real, provider fake, controller e service | LOCAL/STUB | OK |
| Pagamentos | Endpoints e payloads validados | Flutter 503 e backend service/repository fake | STUB | OK |
| Processos/captcha | Rotas e query params validados | Timeout de tipo de atividade no provider | STUB | OK |
| Certidao extrajudicial | Contrato PDF validado | Erro textual em bytes e payload PDF | STUB | OK |
| Notificacoes FCM | Contratos de device/push validados | Registro/desautorizacao sem token em log | LOCAL/STUB | OK |
| Designacoes | Contratos e payloads validados | Regressao backend e services existentes | PARCIAL | OK |
| Concessoes/afastamentos | Query/body/datas/operacoes validados | Regressao Flutter e backend | STUB/PARCIAL | OK |
| Contracheque | Competencias e PDF validados | Regressao geral | PARCIAL | OK |
| Carteira funcional | Cache/modelos validados | Runtime Android sem crash inicial | PARCIAL | OK |
| Noticias/Diario | Providers publicos validados | Runtime Android e regressao | PARCIAL | OK |
| Ouvidoria | Nao aprofundado em Q3 | Sem ambiente autorizado para API real/captcha/upload | BLOQUEADO real | NAO EXECUTADO |
| JCR/imagens | Inventariado em S1/Q1 | Sem credencial JCR real no escopo | BLOQUEADO real | PARCIAL |
| Google Wallet | Configuracao legada removida no backend | Nenhum fluxo ativo identificado | NA | NAO APLICAVEL |

## Leitura Q3 x Q4

A Q4 nao substitui Q3: ela acrescenta passagem controlada por camadas e negativos integrados sem depender de producao. Os contratos Q3 continuam sendo a referencia de compatibilidade Flutter <-> Backend; os casos Q4 exercitam wiring, filtros, providers e bordas de erro.
