# Q13 — Inventário de Alvos de Teste

**Fase:** Q13 — Mutation Testing, Property-Based Testing e Fuzz Testing  
**Data de Execução:** 02/10/2026  
**Seed Canônica Global:** `130013`  
**Escopo:** Frontend Flutter (`app_mppb_flutter`) e Backend Spring Boot (`spring-boot/restapi`)  

---

## 1. Visão Geral e Critérios de Seleção

O escopo da fase Q13 é estruturado para responder a três perguntas centrais de prontidão técnica:
1. **Mutation Testing:** Os testes unitários e de integração existentes realmente falham quando erros deliberados de lógica de negócio são inseridos?
2. **Property-Based Testing:** As invariantes lógicas e contratos fundamentais de domínio continuam válidos sob centenas de combinações determinísticas de entradas geradas pseudoaleatoriamente a partir de uma seed fixa?
3. **Fuzz Testing:** Entradas imprevistas, malformadas, corrompidas ou maliciosas causam crash não tratado, vazamento de memória/threads, ou violação de segurança nas interfaces puras do sistema?

Nenhum teste de mutação ou fuzzing foi executado contra serviços institucionais reais, banco de dados de produção, credenciais ativas ou APIs externas. Todo o processo operou em harnesses unitários controlados, mocks determinísticos e worktrees temporários de mutação isolados (`..\app_mppb_flutter_q13_mut` e `..\restapi_q13_mut`).

---

## 2. Inventário Consolidado de Alvos

