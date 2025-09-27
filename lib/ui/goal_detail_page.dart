import 'package:drift/drift.dart' as drift;
import 'package:fin_fit_app_mobile/command/delete_popup_command.dart';
import 'package:fin_fit_app_mobile/command/edit_popup_command.dart';
import 'package:fin_fit_app_mobile/command/popup.dart';
import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class GoalDetailPage extends StatefulWidget {
  final GoalData goal;
  final VoidCallback onBack;
  final MovementTableHelper movementTableHelper;
  final CategoryTableHelper? categoryTableHelper;

  const GoalDetailPage({
    super.key,
    required this.goal,
    required this.onBack,
    required this.movementTableHelper,
    required this.categoryTableHelper,
  });

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> implements PopUp {
  static const int editTransaction = 1;
  static const int deleteTransaction = 2;

  late GoalData goal = widget.goal;
  late VoidCallback onBack = widget.onBack;
  late double? currentAmount;
  late MovementTableHelper movementTableHelper;
  late CategoryTableHelper categoryTableHelper;
  late List<CategoryData> categories;

  CategoryData? _selectedCategory;
  String? _selectedGoal;
  late List<MovementData> transactions = [];
  late String title;
  late String actionButton;
  late String locale;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  List<bool> isEntryOrExit = [true, false];

  @override
  void initState() {
    super.initState();
    movementTableHelper = widget.movementTableHelper;
    _getGoalBalance(goal.id).then((value) {
      setState(() {
        currentAmount = value;
      });
    });
  }

  Future<double> _getGoalBalance(int goalId) async {
    List<MovementData> movements =
        await movementTableHelper.getByGoalId(goalId);
    double total = 0;
    for (var movement in movements) {
      total += movement.value;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: buildGoalDetails(),
    );
  }

  Widget buildGoalDetails() {
    return FutureBuilder<List<MovementData>>(
      future: movementTableHelper.getByGoalId(goal.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Loading...');
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          print('No data found');
          return const Text('Goal not found');
        } else {
          print('Data loaded: ${snapshot.data!.length} movements');
          List<MovementData> movements = snapshot.data!;
          return _buildGoalInfo(movements);
        }
      },
    );
  }

  List<Widget> _fillTransactionContainer(List<MovementData> transactions) {
    if (transactions.isEmpty) {
      return const [
        Spacer(),
        Text('Não existem transações para essa meta!'),
        Spacer(),
      ];
    }

    return [
      Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 10, right: 10),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _getTransactions(transactions)),
          ))
    ];
  }

  List<Widget> _getTransactions(List<MovementData> transactions) {
    return transactions.map((item) {
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
                        onTapDown: (details) async =>
                            await _showPopupMenu(details.globalPosition, item),
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat('dd/MM/yyyy')
                                    .format(item.timestamp)),
                                const SizedBox(height: 5),
                                Row(children: [
                                  Expanded(
                                    child: Row(children: [
                                      getInflowOrOutflowIcon(item.isIncome),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          child: Text(
                                        item.description,
                                        style: const TextStyle(fontSize: 18),
                                        overflow: TextOverflow.ellipsis,
                                      ))
                                    ]),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      'R\$ ${item.value.toStringAsFixed(2).replaceAll(r'.', ',')}',
                                      style: const TextStyle(fontSize: 18))
                                ])
                              ],
                            ))))),
          ));
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

  Widget _buildGoalInfo(List<MovementData> movements) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Meta: ${goal.description}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text('Saldo', style: TextStyle(fontSize: 20)),
          Text('R\$ ${currentAmount?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(fontSize: 20)),
          Text(
              'Progresso: ${currentAmount != null && goal.value != 0 ? (currentAmount! / goal.value * 100).toStringAsFixed(2) : '0.00'}%',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          Text(
              'Dias restantes: ${goal.dateEnd.difference(DateTime.now()).inDays} d',
              style: const TextStyle(fontSize: 20)),
          ..._fillTransactionContainer(movements),
        ],
      ),
    );
  }

  @override
  Future<void> showAddOrEditDialog(bool isToAdd, int id) async {
    MovementData? item = await movementTableHelper.getById(id);
    setTransactionDialogText(isToAdd);
    if (!isToAdd) setFields(item);
    final result = await _addOrEditTransactionDialog(isToAdd, item);

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Transação salva!"),
        backgroundColor: Colors.green,
      ));
      _setMovementList();
    }
  }

  void _setMovementList() async {
    List<MovementData> list =
        await Future.value(movementTableHelper.getByGoalId(goal.id));
    setState(() => _fillTransactionContainer(list));
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
    final commands = {
      editTransaction: EditPopUpCommand(context, this, item.id),
      deleteTransaction: DeletePopUpCommand(context, this, item.id),
    };

    final value = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(globalPosition.dx, globalPosition.dy,
          globalPosition.dx, globalPosition.dy),
      items: const [
        PopupMenuItem(value: editTransaction, child: Text("Editar")),
        PopupMenuItem(value: deleteTransaction, child: Text("Deletar")),
      ],
      elevation: 8.0,
    );

    if (value != null) {
      await commands[value]?.execute();
    }
  }

  void setFields(MovementData? item) async {
    _descriptionController.text = item!.description;
    _valueController.text = item.value.toStringAsFixed(2).replaceAll(r'.', ',');
    _dateController.text = DateFormat('dd/MM/yyyy').format(item.timestamp);
    _selectedGoal = null;
    _selectedCategory = await categoryTableHelper.getById(item.categoryId);
    isEntryOrExit = [item.isIncome, !item.isIncome];
  }

  Future<bool?> _addOrEditTransactionDialog(
      bool isToAdd, MovementData? item) async {
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
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 24, bottom: 24),
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
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
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
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+(,\d{0,2})?$'))
                        ],
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

  Future<void> _selectDate() async {
    DateTime currentDate = DateFormat("dd/MM/yyyy").parse(_dateController.text);
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _editTransaction(MovementData? item) {
    if (_dateController.text.isEmpty ||
        _selectedCategory == null ||
        _descriptionController.text.isEmpty ||
        _valueController.text.isEmpty) {
      return;
    }

    MovementCompanion movement = MovementCompanion.insert(
      id: drift.Value(item!.id),
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

  @override
  Future<void> showDeleteDialog(int id) async {
    MovementData? item = await movementTableHelper.getById(id);
    if (item == null) return;
    final result = await _deleteTransactionDialog(item);

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Transação deletada!"),
        backgroundColor: Colors.red,
      ));
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
              content: const Text(
                  'Você deseja realmente deletar essa transação?\n\nEssa ação não poderá ser desfeita.'),
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
}
