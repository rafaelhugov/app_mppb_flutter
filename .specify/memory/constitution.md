# Constituição do Aplicativo MPPB+ (`app_mppb_flutter`)

**Versão:** 1.3.0 | **Ratificação:** 2026-11-18 | **Última Emenda:** 2026-11-19

## Princípios Fundamentais

### I. Arquitetura por Funcionalidade (`lib/features/<funcionalidade>/`)
Toda nova funcionalidade do aplicativo deve ser organizada sob `lib/features/<funcionalidade>/`, separando camadas de apresentação (`ui/`), estado/provedores (`providers/` ou `controller/`), modelos/DTOs (`models/`), repositórios/serviços (`data/` ou `services/`). Módulos compartilhados residem em `lib/core/`.

### II. Stack Padrão e Gerenciamento de Estado
O aplicativo utiliza **Flutter/Dart** (`sdk: ^3.12.2`), **Riverpod** (`flutter_riverpod`) para gerenciamento de estado e injeção de dependências, **GoRouter** (`go_router`) para navegação declarativa e **Dio** (`dio`) para comunicação HTTP com o `mobile-service`. Novas dependências no `pubspec.yaml` exigem justificativa técnica quando os pacotes existentes já atendem ao requisito.

### III. Segurança, Autenticação e Controle de Acesso
Tokens e credenciais locais devem permanecer em armazenamento seguro (`flutter_secure_storage`), nunca em texto plano ou logs. Funcionalidades restritas (como painéis administrativos ou de envio de avisos) devem verificar as permissões retornadas pelo backend/autorização antes de exibir ações ou rotas, sabendo que a segurança efetiva é sempre garantida pelo backend (`mobile-service`).

### IV. Experiência do Usuário, Offline e Notificações
Fluxos críticos de consulta devem tratar graciosamente estados de carregamento, vazio, erro de rede e ausência de conectividade. A integração com notificações push (`firebase_messaging`) deve manter sincronia com a caixa de entrada no aplicativo, tratando *deep links* via `go_router` tanto com o app aberto, em segundo plano ou encerrado.

### V. Português Brasileiro e Convenções de Código
Especificações, planos, tarefas, textos de interface e mensagens ao usuário devem utilizar **português brasileiro (pt-BR)**. Identificadores de código Dart seguem as convenções do projeto (`snake_case` para arquivos, `PascalCase` para classes, `camelCase` para membros).

### VI. Qualidade, Testes e Verificação
Novas regras de estado, parsers/modelos e fluxos críticos de UI devem possuir testes automatizados em `test/` (`flutter test` e `flutter analyze`). Nenhuma entrega pode ser declarada concluída sem informar exatamente os testes e análises executados.

### VII. Controle de Versão, Branch Dedicada por Tarefa e Proibição de Trabalho ou Merge Direto na `master`/`main`
Toda tarefa (novo ajuste, correção ou nova funcionalidade) deve obrigatoriamente iniciar atualizando a branch principal (`git checkout master && git pull`, ou `main`) e criando uma branch dedicada (`git checkout -b <tipo>/<slug>`) a partir dela antes de qualquer edição. É estritamente proibido trabalhar diretamente na branch `master` (ou `main`), realizar commit direto ou `git merge` direto na `master`/`main` local, bem como publicar (`git push`) merges locais diretamente em `origin/master` ou `github/master`. Todo trabalho deve ser comitado e publicado exclusivamente em sua branch dedicada (`feat/...`, `fix/...`, `chore/...`), entregando os links de **Merge Request (GitLab)** e **Pull Request (GitHub)** para aprovação humana. A `master`/`main` local só deve ser atualizada via `git pull` após o merge remoto realizado pelo usuário.

### VIII. Uso Obrigatório do Spec Kit para Novos Ajustes
Sempre que o usuário solicitar novos ajustes, refinamentos visuais, correções ou evoluções em qualquer funcionalidade do aplicativo, é obrigatório utilizar o **Spec Kit** (`specs/<NNN>-<funcionalidade>/spec.md`, `plan.md`, `tasks.md`) e atualizar `.specify/feature.json` antes de implementar as mudanças.

## Organização do Spec Kit
- Especificações: `specs/<NNN>-<funcionalidade>/spec.md`, `plan.md`, `tasks.md`
- Constituição: `.specify/memory/constitution.md`
- Seleção ativa: `.specify/feature.json`
