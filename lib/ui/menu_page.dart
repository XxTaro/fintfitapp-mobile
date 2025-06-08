import 'package:fin_fit_app_mobile/service/auth_service.dart';
import 'package:fin_fit_app_mobile/service/category_service.dart';
import 'package:fin_fit_app_mobile/ui/personalize_category_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuPageState extends StatefulWidget {
  const MenuPageState({super.key});

  @override
  State<MenuPageState> createState() => MenuPageStateState();
}

class MenuPageStateState extends State<MenuPageState> {
  Widget? page;
  List<MenuItemModel> menuItemsList = [
    MenuItemModel(
      title: "Personalizar categorias",
      description: "Criar, editar ou remover categorias",
      icon: const Icon(Icons.edit),
      pageBuilder: () => const PersonalizeCategoryPage(key: ValueKey('personalizeCategoryPage')
      // , categoryService: CategoryService(),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        child: Column(
          children: page == null 
          ? menuItems()
          : [
            page!
          ],
        )
      )
    );
  }

  List<Widget> menuItems() {
    return [
      Expanded(
        child: ListView.builder(
          itemCount: menuItemsList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Material(
                child: Ink(
                  width: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: InkWell(
                    highlightColor: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      setState(() {
                        page = menuItemsList[index].pageBuilder();
                      });
                    },
                    child: ListTile(
                      title: Text(menuItemsList[index].title),
                      subtitle: Text(menuItemsList[index].description),
                      leading: menuItemsList[index].icon,
                    ),
                  )
                )
              ) 
            );
          },
        )
      ),
      const Spacer(),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            )
          ),
          onPressed: () => context.read<AuthService>().logout(), 
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text("Finalizar sessão", style: TextStyle(color: Colors.red))
            ],
          )
        ),
      )
    ];
  }

}

typedef PageBuilder = Widget Function();

class MenuItemModel {
  final String title;
  final String description;
  final Icon icon;
  final PageBuilder pageBuilder;

  // Note que o construtor NÃO é const
  MenuItemModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.pageBuilder,
  });
}