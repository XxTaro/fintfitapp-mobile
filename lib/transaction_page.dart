import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPage();
}

class _TransactionPage extends State<TransactionPage> {

  List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5', 'Item 6', 'Item 7', 'Item 8', 'Item 9', 'Item 10'];

  late List<Widget> containers = [];


  @override
  void initState() {
    super.initState();
    containers = items.map((item) {
      return Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        color: Colors.blue,
        child: Text(
          item,
          style: TextStyle(color: Colors.white),
        ),
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
          Stack(
            children: [SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: containers
            ),
          )]
          )
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
          const Center(
            child: Text('Data', style: TextStyle(fontSize: 18))
          ),
          Positioned(
            left: 0,
            child: Container(
              margin: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.arrow_back_ios, size: 18),
            ) 
          ),
          Positioned(
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.arrow_forward_ios, size: 18),
            ) 
          )
        ],
      )
    );
  }
  
}