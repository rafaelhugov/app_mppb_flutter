# Q11 — Evidência de Contraste de Cores e Texto (Q11-T04, Q11-T14)

Data: 01/10/2026 (Reconciliado Q11-R01)  
Status: PASSOU NO ESCOPO MENSURÁVEL

---

## 1. Metodologia e Cálculos Recalibrados

1. **Flutter Guideline Automatizada**: Aplicação de `meetsGuideline(textContrastGuideline)` em testes de widgets onde o motor de renderização do Flutter consegue extrair com precisão a cor do texto e a cor de fundo subjacente.
2. **Cálculo Espectral WCAG 2.2 — SC 1.4.3 Contrast (Minimum), Nível AA (4.5:1 para texto normal, 3.0:1 para texto grande e componentes)**:
   - Fundo institucional Vinho `#D62828` sobre Branco `#FFFFFF`: contraste de **5.01:1** (atende WCAG AA).
   - Texto escuro institucional `#202322` sobre Branco `#FFFFFF`: contraste de **15.85:1** (atende WCAG AAA).
   - Texto secundário `#697370` sobre Branco `#FFFFFF`: contraste de **4.90:1** (atende WCAG AA).
   - Texto escuro institucional `#202322` sobre Cinza Suave `#F7F8F6`: contraste de **14.88:1** (atende WCAG AAA).

## 2. Contraste de Estado (Q11-T14)

- Os estados habilitado vs desabilitado nos botões (`ElevatedButton`, `OutlinedButton`) utilizam tanto variação de opacidade/cor de fundo quanto semântica nativa `enabled: false`.
- O estado de erro na tela de login (`LoginPage`) não depende exclusivamente da tonalidade vermelha: foi inserido o ícone `Icons.error_outline_rounded` em conjunto com a mensagem textual de erro e anúncio via `liveRegion: true` (atendendo ao WCAG SC 1.4.1 Use of Color).

## 3. Delimitação Técnica do Escopo de Contraste (Q11-C14)

- As combinações de cores institucionais explicitamente auditadas atendem aos limiares registrados;
- `LoginPage` passou no teste automatizado `textContrastGuideline`;
- Gradientes complexos, imagens em background e elementos com opacidade dinâmica no canvas permanecem fora da afirmação global de conformidade, evitando falsas declarações de certificação irrestrita.

## 4. Evidência do Teste Automatizado

```text
Q11-T04 — Contraste de Texto:
✓ LoginPage atende textContrastGuideline em seus elementos mensuráveis
```
Resultado: PASSOU.
