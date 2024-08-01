import 'dart:ffi';
import 'dart:io';

import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
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
  late Database _db;

  @override
  void initState() {
    super.initState();
    _db = DatabaseConnection.instance;
    CategoryTableHelper categoryTableHelper = CategoryTableHelper(_db);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 20, left: 10, right: 20),
                child: Text(
                  "Olá!",
                  style: TextStyle(fontSize: 24),
                )),
            _buildCard("Saldo em ${returnMonth(DateTime.now())}", resumedCurrentMonthCardBody(-10000000)),
            _buildCard("Teste 2", [Text("body")]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String header, List<Widget> body) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            child: Card(
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              color: Colors.grey[300],
              borderOnForeground: true,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      header,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10,),
                    ...body,
                  ],
                ),
              ),
            ),
          )
        )
      ],
    );
  }

  List<Widget> resumedCurrentMonthCardBody(double currentMonthBalance) {
    return [
      getMonthSummary(currentMonthBalance),
      const SizedBox(height: 10,),
      getMonthSummaryInputAndOutputFlow(1000, 2500)
    ];
  }

  Widget getMonthSummary(double currentMonthBalance) {
    SvgPicture picture;
    if (currentMonthBalance > 0) {
      picture = SvgPicture.asset(
            "assets/ic_arrow_circle_up_24.svg",
            height: 48,
            width: 48,
            colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
          );
    } else {
      picture = SvgPicture.asset(
          "assets/ic_arrow_circle_down_24.svg",
          height: 48,
          width: 48,
          colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
        );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        picture,
        const SizedBox(width: 5,),
        Text(formattedNumberStr(currentMonthBalance), style: const TextStyle(fontSize: 24))
    ]);
  }

  Widget getMonthSummaryInputAndOutputFlow(double input, double output) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          getFlow('Entrada', input),
          getFlow('Saída', output)
        ],
      );
  }

  Widget getFlow(String text, double flow) {
    return Column(
      children: [
        Text(text),
        Text(formattedNumberStr(flow))
      ],
    );
  }

  String returnMonth(DateTime date) {
    initializeDateFormatting();
    String locale = Platform.localeName;
    return DateFormat.MMMM(locale).format(date);
  }

  String formattedNumberStr(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: ' R\$').format(value);
  }
}
