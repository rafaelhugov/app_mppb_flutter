# Q4 - Integracoes Locais

## Flutter

Comando:

```bash
flutter test test/features/integracao/q4_flutter_integration_test.dart
```

Resultado: 3/3.

Casos:

- Pagamentos atravessa provider, storage fake, Dio fake e modelo, validando header Bearer e tratamento de HTTP 503.
- Processos diferencia timeout de tipo de atividade de erro generico.
- Certidao extrajudicial propaga erro textual remoto de endpoint PDF sem expor bytes sensiveis.

## Backend

Comando:

```bash
mvn -q -pl mobile-service -Dtest=Q4IntegracaoControladaTest test
```

Resultado: 6/6.

Casos:

- Contexto Spring representativo carrega controllers, filtros, services e repositories fake sem infra externa.
- Perfil atravessa filtro de seguranca, controller, service, Auth API fake e repository fake.
- Bearer invalido retorna 401 antes do controller.
- Pagamentos atravessa seguranca, controller, service e repository fake com CPF normalizado.
- Notificacao registra dispositivo com identidade autenticada sem expor token bruto.
- Notificacao sem identidade local retorna 401 sem persistir.

## Docker

Docker disponivel no host (`Docker version 29.4.3`). A fase nao introduziu Testcontainers porque nao havia banco isolado preparado para o modulo e os objetivos de Q4 foram atendidos por dublês deterministicos locais.

## Bug Q4

`BUG-Q4-001`: erro textual recebido como bytes em endpoint PDF de certidao era exibido como numeros. Corrigido em `CertidaoExtrajudicialNotifier._formatError` com decodificacao UTF-8 para `List<int>`.
