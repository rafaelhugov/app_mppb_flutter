# Q5 - Relatorio Final

Data: 2026-09-29  
Escopo: Testes End-to-End Android, sem Q6.

## Resultado executivo

Q5 entregou inventario, matriz, rastreabilidade, harness `integration_test` e regressao verde de Flutter/backend. A tarefa corretiva Q5-R01 estabilizou e provou o smoke minimo em Android valido, mas a aprovacao E2E publica completa nao foi obtida: Pixel_8/API 36 e Pixel_9/API 37 perderam o device com `adb: device offline` durante a jornada publica completa.

Resultado Q5 E2E: **BLOQUEADO POR INFRAESTRUTURA ANDROID/ADB**.

## Automacao criada

| Arquivo | Conteudo |
| --- | --- |
| `integration_test/q5_smoke_home_e2e_test.dart` | Smoke minimo: iniciar app e encontrar Home publica. |
| `integration_test/q5_public_e2e_test.dart` | Jornada publica Home -> Contatos -> Home -> Noticias -> detalhe/estado seguro -> Home. |
| `lib/main.dart` | Flag `Q5_E2E_DISABLE_FCM` para E2E publico sem FCM real. |
| `public_dashboard_page.dart` | Chaves estaveis para servicos publicos. |

## Q5-R01

| Ambiente | Smoke minimo | Jornada publica completa |
| --- | --- | --- |
| Pixel_8, Android 16/API 36 | 3/3 verde, ESTAVEL | BLOQUEADA por `adb: device offline` |
| Pixel_9, Android 17/API 37 | 1/1 verde | BLOQUEADA por `adb: device offline` |

## Bugs encontrados e tratados

| ID | Descricao | Tratamento |
| --- | --- | --- |
| BUG-Q5-001 | Providers assincronos podiam atualizar estado/ref apos dispose durante abortos de runtime. | Adicionados guards `ref.mounted` em noticias, conectividade e notification center. |
| BUG-Q5-002 | Teste de date picker de concessao era sensivel a virada de mes na data corrente. | Ajustado helper para navegar mes visivel ate a data alvo. |

## Bloqueios

| Tipo | Bloqueio |
| --- | --- |
| Ambiente | Emuladores Pixel_9/API 37 e Pixel_8/API 36 encerraram com `exit 139`/ADB offline. |
| Credencial | Jornadas autenticadas nao executadas sem usuario homolog autorizado. |
| Massa | Perfil, carteira, contracheque, pagamentos, designacoes e concessoes exigem massa conhecida e autorizada. |
| Efeito externo | Ouvidoria e operacoes de concessao/afastamento nao devem ser disparadas sem massa descartavel/autorizacao. |
| Sistema externo | FCM real exige Firebase/device estavel e nao foi aprovado pela flag de E2E publico. |

## Recomendacao

Nao iniciar Q6 como fase aprovada. Antes da Q6, executar a jornada publica completa em dispositivo fisico autorizado ou host Android/CI com virtualizacao estavel. Credenciais/massas homolog controladas seguem necessarias para as jornadas autenticadas.
