import 'package:fin_fit_app_mobile/service/auth_service.dart';
import 'package:fin_fit_app_mobile/ui/personalize_category_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuPageState extends StatefulWidget {
  const MenuPageState({super.key});

  @override
  State<MenuPageState> createState() => MenuPageStateState();
}

class MenuPageStateState extends State<MenuPageState> {
  StatefulWidget? page;

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
          itemCount: MenuItems.values.length,
          itemBuilder: (context, index) {
            return GestureDetector(
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
                      page = MenuItems.values[index].page;
                    });
                  },
                  child: ListTile(
                    title: Text(MenuItems.values[index].title),
                    subtitle: Text(MenuItems.values[index].description),
                    leading: MenuItems.values[index].icon,
                  ),
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

enum MenuItems {
  logout("Personalizar categorias", "Criar, editar ou remover categorias de transações", Icon(Icons.edit), PersonalizeCategoryPage()),;

  final String title;
  final String description;
  final Icon icon;
  final StatefulWidget page;

  const MenuItems(this.title, this.description, this.icon, this.page);

}