import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

class StorageService {
  static const String _ingredientsKey = 'user_ingredients';
  static const String _recipesKey = 'user_recipes';
  
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Ingredients
  Future<List<Ingredient>> getIngredients() async {
    final jsonString = _prefs?.getString(_ingredientsKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Ingredient.fromJson(json)).toList();
  }

  Future<void> saveIngredients(List<Ingredient> ingredients) async {
    final jsonString = jsonEncode(ingredients.map((i) => i.toJson()).toList());
    await _prefs?.setString(_ingredientsKey, jsonString);
  }

  // Recipes
  Future<List<Recipe>> getRecipes() async {
    final jsonString = _prefs?.getString(_recipesKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<void> saveRecipes(List<Recipe> recipes) async {
    final jsonString = jsonEncode(recipes.map((r) => r.toJson()).toList());
    await _prefs?.setString(_recipesKey, jsonString);
  }
}