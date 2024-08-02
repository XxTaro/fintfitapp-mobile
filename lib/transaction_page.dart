import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPage();
}

class _TransactionPage extends State<TransactionPage> {
  String date = "date";
  int _dateDiff = 0;
  List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5', 'Item 6', 'Item 7', 'Item 8', 'Item 9', 'Item 10', 'Item 11', 'Item 12', 'Item 13'];

  late List<Widget> containers = [];


  @override
  void initState() {
    super.initState();
    setState(() {
      date = returnMonthAndYear(DateTime(DateTime.now().year, DateTime.now().month - _dateDiff, DateTime.now().day));
    });
    containers = items.map((item) {
      return Flexible(
        fit: FlexFit.loose,
        child: Container(
          width: 500,
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('30/07/2024'),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    SvgPicture.asset(
                      "assets/ic_arrow_circle_up_24.svg",
                      height: 28,
                      width: 28,
                      colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 5),
                    Text('Test', style: const TextStyle(fontSize: 18))
                  ]),
                  Text('R\$ 100,00', style: const TextStyle(fontSize: 18)) 
                ]
              )
            ],
          )
        )
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildTransactionHeader(),
          _buildDateSelection(),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: containers
              ),
            )
          ),)
        ],
      )
    );
  }

  Widget _buildTransactionHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20), 
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text('Transações', style: TextStyle(fontSize: 28))
          ),
          Positioned(
            right: 0, 
            child: Icon(Icons.filter_alt_off, size: 28)
          )
        ],
      )
    );
  }

  Widget _buildDateSelection() {
    return Padding(
      padding: const EdgeInsets.only(top: 30), 
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(date, style: TextStyle(fontSize: 18))
          ),
          Positioned(
            left: 0,
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 24), 
                  onPressed: () {
                    setState(() {
                      _dateDiff--;
                      date = returnMonthAndYear(DateTime(DateTime.now().year, DateTime.now().month + _dateDiff, DateTime.now().day));
                    });
                  },
                ),
            ) 
          ),
          Positioned(
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 24), 
                  onPressed: () {
                    setState(() {
                      _dateDiff++;
                      date = returnMonthAndYear(DateTime(DateTime.now().year, DateTime.now().month + _dateDiff, DateTime.now().day));
                    });
                  },
                )
            ) 
          )
        ],
      )
    );
  }

  String returnMonthAndYear(DateTime date) {
    initializeDateFormatting();
    String locale = Platform.localeName;

    return DateFormat.yMMMM(locale).format(date);
  }
  
}