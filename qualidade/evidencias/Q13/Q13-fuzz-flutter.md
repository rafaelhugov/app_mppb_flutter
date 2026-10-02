# Q13 — Evidência de Fuzz Testing: Flutter

**Data:** 02/10/2026  
**Arquivo de Teste:** `test/features/qualidade/q13_fuzz_property_test.dart`  
**Seed Canônica Global:** `130013`  

---

## 1. Visão Geral do Fuzzing no Frontend

O objetivo do Fuzz Testing no Flutter foi submeter as interfaces puras de parsing de cache, validação de entradas de texto, sanitizadores e limites numéricos a cargas anômalas, malformadas e extremas para confirmar a inexistência de:
1. `Unhandled Exceptions` ou travamento do loop de eventos da UI;
2. Loops infinitos ou congelamentos no parser de strings;
3. `RangeError` ou inconsistência de limites em índices de paginação;
4. Degradação de memória decorrente de payloads malformados.

---

## 2. Resumo de Execução do Fuzzing (Flutter)

| Fuzz target | Seed | Casos | Crashes | Bugs |
|---|---:|---:|---:|---:|
| **F01**: Parsers de JSON de Cache Local (`UsuarioCarteira`, `PerfilUsuario`) | Determinístico | 14 vetores anômalos | 0 | 0 |
| **F02**: Strings Extremas (0, 1, 10, 255, 1024, 4096 caracteres) | `130018` | 100 variações | 0 | 0 |
| **F03**: Unicode, Emojis, RTL e Caracteres de Controle | `130019` | 120 variações | 0 | 0 |
| **F04**: Números e Limites de Paginação (-1, 0, 1, 100, 1000) | `130020` | 200 variações | 0 | 0 |

---

## 3. Detalhamento dos Vetores de Fuzzing

### F01: JSON Corrompido e Aninhado
- **Cargas Testadas:**
  - Strings vazias `""` e apenas espaços `"   "`;
  - Chaves abertas sem fechamento `"{", "{{{{{"` e chaves invertidas `"}"`;
  - Literais nulos `"null"` e listas onde objetos eram esperados `"[]"`;
  - Objetos vazios `"{}"`;
  - Tipos invertidos (números onde string esperada, booleanos onde lista esperada);
  - JSON profundamente aninhado (`{"deep": {"nested": ...}}`);
  - Surrogates não pareados (`\uD800\uD800`);
  - Propriedades adicionais desconhecidas (`{"extra_fields": "unexpected"}`).
- **Comportamento Observado:** Todas as cargas foram absorvidas com `FormatException` ou `TypeError` capturados pelas camadas de proteção, sem nenhum encerramento anômalo da thread.

### F02: Strings Extremas de Entrada
- **Comprimentos Testados:** 0, 1, 10, 255, 1024 e 4096 caracteres.
- **Comportamento Observado:** O validador de CPF rejeita imediatamente comprimentos != 11. O formatador de telefone trunca adequadamente os dígitos excedentes para 11 números sem transbordamento ou lentidão.

### F03: Unicode, Emojis, RTL e Controle
- **Caracteres Injetados:** Emojis múltiplos (`🧪🚀💥🇧🇷`), diacríticos acentuados (`áéíóúãõç`), texto RTL em árabe (`مرحبا`) e hebraico (`שלום`), caracteres zero-width (`\u200B`), byte-order mark (`\uFEFF`) e quebras de linha (`\r\n\t`).
- **Comportamento Observado:** Nenhuma alteração corrompeu a estabilidade dos formatters; os dígitos e regras de máscara permaneceram totalmente previsíveis.

### F04: Números e Limites de Paginação
- **Faixas Testadas:** `page = -1`, `page = 0`, `page = 1`, `pageSize = 0`, `pageSize = 1000`.
- **Comportamento Observado:** O cálculo de sublistas (`paginatedNews`) utiliza clamping determinístico `end = (start + pageSize).clamp(0, total)` evitando integralmente `RangeError`.
