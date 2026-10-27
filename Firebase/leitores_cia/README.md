# Leitores & Cia. — Book Nook

Documentação de requisitos e planejamento de software do projeto acadêmico **Leitores & Cia. — Book Nook**, elaborada com base nas diretrizes da norma **ISO/IEC/IEEE 29148**.

---

## 1. Identificação do Projeto

- **Nome do Projeto:** Leitores & Cia. — Book Nook
- **Natureza:** Projeto acadêmico de desenvolvimento de aplicação móvel com arquitetura em nuvem (BaaS / Serverless).
- **Objetivo Geral:** Prover uma estante digital pessoal para dispositivos móveis, permitindo ao usuário buscar obras literárias, organizar seus livros em diferentes estágios de leitura e acompanhar métricas consolidadas sobre seus hábitos de leitura (quantidade de livros lidos e volume de páginas concluídas).
- **Descrição Resumida:** O aplicativo móvel é construído com Flutter e integra serviços da plataforma Firebase (Authentication e Cloud Firestore), com plano de integração à Google Books API para obtenção de dados bibliográficos e ao Cloud Functions para automação confiável e idempotente das estatísticas de leitura.

---

## 2. Escopo

### 2.1. Dentro do Escopo Inicial (Funcionalidades Planejadas)
- Cadastro e autenticação de usuários por e-mail e senha utilizando Firebase Authentication.
- Encerramento seguro de sessão (logout) e proteção de rotas autenticadas.
- Busca assíncrona de livros por título ou autor consumindo a Google Books API.
- Visualização de detalhes essenciais da obra (título, autor(es), número de páginas e capa).
- Gestão de estante digital individual organizada em três categorias fixas: **"Quero Ler"**, **"Lendo"** e **"Lidos"**.
- Operações de adicionar, consultar, alterar status (mover entre estantes) e remover livros da coleção pessoal.
- Armazenamento em nuvem com Cloud Firestore, garantindo isolamento estrito de dados entre diferentes usuários.
- Automação via Cloud Function disparada por eventos do Firestore (`onWrite`), adotando como estratégia o recálculo dos totais consolidados a partir do conjunto de livros com status "Lidos" do usuário.
- Painel para visualização das estatísticas do usuário (total de livros lidos e total de páginas lidas).
- Tratamento de idempotência e consistência para impedir contagens duplicadas causadas por eventos repetidos e garantir a correta dedução ao sair da estante "Lidos" ou ao excluir livros.
- Proteção de acesso e integridade dos dados por meio de regras de segurança do Firestore (Firestore Security Rules), assegurando que o cliente possa apenas ler suas próprias estatísticas, sendo a gravação restrita exclusivamente à Cloud Function via Firebase Admin SDK.

### 2.2. Fora do Escopo Inicial (Não faz parte desta fase)
- Recursos de rede social (seguir usuários, feed comunitário, compartilhamento social ou curtidas).
- Empréstimo, doação, venda ou troca de exemplares físicos.
- Leitor interno de e-books (visualização de arquivos PDF, EPUB ou audiolivros).
- Leitura de código de barras ou ISBN via câmera do dispositivo.
- Gamificação avançada (sistema de medalhas, rankings competitivos ou metas anuais complexas).
- Suporte oficial ou testes homologados para iOS, Web e Desktop (o ambiente configurado no momento é voltado para Android).

---

## 3. Contexto e Usuários

- **Contexto Operacional:** O sistema opera como um assistente de leitura individual para dispositivos móveis. A comunicação com serviços de nuvem ocorre via internet, utilizando comunicação segura (HTTPS) para persistência em nuvem e consulta a serviços externos.
- **Público-Alvo:** Leitores e estudantes que buscam centralizar o controle de suas leituras em um único ambiente digital, sem a complexidade de planilhas manuais ou anotações físicas.
- **Finalidade do Sistema:** Oferecer uma interface intuitiva e responsiva para catálogo e acompanhamento de leitura, com cálculo automatizado, seguro e auditável do progresso do leitor.

---

## 4. Requisitos Funcionais (RF)

Os requisitos funcionais estão identificados de forma única e estável pela nomenclatura `RF-XX`.

