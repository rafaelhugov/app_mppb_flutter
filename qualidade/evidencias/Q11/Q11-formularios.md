# Q11 — Evidência de Acessibilidade em Formulários (Q11-T10, Q11-T11, Q11-T12, Q11-T15)

Data: 01/10/2026  
Telas Auditadas: LoginPage, ConsultaProcessosPage  
Status: PASSOU

---

## 1. Escopo de Avaliação

Verificação dos requisitos de formulários acessíveis:
- Labels persistentes nos campos (não depender unicamente de placeholder ou hint);
- Associação de erros e validação acessível;
- Campo de senha com controle acessível de visibilidade;
- Navegação sequencial de foco por teclado/tabulação (`TextInputAction`);
- Sinalização semântica de loading no botão ou tela;
- Mensagens de erro com sinalização múltipla (não unicamente dependente de cor).

## 2. Inspeção e Implementação de Melhorias

### 2.1 LoginPage
1. **Labels Persistentes**:
   - `labelText: 'Usuário'` e `labelText: 'Senha'`. Ao digitar, o label flutua mantendo o contexto visível permanentemente para o usuário.
2. **Controle de Senha**:
   - `IconButton` de visibilidade implementado com tooltip dinâmico: `_obscurePassword ? 'Mostrar senha' : 'Ocultar senha'`.
3. **Foco e Teclado**:
   - Campo Usuário configurado com `keyboardType: TextInputType.visiblePassword` e `textInputAction: TextInputAction.next`.
   - Campo Senha configurado com `keyboardType: TextInputType.visiblePassword` e `textInputAction: TextInputAction.done`.
   - A ação `next` transfere o foco diretamente para a senha via teclado físico ou virtual.
4. **Mensagem de Erro (BUG-Q11-008)**:
   - Anteriormente: container vermelho exibindo texto simples sem anúncio assíncrono.
   - Corrigido:
     - Adicionado ícone de aviso `Icons.error_outline_rounded` (informação não depende exclusivamente de cor).
     - Envelopado em `Semantics(liveRegion: true)` garantindo que o leitor de tela anuncie a mensagem de erro imediatamente quando exibida.
5. **Indicador de Carregamento**:
   - `CircularProgressIndicator` envolto em `semanticsLabel: 'Carregando autenticação'`.
6. **Áreas de Toque (Touch Targets - BUG-Q11-002)**:
   - Botões com altura mínima de 48dp (`minHeight: 48`).

### 2.2 ConsultaProcessosPage
1. **Campos de Busca**:
   - Campos com `labelText` e validações de preenchimento.
2. **Refresh de Captcha**:
   - Botão de recarga de captcha equipado com `tooltip: 'Recarregar captcha'`.
3. **Botão de Submissão**:
   - Altura mínima ajustada para 48dp e indicador de busca equipado com `semanticsLabel: 'Pesquisando processos'`.

## 3. Evidência dos Testes Automatizados

Execução em `test/features/acessibilidade/q11_acessibilidade_test.dart`:
```text
Q11-T10 & Q11-T15 — Formulário de Login e Navegação por Foco:
✓ Campos de login possuem labels persistentes e foco sequencial correto
✓ Botão mostrar/ocultar senha possui tooltip dinâmico

Q11-T11 & Q11-T12 — Feedback de Erro e Loading com Semântica:
✓ Mensagem de erro de login possui ícone, texto e liveRegion
```
Resultado: PASSOU.
