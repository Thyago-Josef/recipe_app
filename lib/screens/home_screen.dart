import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

void _showAddIngredientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddIngredientDialog(),
    );
  }

  // Keep old method for compatibility but not used
  // void _addIngredient(BuildContext context) {} // Removed - replaced by new dialog logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Livro de Receitas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.kitchen), text: 'Minhas Receitas'),
            Tab(icon: Icon(Icons.inventory), text: 'Meus Ingredientes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () => _showAddIngredientDialog(context),
            tooltip: 'Adicionar Ingredientes',
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () => Navigator.pushNamed(context, '/add-recipe'),
            tooltip: 'Adicionar Receita',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecipesTab(context),
          _buildIngredientsTab(context),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddIngredientDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Ingrediente'),
            )
          : null,
    );
  }

  Widget _buildRecipesTab(BuildContext context) {
    return Consumer2<IngredientProvider, RecipeProvider>(
      builder: (context, ingredientProvider, recipeProvider, child) {
        final selectedIngredients = ingredientProvider.selectedIngredients;
        final matchingRecipes = recipeProvider.findMatchingRecipes(selectedIngredients);
        final userRecipes = recipeProvider.userRecipes;

        if (selectedIngredients.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.shopping_basket,
            title: 'Nenhum ingrediente selecionado',
            subtitle: 'Vá na aba "Meus Ingredientes" e marque os que você tem\npara ver as receitas possíveis!',
            actionText: 'Ir para Ingredientes',
            onAction: () => _tabController.animateTo(1),
          );
        }

        if (matchingRecipes.isEmpty && userRecipes.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.restaurant_menu,
            title: 'Nenhuma receita encontrada',
            subtitle: 'Tente adicionar mais ingredientes\nou cadastre suas próprias receitas!',
            actionText: 'Adicionar Receita',
            onAction: () => Navigator.pushNamed(context, '/add-recipe'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selected ingredients summary
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedIngredients.length} ingrediente(s) selecionado(s)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedIngredients
                          .map((i) => IngredientChip(
                                ingredient: i,
                                onTap: () => ingredientProvider.toggleIngredient(i.id),
                                showCheckmark: true,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Matching recipes
            if (matchingRecipes.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Receitas que você pode fazer',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${matchingRecipes.length} encontrada(s)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: matchingRecipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final recipe = matchingRecipes[index];
                  final availableIngredients = recipe.ingredients
                      .map((i) => i.toLowerCase())
                      .toSet()
                      .intersection(
                        selectedIngredients.map((i) => i.name.toLowerCase()).toSet(),
                      )
                      .length;
                  final matchPercent = (availableIngredients / recipe.ingredients.length * 100).round();
                  
                  return RecipeCard(
                    recipe: recipe,
                    matchPercent: matchPercent,
                    onTap: () => _showRecipeDetail(context, recipe),
                  );
                },
              ),
            ],

            // User added recipes
            if (userRecipes.isNotEmpty) ...[
              if (matchingRecipes.isNotEmpty) const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Suas receitas cadastradas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${userRecipes.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userRecipes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final recipe = userRecipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    isUserRecipe: true,
                    onTap: () => _showRecipeDetail(context, recipe),
                    onDelete: () => _confirmDeleteRecipe(context, recipe),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildIngredientsTab(BuildContext context) {
    return Consumer<IngredientProvider>(
      builder: (context, provider, child) {
        final ingredients = provider.ingredients;

        if (ingredients.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.inventory_2,
            title: 'Nenhum ingrediente cadastrado',
            subtitle: 'Toque no botão "+" para adicionar\ningredientes que você tem em casa',
            actionText: 'Adicionar Primeiro',
            onAction: () => _showAddIngredientDialog(context),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ingredients.length + 1, // +1 for the add button
          itemBuilder: (context, index) {
            if (index == ingredients.length) {
              // Add button at the bottom
              return Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showAddIngredientDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Mais Ingredientes'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              );
            }
            
            final ingredient = ingredients[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Checkbox(
                  value: ingredient.isSelected,
                  onChanged: (_) => provider.toggleIngredient(ingredient.id),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                title: Text(
                  ingredient.name,
                  style: TextStyle(
                    decoration: ingredient.isSelected ? TextDecoration.lineThrough : null,
                    color: ingredient.isSelected ? Colors.grey : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDeleteIngredient(context, ingredient),
                ),
                onTap: () => provider.toggleIngredient(ingredient.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetail(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  recipe.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (recipe.isUserAdded)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Sua receita',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Info chips
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.timer,
                            label: recipe.formattedTime,
                          ),
                          _InfoChip(
                            icon: Icons.people,
                            label: '${recipe.servings} porções',
                          ),
                          _InfoChip(
                            icon: Icons.category,
                            label: recipe.category,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Ingredients
                      Text(
                        'Ingredientes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...recipe.ingredients.map((ing) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(ing)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 24),
                      // Instructions
                      Text(
                        'Modo de Preparo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...recipe.instructions.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteIngredient(BuildContext context, Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover ingrediente?'),
        content: Text('Deseja remover "${ingredient.name}" da sua lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<IngredientProvider>().removeIngredient(ingredient.id);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              messenger.showSnackBar(
                SnackBar(content: Text('${ingredient.name} removido')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRecipe(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir receita?'),
        content: Text('Deseja excluir "${recipe.name}" permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              context.read<RecipeProvider>().removeRecipe(recipe.id);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              messenger.showSnackBar(
                SnackBar(content: Text('${recipe.name} excluída')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AddIngredientDialog extends StatefulWidget {
  const _AddIngredientDialog();

  @override
  State<_AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<_AddIngredientDialog> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addField() {
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removeField(int index) {
    setState(() => _controllers.removeAt(index));
  }

  void _submit() {
    final names = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (names.isNotEmpty) {
      for (final name in names) {
        context.read<IngredientProvider>().addIngredient(name);
      }
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('${names.length} ingrediente(s) adicionado(s)!')),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Ingredientes'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            ..._controllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Ingrediente ${index + 1}',
                          hintText: 'Ex: tomate, cebola, arroz...',
                        ),
                        textCapitalization: TextCapitalization.words,
                        autofocus: index == 0,
                        onSubmitted: (_) {
                          if (index == _controllers.length - 1) {
                            _addField();
                          }
                        },
                      ),
                    ),
                    if (_controllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeField(index),
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addField,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar mais'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Adicionar Todos'),
        ),
      ],
    );
  }
}