| ID | Camada | Alvo | Técnica | Invariante/Risco | Criticidade |
|---|---|---|---|---|---|
| MUT-FLUTTER-01 | Flutter | `auth_provider.dart` (`login`) | Mutation | Omissão de persistência do token JWT deve quebrar autenticação observada | Crítica |
| MUT-FLUTTER-02 | Flutter | `session_reset_provider.dart` | Mutation | Omissão de invalidação do `carteiraProvider` no logout deve vazar sessão | Crítica |
| MUT-FLUTTER-03 | Flutter | `auth_state.dart` (`isAuthenticated`) | Mutation | Inversão do getter booleano deve quebrar guardas de rota e UI | Crítica |
| MUT-FLUTTER-04 | Flutter | `noticia_provider.dart` (`fetchNoticias`) | Mutation | Manutenção de `isLoading: true` no catch causa bloqueio perpétuo de UI | Média |
| MUT-FLUTTER-05 | Flutter | `noticia_provider.dart` (`fetchNoticias`) | Mutation | Manutenção de `errorMessage` residual após retry bem-sucedido | Média |
| MUT-FLUTTER-06 | Flutter | `perfil_provider.dart` (`_loadFromCache`) | Mutation | Re-lançamento de `FormatException` de cache corrompido causa crash | Média |
| MUT-FLUTTER-07 | Flutter | `carteira_provider.dart` (`_carregar`) | Mutation | Fallback offline marcando `isOffline: false` viola contrato visual | Crítica |
| MUT-FLUTTER-08 | Flutter | `ouvidoria_provider.dart` (`_isValidCPF`) | Mutation | Inversão do cálculo do primeiro dígito verificador do CPF | Crítica |
| MUT-FLUTTER-09 | Flutter | `ouvidoria_provider.dart` (`_isValidCPF`) | Mutation | Alteração do tamanho de validação de CPF de `!= 11` para `!= 10` | Crítica |
| MUT-FLUTTER-10 | Flutter | `device_registration_manager.dart` | Mutation | Pular chamada de registro FCM silenciosamente impede notificações | Crítica |
| MUT-FLUTTER-11 | Flutter | `input_formatters.dart` (`Telefone`) | Mutation | Inversão da condição `length > 10` corrompe máscara de celular | Média |
| MUT-FLUTTER-12 | Flutter | `input_formatters.dart` (`CpfCnpj`) | Mutation | Troca de separador de ponto por hífen corrompe máscara formal | Média |
| MUT-BACKEND-01 | Backend | `ApiExceptionHandler.handleBusinessRuleException` | Mutation | Mapeamento de 422 para 200 mascara violação de regra de negócio | Crítica |
| MUT-BACKEND-02 | Backend | `ApiExceptionHandler.handleNotFoundException` | Mutation | Mapeamento de 404 para 500 mascara recurso inexistente | Crítica |
| MUT-BACKEND-03 | Backend | `ApiExceptionHandler.handleRetryableException` | Mutation | Mapeamento de 503 para 200 causa falso positivo sob indisponibilidade | Crítica |
| MUT-BACKEND-04 | Backend | `ApiExceptionHandler.handleClientApiException` | Mutation | Mapeamento de 502 para 500 mascara falha em gateway downstream | Crítica |
| MUT-BACKEND-05 | Backend | `ApiExceptionHandler.handleGenericException` | Mutation | Exposição de mensagem sensível/stacktrace em resposta pública | Crítica |
| MUT-BACKEND-06 | Backend | `FeignErrorDecoder.decode` | Mutation | Restrição `status >= 400` para `status > 500` ignora erros 4xx | Crítica |
| MUT-BACKEND-07 | Backend | `FeignErrorDecoder.readBody` | Mutation | Retorno de corpo vazio silencia detalhes operacionais do downstream | Média |
| MUT-BACKEND-08 | Backend | `DispositivoFcmService.registrar` | Mutation | Omissão de hash SHA-256 e gravação de token em texto claro | Crítica |
| MUT-BACKEND-09 | Backend | `DispositivoFcmService.registrar` | Mutation | Inversão de branch de dispositivo existente vs novo registro | Crítica |
| MUT-BACKEND-10 | Backend | `DispositivoFcmService.plataformaValida` | Mutation | Rejeição incorreta da plataforma legítima "ANDROID" | Crítica |
| MUT-BACKEND-11 | Backend | `DispositivoFcmService.desativar` | Mutation | Inversão do booleano de confirmação de desativação | Crítica |
| MUT-BACKEND-12 | Backend | `ApiExceptionHandler.handleAccessDeniedException` | Mutation | Mapeamento de 403 para 401 confunde autorização com autenticação | Crítica |
| PROP-FLUTTER-01 | Flutter | `UsuarioCarteira` / `PerfilUsuario` (P01) | Property | Roundtrip `toJson` -> `fromJson` preserva campos essenciais | Alta |
| PROP-FLUTTER-02 | Flutter | Formatters e Sanitizadores (P02) | Property | Nenhuma entrada causa exceção inesperada ou trava de thread | Média |
| PROP-FLUTTER-03 | Flutter | `OuvidoriaProvider._isValidCPF` (P03) | Property | 500 CPFs válidos são aceitos; dígitos corrompidos são rejeitados | Alta |
| PROP-FLUTTER-04 | Flutter | `TelefoneInputFormatter` (P04) | Property | 10 dígitos produzem formato fixo, 11 produzem celular, dígitos preservados | Média |
| PROP-FLUTTER-05 | Flutter | `ServicoLinksExternos.uriEmail` (P05) | Property | URIs mailto permanecem estruturalmente válidas | Média |
| PROP-FLUTTER-06 | Flutter | Notícias e Listagens (P06) | Property | Sucesso ou erro sempre deixam `isLoading == false` | Alta |
| PROP-FLUTTER-07 | Flutter | `sessionResetProvider` (P07) | Property | Transição de autenticado para desautenticado invalida caches privados | Crítica |
| PROP-BACKEND-08 | Backend | `ApiExceptionHandler` (P08) | Property | Respostas de erro sob prod nunca contêm `trace` ou stacktrace | Crítica |
| PROP-BACKEND-09 | Backend | `DispositivoFcmService` (P09) | Property | Hash FCM é sempre 64 caracteres hexadecimais em minúsculas (SHA-256) | Crítica |
| FUZZ-FLUTTER-01 | Flutter | Parsers de Cache Local (F01) | Fuzz | JSONs truncados, malformados ou aninhados não causam crash não tratado | Alta |
| FUZZ-FLUTTER-02 | Flutter | Validadores de Entrada (F02) | Fuzz | Strings de 0, 1, 10, 255, 1024, 4096 caracteres não estouram memória | Média |
| FUZZ-FLUTTER-03 | Flutter | Sanitizadores de Texto (F03) | Fuzz | Emojis, caracteres RTL, zero-width e surrogates não travam o parser | Média |
| FUZZ-FLUTTER-04 | Flutter | Paginação e Índices (F04) | Fuzz | Índices negativos, zero, max e max+1 não causam RangeError na UI | Média |
| FUZZ-BACKEND-05 | Backend | Jackson Object Deserializer (F05) | Fuzz | Payloads DTO corrompidos lançam exceções controladas sem crash da JVM | Alta |
| FUZZ-BACKEND-06 | Backend | `ApiExceptionHandler` (F06) | Fuzz | Vetores com SQL, caminhos de arquivo e senhas são mascarados | Crítica |
| FUZZ-BACKEND-07 | Backend | `FeignErrorDecoder` (F07) | Fuzz | Status inesperados e corpos binários/corrompidos não travam decoder | Alta |

---

## 3. Quantitativo por Categoria

- **Total de alvos catalogados:** 38
- **Alvos no Flutter:** 23 (12 Mutation, 7 Property, 4 Fuzz)
- **Alvos no Backend:** 15 (12 Mutation, 2 Property, 3 Fuzz)
- **Distribuição por Técnica:**
  - Mutation Testing: 24 alvos (12 Flutter, 12 Backend)
  - Property-Based Testing: 9 propriedades (7 Flutter, 2 Backend)
  - Fuzz Testing: 7 baterias de fuzzing (4 Flutter, 3 Backend)
- **Distribuição por Criticidade:**
  - Crítica: 18 alvos
  - Alta: 9 alvos
  - Média: 11 alvos
