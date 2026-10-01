# Evidência Q12 — Flutter Erros Globais e Renderização

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R01 — Reconciliação Metodológica e Validação Definitiva  
**Ambiente:** Flutter (App Mobile)  
**Arquivo de Teste:** `test/features/resiliencia/q12_resiliencia_test.dart`

---

## 1. Auditoria dos Mecanismos Globais no Código de Produção

A inspeção do ponto de entrada da aplicação (`lib/main.dart`) revelou:
- **`FlutterError.onError`**: Não configurado explicitamente no `main.dart`. Utiliza o fallback padrão da engine Flutter, que direciona logs de renderização para o stderr do console e constrói um `ErrorWidget`.
- **`PlatformDispatcher.instance.onError`**: Não registrado. Erros assíncronos não capturados fora de `runZonedGuarded` não possuem um interceptor global centralizado.
- **`runZonedGuarded`**: Não utilizado para envelopar o `runApp()` na aplicação de produção.
- **`ErrorWidget.builder`**: Não customizado com layout institucional personalizado; exibe o `ErrorWidget` padrão do framework.
- **Crashlytics / Sentry**: Não instalados (ausentes do `pubspec.yaml`).

Classificação conforme regra metodológica: **AUSENTE** no nível global/central da aplicação de produção.

---

## 2. Testes de Falha Controlada

### 2.1 Q12-T01: Fallback Padrão de Exceção de Renderização Flutter
- **Cenário:** Simulação de lançamento de exceção durante o método `build` de um widget filho na árvore.
- **Comportamento Validado:**
  - `FlutterError.onError` default do framework interceptou a exceção.
  - `ErrorWidget` padrão foi renderizado na viewport correspondente.
  - O aplicativo não entrou em loop infinito de renderização.
  - A execução não encerrou o processo/isolate do Dart.
  - *Constatação:* `ErrorWidget` padrão validado; observabilidade global de produção continua ausente.
- **Status:** **PASSOU**

### 2.2 Q12-T02: Erro Assíncrono Não Tratado
- **Cenário:** Disparo de `Future.delayed` lançando `StateError` dentro de uma zona de execução controlada no teste.
- **Comportamento Validado:**
  - A zona de teste capturou a exceção via callback de erro sem derrubar o container Riverpod.
  - *Calibração Metodológica:* O teste comprova apenas que uma Dart Zone isola o erro dentro do harness. A aplicação de produção **NÃO** possui `runZonedGuarded` nem `PlatformDispatcher.instance.onError` registrados. Falhas assíncronas reais em produção cairão no handler nativo do Dart sem registro centralizado (`RISCO-Q12-004`).
- **Status:** **PARCIAL**

### 2.3 Q12-T21: Fallback de Imagem e PDF
- **Cenário:** Falha de carregamento de imagem externa e stream de PDF corrompido/inexistente.
- **Comportamento Validado:**
  - `Image.network` com `errorBuilder`: Exibição de ícone de fallback (`Icons.broken_image`) e texto informativo, sem crash.
  - `DiarioOficialPage`: Trata falha de PDF com mensagem amigável e ação alternativa de abertura via navegador externo.
- **Status:** **PASSOU**
