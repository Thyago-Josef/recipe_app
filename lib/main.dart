import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/ingredient.dart';
import 'models/recipe.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/add_recipe_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IngredientProvider(storageService)),
        ChangeNotifierProvider(create: (_) => RecipeProvider(storageService)),
      ],
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Livro de Receitas',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/add-recipe': (context) => const AddRecipeScreen(),
      },
    );
  }
}

class IngredientProvider with ChangeNotifier {
  final StorageService _storage;
  List<Ingredient> _ingredients = [];

  IngredientProvider(this._storage) {
    _loadIngredients();
  }

  List<Ingredient> get ingredients => _ingredients;

  Future<void> _loadIngredients() async {
    _ingredients = await _storage.getIngredients();
    notifyListeners();
  }

  Future<void> addIngredient(String name) async {
    final ingredient = Ingredient(name: name.trim());
    _ingredients.add(ingredient);
    await _storage.saveIngredients(_ingredients);
    notifyListeners();
  }

  Future<void> removeIngredient(String id) async {
    _ingredients.removeWhere((i) => i.id == id);
    await _storage.saveIngredients(_ingredients);
    notifyListeners();
  }

  Future<void> toggleIngredient(String id) async {
    final index = _ingredients.indexWhere((i) => i.id == id);
    if (index != -1) {
      _ingredients[index] = _ingredients[index].copyWith(isSelected: !_ingredients[index].isSelected);
      await _storage.saveIngredients(_ingredients);
      notifyListeners();
    }
  }

  List<Ingredient> get selectedIngredients => 
      _ingredients.where((i) => i.isSelected).toList();
}

class RecipeProvider with ChangeNotifier {
  final StorageService _storage;
  List<Recipe> _recipes = [];

  RecipeProvider(this._storage) {
    _loadRecipes();
  }

  List<Recipe> get recipes => _recipes;

  List<Recipe> get userRecipes => _recipes.where((r) => r.isUserAdded).toList();
  List<Recipe> get defaultRecipes => _recipes.where((r) => !r.isUserAdded).toList();

  Future<void> _loadRecipes() async {
    _recipes = await _storage.getRecipes();
    // Add default recipes if empty
    if (_recipes.isEmpty) {
      _recipes = _getDefaultRecipes();
      await _storage.saveRecipes(_recipes);
    }
    notifyListeners();
  }

  Future<void> addRecipe(Recipe recipe) async {
    _recipes.add(recipe);
    await _storage.saveRecipes(_recipes);
    notifyListeners();
  }

  Future<void> removeRecipe(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    await _storage.saveRecipes(_recipes);
    notifyListeners();
  }

  List<Recipe> findMatchingRecipes(List<Ingredient> availableIngredients) {
    final availableNames = availableIngredients.map((i) => i.name.toLowerCase()).toSet();
    
    return _recipes.where((recipe) {
      final recipeIngredients = recipe.ingredients.map((i) => i.toLowerCase()).toSet();
      // Recipe matches if user has at least 50% of ingredients
      final matches = recipeIngredients.intersection(availableNames).length;
      return matches >= (recipeIngredients.length * 0.5).ceil();
    }).toList()
      ..sort((a, b) {
        // Sort by match percentage descending
        final aMatch = a.ingredients.map((i) => i.toLowerCase()).toSet().intersection(availableNames).length / a.ingredients.length;
        final bMatch = b.ingredients.map((i) => i.toLowerCase()).toSet().intersection(availableNames).length / b.ingredients.length;
        return bMatch.compareTo(aMatch);
      });
  }

