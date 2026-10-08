# Especificação Técnica de Contrato e Roteamento Gateway — Store Review Isolado (R02)

Data de Emissão: 06/10/2026  
Status do Ciclo: **Q14 CONCLUÍDA** | **CICLO Q1–Q14 CONCLUÍDO**  
Status do Store Review: **NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001** (Etapa R02 concluída; infraestrutura e credenciais externas pendentes para R03/R04)

---

## 1. Contexto e Motivação Arquitetural

Para aprovação do aplicativo do MPPB nas lojas Google Play Store e Apple App Store sem expor dados reais de membros e servidores a revisores externos, foi adotada a seguinte arquitetura:

```text
REVIEWER (Google Play / Apple App Store)
    │
    ▼
App normal de produção (Flutter master: 0ad8acd)
    │  AUTH_BASE_URL: https://auth-api.mppb.mp.br
    │  API_URL:       https://aplicativo-api.mppb.mp.br
    ▼
GATEWAY / REVERSE PROXY INSTITUCIONAL (Roteamento Server-Side Seguro)
    ├─────────────────────────────────────────┬─────────────────────────────────────────┐
    │ Se Token / Login for de Store Review   │ Se Token / Login for Institucional      │
    ▼                                         ▼                                         ▼
Backend REVIEW Isolado                   Backend Produção Real                     Token Inválido / Desconhecido
(SPRING_PROFILES_ACTIVE=review)          (SPRING_PROFILES_ACTIVE=prod)             HTTP 401 / 403 Rejeitado
- Dataset Sintético Dedicado             - Dados Funcionais Reais
- Sandbox em Memória                     - Zero Acesso Sintético
- Zero chamadas a AuthServiceClient
```

Esta rodada (**STORE-REVIEW-R02**) implementou e validou localmente o contrato seguro de token e autenticação, preparando as definições exatas para a atuação do Gateway.

---

## 2. Princípio Fundamental de Isolamento de Processos

1. **Separação Rígida de Profiles:**
   - O processo de produção (`prod`, `production`, `prd`) **recusa terminantemente o startup** se:
     - `uat.synthetic-users.enabled=true`
     - `review.enabled=true`
     - Profile contiver `review` junto com `prod`
   - Essa regra é assegurada pelo componente `ValidadorConfiguracaoSegura.java` via `IllegalStateException` fail-fast incondicional.

2. **Processo Exclusivo de Review:**
   - O ambiente Review opera em processo separado com `SPRING_PROFILES_ACTIVE=review`.
   - É proibida a combinação híbrida como `prod,review`.

---

## 3. Identidades Review Permitidas (Allowlist Exata)

Apenas as quatro seguintes identidades são admitidas no ambiente de Store Review:

| Login Exato | Origem | Perfil Funcional | Matrícula Sintética | Dataset Vinculado |
| :--- | :--- | :--- | :--- | :--- |
| `review.google.membro` | `GOOGLE_REVIEW` | `MEMBRO` | `900001` | `DATASET_MEMBRO` (Dr. Lucas Almeida Monteiro) |
| `review.google.servidor` | `GOOGLE_REVIEW` | `SERVIDOR` | `900002` | `DATASET_SERVIDOR` (Sra. Mariana Costa Ribeiro) |
| `review.apple.membro` | `APPLE_REVIEW` | `MEMBRO` | `900001` | `DATASET_MEMBRO` (Dr. Lucas Almeida Monteiro) |
| `review.apple.servidor` | `APPLE_REVIEW` | `SERVIDOR` | `900002` | `DATASET_SERVIDOR` (Sra. Mariana Costa Ribeiro) |

**Regras Estritas de Bloqueio:**
- Rejeição absoluta de wildcard matching: `review.*`, `review.google.*`, `review.apple.*` são terminantemente rejeitados (401).
- Usuários do ambiente UAT interno (`uat.membro`, `uat.servidor`) retornam **401 Unauthorized** no ambiente Review.
- Usuários institucionais reais retornam **401 Unauthorized** no ambiente Review.
- `AuthServiceClient` tem **ZERO** interações no ambiente Review.

---

## 4. Contrato do Token Store Review

### 4.1. Estrutura do Token
O token de Store Review adota estrutura JWT assinada com chave secreta dedicada:

```text
REVIEW-SYNTH.<base64url(header)>.<base64url(payload)>.<signature>
```

### 4.2. Header
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### 4.3. Payload (Claims Server-Side Obrigatórios)
Todos os claims são gerados server-side pelo backend Review após validação da senha. Nenhum claim enviado pelo cliente é considerado confiável.

| Claim | Valor Conceitual | Descrição |
| :--- | :--- | :--- |
| `iss` | `mppb-store-review` | Emissor exclusivo do token de Review |
| `aud` | `mppb-mobile-review` | Audiência exclusiva para o app móvel em modo Review |
| `sub` | `review.google.membro` (...) | Identidade Review exata autenticada |
| `origin` / `origem` | `GOOGLE_REVIEW` ou `APPLE_REVIEW` | Origem da plataforma avaliadora |
| `profile` / `perfil` | `MEMBRO` ou `SERVIDOR` | Perfil funcional |
| `matricula` | `900001` ou `900002` | Matrícula sintética mapeada |
| `identificador` | `900001` ou `900002` | Identificador numérico funcional |
| `jti` | `<UUID v4>` | Identificador único do token para auditoria e rastreio |
| `iat` | `<timestamp epoch>` | Momento da emissão |
| `exp` | `<timestamp epoch>` | Expiração controlada (TTL curto, padrão 7200s) |

