import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int servings;
  final String category;
  final bool isUserAdded;
  final DateTime createdAt;

  Recipe({
    String? id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.servings,
    required this.category,
    this.isUserAdded = false,
    DateTime? createdAt,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now();

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    int? prepTimeMinutes,
    int? servings,
    String? category,
    bool? isUserAdded,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      servings: servings ?? this.servings,
      category: category ?? this.category,
      isUserAdded: isUserAdded ?? this.isUserAdded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'ingredients': ingredients,
    'instructions': instructions,
    'prepTimeMinutes': prepTimeMinutes,
    'servings': servings,
    'category': category,
    'isUserAdded': isUserAdded,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    ingredients: List<String>.from(json['ingredients']),
    instructions: List<String>.from(json['instructions']),
    prepTimeMinutes: json['prepTimeMinutes'],
    servings: json['servings'],
    category: json['category'],
    isUserAdded: json['isUserAdded'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );

  String get formattedTime {
    if (prepTimeMinutes < 60) {
      return '${prepTimeMinutes} min';
    }
    final hours = prepTimeMinutes ~/ 60;
    final minutes = prepTimeMinutes % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}min';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Recipe(id: $id, name: $name)';
}