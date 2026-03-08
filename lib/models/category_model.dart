class CategoryModel {
  final int id;
  final String name;
  final String description;
  final double basePrice;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      basePrice: (json['base_price'] as num).toDouble(),
    );
  }
  factory CategoryModel.fromApi(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      basePrice: (json['base_price'] as num).toDouble(),
    );
  }

CategoryModel copyWith({
    int? id,
    String? name,
    String? description,
    double? basePrice, // ✅ correct field name
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice, // ✅ now valid
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_price': basePrice,
    };
  }
}