### 4.4. Assinatura e Chave Criptográfica
- **Algoritmo:** HMAC-SHA256 (`HmacSHA256`).
- **Segredo:** Injetado via variável de ambiente `STORE_REVIEW_JWT_SECRET` (`review.jwt-secret`).
- **Restrições:**
  - Segredo deve ser único e exclusivo do ambiente Review.
  - Deve ser obrigatoriamente diferente do segredo de UAT (`uat.synthetic-users.jwt-secret`).
  - Segredo vazio gera **FAIL-FAST** imediato na inicialização.
  - Segredos e tokens completos nunca são impressos em logs de execução.

---

## 5. Especificação do Roteamento no Gateway (Reverse Proxy)

### 5.1. Mecanismo de Identificação de Tráfego

Para que o Gateway diferencie o tráfego institucional do tráfego de Store Review sem alterar o aplicativo Flutter de produção:

1. **Critérios Válidos (Server-Side Only):**
   - **Assinatura Criptográfica:** Verificação da assinatura HMAC-SHA256 com a chave pública/secreta de Store Review.
   - **Claims Críticos:** `iss == "mppb-store-review"` e `aud == "mppb-mobile-review"`.
   - **Prefixo do Token:** `REVIEW-SYNTH.` identifica o namespace sintético de Review.

2. **Mecanismos Proibidos (Anti-patterns rejeitados):**
   - `X-Review` ou qualquer header customizado enviado pelo app Flutter.
   - Parâmetros em query string (`?review=true` ou `?user=...`).
   - Flags embutidas no binário Flutter.
   - User-Agent do dispositivo.
   - Geolocalização ou IP de origem do reviewer.

### 5.2. Tabela de Decisão do Gateway

| Ponto de Entrada | Condição Inspecionada | Ação do Gateway | Destino |
| :--- | :--- | :--- | :--- |
| `POST /acesso/autoriza` | Payload JSON contém login na allowlist exata (`review.google.*`, `review.apple.*`) | Roteia requisição de login para backend Review | `https://backend-review.interno/acesso/autoriza` |
| `POST /acesso/autoriza` | Payload JSON contém login institucional ou qualquer outro | Roteia requisição para Auth API Institucional | `https://auth-api.mppb.mp.br/acesso/autoriza` |
| `ANY /*` (com Bearer Token) | Header `Authorization: Bearer REVIEW-SYNTH...` com assinatura e claims `iss/aud` válidos de Review | Roteia para Backend Review | `https://backend-review.interno/*` |
| `ANY /*` (com Bearer Token) | Header `Authorization: Bearer <Token Institucional>` emitido pela autoridade corporativa | Roteia para Backend Institucional de Produção | `https://aplicativo-api.mppb.mp.br/*` |
| `ANY /*` | Token corrompido, assinatura inválida, expirado ou não reconhecido | Rejeita diretamente no Gateway com HTTP 401 Unauthorized | N/A |

---

## 6. Mecanismos de Revogação e Expiração Temporal

1. **Desativação Centralizada (`review.enabled`):**
   - Configurado via `STORE_REVIEW_ENABLED=false` em tempo de execução/variável de ambiente.
   - Ao ser desativado, o backend Review e o autenticador rejeitam todas as quatro identidades imediatamente com HTTP 401 controlado, sem requerer novo build ou recompilação.

2. **Expiração por Data Limite (`review.valid-until`):**
   - Configurado via `STORE_REVIEW_VALID_UNTIL=YYYY-MM-DDTHH:mm:ss` (ex.: `2026-12-31T23:59:59`).
   - Caso a data/hora atual ultrapasse o valor configurado, qualquer tentativa de autenticação Review é automaticamente recusada com 401 controlado.

---

## 7. Módulos e Sandbox de Operações Mutáveis

No backend Review isolado:
- **Perfil:** Retorna dados cadastrais do perfil sintético correspondente (Lucas Almeida ou Mariana Costa).
- **Carteira Funcional:** Retorna espelho funcional sintético com tarja e dados fictícios.
- **Contracheque & Pagamentos:** Competências de 2025/2026 com valores estáticos e comprovante de validação sintético.
- **Designações:** Retorna portaria sintética apenas para o perfil de Membro; lista vazia para Servidor.
- **Concessões/Folgas (Operações Mutáveis):** Gerenciadas exclusivamente em memória através do `SyntheticSandboxStorage`. Nenhuma escrita atinge banco funcional, MPVirtual ou RH real.
- **Notificações Push / FCM:** Operação em modo sandbox neutro, com zero acionamento de serviços reais do Google Firebase.

---

## 8. Conformidade de Testes e Gates da Rodada R02

- **Suíte restapi-common:** 11/11 testes aprovados (0 falhas, 0 erros, 0 pulados).
- **Suíte mobile-service:** 200/200 testes aprovados (0 falhas, 0 erros, 0 pulados).
- **Total Geral Backend:** **211/211 testes aprovados** (Baseline anterior Q14 = 202).
- **Classe de Testes Dedicada:** `StoreReviewIsoladoTest.java` (20 cenários cobrindo todos os requisitos contratuais).
- **Status do Build/Package:** `BUILD SUCCESS` (JAR `mobile-service-0.3.25.jar` gerado com sucesso).
- **Verificação de Segredos:** Zero senhas ou chaves expostas ou versionadas. Segredos com defaults vazios obrigatórios via fail-fast.
- **Flutter Repo:** Zero alterações de código (`git diff lib test` = 0). Preservação da versão 4.0.0+72 de Q14.
