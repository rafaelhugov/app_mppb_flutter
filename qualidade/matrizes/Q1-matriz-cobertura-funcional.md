# Q1 - Matriz central de cobertura funcional

Legenda: COBERTO, PARCIAL, AUSENTE, BLOQUEADO, N/A.

| ID | Funcionalidade | Criticidade | Positivo | Negativo | Limites | UI states | Integracao | E2E | Runtime | Cobertura atual | Q futura |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RF-001 | Inicializacao/Home/conectividade | Alta | PARCIAL | PARCIAL | AUSENTE | PARCIAL | PARCIAL | AUSENTE | PARCIAL | PARCIAL | Q2/Q5/Q7/Q9 |
| RF-002 | Noticias | Media | PARCIAL | AUSENTE | AUSENTE | PARCIAL | PARCIAL | AUSENTE | PARCIAL | PARCIAL | Q2/Q3/Q4/Q5/Q7 |
| RF-003 | Diario Oficial | Media | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | PARCIAL | AUSENTE | Q2/Q3/Q4/Q5 |
| RF-004 | Consulta publica de processos | Alta | PARCIAL | PARCIAL | PARCIAL | AUSENTE | PARCIAL | AUSENTE | PARCIAL | PARCIAL | Q2/Q3/Q4/Q5/Q7/Q8 |
| RF-005 | Detalhe processo/captcha | Alta | PARCIAL | PARCIAL | AUSENTE | AUSENTE | PARCIAL | AUSENTE | BLOQUEADO | PARCIAL | Q2/Q3/Q4/Q5/Q7 |
| RF-006 | Emissao certidao extrajudicial | Alta | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | PARCIAL | AUSENTE | Q2/Q3/Q4/Q5/Q12 |
| RF-007 | Consulta certidao por codigo | Media | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | PARCIAL | AUSENTE | Q2/Q3/Q4/Q5 |
| RF-008 | Ouvidoria | Alta | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | BLOQUEADO | AUSENTE | Q2/Q3/Q4/Q5/Q12 |
| RF-009 | Contatos | Baixa | COBERTO | PARCIAL | PARCIAL | PARCIAL | N/A | AUSENTE | PARCIAL | PARCIAL | Q2/Q5/Q9/Q11 |
| RF-010 | Autenticacao/sessao/logout | Critica | PARCIAL | PARCIAL | AUSENTE | AUSENTE | PARCIAL | AUSENTE | BLOQUEADO | PARCIAL | Q2/Q3/Q4/Q5/Q7/Q12 |
| RF-011 | Perfil | Alta | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | BLOQUEADO | AUSENTE | Q2/Q3/Q4/Q5 |
| RF-012 | Carteira funcional | Critica | PARCIAL | PARCIAL | AUSENTE | AUSENTE | PARCIAL | AUSENTE | BLOQUEADO | PARCIAL | Q2/Q3/Q4/Q5/Q7/Q9/Q10 |
| RF-013 | Contracheque/PDF | Critica | PARCIAL | AUSENTE | AUSENTE | PARCIAL | AUSENTE | AUSENTE | BLOQUEADO | PARCIAL | Q2/Q3/Q4/Q5/Q7/Q8 |
| RF-014 | Pagamentos | Alta | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | AUSENTE | BLOQUEADO | AUSENTE | Q2/Q3/Q4/Q5 |
| RF-015 | Designacoes | Alta | PARCIAL | PARCIAL | PARCIAL | PARCIAL | PARCIAL | AUSENTE | BLOQUEADO | PARCIAL | Q2/Q3/Q4/Q5/Q7 |
| RF-016 | Concessoes/afastamentos - consulta | Critica | PARCIAL | PARCIAL | PARCIAL | PARCIAL | PARCIAL | AUSENTE | BLOQUEADO | PARCIAL | Q2/Q3/Q4/Q5/Q7/Q8 |
| RF-017 | Concessoes/afastamentos - operacoes | Critica | PARCIAL | PARCIAL | PARCIAL | PARCIAL | PARCIAL | AUSENTE | BLOQUEADO | PARCIAL | Q2/Q3/Q4/Q5/Q6/Q7/Q12 |
| RF-018 | Notificacoes push/central/dispositivo | Alta | PARCIAL | PARCIAL | PARCIAL | PARCIAL | PARCIAL | AUSENTE | BLOQUEADO | PARCIAL | Q2/Q3/Q4/Q5/Q7/Q12 |
| RF-019 | Navegacao complementar/servicos | Media | PARCIAL | AUSENTE | AUSENTE | PARCIAL | N/A | AUSENTE | PARCIAL | PARCIAL | Q2/Q5/Q9/Q11 |

Justificativas de N/A:

- RF-009 e RF-019 nao possuem endpoint backend proprio para contatos locais e navegacao local.

Resumo por cobertura atual:

| Estado | Quantidade |
| --- | ---: |
| Coberto | 0 |
| Parcial | 13 |
| Ausente | 6 |
| Bloqueado | 0 |

Observacao: "BLOQUEADO" aparece em colunas de Runtime quando credenciais, massa ou dispositivo mobile eram necessarios, mas a cobertura atual da funcionalidade foi classificada pelo conjunto de testes existentes.

