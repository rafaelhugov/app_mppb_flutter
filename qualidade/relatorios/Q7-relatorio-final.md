# Relatório Final — Fase Q7: Rede, Offline e Interrupções

Data: 2026-09-30  
Branch Original de Testes: `qualidade/q7-rede-offline-interrupcoes`  
Commit de consolidação Q7 Flutter: `20d4c89`  
Commit de consolidação Q7 Backend: `4c1bd3e`  
Status: **Q7 CONCLUÍDA — REDE, OFFLINE E INTERRUPÇÕES VALIDADAS NO ESCOPO TESTADO**  
Próxima Fase: **Q8 NÃO INICIADA**

---

## 1. Visão Geral da Fase Q7

A fase Q7 teve por objetivo comprovar o comportamento do App MPPB e de seu Backend quando a comunicação de rede:
- não existe (offline prévio);
- cai antes ou durante a requisição;
- demora além do timeout (15s padrão Dio);
- retorna erro HTTP (400, 401, 403, 404, 500, 502, 503, 504);
- retorna payload truncado ou malformado;
- é restabelecida após falha (reconexão transparente);
- é interrompida durante download de arquivo binário (stream de PDF);
- é interrompida pela destruição do componente (lifecycle / dispose);
- falha em dependência externa downstream (Auth API institucional, MPVirtual, JCR).

O princípio norteador comprovado nesta fase:
```text
falha de rede → erro controlado → estado consistente → recuperação previsível
```

---

## 2. Inventário de Dependências de Rede (Q7-T01 e Q7-T02)

Foram catalogadas **29 integrações de rede reais**, estruturadas no artefato `qualidade/inventarios/Q7-inventario-rede.md`:

- **Operações de Leitura (Total: 17)**:
  - **Leituras Seguras para Retry (16)**: Perfil, Carteira Dados, Carteira Foto, Contracheque Exercícios, Contracheque Meses, Contracheque PDF, Pagamentos Exercícios, Pagamentos Dados, Designações, RH Concessões, RH Ausências, Notícias, Diário Oficial Edições, Diário Oficial PDF, Certidão Consulta, Conectividade Health Probe.
  - **Leituras com Retry Condicional (1)**: Processos com Captcha (consulta pública cuja repetição é estritamente condicionada à resolução de novo Captcha pelo usuário).
- **Operações de Mutação (Total: 12)**:
  - **Mutações com Retry Automático Proibido (9)**: Login, Solicitar Férias, Adiar Férias, Antecipar Férias, Cancelar Férias, Suspender Férias Integral, Suspender Férias Parcial, Certidão Emitir, Ouvidoria Manifestação Enviar.
  - **Mutações com Retry Condicional / Descarte / Idempotente (3)**: FCM Registrar (idempotente com reenvio em reconexão/startup), FCM Desativar (idempotente com descarte em falha), Logout (limpeza local atômica e descarte gracioso em falha remota).
- **Soma das Categorias de Mutações**: 9 (Proibido) + 3 (Condicional/Descarte) = 12 mutações.
- **Recursos com Cache Local / Persistência**: 7 fluxos (Perfil, Carteira Funcional, Foto em cache, Notícias em memória, Formulário Ouvidoria em memória, Logout atômico local, Token FCM).
- **Dependências Externas**: 10 fluxos (Auth API, MPVirtual [7 endpoints], JCR, CMS).
- **Operações Bloqueadas para Automação Ativa**: 3 (Processos com Captcha, Emissão de Certidão, Envio de Manifestação Ouvidoria).

---

## 3. Comportamento Comprovado — Flutter

A bateria determinística implementada em `test/features/rede/q7_rede_interrupcoes_test.dart` comprovou:

