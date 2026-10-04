# Q14 — Evidências de Execução: Escopo Autenticado (10 Jornadas Q14-U09 a Q14-U18)

**Data da Auditoria e Execução:** 04/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final (Execução Q14-R04)  
**Dispositivo Físico:** Samsung Galaxy A52 (`SM-A525M`, Android 14 / One UI 6.1, API 34, Serial `RX8RC09H70X`)  
**Pacote Avaliado:** `br.mp.mppbapp.app.homolog` (v4.0.0+72, APK SHA-256: `B23096118DFD80E3FC8A687B94B994B8622130E33485A786D0A3BFF674971FA7`)  
**Backend:** Spring Boot `mobile-service-0.3.25.jar` em porta 9003 com `UAT_SYNTHETIC_USERS_ENABLED=true` conectado via ADB Reverse `tcp:9003 tcp:9003`  
**Executor:** `TÉCNICO` (Avaliação objetiva de pré-requisito técnico; não substitui o Aceite Humano Institucional)

---

## 1. Princípio de Execução Técnica com Massa Sintética Homologada

Em conformidade com a arquitetura definida em `qualidade/uat/Q14-usuarios-sinteticos-arquitetura.md` e `qualidade/uat/Q14-datasets-sinteticos.md`:
1. **Ambiente Isolado e Controlado:** A execução foi realizada com credenciais sintéticas criptograficamente geradas em tempo de execução (`uat.membro` e `uat.servidor`), com validação ponta a ponta no dispositivo físico Samsung Galaxy A52.
2. **Segurança e Sigilo:** Nenhuma senha ou segredo JWT foi exposto em console, logs ou arquivos versionados. Todas as credenciais temporárias foram expurgadas após o teste.
3. **Marca d'Água Obrigatória:** Todos os artefatos visuais e documentos PDF gerados durante o teste autenticado contêm marcas d'água explícitas de dados sintéticos sem valor funcional.
4. **Isolamento de Perfis (Cross-Isolation):** O perfil `uat.servidor` não possui acesso aos dados, requerimentos ou histórico do perfil `uat.membro`, e vice-versa.

---

## 2. Matriz Consolidada de Execução Autenticada (Q14-U09 a Q14-U18)

