# STORE-REVIEW-R02 — Configuração Operacional no Portainer

## 1. Visão Geral

A infraestrutura de backend para Store Review opera de forma 100% isolada e sua parametrização é realizada **exclusivamente por variáveis de ambiente** configuradas no Portainer (ou compose/orquestrador de contêineres).

Não é permitida nem orientada a passagem de segredos ou senhas via argumentos de linha de comando Java (`-D`).

---

## 2. Variáveis de Ambiente Oficiais (Portainer)

As seguintes variáveis de ambiente devem ser configuradas na definição do container ou stack no Portainer:

| Variável | Obrigatoriedade | Descrição |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | Obrigatória | Deve conter o perfil `review`. Proibido combinar com `prod`, `production` ou `prd`. |
| `STORE_REVIEW_ENABLED` | Obrigatória | Habilita a infraestrutura de Store Review (`true`). |
| `STORE_REVIEW_JWT_SECRET` | Obrigatória | Segredo HMAC-SHA256 para assinatura dos tokens das personas de revisão. Não possui fallback. |
| `GOOGLE_REVIEW_MEMBER_PASSWORD` | Obrigatória | Senha para a persona `review.google.membro`. Não possui valor default. |
| `GOOGLE_REVIEW_SERVER_PASSWORD` | Obrigatória | Senha para a persona `review.google.servidor`. Não possui valor default. |
| `APPLE_REVIEW_MEMBER_PASSWORD` | Obrigatória | Senha para a persona `review.apple.membro`. Não possui valor default. |
| `APPLE_REVIEW_SERVER_PASSWORD` | Obrigatória | Senha para a persona `review.apple.servidor`. Não possui valor default. |
| `STORE_REVIEW_VALID_UNTIL` | Opcional | Data limite para validade das credenciais de revisão. Se vazia, não expira por calendário. |

### Exemplo de Configuração de Ambiente (Environment / Portainer)

> **ATENÇÃO:** NUNCA inserir segredos ou senhas reais no código-fonte ou controle de versão. Os valores devem ser definidos diretamente na interface ou secrets do Portainer.

```env
SPRING_PROFILES_ACTIVE=review
STORE_REVIEW_ENABLED=true

STORE_REVIEW_JWT_SECRET=<CONFIGURAR_NO_PORTAINER>
GOOGLE_REVIEW_MEMBER_PASSWORD=<CONFIGURAR_NO_PORTAINER>
GOOGLE_REVIEW_SERVER_PASSWORD=<CONFIGURAR_NO_PORTAINER>
APPLE_REVIEW_MEMBER_PASSWORD=<CONFIGURAR_NO_PORTAINER>
APPLE_REVIEW_SERVER_PASSWORD=<CONFIGURAR_NO_PORTAINER>

# Opcional (deixar vazio ou omitir para vigência indeterminada durante a submissão)
STORE_REVIEW_VALID_UNTIL=
```

---

## 3. Ciclo de Vida das Senhas e Resiliência a Restart

1. **Estabilidade durante a submissão:**
   - As senhas das 4 personas Store Review são **estáveis** ao longo de todo o ciclo de avaliação de uma submissão nas lojas Google Play e Apple App Store.
   - As senhas **não são geradas dinamicamente** a cada inicialização/restart do container.
2. **Reinício de Contêineres:**
   - Um restart do container (por atualização de imagem, reinício do daemon Docker ou do nó do Portainer) reutiliza imediatamente as variáveis de ambiente já salvas no Portainer.
   - Google e Apple continuam conseguindo se autenticar perfeitamente após qualquer reinício do container sem perda de estado ou necessidade de reconfiguração.
3. **Pós-aprovação / Desativação:**
   - Após a aprovação e publicação do aplicativo nas lojas, a funcionalidade de Store Review pode ser desativada no Portainer alterando `STORE_REVIEW_ENABLED=false` ou removendo o perfil `review`.
4. **Rotação de Senhas:**
   - Antes de uma nova submissão com novo ciclo de revisão, as senhas podem ser rotacionadas manualmente atualizando os valores das variáveis no Portainer.

---

## 4. Janela de Validade (`STORE_REVIEW_VALID_UNTIL`)

- **Formato canônico suportado:**
  - Data curta: `yyyy-MM-dd` (exemplo: `2026-12-31`), interpretada como o final do dia UTC (`2026-12-31T23:59:59Z`).
  - Instant ISO-8601 completo: `yyyy-MM-ddTHH:mm:ssZ` (exemplo: `2026-12-31T23:59:59Z`).
- **Comportamento quando VAZIO ou omitido:**
  - Comportamento padrão: as credenciais permanecem válidas enquanto `STORE_REVIEW_ENABLED=true`, sem bloqueio temporal programado.
- **Comportamento quando preenchido:**
  - Caso o relógio do sistema ultrapasse a data/hora configurada, qualquer tentativa de login para identidades Store Review é imediatamente recusada com a justificativa de auditoria `STORE_REVIEW_EXPIRADO`.
  - Caso o formato fornecido seja inválido, o startup/login bloqueia o acesso por princípio do menor privilégio.

---

## 5. Fail-Fast e Segurança

- Se `STORE_REVIEW_ENABLED=true` (ou profile `review` ativo) e qualquer uma das variáveis obrigatórias (`STORE_REVIEW_JWT_SECRET` ou qualquer uma das 4 senhas) estiver ausente ou em branco, o backend recusa a inicialização imediatamente no startup (`ValidadorConfiguracaoSegura`).
- Não existem senhas default nem segredos de fallback hardcoded.
- Combinações com perfis de produção (`prod`, `production`, `prd`) causam interrupção imediata da inicialização da aplicação (`STARTUP RECUSADO`).
