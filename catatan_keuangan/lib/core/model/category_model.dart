class CategoryModel {
  final int id;
  final String name;
  final bool canDelete;
  CategoryModel(this.id, this.name, {this.canDelete = false});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    int id = json['id'] as int;
    String name = json['category_name'] as String;
    bool canDelete = false;
    if (json['canDelete'] is String) {
      canDelete = json['canDelete'] == '1' ? true : false;
    } else if (json['canDelete'] is bool) {
      canDelete = json['canDelete'] as bool;
    }

    return CategoryModel(id, name, canDelete: canDelete);
  }
  Map<String, dynamic> toJsonSave() {
    return {
      'category_name': name,
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      'id': id,
      'category_name': name,
    };
  }
}
