import 'dart:io';

import 'package:drift/drift.dart' show Value;
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
  CategoryData? _selectedFilterCategory;
  CategoryData? _oldSelectedFilterCategory;
  String? _selectedGoal;

  static const int editTransaction = 1;
  static const int deleteTransaction = 2;
  
  late Database _db;
  late MovementTableHelper movementTableHelper;
  late CategoryTableHelper categoryTableHelper;
  late List<CategoryData> categories;
  late List<Widget> containers = [];
  late List<MovementData> transactions = [];
  late String title;
  late String actionButton;
 
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  List<bool> isEntryOrExit = [
    true,
    false
  ];

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
                child: _fillTransactionContainer()
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
                        onChanged: _onSearchChanged,
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

  Future<void> _onSearchChanged(String value) async {
    List<MovementData> list = await movementTableHelper.getByContainsNameAndDate(
      value, 
      DateTime(
        DateTime.now().year,
        DateTime.now().month + _dateDiff,
      ),
    );
    transactions = list;
    setState(_fillTransactionContainer);
  }

  void _setCategoriesList() async {
    List<CategoryData> list = await Future.value(categoryTableHelper.getAllCategories());
    categories = list;
  }

  void _setMovementList() async {
    List<MovementData> list = await Future.value(movementTableHelper.getByMonth(DateTime(
      DateTime.now().year,
      DateTime.now().month + _dateDiff
    )));
    transactions = list;
    setState(_fillTransactionContainer);
  }

  void _setFilteredMovementList(CategoryData? categoryData) async {
    List<MovementData> list = await Future.value(movementTableHelper.getByMonthAndCategory(DateTime(
      DateTime.now().year,
      DateTime.now().month + _dateDiff
    ), categoryData));
    transactions = list;
    setState(_fillTransactionContainer);
  }

  Widget _fillTransactionContainer() {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('Não existem transações para o mês e ano selecionado!')
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _getTransactions()
      ),
    );
  }

  List<Widget> _getTransactions() {
    return containers = transactions.map((item) {
        return Flexible(
          fit: FlexFit.loose,
          child: Container(
            margin: const EdgeInsets.all(2),
            child: Material(
              child: Ink(
                width: 500,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  highlightColor: Colors.grey[700],
                  borderRadius: BorderRadius.circular(6),
                  onTapDown: (details) async => await _showPopupMenu(details.globalPosition, item),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                            Text('R\$ ${item.value.toStringAsFixed(2).replaceAll(r'.', ',')}', style: const TextStyle(fontSize: 18)) 
                          ]
                        )
                      ],
                    )
                  )
                )
              )
            ),
          )
        );
      }).toList();
  }

  void setTransactionDialogText(bool isToAdd) {
    if (isToAdd) {
      title = "Adicionar transação";
      actionButton = "Adicionar";
      return;
    } 
    title = "Editar transação";
    actionButton = "Editar";
  }

  Future<void> _showPopupMenu(Offset globalPosition, MovementData item) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(globalPosition.dx, globalPosition.dy, globalPosition.dx, globalPosition.dy),
      items: const[
        PopupMenuItem(
           value: editTransaction,
          child: Text("Editar"),
        ),
        PopupMenuItem(
          value: deleteTransaction,
          child: Text("Deletar"),
        ),
      ],
      elevation: 8.0,
    ).then((value) async {
      if (value == null) return;
      switch (value) {
        case editTransaction:
          _setFields(item);
          _showAddOrEditTransactionDialog(false, item);
          break;
        case deleteTransaction:
          _showDeleteTransactionDialog(item);
          break;
      }
    });
  }

  void _setFields(MovementData item) async {
    _descriptionController.text = item.description;
    _valueController.text = item.value.toStringAsFixed(2).replaceAll(r'.', ',');
    _dateController.text = DateFormat('dd/MM/yyyy').format(item.timestamp);
    _selectedGoal = null;
    _selectedCategory = await categoryTableHelper.getById(item.categoryId);
    isEntryOrExit = [item.isIncome, !item.isIncome];
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
              onPressed: _showFilterTransactionDialog,
              icon: (_selectedFilterCategory == null) ? const Icon(Icons.filter_alt_off, size: 28) : const Icon(Icons.filter_alt_rounded, size: 28),
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
                isEntryOrExit = [true, false];
                _showAddOrEditTransactionDialog(true, null);
              }, 
              icon: const Icon(Icons.add, size: 28)
            )
          )
        ],
      )
    );
  }

  Future<void> _showAddOrEditTransactionDialog(bool isToAdd, MovementData? item) async {
    setTransactionDialogText(isToAdd);
    final result = await _addOrEditTransactionDialog(isToAdd, item);

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Transação salva!"),
          backgroundColor: Colors.green,
        )
      );
      _setMovementList();
    }
  }

  Future<bool?> _addOrEditTransactionDialog(bool isToAdd, MovementData? item) async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              title: Text(title),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: ListBody(
                    children: <Widget>[
                      Center(
                        child: ToggleButtons(
                          disabledColor: Colors.black,
                          disabledBorderColor: Colors.grey,
                          selectedColor: Colors.deepPurple,
                          selectedBorderColor: Colors.deepPurple,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),

                          isSelected: isEntryOrExit,
                          onPressed: (int index) {
                            setState(() {
                              isEntryOrExit = List.generate(
                                isEntryOrExit.length,
                                (i) => i == index,
                              );
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Entrada'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Saída'),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        onTap: _selectDate,
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
                          label: Text('Categoria'),
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
                          label: Text('Meta'),
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
                      ),
                    ],
                  ),
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
                  child: Text(actionButton),
                  onPressed: () {
                    if (isToAdd) {
                      _addTransaction();
                    } else {
                      _editTransaction(item);
                    }

                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showFilterTransactionDialog() async {
    final result = await _filterTransactionDialog();

    if (result == true && mounted) {
      _setFilteredMovementList(_selectedFilterCategory);
    }
  }

  Future<bool?> _filterTransactionDialog() async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              title: const Text("Filtrar transações"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: ListBody(
                    children: <Widget>[
                      DropdownButtonFormField(
                        decoration: const InputDecoration(
                          filled: true,
                          prefixIcon: Icon(Symbols.target, weight: 700),
                          border: UnderlineInputBorder(),
                          label: Text('Categoria'),
                        ),
                        menuMaxHeight: 250,
                        value: _selectedFilterCategory,
                        isExpanded: true,
                        items: categories.map((CategoryData category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFilterCategory = value as CategoryData;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    _selectedFilterCategory = _oldSelectedFilterCategory;
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Limpar'),
                  onPressed: () {
                    _selectedFilterCategory = null;
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: const Text('Salvar'),
                  onPressed: () {
                    _oldSelectedFilterCategory = _selectedFilterCategory;
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editTransaction(MovementData? item) {
    if (_dateController.text.isEmpty ||
        _selectedCategory == null ||
        _descriptionController.text.isEmpty ||
        _valueController.text.isEmpty) {
      return;
    }

    MovementCompanion movement = MovementCompanion.insert(
      id: Value(item!.id),
      timestamp: DateFormat('dd/MM/yyyy').parse(_dateController.text),
      createdAt: item.createdAt,
      updatedAt: DateTime.now(),
      isIncome: isEntryOrExit[0],
      description: _descriptionController.text,
      value: double.parse(_valueController.text.replaceAll(',', '.')),
      categoryId: _selectedCategory!.id,
    );

    movementTableHelper.updateTransaction(movement);
  }

  void _addTransaction() {
    if (_dateController.text.isEmpty ||
        _selectedCategory == null ||
        _descriptionController.text.isEmpty ||
        _valueController.text.isEmpty) {
      return;
    }
    MovementCompanion movement = MovementCompanion.insert(
      timestamp: DateFormat('dd/MM/yyyy').parse(_dateController.text),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isIncome: isEntryOrExit[0],
      description: _descriptionController.text,
      value: double.parse(_valueController.text.replaceAll(',', '.')),
      categoryId: _selectedCategory!.id,
    );

    movementTableHelper.addTransaction(movement);
  }

  Future<void> _showDeleteTransactionDialog(MovementData item) async {
    final result = await _deleteTransactionDialog(item);

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Transação deletada!"),
          backgroundColor: Colors.red,
        )
      );
      _setMovementList();
    } 
  }

  Future<bool?> _deleteTransactionDialog(MovementData item) async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.zero,
              title: const Text('Deletar transação'),
              content: const Text('Você deseja realmente deletar essa transação?\n\nEssa ação não poderá ser desfeita.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Não'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Sim'),
                  onPressed: () {
                    movementTableHelper.deleteTransaction(item.id);
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate() async {
    DateTime currentDate = DateFormat("dd/MM/yyyy").parse(_dateController.text);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
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
                      _setMovementList();
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
                      _setMovementList();
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