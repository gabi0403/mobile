# Documento de Identidade Visual e Design System — Leitores & Cia.

Este documento consolida as especificações de design extraídas diretamente do projeto oficial no **Stitch** via StitchMCP.

---

## 1. Identificação do Projeto no Stitch

- **Nome do Projeto no Stitch:** `leitores_cia`
- **Resource Name:** `projects/120332651349505398`
- **Nome do Design System:** `Warm Editorial Book Nook`
- **Tipo de Dispositivo:** `MOBILE` (Design voltado para smartphones, otimizado para a ergonomia do Android)
- **Modo de Cor:** `LIGHT`
- **Arredondamento Padrão:** `ROUND_EIGHT` / `ROUND_TWELVE` (Cantos suaves de 8px a 16px para cards e botões; 9999px para chips e badges)
- **Conceito Visual:** *Tactile Minimalist / Warm Editorial* — Uma união entre o rigor estrutural do Material You (Material 3) e o aconchego sensorial de uma biblioteca física (tons de papel não branqueado, verde-sálvia botânico, terracota suave e tipografia serifada literária para títulos).

---

## 2. Paleta de Cores (Design Tokens Oficiais)

As cores abaixo foram obtidas da especificação `designTheme.namedColors` e do arquivo `tailwind.config` gerado pelo Stitch:

### 2.1. Cores Primárias (Verde Sálvia Editorial)
- **Primary:** `#3E644A` — Botões principais de ação (Entrar, Adicionar à Estante), tabs ativas e destaques primários.
- **On-Primary:** `#FFFFFF` — Tipografia e ícones sobre superfícies primárias.
- **Primary Container:** `#567D62` — Estado de foco/hover de botões primários e badges de contagem ativa.
- **On-Primary Container:** `#F6FFF4` — Texto sobre containers primários.
- **Primary Fixed:** `#C2EDCB` — Pílula de destaque ativo na barra de navegação inferior.
- **Primary Fixed Dim:** `#A7D1B0` — Subtítulos e legendas em cards com fundo primário.
- **On-Primary Fixed:** `#00210F` — Glifos e textos de contraste sobre `Primary Fixed`.

### 2.2. Cores Secundárias (Tons Terrosos e Café)
- **Secondary:** `#6C5B51` — Subtítulos, nomes de autores, metadados e ícones neutros.
- **On-Secondary:** `#FFFFFF` — Texto sobre fundos secundários.
- **Secondary Container:** `#F6DED1` — Badges de status ("Quero Ler"), cards acolhedores de citações e destaques amenos.
- **On-Secondary Container:** `#726157` — Texto e ícones sobre `Secondary Container`.
- **Secondary Fixed:** `#F6DED1`
- **Secondary Fixed Dim:** `#D9C2B6`

### 2.3. Cores Terciárias (Terracota Quente)
- **Tertiary:** `#8D4932` — Marcadores especiais, estrelas de avaliação, aspas de citações e badges de destaque.
- **On-Tertiary:** `#FFFFFF`
- **Tertiary Container:** `#AB6148`
- **On-Tertiary Container:** `#FFFBFF`
- **Tertiary Fixed:** `#FFDBD0` — Chips de status "Lido" e badges concluídos.
- **Tertiary Fixed Dim:** `#FFB59E`

### 2.4. Superfícies, Fundos e Neutros (Tons Pergaminho / Papel Suave)
- **Surface / Background:** `#FCF9F4` — Fundo geral da aplicação (off-white acolhedor que reduz fadiga ocular).
- **On-Surface / On-Background:** `#1C1C19` — Cor principal de texto e títulos (café profundo, sem o contraste agressivo do preto puro).
- **Surface Container Lowest:** `#FFFFFF` — Fundo de menus suspensos, campos com foco e modais.
- **Surface Container Low:** `#F6F3EE` — Superfície de cards de livros, inputs em repouso e caixas de busca.
- **Surface Container:** `#F0EDE9` — Divisores de seção e chips de filtros secundários.
- **Surface Container High:** `#EBE8E3` — Trilha inativa de barras de progresso e tabs inativas.
- **Surface Container Highest:** `#E5E2DD` — Bordas suaves e divisores horizontais.
- **Surface Variant:** `#E5E2DD`
- **On-Surface Variant:** `#424942` — Textos de apoio, contadores de páginas e legendas secundárias.
- **Outline:** `#727972` — Contornos de inputs e placeholders.
- **Outline Variant:** `#C1C8C0` — Bordas decorativas de baixa opacidade.

