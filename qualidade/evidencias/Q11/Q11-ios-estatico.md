# Q11 — Evidência de Auditoria Estática iOS (Q11-T17, Q11-C31, Q11-C32)

Data: 01/10/2026 (Reconciliado Q11-R01)  
Status: ANÁLISE ESTÁTICA PASSOU / RUNTIME VOICEOVER BLOQUEADO POR LIMITAÇÃO DE AMBIENTE

---

## 1. Delimitação Clara de Escopo e Ambiente

O ambiente de desenvolvimento e auditoria é uma estação de trabalho **Windows 11** sem acesso local a hardware macOS, Xcode ou simuladores iOS.  
Por conseguinte:
- **Runtime VoiceOver em Dispositivo Físico iOS (Q11-C32)**: Classificado formalmente como `BLOQUEADO POR LIMITAÇÃO DE AMBIENTE`. Não se declara nem se presume VoiceOver validado em hardware real Apple.
- **Auditoria Estática de Código Compartilhado iOS (Q11-C31)**: Classificado formalmente como `PASSOU`.

## 2. Calibração da Auditoria de Estrutura Compartilhada

A estrutura compartilhada de widgets Flutter foi auditada para garantir compatibilidade com os mecanismos que o framework projeta na plataforma iOS:
1. **Rótulos e Tooltips**:
   - As anotações de `tooltip`, `Semantics(label: ...)` e `Semantics(button: ...)` implementadas em `MppbAppBar`, `LoginPage`, `CarteiraPage` e `MainLayout` mapeiam diretamente para `accessibilityLabel` e `accessibilityTraits` da API `UIAccessibilityElement` do iOS.
2. **Imagens Decorativas**:
   - O uso de `ExcludeSemantics` orienta o framework a não expor elementos puramente visuais (como o brasão ou marcas d'água no fundo dos cards), prevenindo poluição na navegação por varredura.
3. **Áreas de Toque (iOSTapTargetGuideline)**:
   - A diretriz `iOSTapTargetGuideline` (44x44 pt) foi explicitamente testada e aprovada para `LoginPage` e `MppbAppBar`. O piso de 48x48dp estabelecido atende e supera a recomendação oficial de 44x44pt da Apple (*Human Interface Guidelines*).
4. **Reserva de Espaço e SafeArea**:
   - Estrutura compatível com áreas seguras (notches e Dynamic Island) por meio de `SafeArea` e componentes estruturais do Material 3.
5. **Declaração Formal de Limitação**:
   - A estrutura compartilhada é compatível com os mecanismos Flutter/iOS auditados; contudo, o comportamento runtime VoiceOver/Dynamic Type não foi aferido em hardware Apple.
