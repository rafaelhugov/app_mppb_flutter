# Q4 - Inventario de Integracoes Controladas

Data: 2026-09-28

Escopo: integracoes entre camadas Flutter, API mobile Spring Boot, seguranca, servicos, repositorios e pontos externos mapeados. A fase nao executou testes E2E, nao usou credenciais reais e nao acionou producao.

| ID | Integracao | Camadas | Dependencia externa | Credencial/dado sensivel | Evidencia Q4 | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| INT-Q4-001 | Autenticacao e perfil | Flutter provider, Dio, Spring Security, controller, service, Auth API | Auth API | Bearer token | `Q4IntegracaoControladaTest`, `q4_flutter_integration_test.dart` | LOCAL/STUB |
| INT-Q4-002 | API HTTP mobile | Flutter repositories/providers e backend REST | Backend mobile | Bearer quando privado | Q3 contratos e Q4 casos locais | STUB |
| INT-Q4-003 | Filtros Spring Security | Filtros, SecurityContext e controllers | Nenhuma | Bearer token sintatico | MockMvc com filtros reais e provider fake | LOCAL |
| INT-Q4-004 | Persistencia relacional | Services e repositories de dominio | PostgreSQL | Datasource | Repositories substituidos por fakes controlados | STUB/PARCIAL |
| INT-Q4-005 | Pagamentos | Flutter provider, Dio, controller, service, repository | Base interna | CPF/matricula autenticada | Casos Q4 Flutter e backend | STUB |
| INT-Q4-006 | Processos e captcha | Flutter provider, Dio e API publica | Base processual/captcha | Captcha token publico | Timeout controlado em Flutter; Q3 contrato | STUB/PARCIAL |
| INT-Q4-007 | Certidao extrajudicial PDF | Flutter provider e endpoint PDF | Backend certidao/PDF | Dados pessoais no formulario | Caso Q4 com erro textual em `ResponseType.bytes` | STUB |
| INT-Q4-008 | Notificacoes de dispositivo | Controller, service e repository FCM | Firebase/FCM | Token FCM | Registro/desautorizacao em MockMvc | LOCAL/STUB |
| INT-Q4-009 | Push Firebase no Flutter | Firebase init e handlers Flutter | Firebase Messaging | Token FCM | Testes Q2/Q3 e smoke Android | PARCIAL |
| INT-Q4-010 | Designacoes | Controllers/services, scheduler e notificacoes | Base interna/FCM | Matricula | Regressao backend e Q3 contratos | PARCIAL/STUB |
| INT-Q4-011 | Concessoes/afastamentos | Flutter repository e API mobile | MPVirtual/RH | Matricula/token institucional | Q3 contratos e regressao Q4 | STUB/PARCIAL |
| INT-Q4-012 | Contracheque/PDF | Flutter provider, API mobile e geracao PDF | Base interna/PDF | CPF/matricula | Q3 contratos e regressao Q4 | PARCIAL |
| INT-Q4-013 | Carteira e imagens | Providers/services e JCR/classpath | JCR | Credenciais JCR | Smoke Android e regressao; JCR real nao acionado | PARCIAL/BLOQUEADO real |
| INT-Q4-014 | Noticias e Diario Oficial | Public providers e API mobile | Feed/base publica | Nenhuma | Testes existentes e smoke Android | PARCIAL |
| INT-Q4-015 | Ouvidoria | Flutter client externo | API Ouvidoria/captcha/upload | Cookie/captcha/anexos | Nao executado por ausencia de ambiente controlado autorizado | BLOQUEADO real |
| INT-Q4-016 | Google Wallet | Configuracao legada removida da API mobile | Nenhuma ativa identificada | Nao aplicavel | Historico mostra remocao de config legada | NAO APLICAVEL |

## Observacoes

- Docker estava disponivel no host, mas nao foi usado para Testcontainers porque a fase foi satisfeita com dublês deterministicos e nao havia infraestrutura de banco isolada preparada para o modulo.
- Integracoes reais com Auth API, MPVirtual/RH, JCR, Firebase remoto, Ouvidoria e bases institucionais ficaram bloqueadas ou parciais por falta de credenciais/massa autorizada no escopo Q4.
- O teste runtime Android abriu o APK homolog em emulador e registrou evidencias sem navegar em fluxos autenticados.