### 2.5. Erro e Alerta
- **Error:** `#BA1A1A` — Botões de exclusão e mensagens de validação.
- **On-Error:** `#FFFFFF`
- **Error Container:** `#FFDAD6` — Fundo do diálogo de confirmação de exclusão e alertas de erro.
- **On-Error Container:** `#93000A`

---

## 3. Tipografia

A identidade tipográfica emprega uma abordagem híbrida: **Literata** para títulos e elementos literários, combinada com **Plus Jakarta Sans** para interface funcional e legibilidade de dados.

### 3.1. Famílias Tipográficas
1. **Títulos Literários:** `Literata` (Serifada com desenho orgânico, elegante e humanista).
2. **Interface e Metadados:** `Plus Jakarta Sans` (Sem-serifa geométrica moderna e limpa).

### 3.2. Escala Tipográfica Extraída do Stitch

| Token | Família | Tamanho (rem / px) | Line Height | Letter Spacing | Peso (FontWeight) | Aplicação |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`display-lg`** | Literata | 3.5rem (56px) | 4.0rem (64px) | -0.02em | 600 (SemiBold) | Números heróicos de estatísticas |
| **`display-md`** | Literata | 2.8rem (45px) | 3.25rem (52px) | -0.015em | 600 (SemiBold) | Destaque numérico de livros lidos |
| **`headline-lg`** | Literata | 2.0rem (32px) | 2.5rem (40px) | -0.01em | 600 (SemiBold) | Títulos de seções principais |
| **`headline-lg-mobile`**| Literata | 1.75rem (28px) | 2.25rem (36px) | -0.01em | 600 (SemiBold) | Título principal das telas no smartphone |
| **`headline-md`** | Literata | 1.5rem (24px) | 2.0rem (32px) | normal | 600 (SemiBold) | Métricas secundárias em cards |
| **`headline-sm`** | Literata | 1.25rem (20px) | 1.75rem (28px) | normal | 600 (SemiBold) | Títulos de livros e cabeçalhos de cards |
| **`title-lg`** | Plus Jakarta Sans | 1.25rem (20px) | 1.75rem (28px) | normal | 700 (Bold) | Cabeçalhos de diálogos e modais |
| **`title-md`** | Plus Jakarta Sans | 1.0rem (16px) | 1.5rem (24px) | normal | 600 (SemiBold) | Títulos nos cards de lista e logotipo |
| **`title-sm`** | Plus Jakarta Sans | 0.875rem (14px) | 1.25rem (20px) | normal | 600 (SemiBold) | Rótulos de campos e links destacados |
| **`body-lg`** | Plus Jakarta Sans | 1.0rem (16px) | 1.6rem (25.6px)| normal | 400 (Regular) | Textos de leitura e campos de busca |
| **`body-md`** | Plus Jakarta Sans | 0.875rem (14px) | 1.45rem (23.2px)| normal | 400 (Regular) | Autores, parágrafos explicativos |
| **`body-sm`** | Plus Jakarta Sans | 0.75rem (12px) | 1.2rem (19.2px) | normal | 400 (Regular) | Metadados de páginas, datas e citações |
| **`label-lg`** | Plus Jakarta Sans | 0.875rem (14px) | 1.25rem (20px) | 0.01em | 600 (SemiBold) | Texto de botões principais |
| **`label-md`** | Plus Jakarta Sans | 0.75rem (12px) | 1.0rem (16px) | 0.02em | 600 (SemiBold) | Itens da barra de navegação e chips |
| **`label-sm`** | Plus Jakarta Sans | 0.6875rem (11px)| 0.875rem (14px)| 0.03em | 600 (SemiBold) | Tags de status e contadores de páginas |

---

## 4. Espaçamentos, Elevação e Bordas

