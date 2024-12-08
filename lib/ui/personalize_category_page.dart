import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:fin_fit_app_mobile/ui/menu_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

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

  final TextEditingController _categoryNameController = TextEditingController();
  String title = "";
  String actionButton = "";

  @override
  void initState() {
    super.initState();

    _db = DatabaseConnection.instance;
    movementTableHelper = MovementTableHelper(_db);
    categoryTableHelper = CategoryTableHelper(_db);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getCategoriesList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                      },
                    )
                  )
                ),
                const Expanded(
                  flex: 2,
                  child: Center(child: Text("Categorias", style: TextStyle(fontSize: 28),)) 
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _showAddOrEditCategoryDialog(true, null);
                      },
                    )
                  )
                )
              ],
            ),
          ),
          FutureBuilder<List<CategoryData>>(
          future: _getCategoriesList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Enquanto o Future ainda está sendo carregado, mostre um indicador de progresso ou algo semelhante
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Caso ocorra algum erro, você pode mostrar uma mensagem de erro
              return const Center(child: Text('Erro ao carregar as categorias'));
            } else if (snapshot.hasData) {
              // Quando o Future retornar os dados, você pode mostrar o card com o saldo
              final List<CategoryData> categories = snapshot.data ?? [];
              return _buildCategoriesListView(categories);
            } else {
              return const Center(child: Text('Nenhuma categoria encontrada'));
            }
          },
        )
        ],
      )
    );
  }

  Widget _buildCategoriesListView(List<CategoryData> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text('No categories found'),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: categories.length,
      
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(categories[index].name),
          trailing: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showAddOrEditCategoryDialog(false, categories[index]);
                  },
                ),
                const VerticalDivider(
                  width: 5, 
                  color: Colors.grey,
                  thickness: 0.5, 
                  indent: 5,
                  endIndent: 5
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteCategoryDialog(categories[index]),
                ),
              ],
            ),
          )
        );
      },
    );
  }

  Future<void> _showDeleteCategoryDialog(CategoryData item) async {
    final result = await _deleteCategoryDialog(item);

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Categoria '${item.name}' deletada!"),
          backgroundColor: Colors.red,
        )
      );
      setState(() {});
    } 
  }

  Future<bool?> _deleteCategoryDialog(CategoryData item) async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.zero,
              title: const Text('Deletar categoria'),
              content: const Text('Você deseja realmente deletar essa categoria?\n\nEssa ação não poderá ser desfeita.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Não'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Sim'),
                  onPressed: () {
                    categoryTableHelper.deleteCategory(item.id);
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void setTransactionDialogText(bool isToAdd) {
    if (isToAdd) {
      title = "Adicionar categoria";
      actionButton = "Adicionar";
      return;
    } 
    title = "Editar categoria";
    actionButton = "Editar";
  }

  Future<void> _showAddOrEditCategoryDialog(bool isToAdd, CategoryData? category) async {
    setTransactionDialogText(isToAdd);
    if (isToAdd) {
      _categoryNameController.clear();
    } else {
      _categoryNameController.text = category!.name;
    }
    final result = await _addOrEditCategoryDialog(isToAdd, category);

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Categoria ${isToAdd ? 'adicionada' : 'editada'}!"),
          backgroundColor: Colors.green,
        )
      );
      setState(() {});
    }
  }

  Future<bool?> _addOrEditCategoryDialog(bool isToAdd, CategoryData? category) async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              title: Text(title),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: ListBody(
                    children: <Widget>[
                      TextField(
                        controller: _categoryNameController,
                        decoration: const InputDecoration(
                          filled: true,
                          prefixIcon: Icon(Symbols.target, weight: 700),
                          contentPadding: EdgeInsets.all(0),
                          border: UnderlineInputBorder(),
                          labelText: 'Nome da categoria',
                          hintText: 'Nome da categoria',
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(actionButton),
                  onPressed: () async {
                    if (isToAdd) {
                      CategoryData? existCat = await categoryTableHelper.getByName(_categoryNameController.text);

                      if (existCat != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Categoria '${existCat.name}' já existe!"),
                            backgroundColor: Colors.red,
                          )
                        );
                        return;
                      }
                      categoryTableHelper.addCategory(CategoryCompanion.insert(name: _categoryNameController.text));

                    } else {
                      CategoryCompanion entry = CategoryCompanion.insert(name: _categoryNameController.text);
                      categoryTableHelper.updateCategoryById(entry, category!.id);
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<List<CategoryData>> _getCategoriesList() async {
    return await Future.value(categoryTableHelper.getAllCategories());
  }
}