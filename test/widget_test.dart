// This is a basic Flutter widget test for RecipeApp.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:recipe_app/main.dart';
import 'package:recipe_app/services/storage_service.dart';

void main() {
  testWidgets('RecipeApp loads and shows home screen', (WidgetTester tester) async {
    final storage = StorageService();
    await storage.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => IngredientProvider(storage)),
          ChangeNotifierProvider(create: (_) => RecipeProvider(storage)),
        ],
        child: const RecipeApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app title
    expect(find.text('Meu Livro de Receitas'), findsOneWidget);
    
    // Verify tabs
    expect(find.text('Minhas Receitas'), findsOneWidget);
    expect(find.text('Meus Ingredientes'), findsOneWidget);
  });

  testWidgets('Can add ingredient via dialog', (WidgetTester tester) async {
    final storage = StorageService();
    await storage.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => IngredientProvider(storage)),
          ChangeNotifierProvider(create: (_) => RecipeProvider(storage)),
        ],
        child: const RecipeApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Ingredients tab
    await tester.tap(find.text('Meus Ingredientes'));
    await tester.pumpAndSettle();

    // Open add ingredient dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter ingredient name
    await tester.enterText(find.byType(TextField), 'Tomate');
    await tester.pumpAndSettle();

    // Tap Adicionar button
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    // Verify ingredient appears
    expect(find.text('Tomate'), findsOneWidget);
  });
}