### 4.1. Espaçamentos (Grid de 4dp / 8dp)
- `space-xs`: `4px` (0.25rem) — Espaçamentos internos de ícones e micro-badges.
- `space-sm`: `8px` (0.5rem) — Distância entre elementos internos de cards.
- `space-md`: `16px` (1.0rem) — Margens padrão de tela (`margin`), calhas (`gutter`) e padding de cards.
- `space-lg`: `24px` (1.5rem) — Distância entre blocos de conteúdo.
- `space-xl`: `32px` (2.0rem) — Margem inferior de telas e separação de seções heróicas.
- `space-2xl`: `48px` (3.0rem) — Espaçamento para áreas vazias (*empty states*).

### 4.2. Arredondamentos (Border Radius)
- **Cards e Caixas de Conteúdo:** `12px` a `16px` (`rounded-xl` / `rounded-2xl`).
- **Botões de Ação Principal:** `12px` a `14px` (`rounded-[14px]`).
- **Capas de Livros:** `8px` (`rounded-lg`) com simulação de lombada física.
- **Chips, Tags e Badges:** `9999px` (`rounded-full` / *pill-shape*).
- **Modais e Bottom Sheets:** `24px` nos cantos superiores (`BorderRadius.vertical(top: Radius.circular(24))`).

### 4.3. Elevações e Sombras
- O design rejeita sombras pretas pesadas e prioriza **camadas tonais suaves**:
  - **Cards em repouso:** Fundo `#F6F3EE` com sombra ambiente imperceptível (`shadow-sm`).
  - **Diálogos e Menus Flutuantes:** Sombra quente difusa (`box-shadow: 0 8px 24px rgba(74, 59, 50, 0.08)`).
  - **Efeito de Lombada de Livro:** Gradiente suave de `1.5px` à esquerda da capa (`from-black/25 to-transparent`).

---

## 5. Componentes Principais do Design

1. **Botões de Ação Primária:**
   - Altura padrão de 48dp a 52dp (`h-12` a `h-13`), fundo verde `#3E644A`, texto branco com ícone à esquerda e efeito sutil de clique (`active:scale-[0.98]`).
2. **Campos de Entrada (Text Inputs):**
   - Altura de 48dp a 52dp, fundo `#F0EDE9` em repouso, cantos arredondados de 12px, ícone em 20px no início e transição para fundo branco `#FFFFFF` ao receber foco.
   - Campo de senha com botão alternador de visibilidade (`visibility` / `visibility_off`).
3. **Barra de Navegação Inferior (Bottom Navigation Bar):**
   - Altura de 64dp a 72dp + safe area inferior, fundo `#FCF9F4` translúcido com `backdrop-blur-xl` e linha divisória superior imperceptível.
   - Três destinos centrais:
     1. **Estante** (`auto_stories`)
     2. **Buscar** (`search`)
     3. **Estatísticas** (`bar_chart`)
   - O item ativo é evidenciado por um container pílula em tom `#C2EDCB` com o ícone e rótulo em `#3E644A` (bold).
4. **Cabeçalho Superior (App Bar):**
   - Altura de 64dp + safe area superior, com logotipo editorial, texto "Leitores & Cia.", identificação da tela atual e botão circular para acesso ao Perfil do usuário.
5. **Tabs de Estante:**
   - Pílulas selecionáveis para `"Lendo"`, `"Quero Ler"` e `"Lidos"`, cada qual com badge numérico embutido que reflete a quantidade de livros cadastrados.
6. **Cards de Livro da Estante:**
   - Formato horizontal compacto: capa com proporção aproximada de 2:3, título em Literata, autor, barra de progresso linear em verde (para obras em andamento) e botão de três pontos (`more_vert`) para menu de opções (mudar status ou remover).
7. **Diálogo de Confirmação de Exclusão (Bottom Sheet Android):**
   - Apresenta alça de arraste superior (*drag handle*), ícone de alerta em `error-container`, texto de aviso sobre irreversibilidade e botões de ação ("Cancelar" e "Confirmar Exclusão").

---

## 6. Telas Consultadas no Stitch (Existentes)

No projeto `projects/120332651349505398`, foram localizadas e inspecionadas as seguintes **5 telas**:

1. **`Login — Leitores & Cia.`** (`screens/8780f49567fa4a55b2df0ffc84b58ee3`)
   - Emblema com ícone de livro e brilho acolhedor.
   - Formulário com campos de E-mail e Senha (com botão de visibilidade).
   - Botão "Esqueci minha senha" e botão principal "Entrar na Estante".
   - Opção "Explorar como Visitante" e bloco de citação literária de George R.R. Martin.
   - Link de rodapé direcionando para a tela de cadastro.
