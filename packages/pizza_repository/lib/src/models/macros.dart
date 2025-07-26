import '../entities/macros_entity.dart';

class Macros {
  int calories;
  int proteins;
  int fat;
  int carbs;

  Macros({
    required this.calories,
    required this.proteins,
    required this.fat,
    required this.carbs,
  });

  MacrosEntity toEntity() {
    return MacrosEntity(
      calories: calories,
      proteins: proteins,
      fat: fat,
      carbs: carbs,
    );
  }

  static Macros fromEntity(MacrosEntity entity) {
    return Macros(
        calories: entity.calories,
        proteins: entity.proteins,
        fat: entity.fat,
        carbs: entity.carbs);
  }

  Map<String, Object?> toDocument() {
    return {
      'calories': calories,
      'proteins': proteins,
      'fat': fat,
      'carbs': carbs,
    };
  }

  static Macros fromDocument(Map<String, dynamic> doc) {
    return Macros(
      calories: doc['calories'],
      proteins: doc['proteins'],
      fat: doc['fat'],
      carbs: doc['carbs'],
    );
  }
}