| Identificador | Título | Descrição |
| :--- | :--- | :--- |
| **RF-01** | Cadastro de Usuário | O sistema deve permitir que um novo usuário crie uma conta informando e-mail válido e senha via Firebase Authentication. |
| **RF-02** | Autenticação e Logout | O sistema deve autenticar o usuário com suas credenciais cadastradas e permitir o encerramento seguro da sessão ativa (logout), retornando à tela de autenticação. |
| **RF-03** | Busca de Livros | O sistema deve permitir a pesquisa de obras literárias por título ou autor através da Google Books API. |
| **RF-04** | Exibição de Detalhes da Obra | O sistema deve apresentar os metadados do livro retornado (título, autores, total de páginas e imagem de capa, quando disponíveis). |
| **RF-05** | Estruturação de Estantes | O sistema deve disponibilizar três estantes exclusivas para cada usuário: "Quero Ler", "Lendo" e "Lidos". |
| **RF-06** | Adição à Estante | O sistema deve permitir ao usuário adicionar uma obra localizada na busca a uma de suas três estantes. |
| **RF-07** | Listagem da Coleção Pessoal | O sistema deve exibir os livros salvos pelo usuário autenticado, com filtro por status/estante. |
| **RF-08** | Alteração de Status de Leitura | O sistema deve permitir transferir um livro entre as estantes (ex.: de "Lendo" para "Lidos", ou de "Quero Ler" para "Lendo"). |
| **RF-09** | Remoção de Livro | O sistema deve permitir a exclusão de um livro da estante do usuário, mediante confirmação. |
| **RF-10** | Isolamento de Dados por Usuário | O sistema deve persistir e consultar as informações garantindo que um usuário acesse exclusivamente seus próprios livros e métricas. |
| **RF-11** | Atualização de Estatísticas via Cloud Function | O sistema deve executar uma Cloud Function em resposta a alterações no Firestore (criação, edição ou exclusão) para recalcular e atualizar o documento de resumo de estatísticas do usuário. |
| **RF-12** | Prevenção de Duplicidades e Idempotência por Recálculo | A lógica de estatísticas deve adotar o recálculo dos totais com base em todos os livros atualmente marcados como "Lidos" do usuário, garantindo idempotência frente a eventos repetidos, tratando páginas nulas/ausentes como zero e deduzindo automaticamente valores caso o livro saia de "Lidos" ou seja excluído. |
| **RF-13** | Visualização de Estatísticas | O sistema deve exibir ao usuário autenticado o total consolidado de livros lidos e o total acumulado de páginas lidas a partir do documento de resumo. |

---

## 5. Requisitos Não Funcionais (RNF)

Os requisitos não funcionais seguem identificação estável pela nomenclatura `RNF-XX`.

| Identificador | Categoria | Descrição |
| :--- | :--- | :--- |
| **RNF-01** | Portabilidade e Plataforma | O aplicativo móvel deve ser desenvolvido utilizando o framework Flutter (linguagem Dart), direcionado prioritariamente ao sistema operacional Android. |
| **RNF-02** | Segurança e Controle de Acesso | Todas as operações de leitura e escrita nas coleções do Firestore devem exigir autenticação prévia via Firebase Authentication. |
| **RNF-03** | Integridade dos Dados e Bloqueio de Escrita em Estatísticas | O Cloud Firestore deve aplicar regras de segurança declarativas (*Security Rules*) que impeçam que um usuário acesse registros de outro `uid` e bloqueiem expressamente qualquer gravação ou modificação direta do cliente no documento `users/{userId}/stats/summary`, cuja escrita é exclusiva do backend via Firebase Admin SDK. |
| **RNF-04** | Idempotência e Consistência | O processamento no Cloud Functions deve tolerar reexecuções de gatilhos sem provocar inconsistências nas contagens acumuladas, utilizando estratégia de recálculo determinístico com base nos livros em "Lidos". |
| **RNF-05** | Usabilidade e Feedback | A aplicação deve fornecer indicadores de progresso durante requisições assíncronas (busca externa, autenticação e sincronização) e mensagens claras em cenários de erro. |
| **RNF-06** | Tolerância a Falhas de Rede | O aplicativo deve tratar indisponibilidades da rede durante a busca na Google Books API sem travar a aplicação, informando a falha de conexão ao usuário. |
| **RNF-07** | Desempenho na Interface | A listagem de livros nas estantes deve empregar renderização otimizada com rolagem suave (*lazy loading* / construtores eficientes de listas). |

---

## 6. Interfaces Externas

O projeto prevê o uso integrado das seguintes tecnologias e interfaces:

