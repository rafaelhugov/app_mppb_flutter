# Q11 — Evidência de Escala de Texto / Text Scaling (Q11-T05, Q11-T16, Q11-C30)

Data: 01/10/2026 (Reconciliado Q11-R01)  
Status: PASSOU

---

## 1. Escopo e Diretriz Técnica

Avaliação de robustez da interface do aplicativo sob diferentes fatores de ampliação de texto pelo sistema operacional (`TextScaler.linear`), sem causar:
- `RenderFlex overflow` (faixas amarelas/pretas de estouro de layout);
- Truncamento indevido ou ilegível de títulos e ações críticas;
- Impossibilidade de acionamento de botões.
- **Enquadramento WCAG**: **WCAG 2.2 — SC 1.4.4 Resize Text, Nível AA** e **SC 1.3.4 Orientation, Nível AA**.

Escalas canônicas testadas em portrait:
- **1.0x** (Tamanho padrão);
- **1.3x** (Aumento moderado);
- **1.5x** (Aumento grande);
- **2.0x** (Aumento máximo / acessibilidade severa).

Cenário combinado de estresse auditado:
- **Landscape (2400×1080) + TextScaler 2.0x** (Q11-C30).

## 2. Não Conformidades Encontradas e Corrigidas

### 2.1 PublicDashboardPage (BUG-Q11-003)
- **Problema**: Na escala `2.0x`, o cabeçalho da seção Notícias apresentava uma `Row` contendo o título "Notícias" e o botão `FilledButton` "Todas as notícias", gerando estouro lateral:
  ```text
  A RenderFlex overflowed by 73 pixels on the right.
  Row:file:///lib/features/public/ui/public_dashboard_page.dart:188:25
  ```
- **Correção**: Substituição da `Row` rígida por `Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 8, children: [...])`. O botão quebra de linha de maneira harmônica em fontes grandes, preservando 100% da usabilidade e visibilidade.

### 2.2 ConsultaProcessosPage (BUG-Q11-004)
- **Problema**: Cabeçalho de filtros com `Row` rígida sofria overflow lateral em 2.0x.
- **Correção**: Envolvido em `Wrap` responsivo com `WrapAlignment.spaceBetween`.

## 3. Matriz de Resultados de Escala de Texto

| Escala | Orientação | Telas Validadas | Resultado | Overflow Detectado |
|---:|---|---|---|---|
| **1.0** | Portrait | PublicDashboard, Login, ConsultaProcessos, DiarioOficial, ContraCheque | PASSOU | Nenhum |
| **1.3** | Portrait | PublicDashboard, Login, ConsultaProcessos, DiarioOficial, ContraCheque | PASSOU | Nenhum |
| **1.5** | Portrait | PublicDashboard, Login, ConsultaProcessos, DiarioOficial, ContraCheque | PASSOU | Nenhum |
| **2.0** | Portrait | PublicDashboard, Login, ConsultaProcessos, DiarioOficial, ContraCheque | PASSOU | Nenhum (após correção BUG-Q11-003/004) |
| **2.0** | Landscape | PublicDashboard, Login, ConsultaProcessos | PASSOU | Nenhum (Q11-C30 comprovado) |

## 4. Evidência dos Testes Automatizados

23 casos de testes executados na suite `test/features/acessibilidade/q11_acessibilidade_test.dart`:
```text
Q11-T05 — Text Scaling (1.0, 1.3, 1.5, 2.0):
✓ 20 testes em portrait (5 telas × 4 escalas) sem qualquer exceção

Q11-T16 / Q11-C30 — Orientação Landscape combinada com Text Scaling 2.0x:
✓ PublicDashboardPage em landscape com TextScaler 2.0 não apresenta overflow
✓ LoginPage em landscape com TextScaler 2.0 não apresenta overflow
✓ ConsultaProcessosPage em landscape com TextScaler 2.0 não apresenta overflow
```
Status: 23/23 PASSOU.