| Cenário | Comportamento Observado | Status |
| :--- | :--- | :---: |
| **Sem Rede (Offline prévio)** | Encerra loading, não trava UI, popula mensagem amigável, sem crash | PASSOU |
| **Timeout de Conexão / Resposta** | Interceptado no tempo limite (15s), loading encerra com erro amigável | PASSOU |
| **Queda Durante Requisição** | Resposta abortada limpa loading, sem dados parciais corrompidos | PASSOU |
| **Retry de Leitura** | Retry manual limpa erro anterior, reinicia loading e exibe dados com sucesso | PASSOU |
| **Preservação de Dados Prévios** | Falha no refresh mantém notícias já renderizadas na tela sem apagá-las | PASSOU |
| **Reconexão de Rede** | Retorno da conectividade permite nova requisição transparente sem reiniciar o app | PASSOU |
| **Resposta Inválida / Truncada** | Captura `FormatException`/`TypeError` sem crash e informa erro amigável | PASSOU |
| **Download Interrompido** | Stream de PDF interrompido não grava bytes incompletos como sucesso | PASSOU |
| **Lifecycle / Dispose** | Notifier descartado com request em trânsito não dispara erro pós-dispose | PASSOU |
| **HTTP 401 (Sessão Expirada)** | Interceptor do `dioProvider` executa logout automático e limpa credenciais | PASSOU |
| **HTTP 403 (Acesso Negado)** | Interceptor não aciona logout indevido; preserva autenticação do usuário | PASSOU |
| **HTTP 500 / 503 Backend** | Traduzido em mensagem amigável de indisponibilidade de serviço na UI | PASSOU |
| **HTTP 429 Rate Limiting** | Sem contrato ou política de rate limiting vigente na API móvel | N/A |

---

## 4. Comportamento Comprovado — Backend

A bateria determinística implementada em `Q7RedeInterrupcoesTest.java` no módulo `mobile-service` comprovou:

| Cenário | Comportamento Observado | Status |
| :--- | :--- | :---: |
| **Sistema Externo Indisponível** | `feign.RetryableException` é capturada pelo `ApiExceptionHandler` e convertida em HTTP 503 com ProblemDetail padronizado | PASSOU |
| **Tratamento de Timeout Feign** | `feign.RetryableException` de timeout capturada e respondida imediatamente em HTTP 503 sem vazar stacktrace (comprovado no handler; retenção de socket congelado coberta por `RISCO-Q7-001`) | PASSOU |
| **Erro 5xx Upstream** | Resposta 500 upstream decodificada por `FeignErrorDecoder` e convertida em HTTP 502 Bad Gateway | PASSOU |
| **Falha de Consulta Externa (Fallback Null)** | Falhas de autorização externa em `PerfilUsuarioService` retornam `null` com log sem quebrar a API | PASSOU |
| **Token Inválido / Expirado** | `PerfilUsuarioController` retorna HTTP 401 Unauthorized de forma consistente | PASSOU |
| **Autorização Negada (403)** | `AccessDeniedException` tratada como HTTP 403 Forbidden com ProblemDetail seguro | PASSOU |

---

## 5. Validação em Android Físico

- **Ambiente de Execução**: Windows físico + Samsung Galaxy A52 (`SM-A525M`) + APK flavor homolog + endpoint público de produção.
- **Dispositivo**: Samsung Galaxy A52 (`SM-A525M`), Android 14 / One UI 6.1 (API 34), arquitetura `arm64-v8a`.
- **Classificação do Endpoint**: **CENÁRIO FÍSICO Q7 EXECUTADO CONTRA ENDPOINT PÚBLICO DE PRODUÇÃO POR CONFIGURAÇÃO DO BUILD** (build APK com flavor homolog mas sem `--dart-define=API_URL=...`, adotando o fallback padrão `https://aplicativo-api.mppb.mp.br`).
- **Escopo**: Home pública, health probe, Notícias públicas, desconexão, reconexão, nenhuma mutação, nenhuma operação autenticada/restrita.
- **Método de Desconexão**: `E2E MANUAL CONTROLADO` (Desativação de Wi-Fi e Dados Móveis).
- **Jornada**: Home pública → Notícias online → Desconexão de rede → Pull-to-refresh offline → Feedback de erro controlado sem perda dos itens já carregados → Reconexão Wi-Fi → Retry manual → Sucesso.
- **Logcat**: Zero `FATAL EXCEPTION`, zero `AndroidRuntime`, zero `SIGSEGV`, zero `PlatformException`, zero crashes de Flutter.

