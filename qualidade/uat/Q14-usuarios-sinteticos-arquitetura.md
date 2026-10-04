# Q14 — Arquitetura de Usuários Sintéticos para UAT Interno e Store Review (Google/Apple)

- **Fase:** Q14 — Qualidade e Homologação
- **Atividade:** Q14-R03-R03 — Hardening Final da Infraestrutura Sintética
- **Data:** 03/10/2026
- **Status:** Hardening Concluído; `BLOQUEIO-Q14-SYNTH-001` Resolvido; UAT Interno Pronto

---

## 1. Contexto e Motivação

Durante o Pré-UAT Técnico da Q14, identificou-se que as jornadas públicas e anônimas (`Q14-U01` a `Q14-U08`) foram 100% validadas, porém as jornadas autenticadas (`Q14-U09` a `Q14-U18`) encontravam-se pendentes de validação de segurança e conformidade LGPD.

A atividade **Q14-R03-R02** comprovou com sucesso a parametrização segura de autenticação no Flutter e realizou o smoke físico no dispositivo Samsung Galaxy A52.
A atividade **Q14-R03-R03** consolidou o **hardening final da infraestrutura sintética**:
- Eliminação total de proxy de autenticação institucional;
- Condicionamento estrito do ciclo de vida dos beans sintéticos via `@ConditionalOnProperty`;
- Auditoria e resolução de ambiguidade em construtores Spring nos 8 serviços estendidos;
- Rotação mandatória de segredos efêmeros com política de zero vazamento em logs/transcripts;
- Documentação formal da coerência de datasets e limitações de replay.

---

## 2. Resolução do Bloqueio de Rota (`BLOQUEIO-Q14-SYNTH-001`)

O bloqueio original identificou que o Flutter apontava hardcoded para `https://auth-api.mppb.mp.br/acesso/autoriza`.
A resolução implementada e testada no Flutter:
1. **Configuração via `--dart-define`:** `AUTH_BASE_URL` parametrizável em `lib/core/network/api_client.dart` com default estrito `https://auth-api.mppb.mp.br`.
2. **Ambiente UAT:** Invocação do Flutter passando `--dart-define=AUTH_BASE_URL=http://<IP>:9003` para direcionar a autenticação ao backend sintético durante testes locais, preservando intacto o comportamento de produção.
3. **Evidência Física:** Smoke físico realizado com sucesso no Galaxy A52 para `uat.membro` e `uat.servidor` (login, dashboard, perfil e logout aprovados).
4. **Estado:** `BLOQUEIO-Q14-SYNTH-001` **RESOLVIDO**.

---

## 3. Diretrizes de Hardening da Infraestrutura Sintética

### 3.1. Zero Alterações em `restapi-common`
O módulo `restapi-common` é infraestrutura corporativa compartilhada.
- Permanece com `git diff` = 0.
- Nenhum bypass, token sintético ou regra UAT foi introduzida no módulo comum. Toda a lógica sintética reside exclusivamente no `mobile-service`.

### 3.2. Zero Proxy Institucional no Endpoint Sintético
Em versões preliminares, cogitou-se repassar credenciais desconhecidas para a `auth-api` corporativa via `AuthServiceClient`.
A auditoria técnica comprovou que o `mobile-service` não possui nenhum consumidor real para `/acesso/autoriza` fora do mecanismo Q14.
**Decisão Arquitetural Mandatória:**
- A delegação ao `AuthServiceClient` foi **completamente removida** do `AutenticacaoSinteticaController`.
- Com a feature ligada (`uat.synthetic-users.enabled=true`):
  - Contas sintéticas válidas (`uat.membro`, `uat.servidor`, etc.) autenticam com HTTP 200 + token `UAT-SYNTH.*`;
  - Contas desconhecidas ou senhas inválidas recebem **HTTP 401 controlado imediatamente**;
  - O `AuthServiceClient` tem **ZERO interações** (nenhuma credencial de usuário é encaminhada para fora).
- Com a feature desligada (`uat.synthetic-users.enabled=false`):
  - O endpoint `/acesso/autoriza` é inexistente no `mobile-service` (HTTP 404).

### 3.3. Ciclo de Vida Condicionado dos Beans Sintéticos
Todos os 7 componentes da infraestrutura sintética são estritamente condicionados via:
```java
@ConditionalOnProperty(name = "uat.synthetic-users.enabled", havingValue = "true")
```
- `AutenticacaoSinteticaController`
- `SyntheticSecurityConfig`
- `SyntheticTokenAuthenticationProvider`
- `AutenticadorUsuarioSintetico`
- `AuditoriaUsuarioSintetico`
- `SyntheticDataService`
- `SyntheticSandboxStorage`

