import 'package:fin_fit_app_mobile/ui/main_page.dart';
import 'package:fin_fit_app_mobile/ui/menu_page.dart';
import 'package:fin_fit_app_mobile/ui/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_symbols_icons/symbols.dart';


class InitialPage extends StatefulWidget {
  const InitialPage({super.key, required this.title});

  final String title;

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  int _currentIndex = 0;
  List<Widget> body = [
    const MainPage(),
    const TransactionPage(),
    SvgPicture.asset("assets/ic_target_24.svg", height: 24, width: 24),
    const MenuPageState()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (int newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
          items: const [
            BottomNavigationBarItem(
                label: "Início",
                icon: Icon(Icons.home)),
            BottomNavigationBarItem(
                label: "Transações",
                icon: Icon(Icons.receipt_long)),
            BottomNavigationBarItem(
                label: "Metas",
                icon: Icon(Symbols.target, weight: 700)
            ),
            BottomNavigationBarItem(
                label: "Menu",
                icon: Icon(Icons.menu)
            ),
            
          ],
        ),
        body: Center(
          child: body[_currentIndex],
        )
    );
  }
}