2. **`Cadastro — Leitores & Cia.`** (`screens/923b2ba2980f45afba2c52a25377a8ab`)
   - Botão de retorno e identificador "Book Nook".
   - Campos: Nome completo, E-mail, Senha (com indicador visual de força da senha em 3 níveis) e Confirmar senha (com validação de correspondência).
   - Checkbox de termos de uso e política de privacidade.
   - Botão principal "Criar minha conta" e link para retornar ao Login.
3. **`Buscar Livros — Leitores & Cia.`** (`screens/7ccef4142ad94418b5263fe58115ffa8`)
   - Campo de busca com botão de limpar e chips de filtro ("Todos", "Por Título", "Por Autor").
   - Três estados desenhados:
     - **Resultados:** Cards de livros com capa, título, autor, quantidade de páginas, gênero e botão de ação rápida "+ Adicionar à Estante" com menu suspenso para escolher o status ("Quero Ler", "Lendo", "Lido").
     - **Carregamento:** Indicador de progresso circular animado e cartões de *shimmer* suaves.
     - **Vazio:** Ilustração acolhedora e mensagem "Nenhum livro encontrado" com dicas de pesquisa.
   - Barra de navegação inferior ativa na aba "Buscar".
4. **`Estante Pessoal — Leitores & Cia.`** (`screens/2d2e0898e8c640b3b5f975985c04586f`)
   - Saudação personalizada ("Olá, Leitora! ☕") e contador geral de livros no acervo.
   - Tabs de seleção rápida ("Lendo", "Quero Ler", "Lidos" e estado vazio demonstrativo).
   - Lista de livros com capas, barra de progresso percentual para leitura ativa, notas de avaliação e menu de contexto para transição de status.
   - Bottom sheet interativo de confirmação para remoção de livros.
   - Barra de navegação inferior ativa na aba "Estante".
5. **`Estatísticas — Leitores & Cia.`** (`screens/a8a94a2d53a040708bdc7065f50f07ca`)
   - Cabeçalho acolhedor "Jornada Literária — Seu Caderno de Leituras".
   - **Hero Card Primário:** Total de livros concluídos em destaque verde com tipografia `display-md`.
   - **Card Secundário:** Total consolidado de páginas percorridas.
   - Cards complementares: Média de páginas por obra e consistência de leitura.
   - Seção "Distribuição da Estante" com barras de proporção visual entre Lidos, Lendo e Quero Ler.
   - Card "Última Conquista" com capa e avaliação da leitura mais recente.
   - Barra de navegação inferior ativa na aba "Estatísticas".

---

## 7. Telas e Componentes Pendentes de Criação no Design (Lacunas vs. README.md)

Para atender integralmente aos requisitos definidos no [README.md](file:///c:/Users/35T1/Documents/Gabi/mobile/Firebase/leitores_cia/README.md), identificou-se que as seguintes telas/componentes visuais ainda não foram desenhados no Stitch:

1. **Tela de Detalhes da Obra / Livro (Requisito `RF-04`):**
   - **Descrição:** O `README.md` prevê a visualização completa dos metadados da obra selecionada. No design atual, há apenas o card compacto na busca.
   - **Elementos necessários:** Capa ampliada em proporção 2:3, título completo, lista de autores, editora, data/ano de publicação, sinopse/descrição editorial completa, contagem oficial de páginas e seletor evidente para adicionar à estante ou mudar o status.
2. **Tela ou Diálogo de Perfil do Usuário e Logout (Requisito `RF-02`):**
   - **Descrição:** O cabeçalho de todas as telas principais inclui o botão de avatar/perfil no topo direito, mas não há tela correspondente vinculada no Stitch.
   - **Elementos necessários:** Nome do leitor, e-mail autenticado via Firebase Authentication, data de criação da conta e o botão explícito e seguro de **"Sair da Conta / Logout"** (essencial para validação do `CA-01`).
3. **Diálogo de Atualização de Progresso de Leitura:**
   - **Descrição:** A tela de Estante exibe o progresso de leitura (ex.: "Página 185 de 264 - 70%").
   - **Elementos necessários:** Modal simples ou bottom sheet onde o leitor possa digitar a página atual em que parou a leitura, atualizando a barra de progresso.
