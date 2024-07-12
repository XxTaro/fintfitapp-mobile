import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPage();
}

class _TransactionPage extends State<TransactionPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildTransactionHeader(),
          Center(child: Row(
            children: [
              Icon(Icons.arrow_back_ios_new_rounded),
              Text('data'),
              Icon(Icons.arrow_forward_ios_rounded)
            ],
          ))
          
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
  
}