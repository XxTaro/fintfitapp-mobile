import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPage();

}

class _MainPage extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildCard("Saldo em " + returnMonth(DateTime.now()), resumedCurrentMonthCardBody(-1500.abs())),
            _buildCard("Teste 2", Text("body")),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String header, Widget body) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            child: Card(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              color: Colors.grey,
              borderOnForeground: true,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(children: [Text(header, style: const TextStyle(fontSize: 18),)]),
                    Row(children: [body]),
                  ],
                ),
              ),
            ),
          )
        )
      ],
    );
  }

  Widget resumedCurrentMonthCardBody(int currentMonthBalance) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (currentMonthBalance > 0)...[
          SvgPicture.asset("assets/ic_arrow_circle_up_24.svg", height: 24, width: 24, colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),),
          Text("R\$ $currentMonthBalance")
        ]
        else ...[
          SvgPicture.asset("assets/ic_arrow_circle_down_24.svg", height: 24, width: 24, colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),),
          Text("- R\$ ${currentMonthBalance.abs()}")
        ]
      ],
    );
  }

  String returnMonth(DateTime date) {
    initializeDateFormatting();
    return DateFormat.MMMM().format(date);
  }
}
