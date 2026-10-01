# Matriz de Rastreabilidade Integrada — Q1 a Q10

Data: 01/10/2026  
Escopo: Qualidade, Confiabilidade e Prontidão do App MPPB  
Fase Corrente: **Q10 — Instalação, Atualização e Migração**

---

## 1. Rastreabilidade Vertical Entre Fases

A tabela abaixo conecta os achados e garantias consolidados desde a fase de contratos (Q3) até a validação de ciclo de vida e migração (Q10).

| Fase | Domínio Principal | Garantia Consolidada | Conexão com Q10 (Instalação / Atualização / Migração) |
|---|---|---|---|
| **Q3** | Contratos e DTOs | Modelos de dados serializados/deserializados com esquemas validados | A integridade dos DTOs de `UsuarioCarteira`, `PerfilUsuario` e `Noticia` assegura que os objetos em cache JSON não sofram quebra de schema ao serem deserializados após uma atualização de versão do app. |
| **Q4** | Integração | Comunicação cliente-servidor com tratamento de erros HTTP e status codes | Na primeira instalação limpa (Q10-T01) e após clear data (Q10-T08), as chamadas iniciais de notícias e serviços públicos operam sobre o endpoint homolog com integração resiliente. |
| **Q5** | E2E e Jornadas | Fluxos completos de navegação pública e autenticada | A Home pública e as telas de serviços ao cidadão foram verificadas funcionando perfeitamente tanto no first-run quanto imediatamente após o in-place upgrade. |
| **Q6** | Integridade e Concorrência | Expurgo de credenciais legadas em plain text e proteção contra concorrência | A rotina `_migrarSenhaBiometricaLegada` e a higienização de cache ao alternar usuários operam diretamente na proteção contra dados órfãos ou corrupção durante upgrades. |
| **Q7** | Rede, Offline e Interrupções | Caches offline resilientes e fallbacks quando sem rede | O cache offline seguro (`carteira_cache_data`, `perfil_cache_data`) gravado em versões anteriores permanece legível após atualização; erros de deserialização caem graciosamente no fallback offline sem crash. |
| **Q8** | Performance e Carga | Tempos de inicialização (cold/warm start), consumo de CPU e memória | O cold start após instalação limpa (5989ms) e após upgrade (8616ms no primeiro boot de dexopt/compilação AOT, estabilizando para warm start instantâneo) foi aferido no hardware físico Galaxy A52. |
| **Q9** | Compatibilidade | Suporte a arquiteturas (arm64-v8a) e versões de SO (Android 14) | A compatibilidade do binário Flutter gerado foi comprovada diretamente no runtime real do Android 14 (API 34), confirmando o empacotamento multi-ABI funcional. |
| **Q10** | Instalação, Atualização e Migração | Validação empírica de clean install, in-place upgrade (+69 → +72), downgrade rejection, clear data e persistência | Comprova que o ciclo de distribuição e atualização de versão no ecossistema Android preserva a identidade do aplicativo, seus dados criptografados e a experiência do usuário. |

---

## 2. Rastreabilidade de Artefatos Locais e Mecanismos de Persistência

| Store / Componente | Cenário de Validação Q10 | Validação Relacionada | Status Q10 |
|---|---|---|---|
| `FlutterSecureStorage` | Q10-T01, Q10-T02, Q10-T03, Q10-T04, Q10-T05 | Q6 (sanitização de senha) / Q7 (cache offline) | **PASSOU (T01/T02/T04) / PARCIAL (T03 valores, T05 payload)** |
| `DeviceRegistrationStore` (FCM) | Q10-T01, Q10-T02, Q10-T15 | Q4 (integração de push) | **PASSOU (T01/T02) / PARCIAL (T15 valor)** |
| `FlutterCacheManager` / Imagens | Q10-T01, Q10-T02, Q10-T03 | Q7 (cache de rede) | **PASSOU** |
| In-memory PDF / Printing | Q10-T14 | Q5 (visualização de relatórios/diário) | **PASSOU** |
| Sandbox Isolation (Flavors) | Q10-T09 | Q9 (compatibilidade e distribuição) | **PASSOU** |
| Android Package Manager Policy | Q10-T06 | Segurança de distribuição Android | **PASSOU** |
| Keystore Signing Pipeline | Q10-T10, Q10-T11 | Pipeline CI/CD e distribuição segura | **PASSOU (T10) / PARCIAL (T11 AAB)** |