| ID Cenário | Jornada Correspondente | Perfil Testado | Evidências Coletadas | Resultado Técnico | Ressalvas / Observações |
|---|---|---|---|---|---|
| **Q14-U09** | Q14-J09 — Acesso Restrito / Autenticação Institucional | Membro / Servidor | `q14-uat-login-invalido.png`<br>`q14-uat-membro-dashboard.png`<br>`q14-uat-servidor-dashboard.png` | **APROVADO** | Credencial inválida rejeitada com HTTP 401 e alerta orientativo; logins de Membro (`uat.membro`) e Servidor (`uat.servidor`) autorizados com sucesso, emissão de JWT e transição fluida para dashboards respectivos. |
| **Q14-U10** | Q14-J10 — Home Autenticada, Dashboard Restrito e Logout | Membro / Servidor | `q14-uat-sessao-persistencia.png`<br>`q14-uat-membro-dashboard.png`<br>`q14-uat-logout-home.png` | **APROVADO** | Persistência de token segura validada (force-stop via ADB e reinicialização imediata com restauração transparente de sessão); logout executado com limpeza de sessão e retorno à Home pública desautenticada. |
| **Q14-U11** | Q14-J11 — Consulta e Visualização do Perfil Funcional | Membro / Servidor | `q14-uat-membro-perfil.png`<br>`q14-uat-membro-perfil-detalhes.png`<br>`q14-uat-servidor-perfil.png` | **APROVADO** | Dados cadastrais carregados com sucesso: Membro (Lucas Almeida Monteiro, Promotor Substituto, mat. 900001) e Servidora (Mariana Costa Ribeiro, Analista Ministerial - TI, mat. 900002). |
| **Q14-U12** | Q14-J12 — Visualização da Carteira Funcional Digital | Membro / Servidor | `q14-uat-carteira-membro.png`<br>`q14-uat-carteira-membro-verso.png`<br>`q14-uat-carteira-servidor.png` | **APROVADO** | Carteira renderizada nos layouts oficiais: Vermelha (Membro) com brasão e monograma LM; Bege/Dourada (Servidor); verso auditado com marca d'água obrigatória `DADOS SINTÉTICOS — UAT SEM VALOR FUNCIONAL`. |
| **Q14-U13** | Q14-J13 — Consulta de Contracheques e Exportação PDF | Membro / Servidor | `q14-uat-contracheque.png`<br>`q14-uat-contracheque-valores.png`<br>`q14-uat-contracheque-pdf.png`<br>`q14-uat-contracheque-servidor.png` | **APROVADO** | Competências listadas (09/2026 a 06/2026); detalhamento de proventos e descontos; alternador de privacidade (olho); PDF gerado com marca d'água `UAT-SYNTH-202609-SEM-VALOR-FUNCIONAL`. |
| **Q14-U14** | Q14-J14 — Consulta de Informações de Pagamentos | Membro / Servidor | `q14-uat-pagamentos.png`<br>`q14-uat-pagamentos-2025.png`<br>`q14-uat-pagamentos-servidor.png`<br>`q14-uat-pagamentos-vazio.png` | **APROVADO** | Exercícios 2026 e 2025 consultados; listagem de parcelas e detalhamento financeiro; comportamento com exercício sem pagamentos validado com estado vazio informativo. |
| **Q14-U15** | Q14-J15 — Consulta de Designações Funcionais Ativas | Membro / Servidor | `q14-uat-designacoes-membro.png`<br>`q14-uat-designacoes-vazio.png` | **APROVADO** | Membro com designação ativa (Portaria PGJ nº 101/2025, Promotoria de Justiça de Cabedelo); Servidora sem designações com estado vazio amigável ("Nenhuma designação ativa encontrada"). |
| **Q14-U16** | Q14-J16 — Consulta de Concessões de Folga e Ausências | Membro / Servidor | `q14-uat-concessoes-baseline.png`<br>`q14-uat-concessoes-saldos.png`<br>`q14-uat-concessoes-servidor.png` | **APROVADO** | Calendário de ausências Outubro/2026; saldos de Férias e Folgas apurados corretamente para Membro (15 dias disp.) e Servidora (30 dias disp., 1º período/2025). |
| **Q14-U17** | Q14-J17 — Operações de Solicitação de Concessões/Folgas | Membro / Servidor | `q14-uat-concessoes-solicitada.png`<br>`q14-uat-concessoes-detalhes-cancelada.png` | **APROVADO** | Ciclo completo de negócio: seleção de data inicial (05/10/2026), cálculo de sugestões finais (19/10/2026, 15 dias), submissão com sucesso e cancelamento com atualização para 'Cancelada'. Isolamento de leitura e operação entre datasets comprovado (tentativa cruzada rejeitada com HTTP 403 e integridade mantida). |
| **Q14-U18** | Q14-J18 — Diagnóstico e Registro de Notificações Push (FCM) | Membro / Servidor | Log de auditoria backend (`mobile-service`) | **APROVADO COM RESSALVA** | registro e desativação FCM validados em sandbox; entrega de push real não aferida. |

---

## 3. Inventário Criptográfico de Evidências Coletadas no Samsung Galaxy A52

Todas as capturas de tela foram extraídas diretamente do dispositivo `RX8RC09H70X` conectado via ADB e estão armazenadas em `app_mppb_flutter/qualidade/evidencias/Q14/android/`:

