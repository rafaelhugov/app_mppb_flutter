# Q14 — Datasets Sintéticos para UAT Interno e Store Review

- **Fase:** Q14 — Qualidade e Homologação
- **Atividade:** Q14-R03-R03 — Hardening e Auditoria de Coerência dos Datasets
- **Data:** 03/10/2026
- **Status:** Disponível no Backend (`SyntheticDataService`); Coerência Auditada

---

## 1. Princípios dos Datasets

1. **Origem dos Dados Fictícios:** O cadastro sintético utiliza identificadores gerados procedimentalmente para homologação.
2. **Declaração Formal de CPF:** **CPF sintético utilizado exclusivamente pela fixture, não derivado intencionalmente de cadastro funcional real.** As fixtures permanecem confinadas estritamente ao sandbox de teste e nenhum sistema corporativo externo é consultado utilizando tais identificadores.
3. **Marcação Visual de Documentos:** Documentos digitais, carteiras e contracheques gerados pela infraestrutura sintética contêm a inscrição obrigatória:
   `DADOS SINTÉTICOS — UAT SEM VALOR FUNCIONAL`
4. **Reutilização Inteligente:** As 6 identidades de autenticação (UAT Interno, Google Review e Apple Review) convergem em apenas **dois datasets funcionais**:
   - `DATASET_MEMBRO`
   - `DATASET_SERVIDOR`
5. **Contratos Idênticos:** Os DTOs retornados são exatamente os mesmos consumidos pelo app Flutter em ambiente de produção.
6. **Sem Credenciais Versionadas:** As credenciais de acesso são injetadas exclusivamente via variáveis de ambiente.

---

## 2. Auditoria de Coerência de Rótulos (Dashboard × Perfil)

Durante o smoke físico com as identidades sintéticas, observou-se a seguinte diferença textual entre as telas:

| Perfil | Tela do Dashboard | Tela de Perfil | Classificação |
|---|---|---|---|
| **Membro (`uat.membro`)** | `Promotor de Justiça` | `Promotor de Justiça Substituto` | **INTENCIONAL** |
| **Servidor (`uat.servidor`)** | `Analista Ministerial` | `Analista Ministerial - TI` | **INTENCIONAL** |

### Justificativa da Coerência:
A auditoria arquitetural no backend e no Flutter comprovou que essa diferença é **estritamente intencional** e segue o modelo institucional de produção do MPPB:
- O **Dashboard** consome o objeto `carteira` e exibe o campo `cargo` (que representa a carreira geral: *Promotor de Justiça* ou *Analista Ministerial*);
- A tela de **Perfil** consome o objeto `perfil` e prioriza o campo `tituloCargo` (que representa a especialidade ou posição funcional detalhada: *Promotor de Justiça Substituto* ou *Analista Ministerial - TI*), aplicando fallback para `cargo` apenas quando `tituloCargo` for nulo;
- Os DTOs do `SyntheticDataService` fornecem ambos os campos preenchidos de forma coerente, permitindo que cada tela renderize com precisão a granularidade exigida pelo design institucional do MPPB, sem necessidade de alterações na UI.

---

## 3. Mapeamento de Identidades

| Identidade de Login | Origem da Conta | Perfil Funcional | Dataset Vinculado | Propósito |
|---|---|---|---|---|
| `uat.membro` | `UAT` | `MEMBRO` | `DATASET_MEMBRO` | Testes internos de homologação (Membro) |
| `uat.servidor` | `UAT` | `SERVIDOR` | `DATASET_SERVIDOR` | Testes internos de homologação (Servidor) |
| `review.google.membro` | `REVIEW_GOOGLE` | `MEMBRO` | `DATASET_MEMBRO` | Avaliação da Google Play Store (Promotor) |
| `review.google.servidor` | `REVIEW_GOOGLE` | `SERVIDOR` | `DATASET_SERVIDOR` | Avaliação da Google Play Store (Analista) |
| `review.apple.membro` | `REVIEW_APPLE` | `MEMBRO` | `DATASET_MEMBRO` | Avaliação da Apple App Store (Promotor) |
| `review.apple.servidor` | `REVIEW_APPLE` | `SERVIDOR` | `DATASET_SERVIDOR` | Avaliação da Apple App Store (Analista) |