---

## 6. Bugs Identificados e Corrigidos

| ID | Fluxo | Causa Raiz | Correção Aplicada | Status |
| :--- | :--- | :--- | :--- | :---: |
| **BUG-Q7-001** | Carteira Funcional | `CarteiraNotifier._loadFromCache` não checava `ref.mounted` após leitura assíncrona do storage em fallback offline, gerando `StateError` se a tela fosse fechada durante a leitura. | Inseridas guardas `if (!ref.mounted) return;` no início e após cada await em `CarteiraNotifier`. | **CORRIGIDO** |
| **BUG-Q7-002** | Notícias | `NoticiaNotifier.fetchNoticias` disparado pelo microtask de `build()` não checava `ref.mounted` antes de acessar `state`, gerando `StateError` caso o container fosse descartado antes do microtask executar. | Inserida checagem `if (!ref.mounted) return;` no início de `fetchNoticias`. | **CORRIGIDO** |

---

## 7. Riscos Formalizados

| ID | Fluxo | Risco Arquitetural | Impacto e Mitigação | Status |
| :--- | :--- | :--- | :--- | :---: |
| **RISCO-Q7-001** | Backend / Clientes Feign | Os clientes Feign (`AuthServiceClient`, `MPVirtualClient`) não possuem timeout explicitamente governado na configuração da aplicação; portanto, o comportamento depende da configuração/default efetivamente aplicada pela stack utilizada. | A camada de tratamento de exceções converte com segurança `RetryableException` em HTTP 503, mas a parametrização explícita de socket permanece pendente de governança. | **FORMALIZADO** |
| **RISCO-Q6-001** *(Preservado)* | Recursos Humanos / MPVirtual | Operações mutáveis de RH (`/solicitacoes`, `/adiamentos`, etc.) não possuem garantia de deduplicação por `Idempotency-Key` no MPVirtual. | Q7 validou e confirmou que o App MPPB **NÃO** realiza nenhum retry automático nessas rotas, prevenindo duplicações. | **MONITORADO** |

---

## 8. Política de Operações Mutáveis

Fica expressamente comprovado que as seguintes operações mutáveis **NÃO POSSUEM E NÃO DEVEM POSSUIR RETRY AUTOMÁTICO**:
1. `POST /acesso/autoriza` (Login)
2. `POST /recursos-humanos/concessoes/{id}/solicitacoes` (Solicitação de Férias)
3. `POST /recursos-humanos/solicitacoes/{id}/adiamentos` (Adiamento de Férias)
4. `POST /recursos-humanos/solicitacoes/{id}/antecipacoes` (Antecipação de Férias)
5. `POST /recursos-humanos/solicitacoes/{id}/cancelamentos` (Cancelamento de Férias)
6. `POST /recursos-humanos/solicitacoes/{id}/suspensoes-integrais` (Suspensão Integral)
7. `POST /recursos-humanos/solicitacoes/{id}/suspensoes-parciais` (Suspensão Parcial)
8. `POST /certidao-extrajudicial/emitir` (Emissão de Certidão)
9. `POST /ouvidoria/manifestacao` (Envio de Manifestação)

---

## 9. Regressão Final de Portões

- **Flutter Tests**: 187/187 testes PASS (+18 novos testes determinísticos Q7). Baseline anterior: 169/169.
- **Flutter Analyze**: 0 issues (100% verde).
- **Flutter APK Homolog Debug**: Build concluído com sucesso.
- **Flutter Security Gates**: Secret scan e security regression verdes.
- **Backend Tests**: 148/148 testes PASS (+6 novos testes determinísticos Q7). Baseline anterior: 142/142.
- **Backend Package**: BUILD SUCCESS (`restapi-common`, `mobile-service`).
- **Backend Security Gates**: Conforme.
- **Consolidação Git**: Commits de consolidação `20d4c89` (Flutter) e `4c1bd3e` (Backend) integrados via fast-forward na branch `master` local. Alteração preexistente `pubspec.yaml (version: 4.0.0+69 → 4.0.0+72)` preservada de forma não destrutiva fora de commit.
