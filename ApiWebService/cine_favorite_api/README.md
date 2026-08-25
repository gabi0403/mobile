# 🎬 CineFavorite

O **CineFavorite** é uma aplicação Flutter para busca de filmes e séries com suporte a múltiplos perfis de usuário, salvamento de favoritos e gerenciamento de avaliações personalizadas em armazenamento local.

---

## 📌 Funcionalidades

* **Busca de Mídias:** Consulta integrada à API do The Movie Database (TMDB) para filmes e séries.
* **Gerenciamento de Perfis Local:**

  * Criação e seleção de múltiplos perfis.
  * Persistência de foto de perfil via URL.
  * Alternância de contas mantendo o mesmo `userId` sem perda de dados.
* **Galeria de Favoritos:**

  * Adição e remoção de filmes/séries associados exclusivamente ao usuário ativo.
  * Persistência offline via banco de dados SQLite.
* **Sistema de Avaliação:**

  * Permite atribuir ou editar notas individuais (0.0 a 10.0) para mídias salvas.

---

## 🛠️ Tecnologias Utilizadas

* **Flutter & Dart:** Desenvolvimento da interface e regra de negócio.
* **SQLite (`sqflite`):** Banco de dados relacional para persistência offline de favoritos e notas.
* **Shared Preferences:** Armazenamento local leve para gerenciamento dos perfis e controle do usuário ativo.
* **TMDB API:** Integração HTTP para consumo de catálogo audiovisual.

---

## 📂 Arquitetura do Projeto

```text
lib/
├── controllers/       # Gerenciadores de estado (ChangeNotifier)
│   ├── favorites_controller.dart
│   └── profile_controller.dart
│   config/ 
│   └── api_config.dart
├── database/          # Configuração e queries do SQLite
│   └── database_helper.dart
├── models/            # Classes de modelo de dados (Movie, UserProfile, etc.)
│   └── movie.dart
│   └── user_profile.dart
├── services/          # Serviços de API externa e SharedPreferences
│   ├── profile_service.dart
│   └── tmdb_service.dart
├── views/             # Telas e componentes da interface gráfica
│   ├── favorites_screen.dart
│   ├── login_profile_screen.dart
│   ├── main_navigation_screen.dart
│   └── search_screen.dart
└── main.dart          # Ponto de entrada do aplicativo
```

---

## 💾 Estrutura do Banco de Dados Local (SQLite)

A tabela de favoritos é associada ao ID único do perfil do usuário:

| **Coluna**   | **Tipo** | **Restrição / Descrição**             |
| ------------ | -------- | ------------------------------------- |
| `id`         | INTEGER  | ID da mídia no TMDB                   |
| `mediaType`  | TEXT     | Tipo da mídia (`movie` ou `tv`)       |
| `userId`     | TEXT     | ID do perfil proprietário do favorito |
| `title`      | TEXT     | Título do filme ou série              |
| `posterPath` | TEXT     | Caminho da imagem do pôster           |
| `userRating` | REAL     | Nota atribuída pelo usuário (0 a 10)  |

> **Chave Primária Composta:** `PRIMARY KEY (id, mediaType, userId)`

---

## 🚀 Como Executar o Projeto

### Pré-requisitos

* **Flutter SDK** instalado (versão 3.x ou superior).
* Dispositivo físico ou emulador (Android/iOS) configurado.
* Chave de API ativa do **TMDB**.

### Passo a Passo

1. **Clonar o repositório:**

```bash
git clone https://github.com/seu-usuario/cine_favorite.git
cd cine_favorite
```

2. **Instalar as dependências:**

```bash
flutter pub get
```

3. **Configurar a chave da API do TMDB:**

   Abra o arquivo `lib/services/api_config.dart` e insira sua chave:

```dart
class ApiConfig {
  static const String apiKey = 'SUA_CHAVE_TMDB_AQUI';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
}
```

4. **Executar a aplicação:**

```bash
flutter run
```