---

## 4. Especificação do Dataset Membro (`DATASET_MEMBRO`)

### 4.1. Dados Cadastrais e Perfil Funcional
- **ID Sintético:** `UAT-MEMBRO-001`
- **Nome Completo:** `Lucas Almeida Monteiro`
- **Tipo Funcional:** `MEMBRO`
- **Cargo:** `Promotor de Justiça`
- **Título do Cargo (Perfil):** `Promotor de Justiça Substituto`
- **Especialidade:** `Entrância Final`
- **Lotação:** `1ª Promotoria de Justiça de Homologação`
- **Matrícula:** `900001`
- **CPF Sintético:** `000.000.001-91` (CPF sintético de fixture exclusiva)
- **Situação Funcional:** `Ativo`
- **E-mail:** `membro.uat@example.invalid`
- **Telefone:** `(83) 98888-0001`
- **Data de Posse:** `15/03/2012`
- **Órgão:** `Ministério Público da Paraíba`

### 4.2. Carteira Funcional
- **Foto:** Imagem JPEG 300x300 procedural sintética gerada em memória (`SyntheticDataService.gerarFotoProcedural`).
- **Hash de Autenticidade:** `hash-uat-membro-001`
- **Via:** `1ª Via Digital`
- **Código de Segurança:** `UAT-SEC-001`
- **QR Code / Validação:** Aponta para URL de sandbox de homologação (`https://homologacao.mppb.mp.br/valida-carteira/uat-membro-001`), evitando qualquer consulta a banco institucional real.
- **Data de Emissão:** `01/01/2026`
- **Data de Validade:** `31/12/2030`

### 4.3. Contracheques (Múltiplas Competências)
- **Competências Disponíveis:**
  1. `09/2026` (Mais recente):
     - Vencimento Básico: R$ 33.689,11
     - Parcela Compensatória: R$ 3.368,91
     - Total de Vencimentos: R$ 37.058,02
     - Previdência Oficial: R$ 4.817,54
     - Imposto de Renda: R$ 7.214,12
     - Total de Descontos: R$ 12.031,66
     - Valor Líquido: R$ 25.026,36
  2. `08/2026`: Vencimentos R$ 37.058,02 | Descontos R$ 12.031,66 | Líquido R$ 25.026,36
  3. `07/2026`: Vencimentos R$ 37.058,02 | Descontos R$ 12.031,66 | Líquido R$ 25.026,36
- **Download de PDF:** Documento PDF binário gerado dinamicamente com cabeçalhos padrão e marcação inequívoca: `DADOS SINTÉTICOS — UAT SEM VALOR FUNCIONAL`.

### 4.4. Pagamentos e Diárias
- **Exercícios Disponíveis:** `2026`, `2025`
- **Registros (2026):**
  1. Processo: `MPPB-2026-00123` | Diárias Homologação João Pessoa | R$ 1.250,00
  2. Processo: `MPPB-2026-00456` | Ressarcimento Deslocamento Campina Grande | R$ 480,00
  - Total Bruto: R$ 1.730,00
- **Registros (2025):**
  1. Processo: `MPPB-2025-00987` | Diárias Congresso Nacional do MP | R$ 2.400,00
  - Total Bruto: R$ 2.400,00

### 4.5. Designações
- **Designação Ativa:**
  - Órgão: `1ª Promotoria de Justiça de Homologação`
  - Cargo: `Promotor de Justiça Titular`
  - Portaria: `Portaria PGJ nº 0123/2026`
  - Início: `01/02/2026` | Fim: `31/01/2028`
  - Tipo: `Titularidade`
- **Designação Histórica:**
  - Órgão: `Promotoria de Justiça de Cabedelo (Substituição)`
  - Portaria: `Portaria PGJ nº 0845/2025`
  - Início: `01/08/2025` | Fim: `31/08/2025`
  - Tipo: `Substituição Cumulativa`

### 4.6. Concessões e Folgas (Sandbox Mutável)
- **Concessão 1 (Férias):**
  - ID: `1001` | Tipo: `Férias` | Período: `1º Período 2025/2026`
  - Dias Concedidos: `30` | Saldo Restante: `30` | Status: `DISPONÍVEL`
