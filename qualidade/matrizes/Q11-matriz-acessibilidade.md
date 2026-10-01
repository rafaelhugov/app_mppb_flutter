# Matriz de Acessibilidade — Q11

Data: 01/10/2026 (Reconciliado Q11-R01)  
Status Global: VALIDADO NO ESCOPO TESTADO

---

| ID | Critério | Tela | Método | Resultado | Status |
|---|---|---|---|---|---|
| Q11-C01 | Semântica de Controles (Q11-T01) | MppbAppBar | Widget test / Semantics | Tooltips em Notificações, Sair e Início; brasão ExcludeSemantics | PASSOU |
| Q11-C02 | Semântica de Controles (Q11-T01) | LoginPage | Widget test / Semantics | Tooltip no botão Voltar e ExcludeSemantics no brasão | PASSOU |
| Q11-C03 | Semântica de Controles (Q11-T01) | NoticiasPage | Widget test / Semantics | Tooltip nos botões de paginação anterior/próxima e fechar modal | PASSOU |
| Q11-C04 | Semântica de Controles (Q11-T01) | DiarioOficialPage | Widget test / Semantics | Tooltip na paginação anterior/próxima e fechar PDF | PASSOU |
| Q11-C05 | Semântica de Controles (Q11-T01) | ConsultaProcessosPage | Widget test / Semantics | Tooltip fechar modal e recarregar captcha | PASSOU |
| Q11-C06 | Semântica de Controles (Q11-T01) | CarteiraPage | Widget test / Semantics | Rótulo semântico de virar cartão e descrição do QR Code | PASSOU |
| Q11-C07 | Semântica de Controles (Q11-T01) | MainLayout (Dock) | Widget test / Semantics | Abreviações do dock mapeadas para nomes semânticos por extenso | PASSOU |
| Q11-C08 | Semântica de Controles (Q11-T01) | StepAnexos (Ouvidoria) | Inspeção / Semantics | Tooltip 'Remover anexo' no botão excluir | PASSOU |
| Q11-C09 | Touch Targets Android (Q11-T02) | LoginPage | androidTapTargetGuideline | Todos os botões e links atendem à área mínima de 48x48dp | PASSOU |
| Q11-C10 | Touch Targets Android & iOS (Q11-T02) | MppbAppBar | androidTapTargetGuideline & iOSTapTargetGuideline | Ações atendem a >= 48dp (Android) e >= 44pt (iOS) | PASSOU |
| Q11-C11 | Labels de Targets (Q11-T03) | LoginPage | labeledTapTargetGuideline | Todos os controles acionáveis possuem descrição textual/tooltip | PASSOU |
| Q11-C12 | Touch Targets iOS (Q11-T02) | LoginPage | iOSTapTargetGuideline | Todos os controles acionáveis atendem à diretriz iOS de 44x44pt | PASSOU |
| Q11-C13 | Contraste de Texto (Q11-T04) | LoginPage | textContrastGuideline | Textos sobre fundo claro e botões com taxa de contraste aprovada | PASSOU |
| Q11-C14 | Contraste Institucional Delimitado (Q11-T04) | Paleta e Telas Auditadas | Cálculo WCAG 2.2 / Inspeção | Combinações de cores institucionais explicitamente auditadas atendem aos limiares registrados (#D62828/#FFFFFF ≈ 5.01:1, #202322/#FFFFFF ≈ 15.85:1, #697370/#FFFFFF ≈ 4.90:1, #202322/#F7F8F6 ≈ 14.88:1); LoginPage passou textContrastGuideline; gradientes/imagens/opacidade permanecem fora da afirmação global | PASSOU |
| Q11-C15 | Text Scaling 1.0 (Q11-T05) | PublicDashboard, Login, Processos, Diário, Contracheque | Widget test (TextScaler 1.0) | Zero RenderFlex overflow em todas as telas | PASSOU |
| Q11-C16 | Text Scaling 1.3 (Q11-T05) | PublicDashboard, Login, Processos, Diário, Contracheque | Widget test (TextScaler 1.3) | Zero RenderFlex overflow em todas as telas | PASSOU |
| Q11-C17 | Text Scaling 1.5 (Q11-T05) | PublicDashboard, Login, Processos, Diário, Contracheque | Widget test (TextScaler 1.5) | Zero RenderFlex overflow em todas as telas | PASSOU |
| Q11-C18 | Text Scaling 2.0 (Q11-T05) | PublicDashboard, Login, Processos, Diário, Contracheque | Widget test (TextScaler 2.0) | Zero RenderFlex overflow; Notícias e Processos adaptados com Wrap | PASSOU |
| Q11-C19 | Font Scale no Dispositivo (Q11-T06) | Samsung Galaxy A52 (Android 14) | Execução em aparelho físico | Escala original `1.1` registrada; definida para `1.3`; fluxo Home -> Notícias -> Home -> Login -> Processos percorrido na UI física com zero overflow; escala restaurada e confirmada em `1.1` | PASSOU |
| Q11-C20 | Display Density no Dispositivo (Q11-T07) | Samsung Galaxy A52 | ADB wm density / Viewport tests | Densidade física original aferida e preservada; variação de display size/density não executada no aparelho pessoal; responsividade complementar coberta por testes de viewport | PARCIAL |
| Q11-C21 | Leitor TalkBack no Dispositivo (Q11-T08) | Samsung Galaxy A52 | ADB / Análise de serviço | Pacote presente no aparelho; roteiro manual definido, não executado com TalkBack ativo; semântica subjacente validada por testes de widget | PARCIAL |
| Q11-C22 | Ordem de Foco e Leitura (Q11-T09) | LoginPage | FocusNode / Tab Traversal | Foco progride sequencialmente: Usuário -> Senha -> ACESSAR | PASSOU |
| Q11-C23 | Formulários (Q11-T10) | LoginPage | Widget test / Semantics | Labels persistentes ('Usuário', 'Senha'), toggle obscure, validação clara | PASSOU |
| Q11-C24 | Mensagens de Erro (Q11-T11) | LoginPage | Widget test / Semantics | Container de erro com ícone, texto explicativo e `liveRegion: true` | PASSOU |
| Q11-C25 | Loading Semântico (Q11-T12) | LoginPage & Processos | Widget test / Semantics | ProgressIndicator com semanticsLabel explícito ('Carregando autenticação', etc.) | PASSOU |
| Q11-C26 | Imagens Informativas vs Decorativas (Q11-T13) | Brasão, QR Code, Banners | Inspeção / ExcludeSemantics | Brasão e marcas d'água excluídos de leitura; QR Code rotulado | PASSOU |
| Q11-C27 | Alternativa QR Code (Q11-T13) | CarteiraPage | Widget test / Semantics | QR rotulado como mecanismo de verificação externa sem vazar payload | PASSOU |
| Q11-C28 | Contraste de Estado (Q11-T14) | Botões e Badges | Inspeção visual e semântica | Estado desabilitado sinalizado por semântica de botão e cor | PASSOU |
| Q11-C29 | Navegação por Teclado Físico (Q11-T15) | LoginPage | Widget test (TextInputAction) | Ação `next` move o foco do usuário para o campo senha sem mouse | PASSOU |
| Q11-C30 | Orientação Landscape + Escala 2.0x (Q11-T16) | PublicDashboard, Login, ConsultaProcessos | Widget test (Landscape 2400x1080 + TextScaler 2.0) | Testes executados especificamente em landscape com TextScaler 2.0x: nenhum RenderFlex overflow, layout íntegro | PASSOU |
| Q11-C31 | Auditoria Estática iOS (Q11-T17) | iOS Framework Flutter | Inspeção estática de widgets | Estrutura compartilhada é compatível com os mecanismos Flutter/iOS auditados; comportamento runtime VoiceOver/Dynamic Type não foi aferido em hardware Apple | PASSOU |
| Q11-C32 | Runtime iOS VoiceOver | iPhone / iOS físico | Execução runtime | Ausência de host macOS/Xcode para execução de VoiceOver em hardware real | BLOQUEADO |

---

## 3. Resumo Estatístico dos Status

- **PASSOU**: 29
- **PARCIAL**: 2 (Q11-C20 Display density não alterada no aparelho pessoal; Q11-C21 Roteiro manual TalkBack formalizado, não executado com TalkBack ativo)
- **FALHOU**: 0
- **BLOQUEADO**: 1 (Q11-C32 Runtime VoiceOver iOS por limitação de host Windows)
- **N/A**: 0
- **Total de Critérios Auditados**: **32**