1. **Flutter (Frontend Mobile):**
   - Papel: Construção da interface gráfica do usuário, gerenciamento de estado da aplicação, navegação entre telas e comunicação com as bibliotecas clientes do Firebase e serviços HTTP.
2. **Firebase Authentication (Serviço de Identidade):**
   - Papel: Gerenciamento do ciclo de vida das contas dos usuários (criação, login com e-mail/senha, logout, validação de sessão e fornecimento do Identificador Único — `uid`).
3. **Cloud Firestore (Banco de Dados NoSQL em Nuvem):**
   - Papel: Armazenamento documental das informações dos livros de cada usuário e do documento consolidado de estatísticas. Responsável pelos gatilhos que notificam o backend sobre mutações de documentos.
4. **Google Books API (API REST Externa):**
   - Papel: Fornecimento de catálogo público para busca de obras literárias a partir de termos informados pelo usuário (título ou autor), retornando metadados como identificador, título, autores, número de páginas e miniatura de capa.
5. **Cloud Functions for Firebase (Backend Serverless):**
   - Papel: Execução de rotinas administrativas acionadas por gatilhos do Firestore (`onWrite` na subcoleção `users/{userId}/books`). Como estratégia planejada para garantir total idempotência e evitar contagens duplicadas decorrentes de eventos repetidos do Firestore, a função recalculará os totais agregando diretamente todos os livros com status `"LIDOS"` do usuário a cada criação, mudança de status ou exclusão, gravando o resultado em `users/{userId}/stats/summary` com credenciais administrativas via Firebase Admin SDK.

---

## 7. Regras de Negócio (RN)

- **RN-01 (Exclusividade de Status):** Cada livro registrado na biblioteca de um usuário deve possuir exatamente um status ativo por vez: `"Quero Ler"`, `"Lendo"` ou `"Lidos"`.
- **RN-02 (Cômputo de Estatísticas):** Apenas os livros cujo status atual seja `"Lidos"` são computados na contagem total de livros lidos e na soma acumulada de páginas lidas.
- **RN-03 (Tratamento de Obras sem Contagem de Páginas):** Se uma obra marcada como `"Lidos"` não contiver número de páginas válido (valor nulo, ausente, negativo ou zero), o sistema deve computar 1 (um) livro lido e somar 0 (zero) ao total de páginas lidas, sem interromper o cálculo.
- **RN-04 (Reversão e Manutenção de Métricas):** Caso uma obra com status `"Lidos"` seja movida para outra estante (`"Lendo"` ou `"Quero Ler"`) ou seja excluída do sistema, suas páginas e a contagem de 1 unidade de livro deixam de fazer parte do total de livros lidos. Em contrapartida, a exclusão ou movimentação de livros que estejam nas estantes `"Quero Ler"` ou `"Lendo"` não afeta e não altera as estatísticas consolidadas.
- **RN-05 (Prevenção de Duplicidades e Estratégia de Recálculo):** Para eliminar o risco de contagens duplicadas decorrentes de alterações repetidas no mesmo documento ou reprocessamento de eventos na infraestrutura do Firestore, a Cloud Function adotará como estratégia o recálculo dos totais agregando todos os livros com status `"Lidos"` do respectivo usuário após qualquer criação, alteração ou exclusão de documento. Essa abordagem assegura que o estado consolidado em `stats/summary` reflita fidedignamente o conjunto real de livros concluídos.
- **RN-06 (Isolamento Multiusuário):** O cálculo e a exibição das métricas devem basear-se estritamente nos registros associados ao usuário autenticado (`uid`), vedado qualquer agrupamento com dados de terceiros.
- **RN-07 (Imutabilidade de Estatísticas pelo Cliente):** O documento `users/{userId}/stats/summary` é estritamente somente leitura para a aplicação cliente (`allow write: if false;`). Qualquer modificação nesse documento deve ser efetuada exclusivamente pela Cloud Function no servidor com o Firebase Admin SDK, impedindo a manipulação arbitrária de números pelo aplicativo cliente.

---

## 8. Dados e Informações

> **Atenção:** As definições abaixo representam a **proposta inicial de modelagem de dados** para o Cloud Firestore. Nenhuma dessas coleções ou documentos foi criada ou validada em ambiente de produção até esta etapa.

### 8.1. Estrutura Proposta no Cloud Firestore