- **Concessão 2 (Folga Compensatória):**
  - ID: `1002` | Tipo: `Folga Compensatória` | Descrição: `Plantão Judiciário`
  - Dias Concedidos: `2` | Saldo Restante: `2` | Status: `DISPONÍVEL`
- **Ausências no Calendário:**
  - `05/10/2026` a `09/10/2026` (5 dias) | Folga Compensatória Plantão | Status: `APROVADA`
- **Operações Permitidas:**
  - Solicitação de férias e folgas;
  - Cancelamento / adiamento de períodos no sandbox isolado.

---

## 5. Especificação do Dataset Servidor (`DATASET_SERVIDOR`)

### 5.1. Dados Cadastrais e Perfil Funcional
- **ID Sintético:** `UAT-SERVIDOR-001`
- **Nome Completo:** `Mariana Costa Ribeiro`
- **Tipo Funcional:** `SERVIDOR`
- **Cargo:** `Analista Ministerial`
- **Título do Cargo (Perfil):** `Analista Ministerial - TI`
- **Especialidade:** `Desenvolvimento de Sistemas`
- **Lotação:** `DITEC — Departamento de Tecnologia da Informação (Homologação)`
- **Matrícula:** `900002`
- **CPF Sintético:** `000.000.002-72` (fixture matemática exclusiva de teste)
- **Situação Funcional:** `Ativo`
- **E-mail:** `servidor.uat@example.invalid`
- **Telefone:** `(83) 98888-0002`
- **Data de Posse:** `10/08/2018`
- **Órgão:** `Ministério Público da Paraíba`

### 5.2. Carteira Funcional
- **Foto:** Imagem JPEG 300x300 procedural sintética gerada em memória (`SyntheticDataService.gerarFotoProcedural`).
- **Hash de Autenticidade:** `hash-uat-servidor-001`
- **Via:** `1ª Via Digital`
- **Código de Segurança:** `UAT-SEC-002`
- **QR Code / Validação:** Aponta para URL de sandbox de homologação (`https://homologacao.mppb.mp.br/valida-carteira/uat-servidor-001`).
- **Data de Emissão:** `01/01/2026`
- **Data de Validade:** `31/12/2030`

### 5.3. Contracheques
- **Competências Disponíveis:**
  1. `09/2026`: Vencimentos R$ 10.740,48 | Descontos R$ 2.878,36 | Líquido R$ 7.862,12
  2. `08/2026` e `07/2026`: Padrão histórico coerente.
- **Download de PDF:** Documento PDF binário gerado dinamicamente com marcação d'água: `DADOS SINTÉTICOS — UAT SEM VALOR FUNCIONAL`.

### 5.4. Pagamentos
- **Exercício Disponível:** `2026`
  1. Processo: `MPPB-2026-SERV-01` | Diárias Capacitação Brasília | R$ 850,00
  - Total Bruto: R$ 850,00
- **Exercício Vazio:** `2025`
  - Retorna lista vazia e total bruto `R$ 0,00` (permite testar o estado vazio no app Flutter).

### 5.5. Designações
- **Comportamento Institucional Real:** Servidores não possuem designações ministeriais de atuação judicial ou plantão de promotoria.
- **Resultado:** Lista de designações vazia (`[]`), exercitando o empty state na interface do Flutter.

### 5.6. Concessões e Folgas (Sandbox Mutável)
- **Concessão 1 (Férias):**
  - ID: `2001` | Tipo: `Férias` | Período: `Período Aquisitivo 2025/2026`
  - Dias Concedidos: `30` | Saldo Restante: `30` | Status: `DISPONÍVEL`
- **Ausências no Calendário:** Nenhuma ausência cadastrada inicialmente (estado limpo).
- **Operações Permitidas:** Agendamento e cancelamento de férias no sandbox.

---

## 6. Gerenciamento e Reset do Sandbox

- Todas as alterações (solicitações de férias, alteração de status e registro de tokens FCM) residem em memória no `SyntheticSandboxStorage`.
- **Reset Automático:** Ocorre a cada reinicialização da aplicação backend.
- **Reset Controlado Programático:** O método `SyntheticSandboxStorage.reset()` é invocado no `@BeforeEach` das rotinas de teste automatizado.
- **Isolamento Externo:** Nenhum endpoint HTTP público de reset é exposto.
