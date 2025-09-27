import 'package:drift/drift.dart' show Value;
import 'package:fin_fit_app_mobile/command/delete_popup_command.dart';
import 'package:fin_fit_app_mobile/command/edit_popup_command.dart';
import 'package:fin_fit_app_mobile/command/popup.dart';
import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/goal_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:fin_fit_app_mobile/ui/goal_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GoalPageStateful extends StatefulWidget {
  final MovementTableHelper? movementTableHelper;
  final CategoryTableHelper? categoryTableHelper;
  final GoalTableHelper? goalTableHelper;
  final String? locale;

  const GoalPageStateful({
    super.key,
    this.movementTableHelper,
    this.categoryTableHelper,
    this.goalTableHelper,
    this.locale,
  });

  @override
  State<GoalPageStateful> createState() => _GoalPageStatefulState();
}

class _GoalPageStatefulState extends State<GoalPageStateful> implements PopUp {
  static const int editGoal = 1;
  static const int deleteGoal = 2;

  CategoryData? _selectedFilterCategory;
  List<GoalData> goals = [];
  CategoryData? _selectedCategory;
  late List<CategoryData> categories;
  late String title;
  late String actionButton;
  GoalData? _selectedGoal;

  late MovementTableHelper movementTableHelper;
  late CategoryTableHelper categoryTableHelper;
  late GoalTableHelper goalTableHelper;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    movementTableHelper = widget.movementTableHelper ??
        MovementTableHelper(DatabaseConnection.instance);
    categoryTableHelper = widget.categoryTableHelper ??
        CategoryTableHelper(DatabaseConnection.instance);
    goalTableHelper =
        widget.goalTableHelper ?? GoalTableHelper(DatabaseConnection.instance);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setCategoriesList();
      _setGoalList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _selectedGoal == null
        ? buildGoalList()
        : GoalDetailPage(
            goal: _selectedGoal!,
            onBack: () {
              setState(() {
                _selectedGoal = null;
              });
            },
            movementTableHelper: movementTableHelper,
            categoryTableHelper: categoryTableHelper,
          );
  }

  Widget buildGoalList() {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(10), child: _fillGoalContainer()),
          )
        ],
      )),
    );
  }

  void _setCategoriesList() async {
    List<CategoryData> list =
        await Future.value(categoryTableHelper.getAllCategories());
    categories = list;
  }

  Widget _buildHeader() {
    return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(child: Text('Metas', style: TextStyle(fontSize: 28))),
            Positioned(
                left: 0,
                child: IconButton(
                  onPressed: _showFilterGoalDialog,
                  icon: (_selectedFilterCategory == null)
                      ? const Icon(Icons.filter_alt_off, size: 28)
                      : const Icon(Icons.filter_alt_rounded, size: 28),
                )),
            Positioned(
                right: 0,
                child: IconButton(
                    onPressed: () {
                      _descriptionController.clear();
                      _valueController.clear();
                      _dateController.clear();
                      _selectedCategory = null;
                      showAddOrEditDialog(true, 0);
                    },
                    icon: const Icon(Icons.add, size: 28)))
          ],
        ));
  }

  Future<void> _showFilterGoalDialog() async {}

  Widget _fillGoalContainer() {
    if (goals.isEmpty) {
      return const Center(
          child: Text('Não existem metas cadastradas!'));
    }

    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: _getGoals()),
    );
  }

  List<Widget> _getGoals() {
    return goals.map((item) {
      return FutureBuilder<double>(
        future: _getGoalBalance(item.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Erro ao carregar progresso: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            final current = snapshot.data!;
            final progress = snapshot.data! / item.value;
            final clampedProgress = progress.clamp(0.0, 1.0);
            final percentText =
                NumberFormat.percentPattern('pt_BR').format(clampedProgress);
            return Flexible(
              fit: FlexFit.loose,
              child: Container(
                margin:
                    const EdgeInsets.only(top: 2, bottom: 8, left: 2, right: 2),
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
                      onTap: () {
                        setState(() {
                          _selectedGoal = item;
                        });
                      },
                      onLongPress: () async {
                        final RenderBox overlay = Overlay.of(context)
                            .context
                            .findRenderObject() as RenderBox;
                        final Offset position = Offset(
                            overlay.size.width / 2, overlay.size.height / 2);
                        await _showPopupMenu(position, item.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Meta',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(item.description,
                                    style: const TextStyle(fontSize: 16))),
                            const SizedBox(height: 5),
                            const Text('Valor atual',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text('R\$ ${current.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16))),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                  '${(progress * 100).toStringAsFixed(2)}% concluído',
                                  style: const TextStyle(fontSize: 16)),
                            ),
                            Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Semantics(
                                  label: 'Progresso da meta: $percentText',
                                  child: LinearProgressIndicator(
                                    value: clampedProgress,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest,
                                  ),
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('R\$ ${item.value.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                                'Data final: ${DateFormat('dd/MM/yyyy').format(item.dateEnd)} (${item.dateEnd.difference(DateTime.now()).inDays} dias restantes)',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
    }).toList();
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

  Future<void> _showPopupMenu(Offset globalPosition, int id) async {
    final commands = {
      editGoal: EditPopUpCommand(context, this, id),
      deleteGoal: DeletePopUpCommand(context, this, id),
    };

    final value = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(globalPosition.dx, globalPosition.dy,
          globalPosition.dx, globalPosition.dy),
      items: const [
        PopupMenuItem(value: editGoal, child: Text("Editar")),
        PopupMenuItem(value: deleteGoal, child: Text("Deletar")),
      ],
      elevation: 8.0,
    );

    if (value != null) {
      await commands[value]?.execute();
    }
  }

  @override
  Future<void> showAddOrEditDialog(bool isToAdd, int id) async {
    GoalData? item = await goalTableHelper.getById(id);
    setGoalDialogText(isToAdd);
    if (!isToAdd) setFields(item);
    final result = await _addOrEditGoalDialog(isToAdd, item);

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Meta salva!"),
        backgroundColor: Colors.green,
      ));
      _setGoalList();
    }
  }

  void _setGoalList() async {
    List<GoalData> list = await Future.value(goalTableHelper.getAllGoals());
    goals = list;
    setState(_fillGoalContainer);
  }

  Future<bool?> _addOrEditGoalDialog(bool isToAdd, GoalData? item) async {
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
                          labelText: 'Valor alvo',
                          hintText: '1000',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                        ],
                        keyboardType: TextInputType.number,
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
                      _addGoal();
                    } else {
                      _editGoal(item);
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

  void _editGoal(GoalData? item) {
    if (_dateController.text.isEmpty ||
        _selectedCategory == null ||
        _descriptionController.text.isEmpty ||
        _valueController.text.isEmpty) {
      return;
    }

    GoalCompanion goal = GoalCompanion.insert(
      id: Value(item!.id),
      dateStart: DateTime.now(),
      dateEnd: DateFormat('dd/MM/yyyy').parse(_dateController.text),
      description: _descriptionController.text,
      value: int.parse(_valueController.text),
      categoryId: _selectedCategory!.id,
    );

    goalTableHelper.updateGoal(goal);
  }

  Future<void> _addGoal() async {
    if (_dateController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _valueController.text.isEmpty) {
      return;
    }

    GoalCompanion goal = GoalCompanion.insert(
      description: _descriptionController.text,
      dateStart: DateTime.now(),
      dateEnd: DateFormat('dd/MM/yyyy').parse(_dateController.text),
      value: int.parse(_valueController.text),
      categoryId: 0,
    );

    await goalTableHelper.addGoal(goal);
  }

  Future<void> _selectDate() async {
    DateTime currentDate;
    if (_dateController.text.isEmpty) {
      currentDate = DateTime.now();
    } else {
      currentDate = DateFormat("dd/MM/yyyy").parse(_dateController.text);
    }
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

  void setFields(GoalData? item) async {
    _descriptionController.text = item!.description;
    _valueController.text = item.value.toString();
    _dateController.text = DateFormat('dd/MM/yyyy').format(item.dateEnd);
    _selectedCategory = await categoryTableHelper.getById(item.categoryId);
  }

  void setGoalDialogText(bool isToAdd) {
    if (isToAdd) {
      title = "Adicionar meta";
      actionButton = "Adicionar";
      return;
    }
    title = "Editar meta";
    actionButton = "Editar";
  }

  @override
  Future<void> showDeleteDialog(int id) async {
    GoalData? item = await goalTableHelper.getById(id);
    if (item == null) return;
    final result = await _deleteGoalDialog(item);

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Meta deletada!"),
        backgroundColor: Colors.red,
      ));
      _setGoalList();
    }
  }

  Future<bool?> _deleteGoalDialog(GoalData item) async {
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
              title: const Text('Deletar meta'),
              content: const Text(
                  'Você deseja realmente deletar essa meta?\n\nEssa ação não poderá ser desfeita.'),
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
                    goalTableHelper.deleteGoal(item.id);
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
