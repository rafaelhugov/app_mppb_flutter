# Q8 — Inventário de Operações, Dependências e Classificação para Testes de Performance

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Objetivo: Mapear todas as operações do App MPPB e de seu Backend (`mobile-service`), avaliando viabilidade de carga, dependências externas e isolamento estrito contra produção.

---

## 1. Regra Fundamental de Segurança em Q8

> [!CAUTION]
> **PROIBIÇÃO EXPRESSA DE CARGA CONTRA PRODUÇÃO E SISTEMAS EXTERNOS**
> - Nenhum teste de carga, stress, spike ou soak pode ser direcionado a `https://aplicativo-api.mppb.mp.br`.
> - É proibido gerar carga contra dependências downstream reais (Auth Institucional, MPVirtual, JCR, Firebase, CMS).
> - As medições de performance de backend devem ser executadas em **ambiente local isolado**, utilizando stubs/mocks determinísticos para downstream.

---

## 2. Inventário de Operações e Endpoints (Q8-T01)

| ID | Endpoint / Fluxo | Tipo | Dependência Downstream | Seguro para Carga? | Classificação Q8 | Métrica Principal |
| :--- | :--- | :---: | :---: | :---: | :--- | :--- |
| **Q8-OP-01** | `GET /api/public/health` | Leitura (Probe) | Nenhuma | Sim (Local) | **SEGURO LOCAL** | RPS, Latência (p50/p95/p99), CPU |
| **Q8-OP-02** | `GET /api/public/noticias` | Leitura (Pública) | CMS Institucional / RSS | Sim (com Stub) | **MOCK EXTERNO NECESSÁRIO** | Throughput, Alocação de Memória, Parsing |
| **Q8-OP-03** | `GET /api/perfil/dados` | Leitura (Autenticada) | Auth API (`/usuarios/autorizados`) | Sim (com Stub) | **MOCK EXTERNO NECESSÁRIO** | Validação de Token, Serialização DTO |
| **Q8-OP-04** | `GET /carteiras-funcionais/dados` | Leitura (Autenticada) | JCR / Repositório Local | Sim (com Stub) | **MOCK EXTERNO NECESSÁRIO** | Tempo de montagem, Consumo de Heap |
| **Q8-OP-05** | `GET /carteiras-funcionais/foto` | Leitura (Binária) | JCR Jackrabbit | Sim (com Stub) | **MOCK EXTERNO NECESSÁRIO** | Transferência de bytes, Pool I/O |
| **Q8-OP-06** | `GET /pagamentos/exercicios` | Leitura (Autenticada) | Repositório / Cache | Sim (Local) | **SEGURO LOCAL** | Latência sob concorrência |
| **Q8-OP-07** | `GET /pagamentos/{ano}` | Leitura (Autenticada) | Repositório / Cache | Sim (Local) | **SEGURO LOCAL** | Filtragem em memória, p95 |
| **Q8-OP-08** | `GET /contracheque/exercicios` | Leitura (Autenticada) | Repositório / Folha | Sim (Local) | **SEGURO LOCAL** | Throughput sob concorrência |
| **Q8-OP-09** | `GET /contracheque/exercicio/{ano}` | Leitura (Autenticada) | Repositório / Folha | Sim (Local) | **SEGURO LOCAL** | Latência, Alocação de Objetos |
| **Q8-OP-10** | `GET /contracheque/{ano}/{mes}/pdf` | Leitura (Geração PDF) | JasperReports / PDFBox | Sim (Controlado) | **SEGURO LOCAL** | CPU pico, Garbage Collection, Heap |
| **Q8-OP-11** | `GET /designacoes` | Leitura (Autenticada) | Repositório / Cache | Sim (Local) | **SEGURO LOCAL** | Filtros concorrentes, Throughput |
| **Q8-OP-12** | `GET /recursos-humanos/minhas-concessoes-folga` | Leitura (Autenticada) | MPVirtual Feign Client | Sim (com Stub) | **MOCK EXTERNO NECESSÁRIO** | Desempenho do Client Feign / Handler |
| **Q8-OP-13** | `GET /recursos-humanos/minhas-ausencias` | Leitura (Autenticada) | MPVirtual Feign Client | Sim (com Stub) | **MOCK EXTERNO NECESSÁRIO** | Latência de agregação |
| **Q8-OP-14** | `POST /processos/consulta` | Consulta Pública | Captcha Service | Não para carga | **BLOQUEADO** | Bloqueado por restrição anti-bot/captcha |
| **Q8-OP-15** | `POST /acesso/autoriza` (Login) | Mutação (Sessão) | Auth API Institucional | Não para carga | **BLOQUEADO** | Risco de lock de conta e sobrecarga Auth |
| **Q8-OP-16** | `POST /recursos-humanos/.../solicitacoes` | Mutação (Férias) | MPVirtual | Não para carga | **BLOQUEADO** | Efeito colateral institucional real |
| **Q8-OP-17** | `POST /recursos-humanos/.../adiamentos` | Mutação (Férias) | MPVirtual | Não para carga | **BLOQUEADO** | Efeito colateral institucional real |
| **Q8-OP-18** | `POST /recursos-humanos/.../antecipacoes` | Mutação (Férias) | MPVirtual | Não para carga | **BLOQUEADO** | Efeito colateral institucional real |
| **Q8-OP-19** | `POST /recursos-humanos/.../cancelamentos` | Mutação (Férias) | MPVirtual | Não para carga | **BLOQUEADO** | Efeito colateral institucional real |
| **Q8-OP-20** | `POST /recursos-humanos/.../suspensoes-integrais` | Mutação (Férias) | MPVirtual | Não para carga | **BLOQUEADO** | Efeito colateral institucional real |
| **Q8-OP-21** | `POST /recursos-humanos/.../suspensoes-parciais` | Mutação (Férias) | MPVirtual | Não para carga | **BLOQUEADO** | Efeito colateral institucional real |
| **Q8-OP-22** | `POST /certidao-extrajudicial/emitir` | Mutação (Oficial) | Corregedoria / Selo | Não para carga | **BLOQUEADO** | Efeito jurídico/cartorário real |
| **Q8-OP-23** | `POST /ouvidoria/manifestacao` | Mutação (Oficial) | Ouvidoria / Protocolo | Não para carga | **BLOQUEADO** | Abertura de protocolo público real |
| **Q8-OP-24** | `POST /notificacoes/dispositivos` | Mutação (Registro) | DB Local / Firebase | Sim (Local) | **MOCK EXTERNO NECESSÁRIO** | Concorrência de escrita, locks |
| **Q8-OP-25** | `DELETE /notificacoes/dispositivos/{id}` | Mutação (Desativação) | DB Local / Firebase | Sim (Local) | **MOCK EXTERNO NECESSÁRIO** | Concorrência de deleção |

---

## 3. Síntese do Inventário

- **Total de Operações Catalogadas**: 25
- **Seguro Local**: 7 operações (Health, Pagamentos Exercícios/Dados, Contracheque Exercícios/Ano/PDF, Designações)
- **Mock Externo Necessário**: 8 operações (Notícias, Perfil, Carteira Dados/Foto, RH Concessões/Ausências, Notificações FCM)
- **Bloqueadas para Testes de Carga**: 10 operações (Login institucional, Processos com Captcha, 6 Mutações de Férias RH, Emissão de Certidão, Envio de Ouvidoria)
- **Critério de Seleção para Carga**: Serão avaliados prioritariamente os endpoints de leitura de alta frequência (`/health`, `/noticias`, `/perfil`, `/pagamentos`, `/carteiras-funcionais`), simulando downstreams externos sem sobrecarregar serviços corporativos.