```text
users/{userId}
  ├── profile data (uid, email, createdAt)
  │
  ├── books/{bookId} (Subcoleção de livros do usuário)
  │     ├── id: string (ID do documento)
  │     ├── googleBooksId: string (ID de referência da API externa)
  │     ├── title: string
  │     ├── authors: array de strings
  │     ├── pageCount: number (inteiro >= 0, padrão 0 se não informado)
  │     ├── thumbnailUrl: string (URL da imagem de capa)
  │     ├── status: string ("QUERO_LER" | "LENDO" | "LIDOS")
  │     ├── addedAt: timestamp
  │     └── updatedAt: timestamp
  │
  └── stats/summary (Documento com totais consolidados - Leitura: Cliente | Escrita: Admin SDK)
        ├── totalBooksRead: number (inteiro >= 0)
        ├── totalPagesRead: number (inteiro >= 0)
        └── lastUpdated: timestamp
```

### 8.2. Justificativa da Modelagem e Segurança
- A utilização de uma subcoleção `books` aninhada ao documento de cada usuário (`users/{userId}/books`) facilita a implementação e auditoria das regras de segurança declarativas no Firestore, garantindo que o caminho do documento coincida com o identificador de autenticação (`request.auth.uid == userId`).
- O isolamento do resumo em `stats/summary` permite aplicar regras de segurança diferenciadas: o cliente autenticado possui permissão de leitura (`allow read: if request.auth.uid == userId;`), mas **não possui permissão de escrita** (`allow write: if false;`), blindando as estatísticas contra adulteração direta no cliente.

---

## 9. Critérios de Aceitação (CA)

Condições objetivas para validação das entregas funcionais e não funcionais:

- **CA-01 (Cadastro, Login e Logout — RF-01, RF-02, RNF-02):**
  - Dado um usuário na tela de cadastro, ao submeter e-mail válido e senha com no mínimo 6 caracteres, uma conta correspondente deve ser criada no Firebase Authentication e o usuário deve ser redirecionado para a tela principal autenticado.
  - Ao fornecer credenciais inválidas ou e-mail já cadastrado, uma mensagem de erro compreensível deve ser exibida e a sessão não deve ser aberta.
  - Ao acionar a opção de encerramento de sessão (logout), a sessão ativa no Firebase Authentication deve ser encerrada imediatamente, redirecionando o usuário à tela de login e impedindo o acesso a telas privadas sem nova autenticação.
- **CA-02 (Busca de Livros e Tolerância a Falhas — RF-03, RF-04, RNF-05, RNF-06):**
  - Dado um termo de pesquisa com pelo menos 2 caracteres, o aplicativo deve exibir indicador visual de carregamento e, em seguida, a lista de resultados da Google Books API com título, autores, número de páginas e capa.
  - Se a busca não retornar registros, a mensagem "Nenhum livro encontrado" deve ser apresentada.
  - Se ocorrer falha de conectividade ou resposta de erro da API, o aplicativo não deve travar e deve apresentar mensagem amigável de erro de conexão.
- **CA-03 (Adição à Estante — RF-05, RF-06):**
  - Ao selecionar um livro da busca e salvá-lo com o status "Quero Ler", um novo documento deve ser gravado na subcoleção do usuário no Firestore com os dados da obra e o status correspondente.
- **CA-04 (Consulta, Filtro e Desempenho das Estantes — RF-07, RNF-07):**
  - O usuário autenticado deve conseguir navegar entre as categorias "Quero Ler", "Lendo" e "Lidos", visualizando apenas os livros pertencentes ao status selecionado, com renderização fluida da lista via construtor sob demanda (*lazy loading*).
- **CA-05 (Mudança de Status — RF-08):**
  - Ao alterar o status de um livro de "Lendo" para "Lidos", o campo `status` no documento correspondente no Firestore deve ser atualizado para `"LIDOS"`.
- **CA-06 (Remoção de Livro e Efeito em Estatísticas — RF-09, RN-04):**
  - Ao acionar a opção de remover livro e confirmar o diálogo de exclusão, o documento deve ser excluído do Firestore e removido visualmente da estante.
  - Caso o livro excluído pertença à estante "Quero Ler" ou "Lendo", nenhuma alteração deve ser disparada nas estatísticas consolidadas.
