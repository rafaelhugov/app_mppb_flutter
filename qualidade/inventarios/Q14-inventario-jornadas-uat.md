# Q14 — Inventário de Jornadas UAT

**Data de Elaboração:** 02/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final  
**Escopo:** Aplicação Mobile MPPB (Flutter) & Backend de Homologação (Spring Boot)

---

## 1. Critério de Mapeamento

Este inventário consolida todas as jornadas de usuário efetivamente existentes no produto App MPPB, baseando-se no inventário funcional canônico (Q1), nas jornadas E2E (Q5), nos contratos de API (Q3/Q4) e no comportamento observado no aplicativo Android em homologação.

Nenhum módulo inexistente foi adicionado. As jornadas foram divididas rigorosamente entre **Públicas** (acessíveis a qualquer cidadão sem credencial) e **Autenticadas** (restritas a membros e servidores do MPPB mediante autenticação institucional).

---

## 2. Inventário de Jornadas

| ID | Jornada | Público | Requer login | Dependência | Criticidade |
|---|---|---|---|---|---|
| **Q14-J01** | Inicialização, Splash e Primeira Abertura | Cidadão / Servidor | Não | Instalação APK / Runtime Android | Crítica |
| **Q14-J02** | Navegação na Home Pública e Serviços ao Cidadão | Cidadão / Servidor | Não | Conectividade básica / API Health | Alta |
| **Q14-J03** | Consulta, Listagem e Leitura de Notícias | Cidadão / Servidor | Não | Portal MPPB / API Notícias (`/api/public/noticias`) | Média |
| **Q14-J04** | Acesso ao Diário Oficial e Edições Recentes | Cidadão / Servidor | Não | Base Diários / API (`/api/public/diarios-oficiais/recentes`) | Média |
| **Q14-J05** | Consulta Pública de Processos e Filtros | Cidadão / Servidor | Não | Base MPVirtual / API (`/api/public/v1/processos/consulta`) | Alta |
| **Q14-J06** | Consulta de Canais de Atendimento e Contatos | Cidadão / Servidor | Não | Dados institucionais locais / Links externos | Baixa |
| **Q14-J07** | Solicitação e Validação de Certidão Extrajudicial | Cidadão / Servidor | Não | MPVirtual / API (`/api/public/certidoes-extrajudiciais/pdf`) | Alta |
| **Q14-J08** | Registro de Manifestação na Ouvidoria | Cidadão / Servidor | Não | Serviço externo de Ouvidoria / Captcha / Upload | Média |
| **Q14-J09** | Acesso Restrito / Autenticação Institucional (Login) | Servidor / Membro | Sim | Serviço de Autenticação (`auth-api.mppb.mp.br`) | Crítica |
| **Q14-J10** | Home Autenticada, Dashboard Restrito e Logout | Servidor / Membro | Sim | Sessão ativa / Token de autorização | Crítica |
| **Q14-J11** | Consulta e Visualização do Perfil Funcional | Servidor / Membro | Sim | API Perfil (`/api/perfil/dados`) | Alta |
| **Q14-J12** | Visualização da Carteira Funcional Digital | Servidor / Membro | Sim | API Carteira (`/carteiras-funcionais/dados`, foto) | Crítica |
| **Q14-J13** | Consulta de Contracheques e Exportação PDF | Servidor / Membro | Sim | API Contracheques (`/contracheques/competencias`, PDF) | Crítica |
| **Q14-J14** | Consulta de Informações de Pagamentos | Servidor / Membro | Sim | API Pagamentos (`/pagamentos/exercicios`) | Alta |
| **Q14-J15** | Consulta de Designações Funcionais Ativas | Servidor / Membro | Sim | API Designações (`/api/designacoes/ativas`) | Alta |
| **Q14-J16** | Consulta de Concessões de Folga e Ausências | Servidor / Membro | Sim | API RH (`/api/recursos-humanos/minhas-concessoes-folga`) | Alta |
| **Q14-J17** | Operações de Solicitação de Concessões/Folgas | Servidor / Membro | Sim | API RH / MPVirtual (`/api/recursos-humanos/concessoes/...`) | Alta |
| **Q14-J18** | Diagnóstico e Registro de Notificações Push (FCM) | Servidor / Membro | Sim | Firebase FCM / API (`/api/notificacoes/dispositivos`) | Média |

---

## 3. Síntese por Escopo

- **Total de Jornadas Mapeadas:** 18
- **Jornadas Públicas:** 8 (Q14-J01 a Q14-J08)
- **Jornadas Autenticadas:** 10 (Q14-J09 a Q14-J18)
- **Criticidade:**
  - Crítica: 5 jornadas
  - Alta: 9 jornadas
  - Média: 3 jornadas
  - Baixa: 1 jornada