| Arquivo de Evidência | Tamanho (Bytes) | SHA-256 Checksum |
|---|---|---|
| `q14-uat-login-invalido.png` | 137.826 | `F87D1E3F5B145A80C432B561EF59B6339490B89C33627DABACF9D7304A39F940` |
| `q14-uat-membro-dashboard.png` | 314.365 | `883FB97AA1400E6B32691EE0DAC2870FA4F1B406103DD72A8449BFEE1858C88B` |
| `q14-uat-sessao-persistencia.png` | 311.654 | `F11B9BD080CA6BB14F7A2C53D417636E74D23D70A74A789D4BDD3A4269528AC2` |
| `q14-uat-logout-home.png` | 478.080 | `665947447B339F3D31562A72A2EB731E1A7F4BCD5484389A1A18DE1F8D28E02A` |
| `q14-uat-membro-perfil.png` | 258.522 | `777D236022601E8E0283306189FE37316AB82E7A1235DC7D07963DABDC9EF2CB` |
| `q14-uat-membro-perfil-detalhes.png` | 268.658 | `548F85CEB29873B82CE1EF59E98D81BF16C7C14BE6EE5BF91D139B875760D7D8` |
| `q14-uat-carteira-membro.png` | 619.690 | `8A2F833F80FBC59CE605671B251EDCB3F139AEC02F20799A8BE3A1DDECC00998` |
| `q14-uat-carteira-membro-verso.png` | 676.955 | `650A14A2AA991D3A831A89DA15A7A17243517C6A29B216D6DDC455D7AF888C05` |
| `q14-uat-contracheque.png` | 400.460 | `BDF592B833C82E64D469C5A4C446F1DE847938D614704531824814FEAD6207C4` |
| `q14-uat-contracheque-valores.png` | 386.712 | `197A237AB8EE4247483B1A270E3070DE8B7D7A8CDBAC28D6E511B4E5D71736DB` |
| `q14-uat-contracheque-pdf.png` | 264.593 | `56D350E56E80D4D46BEE71F9138BE4B03119BAD5B1A7B1786058DC2A31BC263E` |
| `q14-uat-pagamentos.png` | 406.715 | `4923E9D4E00BBB54AF7836793DABEA1372A88062DB5C1E9E2D4BD33C00781481` |
| `q14-uat-pagamentos-2025.png` | 352.052 | `ADF37446158326515B06DA9EE21DB567433DF12267025EC4520623C1B4C658AC` |
| `q14-uat-pagamentos-vazio.png` | 350.293 | `F2D3264FA0D50D6C70C728443DBF6DE3B868C2C626766716C1E1FC187B8FCCCE` |
| `q14-uat-designacoes-membro.png` | 180.052 | `339A47F28806B50087256531C361E0D7D24556E86B1BA2A82F2B4E53529D851A` |
| `q14-uat-concessoes-baseline.png` | 289.334 | `D73D705CC0C026326D1AF9BB37A86ACA469AD3F61AD249EB2FCBE8E4247E57D5` |
| `q14-uat-concessoes-saldos.png` | 289.520 | `AA14D4275AFD4B574D6E30CFC54767D25F686BA87DECB304782848855DEAA148` |
| `q14-uat-concessoes-solicitada.png` | 277.061 | `D7D05C89FCF6C3A8D01A724E23D9F5DBB67F8C50E249AD68F205D0F6A573B1A0` |
| `q14-uat-concessoes-detalhes-cancelada.png` | 293.110 | `B583830A6226385D5DF873EE2D8CD057A15B3A3EF4C5299CDA68D4EAC747CDA2` |
| `q14-uat-servidor-dashboard.png` | 292.801 | `84AC14A0DB40B0D632254A098F786273871382E0216B819736755634A8104165` |
| `q14-uat-servidor-perfil.png` | 259.512 | `D329DB0F2BE72A34CAEF13B9F89804CCEEFDD94A5D93064C988E4CC6E736EDBA` |
| `q14-uat-carteira-servidor.png` | 573.535 | `E4BA49196DE38DC16A1A8E2E65C9CB05CFB9053F5A101951C7C099ED472E07DF` |
| `q14-uat-contracheque-servidor.png` | 404.003 | `9D7A4A96F00E063213BB9750CC4014A6CC4493110AD78D9F0BCDEE1F74C58C42` |
| `q14-uat-pagamentos-servidor.png` | 399.324 | `35FA258EE5165C29F8CBDF043FEF4228ED9F9B6E82F74E36370D8CEC0A6F4344` |
| `q14-uat-designacoes-vazio.png` | 133.275 | `EC002AB9BB0612D630A740B36BAFC72A44E34511193D54DD1083D89095C0FCC1` |
| `q14-uat-concessoes-servidor.png` | 211.178 | `3B25A357E9BC3AB4653F7A5F7E903932737A77DC2B2DCA57109F0D2C52F454DB` |