- **CA-07 (Isolamento de Segurança e Bloqueio de Escrita em Estatísticas — RF-10, RNF-02, RNF-03, RN-06, RN-07):**
  - Tentativas diretas de leitura ou gravação de um usuário com `uid_A` em documentos contidos sob o caminho `users/uid_B` devem ser negadas pelo Firestore com erro de permissão negada (*permission-denied*).
  - Tentativas da aplicação cliente de gravar, alterar ou excluir diretamente o documento `users/{userId}/stats/summary` devem ser sumariamente rejeitadas pelas Security Rules com erro de permissão negada (*permission-denied*).
- **CA-08 (Cálculo de Estatísticas e Obras sem Páginas — RF-11, RF-12, RN-02, RN-03):**
  - Quando um livro de 250 páginas tiver seu status alterado para `"LIDOS"`, a Cloud Function deve recalcular o resumo gravando +1 livro e +250 páginas nos totais.
  - Quando uma obra marcada como `"LIDOS"` não contiver número de páginas cadastrado (ou possuir valor nulo/zero), o recálculo deve computar 1 livro lido e somar 0 páginas ao total acumulado de páginas, mantendo a integridade dos dados.
- **CA-09 (Prevenção de Duplicidades, Eventos Repetidos e Saída de "Lidos" — RF-12, RN-04, RN-05, RNF-04):**
  - Caso ocorram atualizações repetidas no mesmo livro ou disparos duplicados de eventos pela infraestrutura do Firestore, o recálculo com base nos livros em `"LIDOS"` deve manter os mesmos totais corretos, sem incremento duplicado.
  - Se um livro de 250 páginas for movido de `"LIDOS"` para `"LENDO"` ou for excluído, o recálculo das estatísticas deve deduzir exatamente 1 livro e 250 páginas dos totais.
- **CA-10 (Exibição de Estatísticas — RF-13):**
  - Na tela de estatísticas, o aplicativo deve apresentar os valores atualizados de livros lidos e páginas lidas obtidos a partir do documento de resumo do usuário logado.
- **CA-11 (Execução e Compatibilidade Android — RNF-01):**
  - O aplicativo deve compilar e inicializar com sucesso na plataforma Android a partir da estrutura Flutter e configurações geradas pelo FlutterFire CLI.

---

## 10. Matriz de Rastreabilidade

Relação entre requisitos de negócio, requisitos do sistema e seus critérios de aceitação:

| Requisito | Descrição Resumida | Regra de Negócio | Critério de Aceitação / Teste |
| :--- | :--- | :--- | :--- |
| **RF-01** | Cadastro de usuário com e-mail/senha | — | CA-01 |
| **RF-02** | Autenticação e encerramento de sessão (Logout) | — | CA-01 |
| **RF-03** | Busca de obras na Google Books API | — | CA-02 |
| **RF-04** | Exibição de metadados da obra | — | CA-02 |
| **RF-05** | Separação em três estantes fixas | RN-01 | CA-03, CA-04 |
| **RF-06** | Adição de livro à estante pessoal | RN-01 | CA-03 |
| **RF-07** | Listagem e visualização da coleção | RN-01, RN-06 | CA-04 |
| **RF-08** | Alteração de status entre estantes | RN-01, RN-02 | CA-05 |
| **RF-09** | Exclusão de obra da estante | RN-04 | CA-06 |
| **RF-10** | Isolamento de dados por usuário | RN-06 | CA-07 |
| **RF-11** | Atualização de estatísticas via Cloud Function | RN-02, RN-03, RN-05 | CA-08, CA-09 |
| **RF-12** | Idempotência e reversão por recálculo | RN-03, RN-04, RN-05 | CA-08, CA-09 |
| **RF-13** | Exibição de totais de livros e páginas lidas | RN-06 | CA-10 |
| **RNF-01** | Plataforma Android e Flutter | — | CA-11 (Build e execução no Android) |
| **RNF-02** | Autenticação obrigatória para persistência | — | CA-01, CA-07 |
| **RNF-03** | Validação no servidor e bloqueio de escrita cliente em stats | RN-06, RN-07 | CA-07 |
| **RNF-04** | Idempotência em background por recálculo | RN-05 | CA-08, CA-09 |
| **RNF-05** | Indicadores de progresso e usabilidade | — | CA-02 |
| **RNF-06** | Tolerância a falhas de rede na busca | — | CA-02 |
| **RNF-07** | Desempenho e fluidez na listagem | — | CA-04 |

