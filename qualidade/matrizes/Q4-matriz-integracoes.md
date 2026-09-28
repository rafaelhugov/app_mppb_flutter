# Q4 - Matriz de Integracoes Controladas

| Caso | Integracao | Fluxo atravessado | Negativo coberto | Estrategia | Resultado |
| --- | --- | --- | --- | --- | --- |
| Q4-BE-CTX | Spring context representativo | Beans de controllers, filtros, services e repositories fake | Ausencia de infra externa real | `ApplicationContextRunner` | OK |
| Q4-BE-SEC-PERFIL | Perfil autenticado | Basic filter, `SecurityContext`, controller, service, Auth API fake e repository fake | Token invalido retorna 401 antes do controller | MockMvc standalone com filtros reais | OK |
| Q4-BE-PAG | Pagamentos | Security, controller, service e repository fake | CPF autenticado normalizado | MockMvc + repository fake | OK |
| Q4-BE-FCM | Registro de dispositivo | Security, controller, service e persistencia fake | Login sem matricula local retorna 401 e nao persiste | MockMvc + fake de usuario local | OK |
| Q4-FL-PAG | Pagamentos Flutter | Provider, storage fake, Dio fake e modelo | HTTP 503 vira erro de servidor sem quebrar estado | Teste Flutter unitario de integracao local | OK |
| Q4-FL-PROC | Processos Flutter | Provider, Dio fake, query por tipo de atividade | `receiveTimeout` gera mensagem especifica | Teste Flutter unitario de integracao local | OK |
| Q4-FL-CERT | Certidao PDF Flutter | Provider e Dio fake em `ResponseType.bytes` | Erro textual remoto em bytes vira texto sanitizado | Teste Flutter unitario de integracao local | OK apos BUG-Q4-001 |
| Q4-RT-ANDROID | APK homolog | Inicializacao Android, Firebase local e shell Flutter | Sem fatal crash observado no smoke | Emulador Pixel_9 headless | OK/PARCIAL |

## Resultado dos testes novos

| Repositorio | Arquivo | Casos | Resultado |
| --- | --- | --- | --- |
| Flutter | `test/features/integracao/q4_flutter_integration_test.dart` | 3 | 3/3 |
| Backend | `mobile-service/src/test/java/mppb/restapi/mobile/quality/Q4IntegracaoControladaTest.java` | 6 | 6/6 |

## Bug encontrado

`BUG-Q4-001`: o provider de certidao extrajudicial tratava resposta textual de erro recebida como `List<int>` em endpoint PDF como lista generica, exibindo numeros de bytes em vez da mensagem textual. Corrigido com `utf8.decode(data, allowMalformed: true).trim()` antes do tratamento generico de listas.
