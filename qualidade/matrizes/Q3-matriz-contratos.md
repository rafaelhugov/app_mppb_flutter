# Q3 - Matriz de contratos

Data: 2026-09-28

| Estado | Quantidade |
| --- | ---: |
| COMPATIVEL | 30 |
| PARCIAL | 8 |
| DIVERGENTE | 0 |
| NAO TESTADO | 1 |

## Divergencia corrigida

`DIV-Q3-001` - Certidao Extrajudicial: teste direto Flutter usava `tipoDocumento=CPF`, enquanto a UI e o backend usam `F|J`. A fixture foi corrigida para `F`; nao havia divergencia funcional da UI.

## Matriz

| ID | Modulo | Metodo | Endpoint | Estado |
| --- | --- | --- | --- | --- |
| CT-Q3-001 | Auth | POST | auth-api `/acesso/autoriza` | COMPATIVEL |
| CT-Q3-002 | Perfil | GET | `/api/perfil/dados` | COMPATIVEL |
| CT-Q3-003 | Carteira | GET | `/carteiras-funcionais/dados` | COMPATIVEL |
| CT-Q3-004 | Carteira foto | GET | `/carteiras-funcionais/foto` | PARCIAL |
| CT-Q3-005 | Contracheque | GET | `/contracheques/competencias` | COMPATIVEL |
| CT-Q3-006 | Contracheque | GET | `/contracheques/{mes}/{ano}` | COMPATIVEL |
| CT-Q3-007 | Contracheque PDF | GET | `/contracheques/{mes}/{ano}/pdf` | COMPATIVEL |
| CT-Q3-008 | Concessoes | GET | `/api/recursos-humanos/minhas-concessoes-folga` | COMPATIVEL |
| CT-Q3-009 | Concessoes | GET | `/api/recursos-humanos/minhas-ausencias` | COMPATIVEL |
| CT-Q3-010 | Concessoes | GET | `/concessoes/{id}/sugestoes-datas-finais` | COMPATIVEL |
| CT-Q3-011 | Concessoes | POST | `/concessoes/{id}/solicitacoes` | COMPATIVEL |
| CT-Q3-012 | Concessoes | GET | `/solicitacoes/{id}` | PARCIAL |
| CT-Q3-013 | Concessoes | GET | `/solicitacoes/{id}/operacoes` | COMPATIVEL |
| CT-Q3-014 | Concessoes | POST | `/cancelamentos` | COMPATIVEL |
| CT-Q3-015 | Concessoes | POST | `/adiamentos` | COMPATIVEL |
| CT-Q3-016 | Concessoes | POST | `/antecipacoes` | COMPATIVEL |
| CT-Q3-017 | Concessoes | POST | `/interrupcoes` | PARCIAL |
| CT-Q3-018 | Concessoes | POST | `/suspensoes-integrais` | PARCIAL |
| CT-Q3-019 | Concessoes | POST | `/suspensoes-parciais` | COMPATIVEL |
| CT-Q3-020 | Pagamentos | GET | `/pagamentos/exercicios` | COMPATIVEL |
| CT-Q3-021 | Pagamentos | GET | `/pagamentos/{exercicio}` | COMPATIVEL |
| CT-Q3-022 | Designacoes | GET | `/api/designacoes/ativas` | COMPATIVEL |
| CT-Q3-023 | FCM | POST | `/api/notificacoes/dispositivos` | COMPATIVEL |
| CT-Q3-024 | FCM | POST | `/diagnostico` | COMPATIVEL |
| CT-Q3-025 | FCM | DELETE | `/{identificador}` | COMPATIVEL |
| CT-Q3-026 | Processos | GET | `/api/public/v1/processos/filtros` | COMPATIVEL |
| CT-Q3-027 | Processos | POST | `/api/public/v1/processos/consulta` | COMPATIVEL |
| CT-Q3-028 | Captcha | GET | `/api/public/v1/captcha` | COMPATIVEL |
| CT-Q3-029 | Processos | GET | `/processos/{id}/detalhes` | COMPATIVEL |
| CT-Q3-030 | Noticias | GET | `/api/public/noticias` | COMPATIVEL |
| CT-Q3-031 | Diario | GET | `/api/public/diarios-oficiais/recentes` | COMPATIVEL |
| CT-Q3-032 | Certidao | POST | `/certidoes-extrajudiciais/pdf` | COMPATIVEL |
| CT-Q3-033 | Certidao | GET | `/codigo/{codigo}` | COMPATIVEL |
| CT-Q3-034 | Certidao | GET | `/codigo/{codigo}/pdf` | COMPATIVEL |
| CT-Q3-035 | Ouvidoria tipos | GET | externo `/tipos` | PARCIAL |
| CT-Q3-036 | Ouvidoria assuntos | GET | externo `/assuntos/{id}` | PARCIAL |
| CT-Q3-037 | Ouvidoria localidades | GET | externo `/municipios`, `/bairros` | PARCIAL |
| CT-Q3-038 | Ouvidoria manifestacao | POST | externo manifestacao | NAO TESTADO |
| CT-Q3-039 | Health | GET | `/api/public/health` | PARCIAL |