---

## 11. Pré-requisitos e Execução

### 11.1. Configurações Confirmadas no Projeto
- **Estrutura Flutter:** Projeto Flutter criado com restrição de versão do Dart SDK compatível (`environment: sdk: ^3.12.0`).
- **Dependências Declaradas no `pubspec.yaml`:**
  - `firebase_core: ^5.0.0`
  - `firebase_auth: ^7.0.0`
  - `cloud_firestore: ^7.0.0`
- **Conexão ao Firebase Confirmada:**
  - Arquivo `firebase.json` presente.
  - Arquivo `lib/firebase_options.dart` gerado pelo FlutterFire CLI com configurações para a plataforma **Android**, associado ao projeto `leitores-cia`.
- **Etapa 5 — Cloud Functions e regras locais:** A função `recalculateReadingStats` e as regras de segurança estão implementadas localmente. A função usa Firebase Admin SDK e recalcula o resumo de `users/{userId}/stats/summary` a cada gravação, alteração ou exclusão de livro.
- **Testes de segurança:** As regras do Firestore são verificadas localmente pelo Emulator Suite com `npm test` dentro de `functions`; a suíte cobre acesso autenticado próprio, negação de acesso anônimo/entre usuários e bloqueio de escrita cliente em estatísticas.
- **Etapa 6 — estatísticas:** A tela Estatísticas consome reativamente o documento `users/{uid}/stats/summary` para exibir os totais gravados pela Cloud Function, com estados de carregamento, erro e resumo ainda inexistente.

### 11.2. Configurações que Ainda Serão Necessárias
- **Busca e estante:** A busca pela Google Books API, exibição dos metadados disponíveis e inclusão na estante do usuário autenticado estão implementadas. O serviço verifica livros já existentes pelo Google Books ID.
- **Publicação da Etapa 5:** Ainda é necessário confirmar no console Firebase que o Cloud Firestore está habilitado e que o projeto atende aos requisitos de faturamento do Cloud Functions. O repositório não contém `.firebaserc`; por isso, os comandos abaixo informam explicitamente o project ID já presente nas configurações do Firebase. Nenhum deploy foi realizado nesta etapa.
  ```bash
  cd functions
  npm install
  npm test
  cd ..
  firebase deploy --only functions --project leitores-cia
  firebase deploy --only firestore:rules --project leitores-cia
  ```
- **Execução do Aplicativo:**
  ```bash
  # Obtenção de dependências
  flutter pub get

  # Execução em emulador ou dispositivo físico Android conectado
  flutter run
  ```

---

## 12. Estado Atual e Limitações

A tabela a seguir consolida o diagnóstico técnico dos componentes do projeto:

| Componente | Estado Atual | Situação Detalhada |
| :--- | :--- | :--- |
| **Projeto Flutter Base** | Configurado | Estrutura de pastas padrão criada com `pubspec.yaml` e `main.dart` inicial. |
| **Conexão Cloud Firestore** | Conectado (Configuração inicial) | Pacotes do Firebase e arquivo `firebase_options.dart` configurados para Android com o projeto `leitores-cia`. |
| **Inicialização no Código Dart** | Implementada | O Firebase é inicializado em `lib/main.dart` com as opções geradas pelo FlutterFire CLI. |
| **Telas e Interface do Usuário** | Parcialmente implementadas | Cadastro, login, estante, busca e exibição das estatísticas consolidadas estão implementados; detalhes completos do livro e atualização do progresso permanecem fora desta etapa. |
| **Integração Google Books API** | Implementada | Pesquisa por título ou autor, exibição dos metadados disponíveis e adição à estante do usuário autenticado. |
| **Firebase Authentication** | Implementada | Cadastro, login, logout e persistência da sessão estão conectados ao Firebase Authentication. |
| **Cloud Functions** | Implementada localmente; não publicada | `functions/recalculateReadingStats` recalcula deterministicamente livros e páginas lidos com Firebase Admin SDK; a execução em produção depende do deploy. |
| **Regras do Firestore** | Implementadas localmente; não publicadas | `firestore.rules` restringe acesso aos dados do usuário autenticado e bloqueia gravações cliente em `stats`. A publicação depende do deploy. |
| **Testes e execução Android** | Em validação | Testes unitários e de widget cobrem as funcionalidades implementadas; a execução em dispositivo/emulador ainda requer validação. |
