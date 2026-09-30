# Q6 — Evidência de Testes de Concorrência e Integridade (Backend Spring Boot)

Data: 2026-09-29  
Branch: `qualidade/q6-concorrencia-integridade`  
Classe de Testes: `mppb.restapi.mobile.quality.Q6ConcorrenciaIntegridadeTest`  
Módulo: `mobile-service`  

---

## 1. Contexto e Objetivos

Esta suíte de testes do Backend foi desenvolvida com JUnit 5, `ExecutorService`, `CountDownLatch` e `CompletableFuture` para comprovar que as operações mutáveis e de leitura do `mobile-service` mantêm atomicidade, idempotência e isolamento rigoroso sob requisições concorrentes.

---

## 2. Cenários Testados e Resultados

| ID | Cenário | Abordagem de Teste | Resultado |
| :--- | :--- | :--- | :---: |
| **Q6-T08/T09** | Requisições duplicadas/concorrentes de registro de FCM (`/api/notificacoes/dispositivos`) | 4 threads liberadas simultaneamente via `CountDownLatch` registrando o mesmo token/identificador | **PASS (1 único registro ativo mantido, idempotência comprovada)** |
| **Q6-T11** | Desativação repetida de dispositivo FCM | Desativação executada duas vezes consecutivas | **PASS (Idempotente, retorno seguro sem erro)** |
| **Q6-T14** | Rollback e validação transacional | Envio de payload inválido para serviço `@Transactional` | **PASS (Transação rejeitada, zero registros órfãos)** |
| **Q6-T15** | Constraints de unicidade (token já registrado com outro identificador) | Re-registro de token FCM existente para novo identificador (reinstalação de app) | **PASS (Reativação e atualização sem colisão de chave única)** |
| **Q6-T16** | Concorrência de leitura simultânea em Perfil | 10 requisições paralelas via `CompletableFuture` para usuários distintos | **PASS (Nenhum cruzamento de logins ou dados)** |
| **Q6-T16** | Concorrência de leitura simultânea em Pagamentos | Consultas simultâneas de usuários e exercícios distintos | **PASS (Nenhum vazamento de CPF ou processos)** |

---

## 3. Síntese Técnica

1. **Idempotência de Registro FCM**:
   - O serviço `DispositivoFcmService` calcula o SHA-256 do token e consulta `findByTokenHash` antes de tentar inserir.
   - Em cenários concorrentes, o registro converge para o registro existente, executando `atualizar` em vez de gerar duplicação de linha no banco.
2. **Idempotência de Desativação**:
   - A query SQL `UPDATE diariooficial.dispositivofcm SET ativo = FALSE ... WHERE ativo = TRUE` garante que chamadas repetidas sejam naturalmente neutras (retornando `false` sem lançar exceções).
3. **Isolamento de Leitura**:
   - Os serviços `PerfilUsuarioService` e `PagamentosService` são stateless e thread-safe, operando exclusivamente sobre os parâmetros de requisição e dados do banco sem estado compartilhado mutável.
