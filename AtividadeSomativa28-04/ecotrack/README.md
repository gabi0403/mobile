
# EcoTrack: Controle de Hábitos Sustentáveis
**Especificações dos Requisitos de Software (SRE)** *Estrutura Baseada na ISO/IEC/IEEE 29148:2018*

## 1. Identificação do Documento
* **Projeto:** EcoTrack - Gerenciador de Hábitos Ecológicos
* **Versão:** 2.0.0 (Versão Final com Requisitos Opcionais)
* **Data:** 28 de abril de 2026

---

## 2. Introdução

### 2.1 Propósito
Descrever os requisitos finais da aplicação **EcoTrack**, focada no monitoramento de ações sustentáveis, cálculo de impacto ambiental e gamificação do progresso do usuário.

### 2.2 Escopo
O sistema permite ao usuário registrar hábitos, visualizar o impacto de suas ações através de um dashboard dinâmico e personalizar a experiência visual através de temas.

**Conceito do Projeto:**
* **Gerenciamento de Estado:** Implementação total com **Provider**.
* **Interface:** Uso de componentes nativos Flutter (`Scaffold`, `TabBar`, `BottomNavigationBar`, `Drawer`).
* **Gamificação:** Sistema de níveis e pontuação baseada em ações.

---

## 3. Requisitos Funcionais (RF)

| ID | Descrição | Status |
| :--- | :--- | :--- |
| **RF01** | O sistema deve exibir uma tela inicial com nome, logo e descrição da proposta. | **Concluído** |
| **RF02** | O sistema deve listar hábitos pendentes e concluídos em abas separadas (`TabBarView`). | **Concluído** |
| **RF03** | O sistema deve permitir concluir um hábito, movendo-o de lista e atualizando os pontos. | **Concluído** |
| **RF04** | O Dashboard deve exibir: Total de Concluídos, Pontos, Nível e Impacto (CO2). | **Concluído** |
| **RF05** | O sistema deve permitir alternar entre **Modo Claro e Modo Escuro** via configurações. | **Concluído** |
| **RF06** | O sistema deve permitir resetar o progresso de todos os hábitos. | **Concluído** |
| **RF07** | A navegação deve ser acessível via `BottomNavigationBar` e `Drawer`. | **Concluído** |

---

## 4. Requisitos Não-Funcionais (RNF)

| ID | Descrição | Categoria |
| :--- | :--- | :--- |
| **RNF01** | O estado global (temas e listas) deve ser sincronizado via **ChangeNotifier**. | Arquitetura |
| **RNF02** | A interface deve ser responsiva e adaptável ao tema do sistema. | Usabilidade |
| **RNF03** | O código deve seguir a padronização de nomenclatura em Português-BR. | Manutenibilidade |

---

## 5. Regras de Negócio (RN)

* **RN01 - Pontuação:** Cada hábito concluído soma uma quantidade específica de pontos ao perfil do usuário.
* **RN02 - Níveis:** * 0-1 hábitos: Eco-Iniciante.
    * 2-3 hábitos: Eco-Aprendiz.
    * 4+ hábitos: Eco-Guerreiro.
* **RN03 - Impacto:** O cálculo de impacto estimado é de $0.1kg$ de $CO_2$ evitado para cada ponto conquistado.

---

## 6. Modelagem de Dados Final

### Classe Habito
* `titulo` (String): Nome da ação.
* `pontos` (int): Valor da recompensa.
* `concluido` (bool): Status atual.

### Classe HabitoController (Provider)
* `habitos` (List): Armazenamento centralizado.
* `modoEscuro` (bool): Estado do tema global.

---
