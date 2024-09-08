import 'dart:io';

import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPage();
}

class _TransactionPage extends State<TransactionPage> {
  String date = "date";
  int _dateDiff = 0;
  CategoryData? _selectedCategory;
  String? _selectedGoal;
  
  late Database _db;
  late MovementTableHelper movementTableHelper;
  late CategoryTableHelper categoryTableHelper;
  late List<CategoryData> categories;
  late List<Widget> containers = [];
  late List<MovementData> transactions;
 
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _db = DatabaseConnection.instance;
    movementTableHelper = MovementTableHelper(_db);
    categoryTableHelper = CategoryTableHelper(_db);
    setState(() {
      date = returnMonthAndYear(DateTime(DateTime.now().year, DateTime.now().month - _dateDiff, DateTime.now().day));
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setCategoriesList();
      _setMovementList();
      
    });
  }

  _setCategoriesList() async {
    List<CategoryData> list = await Future.value(categoryTableHelper.getAllCategories());
    categories = list;
  }

  _setMovementList() async {
    List<MovementData> list = await Future.value(movementTableHelper.getAllTransactions());
    transactions = list;
    print(list);
    setState(() {
      _fillTransactionContainer();
    });
  }

  _fillTransactionContainer() {
    containers = transactions.map((item) {
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
                Text(DateFormat('dd/MM/yyyy').format(item.timestamp)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      getInflowOrOutflowIcon(item.isIncome),
                      const SizedBox(width: 5),
                      Text(item.description, style: const TextStyle(fontSize: 18))
                    ]),
                    Text('R\$ ${item.value.toString().replaceAll(r'.', ',')}', style: const TextStyle(fontSize: 18)) 
                  ]
                )
              ],
            )
          )
        );
      }).toList();
  }

  Widget getInflowOrOutflowIcon(bool isIncome) {
    if (isIncome) {
      return SvgPicture.asset(
        "assets/ic_arrow_circle_up_24.svg",
        height: 28,
        width: 28,
        colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
      );
    } else {
      return SvgPicture.asset(
        "assets/ic_arrow_circle_down_24.svg",
        height: 28,
        width: 28,
        colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
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
              ),),
              Row(
                children: [
                  Expanded(
                    flex: 80,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: UnderlineInputBorder(),
                          labelText: 'Procure pelo gasto desejado',
                        ),
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20), 
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text('Transações', style: TextStyle(fontSize: 28))
          ),
          Positioned(
            left: 0, 
            child: IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.filter_alt_off, size: 28),
            ) 
          ),
          Positioned(
            right: 0, 
            child: IconButton(
              onPressed: () {
                _descriptionController.clear();
                _valueController.clear();
                _dateController.clear();
                _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
                _selectedGoal = null;
                _selectedCategory = null;
                _showAddTransactionDialog();
              }, 
              icon: const Icon(Icons.add, size: 28)
            )
          )
        ],
      )
    );
  }

  Future<void> _showAddTransactionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          title: const Text('Adicionar transação'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: ListBody(
                children: <Widget>[
                  TextField(
                    onTap: () => _selectDate(),
                    readOnly: true,
                    controller: _dateController,
                    decoration: const InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.calendar_today),
                      contentPadding: EdgeInsets.all(0),
                      border: UnderlineInputBorder(),
                      labelText: 'Data',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.description),
                      contentPadding: EdgeInsets.all(0),
                      border: UnderlineInputBorder(),
                      labelText: 'Descrição',
                    ),
                  ),
                  const SizedBox(height: 20),
                   TextField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      filled: true,
                      prefixIcon: Icon(Icons.attach_money),
                      contentPadding: EdgeInsets.all(0),
                      border: UnderlineInputBorder(),
                      labelText: 'Valor',
                      hintText: '0,00',
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+(,\d{0,2})?$'))],
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        prefixIcon: Icon(Symbols.target, weight: 700),
                        border: UnderlineInputBorder(),
                        label: Text('Categoria')
                      ),
                      menuMaxHeight: 250,
                      value: _selectedCategory,
                      isExpanded: true,
                      items: categories.map((CategoryData category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value as CategoryData;
                        });
                      },
                  
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        prefixIcon: Icon(Icons.sell),
                        border: UnderlineInputBorder(),
                        label: Text('Meta')
                      ),
                      menuMaxHeight: 250,
                      value: _selectedGoal,
                      isExpanded: true,
                      items: [].map((dynamic category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGoal = value.toString();
                        });
                      },
                    )
                  
                ],
              )
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
              child: const Text('Adicionar'),
              onPressed: () {
                if (_dateController.text.isEmpty 
                    || _selectedCategory == null 
                    || _descriptionController.text.isEmpty 
                    || _valueController.text.isEmpty) {
                  return;
                }
                MovementCompanion movement = MovementCompanion.insert(
                  timestamp: DateFormat('dd/MM/yyyy').parse(_dateController.text),
                  createdAt: DateTime.now(),
                  isIncome: true,
                  description: _descriptionController.text,
                  value: double.parse(_valueController.text.replaceAll(r',', '.')),
                  categoryId: _selectedCategory!.id
                );
                movementTableHelper.addTransaction(movement);
                setState(() {
                  _fillTransactionContainer();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100)
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Widget _buildDateSelection() {
    return Padding(
      padding: const EdgeInsets.only(top: 30), 
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(date, style: const TextStyle(fontSize: 18))
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