import 'package:fin_fit_app_mobile/ui/goal_page.dart';
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
    const MainPage(key: Key('statefulMainPage')),
    const TransactionPageStateful(key: Key('statefulTransactionPage')),
    const GoalPageStateful(key: Key('statefulGoalPage')),
    const MenuPageState(key: Key('statefulMenuPage'),),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          key: const Key('navigationBar'),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (int newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
          items: const [
            BottomNavigationBarItem(
              key: Key('navHome'),
              label: "Início",
              icon: Icon(Icons.home)
            ),
            BottomNavigationBarItem(
              key: Key('navTransaction'),
              label: "Transações",
              icon: Icon(Icons.receipt_long)
            ),
            BottomNavigationBarItem(
              key: Key('navGoals'),
              label: "Metas",
              icon: Icon(Symbols.target, weight: 700)
            ),
            BottomNavigationBarItem(
              key: Key('navMenu'),
              label: "Menu",
              icon: Icon(Icons.menu)
            )
          ],
        ),
        body: Center(
          key: const Key('body'),
          child: body[_currentIndex],
        )
    );
  }
}
