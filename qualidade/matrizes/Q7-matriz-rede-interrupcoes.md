# Q7 — Matriz de Testes de Rede, Offline e Interrupções

Data: 2026-09-30  
Branch: `qualidade/q7-rede-offline-interrupcoes`  
Objetivo: Mapeamento de todos os cenários de rede, indisponibilidade, timeout, erro HTTP, respostas truncadas, interrupções de download e lifecycle com resultados obtidos e comportamento de recuperação.

---

## Matriz de Execução Q7

| ID | Fluxo | Falha / Cenário de Rede | Comportamento Esperado | Comportamento Obtido | Recuperação | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **Q7-MAT-01** | Notícias | Sem rede antes da chamada (`connectionError`) | Encerra loading, não crasha, exibe erro coerente na UI e botão "Tentar novamente" | Provider transiciona `isLoading: false`, `error` amigável preenchido, botão reabilitado | Retry manual após retorno da conectividade carrega notícias com sucesso | PASSOU |
| **Q7-MAT-02** | Notícias | Queda durante requisição (`stream interrupted / cancel`) | Não corrompe lista, limpa loading, sem dados parciais, resposta tardia não contamina | Loading encerra, lista permanece consistente, nenhuma exceção não tratada | Novo request completo sob demanda | PASSOU |
| **Q7-MAT-03** | Notícias | Timeout de conexão (`connectTimeout`) | Timeout controlado (15s padrão Dio), sem wait infinito, erro amigável de timeout | Interceptado deterministicamente; estado de erro claro exibido na UI | Retry manual carrega dados | PASSOU |
| **Q7-MAT-04** | Notícias | Retry de leitura seguro (Falha 1 → Retry manual → Sucesso) | Erro anterior é limpo, loading reinicia, novos dados são renderizados na tela | Estado limpa erro, `isLoading: true`, dados válidos populam o estado | Sucesso transparente ao usuário | PASSOU |
| **Q7-MAT-05** | Notícias | Dados prévios renderizados + Refresh falha | Lista de notícias anterior NÃO é apagada da tela; erro é notificado sem destruir dados | Notícias em tela preservadas intactas; estado notifica falha de atualização | Próximo refresh bem-sucedido atualiza lista | PASSOU |
| **Q7-MAT-06** | Inicialização / Home | Inicialização do App sem conexão com a internet | Home pública inicializa normalmente; cards locais funcionam; falha em notícias não impede uso | Home abre, `connectivityProvider` detecta offline, widgets remotos exibem feedback | Conexão restabelecida permite pull-to-refresh | PASSOU |
| **Q7-MAT-07** | Conectividade | Reconexão após indisponibilidade | Transição de offline para online detectada; tentativa de refresh subsequente tem sucesso | `connectivityProvider` atualiza estado para online; requests subsequentes operam normalmente | Total recuperação sem necessidade de reiniciar o app | PASSOU |
| **Q7-MAT-08** | Perfil | Offline antes da requisição com cache prévio | Se usuário já logou anteriormente, exibe dados do cache seguro em vez de tela de erro | Recupera Perfil do cache local indexado por username; exibe badge/indicativo offline | Cache visualizável offline; sincroniza na reconexão | PASSOU |
| **Q7-MAT-09** | Carteira Funcional | Sem internet antes da chamada com cache prévio | Carteira funcional é renderizada a partir dos dados locais em secure storage | Dados e QR code locais são apresentados sem travar; badge offline exibido | Atualiza dados quando online | PASSOU |
| **Q7-MAT-10** | Pagamentos | Timeout de recebimento (`receiveTimeout`) | Exercício selecionado não trava UI; loading encerra com erro amigável | Notifier encerra loading, atribui mensagem de erro e mantém lista de anos | Selecionar novamente ou retry manual recupera | PASSOU |
| **Q7-MAT-11** | Contracheque | Download de PDF interrompido | Conexão abortada no meio da transferência não gera arquivo corrompido nem sucesso falso | Arquivo temporário é descartado/não persistido como válido; erro amigável informado | Usuário clica novamente em baixar e obtém arquivo íntegro | PASSOU |
| **Q7-MAT-12** | Recursos Humanos | Falha de rede em submissão mutável (Férias) | Proibido retry automático (`RISCO-Q6-001`); UI não reenvia automaticamente | Request não é reenviado em background; usuário recebe feedback de erro e instrução | Usuário verifica status antes de reenviar manualmente | PASSOU |
| **Q7-MAT-13** | Sessão Autenticada | HTTP 401 durante requisição autenticada | Interceptor detecta 401, dispara `authProvider.logout()`, invalida sessão e redireciona | Logout atômico disparado pelo Dio interceptor; credenciais locais limpas | Usuário é direcionado à tela de login | PASSOU |
| **Q7-MAT-14** | Sessão Autenticada | HTTP 403 (Acesso não autorizado ao recurso) | Não efetua logout indevido; apenas exibe erro de permissão para a operação | Interceptor não chama logout em 403; tela apresenta mensagem de permissão negada | Sessão preservada; usuário pode navegar em outras áreas | PASSOU |
| **Q7-MAT-15** | Disponibilidade | HTTP 500 / 502 / 503 / 504 no Backend | Exibe mensagem amigável de indisponibilidade de serviço; encerra loading; sem crash | UI encerra loading; erro de serviço temporariamente indisponível exibido | Retry manual sob demanda | PASSOU |
| **Q7-MAT-16** | Parsing de Rede | Resposta truncada / JSON malformado / corpo vazio | Não propaga parse exception descontrolada; traduz para erro controlado na UI | Tratamento captura `FormatException` / `TypeError`, encerra loading e sinaliza erro | Novo request com resposta íntegra recupera | PASSOU |
| **Q7-MAT-17** | Lifecycle Flutter | Request em trânsito e provider / widget é descartado | Sem `setState` / `state` update pós-dispose; sem crash de lifecycle | Notifier valida `ref.mounted` ou lifecycle antes de mutar estado | Retomada coerente na recriação da tela | PASSOU |
| **Q7-MAT-18** | Rate Limiting | HTTP 429 Too Many Requests | Se houver rate limiting, não efetuar retry agressivo | Ausência de contrato ou middleware de rate limiting na arquitetura mobile atual; sem teste de injeção ativo | N/A (sem política de 429 vigente) | N/A |
| **Q7-MAT-19** | Backend Mobile | Dependência externa (Auth API / MPVirtual) fora do ar | Backend captura erro de conexão/503 da dependência e traduz para resposta HTTP controlada | Controller retorna 503 Service Unavailable com payload padronizado, sem stack trace | Cliente mobile consome erro padronizado | PASSOU |
| **Q7-MAT-20** | Backend Mobile | Tratamento de timeout após exceção do cliente Feign | `feign.RetryableException` de timeout capturada e traduzida para resposta HTTP segura sem expor stack | Handler responde HTTP 503 com ProblemDetail padronizado (comprovado no handler; retenção de socket congelado coberta por `RISCO-Q7-001`) | Thread liberada para pool do servidor | PASSOU |
| **Q7-MAT-21** | Android Físico | Modo Offline Real na Jornada Pública | Dispositivo desconectado (Wi-Fi/Dados desligados) executado contra endpoint público de produção por configuração de build: Home abre, notícias acusam erro controlado | App mantém estabilidade sem crash; logcat limpo de exceções não tratadas | Wi-Fi religado: pull-to-refresh atualiza com sucesso | PASSOU |

---

## Síntese da Matriz

- **Total de Cenários Analisados**: 21
- **PASSOU**: 20
- **N/A**: 1 (Q7-MAT-18: HTTP 429 não aplicável/sem contrato no projeto)
- **FALHOU**: 0
- **PARCIAL**: 0
- **BLOQUEADO**: 0
