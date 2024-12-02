import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:flutter/material.dart';

class PersonalizeCategoryPage extends StatefulWidget {
  const PersonalizeCategoryPage({super.key});

  @override
  State<PersonalizeCategoryPage> createState() => _PersonalizeCategoryPageState();
}

class _PersonalizeCategoryPageState extends State<PersonalizeCategoryPage> {

  late Database _db;
  late MovementTableHelper movementTableHelper;
  late CategoryTableHelper categoryTableHelper;

  late List<CategoryData> categories;

  @override
  void initState() {
    super.initState();

    _db = DatabaseConnection.instance;
    movementTableHelper = MovementTableHelper(_db);
    categoryTableHelper = CategoryTableHelper(_db);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setCategoriesList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Expanded(
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            
          },
        )
      )
    );
  }

  void _setCategoriesList() async {
    List<CategoryData> list = await Future.value(categoryTableHelper.getAllCategories());
    categories = list;
  }
}