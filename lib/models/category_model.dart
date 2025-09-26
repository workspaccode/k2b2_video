class CategoryModel {
  final String id;
  final String name;
  final String iconUrl;
  final String coverImageUrl;
  final String description;
  final List<String> subCategories;
  final int videoCount;
  final bool isPopular;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.coverImageUrl,
    required this.description,
    required this.subCategories,
    required this.videoCount,
    this.isPopular = false,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconUrl,
    String? coverImageUrl,
    String? description,
    List<String>? subCategories,
    int? videoCount,
    bool? isPopular,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      description: description ?? this.description,
      subCategories: subCategories ?? this.subCategories,
      videoCount: videoCount ?? this.videoCount,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}
