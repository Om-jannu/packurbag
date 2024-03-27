class Category {
  bool? success;
  String? message;
  List<CategoryData>? categoryData;

  Category({this.success, this.message, this.categoryData});

  Category.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      categoryData = <CategoryData>[];
      json['data'].forEach((v) {
        categoryData!.add(new CategoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> categoryData = new Map<String, dynamic>();
    categoryData['success'] = this.success;
    categoryData['message'] = this.message;
    if (this.categoryData != null) {
      categoryData['data'] = this.categoryData!.map((v) => v.toJson()).toList();
    }
    return categoryData;
  }
}

class CategoryData {
  String? categoryName;
  String? categoryColor;
  int? todoCount;
  int? todoCompleted;
  String? sId;

  CategoryData(
      {this.categoryName, this.categoryColor, this.todoCount,this.todoCompleted, this.sId});

  CategoryData.fromJson(Map<String, dynamic> json) {
    categoryName = json['categoryName'];
    categoryColor = json['categoryColor'];
    todoCount = json['todoCount'];
    todoCompleted = json['todoCompleted'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> categoryData = new Map<String, dynamic>();
    categoryData['categoryName'] = this.categoryName;
    categoryData['categoryColor'] = this.categoryColor;
    categoryData['todoCount'] = this.todoCount;
    categoryData['todoCompleted'] = this.todoCompleted;
    categoryData['_id'] = this.sId;
    return categoryData;
  }
}