  List<Recipe> _getDefaultRecipes() {
    return [
      Recipe(
        name: 'Omelete Simples',
        description: 'Um omelete rápido e nutritivo para qualquer refeição',
        ingredients: ['ovos', 'sal', 'óleo', 'cebola', 'tomate'],
        instructions: [
          'Bata os ovos com sal em uma tigela',
          'Pique a cebola e o tomate',
          'Aqueça o óleo em uma frigideira',
          'Refogue a cebola até dourar',
          'Adicione o tomate e cozinhe por 2 minutos',
          'Despeje os ovos batidos',
          'Cozinhe até firmar, dobre ao meio e sirva'
        ],
        prepTimeMinutes: 10,
        servings: 2,
        category: 'Café da manhã',
      ),
      Recipe(
        name: 'Arroz com Feijão',
        description: 'O prato clássico brasileiro, simples e delicioso',
        ingredients: ['arroz', 'feijão', 'alho', 'cebola', 'óleo', 'sal', 'louro'],
        instructions: [
          'Deixe o feijão de molho por 2 horas',
          'Cozinhe o feijão na pressão com louro e sal por 20 min',
          'Em outra panela, refogue alho e cebola no óleo',
          'Adicione o arroz e frite por 2 minutos',
          'Adicione água (2 xícaras para 1 de arroz) e sal',
          'Cozinhe em fogo baixo até a água secar',
          'Misture o feijão cozido ao arroz e sirva'
        ],
        prepTimeMinutes: 40,
        servings: 4,
        category: 'Almoço',
      ),
      Recipe(
        name: 'Panqueca de Frigideira',
        description: 'Panquecas fofinhas feitas na frigideira',
        ingredients: ['farinha de trigo', 'leite', 'ovos', 'açúcar', 'fermento', 'manteiga', 'sal'],
        instructions: [
          'Misture farinha, açúcar, fermento e sal',
          'Adicione leite, ovos e manteiga derretida',
          'Bata até ficar homogêneo',
          'Aqueça frigideira antiaderente e unte com manteiga',
          'Despeje uma concha de massa',
          'Vire quando formar bolhas na superfície',
          'Sirva com mel, frutas ou doce de leite'
        ],
        prepTimeMinutes: 15,
        servings: 3,
        category: 'Café da manhã',
      ),
      Recipe(
        name: 'Macarrão ao Alho e Óleo',
        description: 'Massas simples e saborosas estilo italiano',
        ingredients: ['macarrão', 'alho', 'óleo', 'pimenta', 'salsa', 'sal', 'queijo parmesão'],
        instructions: [
          'Cozinhe o macarrão em água com sal até al dente',
          'Enquanto isso, frite alho laminado no óleo',
          'Adicione pimenta e salsa picada',
          'Escorra o macarrão (guarde 1 xícara da água)',
          'Misture o macarrão ao molho',
          'Adicione água do cozimento se necessário',
          'Finalize com queijo parmesão ralado'
        ],
        prepTimeMinutes: 15,
        servings: 2,
        category: 'Jantar',
      ),
      Recipe(
        name: 'Salada Caesar',
        description: 'Salada clássica com molho cremoso e croutons',
        ingredients: ['alface', 'frango', 'pão', 'alho', 'maionese', 'limão', 'queijo parmesão', 'mostarda'],
        instructions: [
          'Grelhe o frango temperado com sal e pimenta',
          'Corte o pão em cubos e torre com alho e óleo',
          'Misture maionese, limão, mostarda, alho amassado e queijo para o molho',
          'Rasgue a alface em pedaços grandes',
          'Corte o frango em tiras',
          'Misture tudo com o molho',
          'Finalize com croutons e mais queijo'
        ],
        prepTimeMinutes: 20,
        servings: 2,
        category: 'Almoço',
      ),
      Recipe(
        name: 'Sopa de Legumes',
        description: 'Sopa reconfortante e nutritiva',
        ingredients: ['batata', 'cenoura', 'abobrinha', 'cebola', 'alho', 'tomate', 'óleo', 'sal', 'água'],
        instructions: [
          'Pique todos os legumes em cubos',
          'Refogue cebola e alho no óleo',
          'Adicione os legumes e refogue por 5 min',
          'Cubra com água e cozinhe até macios',
          'Bata metade no liquidificador e volte para a panela',
          'Acerte o sal e cozinhe por mais 5 min',
          'Sirva quente com torradas'
        ],
        prepTimeMinutes: 30,
        servings: 4,
        category: 'Jantar',
      ),
      Recipe(
        name: 'Torta de Frango',
        description: 'Torta caseira cremosa de frango desfiado',
        ingredients: ['frango', 'cebola', 'tomate', 'milho', 'ervilha', 'creme de leite', 'massa de pastel', 'ovo', 'queijo'],
        instructions: [
          'Cozinhe e desfie o frango',
          'Refogue cebola, tomate, milho e ervilha',
          'Misture o frango desfiado e o creme de leite',
          'Forre uma forma com massa de pastel',
          'Coloque o recheio e cubra com mais massa',
          'Pincele com ovo batido',
          'Asse a 180°C por 30-40 min até dourar'
        ],
        prepTimeMinutes: 50,
        servings: 6,
        category: 'Jantar',
      ),
      Recipe(
        name: 'Vitamina de Banana',
        description: 'Bebida energética e saudável',
        ingredients: ['banana', 'leite', 'aveia', 'mel', 'canela'],
        instructions: [
          'Corte a banana em pedaços',
          'Bata todos os ingredientes no liquidificador',
          'Sirva gelado'
        ],
        prepTimeMinutes: 5,
        servings: 1,
        category: 'Lanche',
      ),
    ];
  }
}