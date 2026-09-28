# Q3 - Relatorio final

Data: 2026-09-28
Branch: `qualidade/q3-contratos`

Executada exclusivamente a Q3 - Testes de Contrato Flutter x Backend.

## Resultado

- Contratos inventariados: 39.
- Criticos: 36.
- Compativeis/testados: 30.
- Parciais: 8.
- Divergentes abertos: 0.
- Nao testados: 1.

## Testes

- Flutter antes Q3: 143.
- Flutter depois Q3: 154.
- Backend: suite verde; adicionados 4 testes de contrato de Certidao.
- Cobertura LCOV: 34,43%.

## Divergencias

`DIV-Q3-001`: fixture Flutter de Certidao usava `tipoDocumento=CPF`; backend aceita `F|J` e a UI real usa `F|J`. Corrigido teste/fixture para `F`. Sem divergencia funcional aberta.

## Gates

| Verificacao | Flutter | Backend | Resultado |
| --- | --- | --- | --- |
| Analyze/compilacao | OK | N/A | OK |
| Testes | 154/154 | OK | OK |
| Coverage | OK | N/A | OK |
| Security scans | OK | OK | OK |
| Package/build | APK OK | Maven package OK | OK |

## Runtime Android

`Pixel_9` bootou, instalou e abriu o app homolog. Home publica carregou. Ao tentar navegar para Noticias, o emulador caiu com `bad color buffer handle 291` e exit 139.

Classificacao: falha nativa/emulador grafico. Sem evidencia de bug de contrato/app.

## Pendencias para Q4

- Validar contratos parciais contra integracao real quando houver dependencias externas: Ouvidoria, imagens/PDFs reais, MPVirtual e fluxos autenticados com credenciais autorizadas.
- Repetir smoke Android em ambiente/emulador grafico estavel ou dispositivo fisico.

Nao foi feito commit nem push.

