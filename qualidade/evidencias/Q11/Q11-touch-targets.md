# Q11 — Evidência de Áreas de Toque / Touch Targets (Q11-T02)

Data: 01/10/2026 (Reconciliado Q11-R01)  
Status: PASSOU

---

## 1. Escopo e Diretriz Técnica

Avaliação da conformidade com as diretrizes oficiais de acessibilidade do Flutter:
- `androidTapTargetGuideline`: requer área de toque mínima de **48x48 dp** para controles táteis no ecossistema Android/Material.
- `iOSTapTargetGuideline`: requer área de toque mínima de **44x44 pt** no ecossistema Apple/iOS.
- **Enquadramento WCAG**: **WCAG 2.2 — SC 2.5.8 Target Size (Minimum), Nível AA**. O critério da WCAG 2.2 estabelece um mínimo de 24×24 CSS px (com exceções). A área de 48×48dp (Android) e 44×44pt (iOS) adotadas pelo Flutter e pelo Material Design constituem diretrizes mais conservadoras e rigorosas que o limiar mínimo exigido pelo SC 2.5.8.

## 2. Inspeção e Correções Aplicadas

### 2.1 Formulário de Login (LoginPage)
- **Problema (BUG-Q11-002)**: Botões secundários e botão de acesso possuíam alturas rígidas de 42dp a 46dp, gerando violação estrita da guideline `androidTapTargetGuideline`.
- **Correção**: Todas as caixas de botões principais (`ElevatedButton`, `OutlinedButton`, `TextButton`) em `LoginPage` foram padronizadas com altura mínima de **48dp** (`height: 48`).

### 2.2 Barra de Navegação Superior (MppbAppBar)
- **Problema (BUG-Q11-001)**: `_HomeTapTarget` e botões de ação possuíam padding padrão que podia resultar em dimensões inferiores a 48dp de altura efetiva.
- **Correção**: Inserido `BoxConstraints(minHeight: 48)` em `_HomeTapTarget` e garantido que todos os `IconButton`s utilizem dimensões de área de toque de 48dp através de paddings adequados.

### 2.3 Formulário de Consulta de Processos (ConsultaProcessosPage)
- **Problema (BUG-Q11-004)**: Botão "Pesquisar" possuía altura fixa de 44dp.
- **Correção**: Ajustado para `minHeight: 48dp` com `padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16)`.

## 3. Validação Automatizada (Android e iOS Guidelines)

Execução comprovada na suite `test/features/acessibilidade/q11_acessibilidade_test.dart`:
```dart
testWidgets('LoginPage atende androidTapTargetGuideline e labeledTapTargetGuideline', (tester) async {
  ...
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
});

testWidgets('MppbAppBar atende androidTapTargetGuideline, iOSTapTargetGuideline e labeledTapTargetGuideline', (tester) async {
  ...
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
});
```

**Resultado**: AMBOS OS TESTES PASSARAM para `androidTapTargetGuideline` (48x48dp) e `iOSTapTargetGuideline` (44x44pt).
