# Meu Livro de Receitas

App Flutter para gerenciar ingredientes e encontrar receitas baseadas no que você tem em casa.

## Funcionalidades

- **Ingredientes**: Adicione, marque/desmarque e remova ingredientes que você tem
- **Receitas sugeridas**: Lista receitas que você pode fazer com os ingredientes marcados (match ≥ 50%)
- **Suas receitas**: Cadastre receitas próprias com nome, descrição, ingredientes, modo de preparo, tempo, porções e categoria
- **Persistência**: Dados salvos localmente via `shared_preferences`
- **Tema**: Material 3 com esquema de cores laranja

## Tecnologias

- Flutter 3.x
- Provider (gerenciamento de estado)
- shared_preferences (persistência local)
- uuid (IDs únicos)

## Estrutura

```
lib/
├── main.dart                 # App entry point, providers, tema
├── models/
│   ├── ingredient.dart       # Modelo Ingredient
│   └── recipe.dart           # Modelo Recipe
├── screens/
│   ├── home_screen.dart      # Tabs: Minhas Receitas / Meus Ingredientes
│   └── add_recipe_screen.dart# Formulário de nova receita
├── services/
│   └── storage_service.dart  # Persistência SharedPreferences
└── widgets/
    ├── ingredient_chip.dart  # Chip de ingrediente (selecionável)
    └── recipe_card.dart      # Card de receita (match %, categoria, preview)
```

## Como rodar

```bash
flutter pub get
flutter run
```

## Requisitos

- Flutter SDK ≥ 3.0
- Dart ≥ 3.0

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Licença

MIT