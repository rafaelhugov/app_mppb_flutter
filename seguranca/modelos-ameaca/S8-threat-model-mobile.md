# S8 - Threat model mobile

Data: 2026-09-24

Escopo: `app_mppb_flutter`.

Metodo: STRIDE simplificado com foco em armazenamento local, sessao, notificacoes, plataforma Android/iOS e privacidade.

## Fluxos e ameaças

| Fluxo | Ativos | Ameacas | Controles existentes | Testes/evidencias | Risco residual |
|---|---|---|---|---|---|
| Login/sessao | `auth_token`, usuario, senha digitada | Token em URL/log; senha persistida; sessao residual em troca de conta | Bearer via interceptor; limpeza de `saved_password`; gates S7/S8 | `biometric_password_storage_test.dart`; `security_regression.sh` | Revogacao/refresh depende do backend/auth-api. |
| Biometria | Futuro vinculo biometrico, estado local | Biometria desbloquear senha salva; bypass local sem servidor; troca de usuario | Fluxo inseguro desativado; senha nao gravada | S5/S8; teste de storage | Novo fluxo seguro ainda nao implementado. |
| Carteira/perfil offline | Cache de carteira/perfil, foto, dados funcionais | PII em cache local; mistura de usuario; screenshot/backup | Cache vinculado a username; secrets fora do repo | S1 storage; matriz MASVS | Testar filesystem/backup/aparelho real. |
| Contracheque/PDF | Dados financeiros e PDF | PDF persistido em pasta acessivel; compartilhamento indevido; token em URL | Token removido de URL; acesso por Bearer | S2/S8; testes de apresentacao | Testar ciclo de vida do arquivo em runtime. |
| Concessoes/RH | Solicitacoes e operacoes | Manipulacao de IDs; replay; dados residuais de usuario anterior | Repositories usam API autenticada; testes de contrato | `concessao_afastamento_*_test.dart` | BOLA/replay dependem do backend/homologacao. |
| Pagamentos | Valores, CPF resolvido, exercicio | Enumeracao; exposicao em cache/log | API autenticada por Bearer | S1/S8 | Teste multiusuario em homologacao. |
| FCM/notificacoes | Token FCM, installation id, payload | Payload com PII; rota arbitraria; registro indevido | Payload tecnico permitido; navegacao controlada; registro/desativacao testados | `push_notification_service_test.dart`; `push_navigation_service_test.dart`; `device_registration_*_test.dart` | Validar payload real Firebase/homologacao. |
| Consulta publica | Captcha, filtros, detalhes publicos | Scraping; abuso; bypass captcha | Captcha/rate limit no backend | Testes backend e inventario S1 | Load/abuse test autorizado pendente. |
| Plataforma Android/iOS | Manifest, permissoes, deep links, backup, screenshots | Cleartext; componentes exportados; deep link abusivo; backup indevido | Cleartext release desabilitado no Android; debug/profile isolados | `android_cleartext_manifest_test.dart` | iOS, backup/restore e deep-link fuzz pendentes. |
| Supply chain mobile | Plugins Flutter/nativos, SDKs Firebase, assinatura | Dependencia vulneravel; keystore exposto; build debug distribuido | `.gitignore`; secret scan; build homolog validado | S6/S7/S8 | SCA formal, release assinado e provenance pendentes. |

## Trust boundaries mobile

- App -> `auth-api.mppb.mp.br`: credenciais de login e validacao de identidade.
- App -> `aplicativo-api.mppb.mp.br`: token Bearer e dados funcionais.
- App -> Firebase/FCM: token de dispositivo e payload de push.
- App -> armazenamento local seguro: token, caches, installation id e preferencias.
- App -> sistema operacional: biometria, permissões, backup, screenshots e intents/deep links.

## Decisao

Nao ha regressao local critica identificada. A cobertura mobile final ainda exige validacao dinamica em aparelho/emulador controlado, principalmente storage, backup/restore, screenshots, deep links, iOS e artefato release assinado.
