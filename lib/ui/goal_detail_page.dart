import 'package:drift/drift.dart' as drift;
import 'package:fin_fit_app_mobile/command/delete_popup_command.dart';
import 'package:fin_fit_app_mobile/command/edit_popup_command.dart';
import 'package:fin_fit_app_mobile/command/popup.dart';
import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/goal_table_helper.dart';
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
  final CategoryTableHelper categoryTableHelper;
  final GoalTableHelper goalTableHelper;

  const GoalDetailPage({
    super.key,
    required this.goal,
    required this.onBack,
    required this.movementTableHelper,
    required this.categoryTableHelper,
    required this.goalTableHelper,
  });

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> implements PopUp {
  static const int editTransaction = 1;
  static const int deleteTransaction = 2;

  late GoalData _currentGoal;
  double _currentAmount = 0.0;
  List<CategoryData> _categories = [];
  List<GoalData> _goals = [];

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  List<bool> _isEntryOrExit = [true, false];
  CategoryData? _selectedCategory;
  GoalData? _selectedGoal;

  @override
  void initState() {
    super.initState();
    _currentGoal = widget.goal;
    _loadInitialData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final categories = await widget.categoryTableHelper.getAllCategories();
    final goals = await widget.goalTableHelper.getAllGoals();
    
    setState(() {
      _categories = categories;
      _goals = goals;
    });

    await _refreshGoalProgress();
  }

  Future<void> _refreshGoalProgress() async {
    final total = await _getGoalBalance(_currentGoal.id);
    if (mounted) {
      setState(() {
        _currentAmount = total;
      });
    }
  }

  Future<double> _getGoalBalance(int goalId) async {
    final movements = await widget.movementTableHelper.getByGoalId(goalId);
    return movements.fold<double>(0.0, (sum, item) => sum + item.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditGoalDialog(_currentGoal),
          ),
        ],
      ),
      body: _buildGoalDetails(),
    );
  }

  Widget _buildGoalDetails() {
    return FutureBuilder<List<MovementData>>(
      future: widget.movementTableHelper.getByGoalId(_currentGoal.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              _GoalProgressHeader(
                goal: _currentGoal,
                currentAmount: _currentAmount,
              ),
              const Expanded(
                child: Center(child: Text('Não existem transações para esta meta!')),
              ),
            ],
          );
        }

        final movements = snapshot.data!;
        return Column(
          children: [
            _GoalProgressHeader(
              goal: _currentGoal,
              currentAmount: _currentAmount,
            ),
            Expanded(
              child: _TransactionListView(
                transactions: movements,
                onTransactionTapped: (position, item) {
                  _showPopupMenu(position, item);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Lógica para Popup de Ações da Transação
  Future<void> _showPopupMenu(Offset globalPosition, MovementData item) async {
    final commands = {
      editTransaction: EditPopUpCommand(context, this, item.id),
      deleteTransaction: DeletePopUpCommand(context, this, item.id),
    };

    final value = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
          globalPosition.dx, globalPosition.dy, globalPosition.dx, globalPosition.dy),
      items: const [
        PopupMenuItem(value: editTransaction, child: Text("Editar")),
        PopupMenuItem(value: deleteTransaction, child: Text("Deletar")),
      ],
    );

    if (value != null) {
      await commands[value]?.execute();
    }
  }

  // Lógica para Edição da Meta
  Future<void> _showEditGoalDialog(GoalData goal) async {
    _descriptionController.text = goal.description;
    _valueController.text = goal.value.toString();
    _dateController.text = DateFormat('dd/MM/yyyy').format(goal.dateEnd);
    _selectedCategory = await widget.categoryTableHelper.getById(goal.categoryId);

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildGoalEditDialog(goal),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Meta salva!"),
        backgroundColor: Colors.green,
      ));
      final updatedGoal = await widget.goalTableHelper.getById(goal.id);
      setState(() {
        if(updatedGoal != null) _currentGoal = updatedGoal;
      });
      await _refreshGoalProgress();
    }
  }

  Widget _buildGoalEditDialog(GoalData goal) {
     return AlertDialog(
      title: const Text('Editar meta'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição', prefixIcon: Icon(Icons.description)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Valor alvo', prefixIcon: Icon(Icons.attach_money)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(labelText: 'Data', prefixIcon: Icon(Icons.calendar_today)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: const Text('Editar'),
          onPressed: () {
            _handleGoalUpdate(goal);
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  void _handleGoalUpdate(GoalData originalGoal) {
    if (_descriptionController.text.isEmpty || _valueController.text.isEmpty || _dateController.text.isEmpty) {
      return;
    }

    final updatedGoal = GoalCompanion(
      id: drift.Value(originalGoal.id),
      dateEnd: drift.Value(DateFormat('dd/MM/yyyy').parse(_dateController.text)),
      description: drift.Value(_descriptionController.text),
      value: drift.Value(int.parse(_valueController.text)),
      // Mantém os valores originais que não são editados no diálogo
      dateStart: drift.Value(originalGoal.dateStart),
      categoryId: drift.Value(originalGoal.categoryId),
    );

    widget.goalTableHelper.updateGoal(updatedGoal);
  }


  // Lógica para Edição e Deleção de Transação (implementação da interface PopUp)
  @override
  Future<void> showAddOrEditDialog(bool isToAdd, int id) async {
    final item = await widget.movementTableHelper.getById(id);
    if (item == null) return;

    _descriptionController.text = item.description;
    _valueController.text = NumberFormat.currency(locale: 'pt_BR', symbol: '').format(item.value);
    _dateController.text = DateFormat('dd/MM/yyyy').format(item.timestamp);
    _selectedCategory = await widget.categoryTableHelper.getById(item.categoryId);
    _selectedGoal = item.goalId != null ? await widget.goalTableHelper.getById(item.goalId!) : null;
    _isEntryOrExit = [item.isIncome, !item.isIncome];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildMovementEditDialog(item),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Transação salva!"),
        backgroundColor: Colors.green,
      ));
      setState(() {}); // Força o FutureBuilder a reconstruir
      await _refreshGoalProgress();
    }
  }

  @override
  Future<void> showDeleteDialog(int id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar transação'),
        content: const Text('Você deseja realmente deletar essa transação?\nEssa ação não poderá ser desfeita.'),
        actions: [
          TextButton(
            child: const Text('Não'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Sim'),
            onPressed: () {
              widget.movementTableHelper.deleteTransaction(id);
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Transação deletada!"),
        backgroundColor: Colors.red,
      ));
      setState(() {}); // Força o FutureBuilder a reconstruir
      await _refreshGoalProgress();
    }
  }

  Widget _buildMovementEditDialog(MovementData movement) {
    return AlertDialog(
      title: const Text('Editar Transação'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: ListBody(
              children: [
                // ToggleButtons, TextFields e Dropdowns para edição da transação
                 Center(
                  child: ToggleButtons(
                    isSelected: _isEntryOrExit,
                    onPressed: (int index) {
                      setState(() {
                        _isEntryOrExit = List.generate(_isEntryOrExit.length, (i) => i == index);
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Entrada')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Saída')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  onTap: _selectDate,
                  readOnly: true,
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Data', prefixIcon: Icon(Icons.calendar_today)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição', prefixIcon: Icon(Icons.description)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Valor', prefixIcon: Icon(Icons.attach_money)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+([,.]\d{0,2})?$'))],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<CategoryData>(
                  value: _selectedCategory,
                  items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  decoration: const InputDecoration(labelText: 'Categoria', prefixIcon: Icon(Symbols.category)),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<GoalData?>(
                  value: _selectedGoal,
                  items: _goals.map((goal) => DropdownMenuItem<GoalData>(value: goal, child: Text(goal.description))).toList(),
                  onChanged: (value) => setState(() => _selectedGoal = value),
                  decoration: const InputDecoration(labelText: 'Meta', prefixIcon: Icon(Icons.sell)),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            _handleMovementUpdate(movement);
            Navigator.of(context).pop(true);
          },
          child: const Text('Editar'),
        ),
      ],
    );
  }

  void _handleMovementUpdate(MovementData originalMovement) {
    if (_dateController.text.isEmpty ||
        _selectedCategory == null ||
        _descriptionController.text.isEmpty ||
        _valueController.text.isEmpty) {
      return;
    }

    final valueString = _valueController.text.replaceAll('.', '').replaceAll(',', '.');
    final value = double.tryParse(valueString) ?? 0.0;
    
    final updatedMovement = MovementCompanion(
      id: drift.Value(originalMovement.id),
      timestamp: drift.Value(DateFormat('dd/MM/yyyy').parse(_dateController.text)),
      updatedAt: drift.Value(DateTime.now()),
      isIncome: drift.Value(_isEntryOrExit[0]),
      description: drift.Value(_descriptionController.text),
      value: drift.Value(value),
      categoryId: drift.Value(_selectedCategory!.id),
      goalId: drift.Value(_selectedGoal?.id),
    );

    widget.movementTableHelper.updateTransaction(updatedMovement);
  }

  // Seletor de data genérico
  Future<void> _selectDate() async {
    final initialDate = _dateController.text.isNotEmpty
        ? DateFormat("dd/MM/yyyy").parse(_dateController.text)
        : DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }
}

class _GoalProgressHeader extends StatelessWidget {
  final GoalData goal;
  final double currentAmount;

  const _GoalProgressHeader({
    required this.goal,
    required this.currentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (goal.value != 0) ? (currentAmount / goal.value * 100) : 0.0;
    final remainingDays = goal.dateEnd.difference(DateTime.now()).inDays;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Meta: ${goal.description}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text('Saldo: ${currencyFormat.format(currentAmount)}', style: const TextStyle(fontSize: 20)),
          Text('Progresso: ${progress.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text('Dias restantes: $remainingDays d', style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

// Widget para a Lista de Transações
class _TransactionListView extends StatelessWidget {
  final List<MovementData> transactions;
  final void Function(Offset, MovementData) onTransactionTapped;

  const _TransactionListView({
    required this.transactions,
    required this.onTransactionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final item = transactions[index];
        return _TransactionListItem(
          item: item,
          onTapDown: (details) => onTransactionTapped(details.globalPosition, item),
        );
      },
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final MovementData item;
  final GestureTapDownCallback onTapDown;

  const _TransactionListItem({
    required this.item,
    required this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTapDown: onTapDown,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('dd/MM/yyyy').format(item.timestamp), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  _getInflowOrOutflowIcon(item.isIncome),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.description,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currencyFormat.format(item.value),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: item.isIncome ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getInflowOrOutflowIcon(bool isIncome) {
    return SvgPicture.asset(
      isIncome ? "assets/ic_arrow_circle_up_24.svg" : "assets/ic_arrow_circle_down_24.svg",
      height: 28,
      width: 28,
      colorFilter: ColorFilter.mode(isIncome ? Colors.green : Colors.red, BlendMode.srcIn),
    );
  }
}