**Comportamento com `uat.synthetic-users.enabled=false`:**
- Nenhum dos 7 beans é registrado no contexto Spring.
- O endpoint `/acesso/autoriza` não é mapeado.
- Zero superfície de ataque adicional em relação ao baseline do `mobile-service`.

### 3.4. Resolução de Ambiguidade de Construtores nos Serviços de Negócio
Durante a auditoria de injeção de dependência nos 8 serviços estendidos:
`CarteiraService`, `PerfilUsuarioService`, `ConcessaoFolgaService`, `ContrachequeService`, `PagamentosService`, `DesignacaoConsultaService`, `DesignacaoAuthService`, `DispositivoFcmService`.
- **Causa Raiz:** O Spring Framework 4.3+ permite omitir `@Autowired` apenas quando uma classe possui um único construtor. Ao adicionar o construtor sintético opcional com `SyntheticDataService`, as classes passaram a ter múltiplos construtores, gerando `No default constructor found`.
- **Hardening:** Manteve-se o construtor institucional normal sem parâmetros sintéticos e anotou-se explicitamente com `@Autowired` o construtor completo com `@Autowired(required = false) SyntheticDataService`. Anotações redundantes em nível de campo foram completamente expurgadas.

---

## 4. Política de Segredos e Não Rastreabilidade

1. **Credenciais Anteriores Rotacionadas:**
   As credenciais efêmeras e o `JWT secret` utilizados na sessão de smoke anterior foram considerados formalmente comprometidos/expirados e não são reutilizados em nenhuma sessão futura.
2. **Runtime Local Seguro:**
   Quando a execução exigir runtime com credenciais efêmeras, estas serão geradas programmaticamente fora da árvore do repositório em `%TEMP%\mppb-q14-uat-secrets.json` com ACL restrita ao usuário do SO, sem qualquer `Write-Host` ou eco de valores em logs/transcripts.
3. **Zero Segredos Versionados:**
   Nenhum segredo operacional está versionado no repositório. O arquivo `application.yml` possui apenas referências a variáveis de ambiente com defaults vazios.
4. **Fixture de Teste Automatizado:**
   Valores embutidos na suíte de testes (`Q14UsuariosSinteticosUatReviewTest.java`) são claramente fixtures sintéticas para teste de unidade e sem qualquer aplicação em ambientes reais.

---

## 5. Token Sintético e Limitação de Replay

- **Especificação:** HMAC-SHA256, TTL de 8 horas, claims validados (`sub`, `identificador`, `origem`, `perfil`, `matricula`, `iat`, `exp`, `jti`).
- **Identificador Único (`jti`):** O claim `jti` contém UUID aleatório gerado no momento da emissão, permitindo identificar unicamente cada token emitido para fins de auditoria.
- **Limitação de Replay Documentada:** O mecanismo sintético opera sem estado (stateless) para validação de token e não mantém blacklist/tabela de `jti` consumidos em banco. Portanto, o `jti` **identifica unicamente o token**, mas **não impede replay** de um token válido interceptado durante sua janela de validade (TTL de 8h). Esse comportamento é inerente à arquitetura stateless de teste e é formalmente aceito para o ambiente UAT.

---

## 6. Coerência dos Datasets e Marcação de Documentos

- **Coerência de Rótulos (Dashboard × Perfil):**
  - Dashboard: Exibe `carteira.cargo` (cargo genérico da carreira: "Promotor de Justiça" / "Analista Ministerial").
  - Perfil: Exibe prioritariamente `perfil.tituloCargo` (posição/especialidade funcional detalhada: "Promotor de Justiça Substituto" / "Analista Ministerial - TI").
  - Essa divergência é **INTENCIONAL** e reflete exatamente o comportamento dos sistemas reais de produção do MPPB.
- **Documentos Sintéticos:**
  - PDFs de contracheque e relatórios exibem marcação visual mandatória: `DADOS SINTÉTICOS — UAT SEM VALOR FUNCIONAL`.
  - QRs e hashes utilizam URLs isoladas de sandbox (`https://homologacao.mppb.mp.br/valida-carteira/...`), sem consulta a bases institucionais reais.

---

## 7. Status Final e Próximos Passos

### UAT Interno:
```text
UAT INTERNO:
PRONTO PARA EXECUÇÃO COMPLETA Q14-U09 A Q14-U18
```
A infraestrutura backend de usuários sintéticos e a parametrização Flutter encontram-se 100% endurecidas, isoladas e cobertas por 30 testes automatizados específicos e 199 testes de regressão com zero falhas.

### Store Review (Google Play / Apple App Store):
```text
GOOGLE/APPLE STORE REVIEW:
NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001
```
A feature permanece bloqueada em perfil de produção por regra inviolável de segurança (`ValidadorConfiguracaoSegura`). Qualquer decisão para Store Review será tratada em rodada apropriada pós-UAT.