Total de capturas autenticadas: **26 arquivos únicos** (sem duplicações).

---

## 4. Correções de Robustez Operacional Efetuadas Durante o Pré-UAT (BUG-Q14)

1. **BUG-Q14-001 — Incompatibilidade de Formato de Data nas Sugestões de Término de Concessões:**
   - *Sintoma:* Ao selecionar a data de início da concessão (`05/10/2026`), a chamada para `/api/concessoes/sugestoes-datas-finais` resultava em falha de parsing de data no backend.
   - *Correção:* Ajustada a desserialização e manipulação de datas no `ConcessaoFolgaService` / `SyntheticSandboxStorage` para tolerar formato ISO-8601 estrito (`yyyy-MM-dd`), formato local com timestamp (`yyyy-MM-dd'T'HH:mm:ss.SSS`) e fallback gracioso sem retorno de HTTP 500, retornando 200 OK com as opções sugeridas.
2. **BUG-Q14-002 — Tratamento de Registro de Token Push FCM em Modo Sintético:**
   - *Sintoma:* Chamada para registrar token FCM com credencial sintética tentava persistência em tabela de dispositivos sem vínculo prévio, gerando erro de chave estrangeira.
3. **BUG-Q14-003 — Falha de Estado Pós-Dispose em OuvidoriaNotifier (`Ref._throwIfInvalidUsage`):**
   - *Sintoma:* Disparo assíncrono não cancelado em `_initCombos()` tentava mutação de `state` após o descarte do container de injeção em testes de regressão automatizada.
   - *Correção:* Inseridas guardas `if (!ref.mounted) return;` em `_initCombos` e demais métodos assíncronos de `OuvidoriaNotifier`, protegendo o ciclo de vida contra erros pós-descarte.
4. **Validação de Autorização por Objeto e Isolamento de Operação (Q14-U17):**
   - *Cenário:* Membro (`uat.membro`) cria solicitação de concessão; Servidor (`uat.servidor`) tenta cancelar/adiar a solicitação pelo ID.
   - *Resultado:* Servidor recebe HTTP 403 Forbidden e o estado da solicitação original permanece rigorosamente inalterado. Isolamento de leitura e operação entre datasets comprovado.

---

## 5. Delimitação Metodológica Estrita

- **Classificação:** O executor foi exclusivamente **TÉCNICO**.
- **Avaliação Humana:** **NÃO EXECUTADA**.
- **Aceite Humano:** **PENDENTE**, devendo ser aplicado com usuários reais do órgão com base em `qualidade/uat/Q14-roteiro-avaliador.md` e formalizado em `qualidade/uat/Q14-termo-aceite.md`.
- **Store Review:** **NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001**
  - contas REVIEW ainda não provisionadas operacionalmente;
  - backend externo acessível aos revisores ainda não definido/implantado;
  - modo sintético permanece bloqueado em produção;
  - estratégia de Store Review será definida após o aceite institucional.
  Não enfraquecer a proteção de produção.
- **Status Canônico da Fase:** **Q14 NÃO CONCLUÍDA — PRÉ-UAT TÉCNICO PÚBLICO E AUTENTICADO CONSOLIDADO COM RESSALVAS, ACEITE HUMANO PENDENTE**.
