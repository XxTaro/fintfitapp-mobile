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

class _GoalWithProgress {
  final GoalData goal;
  final double currentBalance;

  _GoalWithProgress({required this.goal, required this.currentBalance});
}

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

  late final MovementTableHelper movementTableHelper;
  late final CategoryTableHelper categoryTableHelper;
  late final GoalTableHelper goalTableHelper;

  List<_GoalWithProgress> _goalsWithProgress = [];
  bool _isLoading = true;
  GoalData? _selectedGoal;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    movementTableHelper = widget.movementTableHelper ?? MovementTableHelper(DatabaseConnection.instance);
    categoryTableHelper = widget.categoryTableHelper ?? CategoryTableHelper(DatabaseConnection.instance);
    goalTableHelper = widget.goalTableHelper ?? GoalTableHelper(DatabaseConnection.instance);

    _refreshGoals();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _refreshGoals() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final goals = await goalTableHelper.getAllGoals();
    final goalsWithProgress = <_GoalWithProgress>[];

    for (final goal in goals) {
      final balance = await _getGoalBalance(goal.id);
      goalsWithProgress.add(_GoalWithProgress(goal: goal, currentBalance: balance));
    }

    if (mounted) {
      setState(() {
        _goalsWithProgress = goalsWithProgress;
        _isLoading = false;
      });
    }
  }

  Future<double> _getGoalBalance(int goalId) async {
    final movements = await movementTableHelper.getByGoalId(goalId);
    return movements.fold<double>(0.0, (sum, item) => sum + item.value);
  }

  void _navigateToDetail(GoalData goal) {
    setState(() => _selectedGoal = goal);
  }

  void _navigateBackToList() {
    setState(() => _selectedGoal = null);
    _refreshGoals();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedGoal != null) {
      return GoalDetailPage(
        goal: _selectedGoal!,
        onBack: _navigateBackToList,
        movementTableHelper: movementTableHelper,
        categoryTableHelper: categoryTableHelper,
        goalTableHelper: goalTableHelper,
      );
    }
    return _buildGoalList();
  }

  Widget _buildGoalList() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _GoalListHeader(
              onAddPressed: () => showAddOrEditDialog(true, 0),
              onFilterPressed: () { /* Lógica de filtro aqui */ },
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _GoalListView(
                      goalsWithProgress: _goalsWithProgress,
                      onGoalTap: _navigateToDetail,
                      onGoalLongPress: _showPopupMenu,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> showAddOrEditDialog(bool isToAdd, int id) async {
    String dialogTitle = isToAdd ? "Adicionar Meta" : "Editar Meta";
    String actionButtonText = isToAdd ? "Adicionar" : "Editar";
    GoalData? goal = isToAdd ? null : await goalTableHelper.getById(id);

    if (goal != null) {
      _descriptionController.text = goal.description;
      _valueController.text = goal.value.toString();
      _dateController.text = DateFormat('dd/MM/yyyy').format(goal.dateEnd);
    } else {
      _descriptionController.clear();
      _valueController.clear();
      _dateController.clear();
    }

    if (mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder: (_) => _buildAddOrEditDialog(dialogTitle, actionButtonText, isToAdd, goal),
      );

      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Meta salva!"),
          backgroundColor: Colors.green,
        ));
        await _refreshGoals();
      }
    }
    
  }

  @override
  Future<void> showDeleteDialog(int id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar meta'),
        content: const Text('Você deseja realmente deletar essa meta?\n\nEssa ação não poderá ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Não')),
          TextButton(
            onPressed: () {
              goalTableHelper.deleteGoal(id);
              Navigator.of(context).pop(true);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Meta deletada!"),
        backgroundColor: Colors.red,
      ));
      await _refreshGoals();
    }
  }
  
  AlertDialog _buildAddOrEditDialog(String title, String actionButton, bool isToAdd, GoalData? item) {
    return AlertDialog(
      title: Text(title),
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
              onTap: _selectDate,
              readOnly: true,
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Data Final', prefixIcon: Icon(Icons.calendar_today)),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        TextButton(
          child: Text(actionButton),
          onPressed: () {
            _handleSaveGoal(isToAdd, item);
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  void _handleSaveGoal(bool isToAdd, GoalData? item) {
    if (_descriptionController.text.isEmpty || _valueController.text.isEmpty || _dateController.text.isEmpty) {
      return;
    }

    final companion = GoalCompanion(
      description: Value(_descriptionController.text),
      value: Value(int.parse(_valueController.text)),
      dateEnd: Value(DateFormat('dd/MM/yyyy').parse(_dateController.text)),
      dateStart: isToAdd ? Value(DateTime.now()) : const Value.absent(),
      categoryId: isToAdd ? const Value(0) : const Value.absent(),
    );

    if (isToAdd) {
      goalTableHelper.addGoal(companion);
    } else if (item != null) {
      goalTableHelper.updateGoal(companion.copyWith(id: Value(item.id)));
    }
  }

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

  Future<void> _showPopupMenu(Offset globalPosition, int id) async {
    final commands = {
      editGoal: EditPopUpCommand(context, this, id),
      deleteGoal: DeletePopUpCommand(context, this, id),
    };

    final value = await showMenu<int>(
      context: context,
      position: RelativeRect.fromRect(globalPosition & const Size(40, 40), Offset.zero & (Overlay.of(context).context.findRenderObject()! as RenderBox).size),
      items: const [
        PopupMenuItem(value: editGoal, child: Text("Editar")),
        PopupMenuItem(value: deleteGoal, child: Text("Deletar")),
      ],
    );

    if (value != null) {
      await commands[value]?.execute();
    }
  }
}

class _GoalListHeader extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onFilterPressed;
  
  const _GoalListHeader({required this.onAddPressed, required this.onFilterPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text('Metas', style: TextStyle(fontSize: 28)),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onFilterPressed,
              icon: const Icon(Icons.filter_alt_off, size: 28),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalListView extends StatelessWidget {
  final List<_GoalWithProgress> goalsWithProgress;
  final Function(GoalData) onGoalTap;
  final Function(Offset, int) onGoalLongPress;

  const _GoalListView({
    required this.goalsWithProgress,
    required this.onGoalTap,
    required this.onGoalLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (goalsWithProgress.isEmpty) {
      return const Center(child: Text('Não existem metas cadastradas!'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: goalsWithProgress.length,
      itemBuilder: (context, index) {
        final item = goalsWithProgress[index];
        return _GoalListItem(
          goalWithProgress: item,
          onTap: () => onGoalTap(item.goal),
          onLongPress: (details) => onGoalLongPress(details.globalPosition, item.goal.id),
        );
      },
    );
  }
}

class _GoalListItem extends StatelessWidget {
  final _GoalWithProgress goalWithProgress;
  final VoidCallback onTap;
  final GestureLongPressStartCallback? onLongPress;

  const _GoalListItem({
    required this.goalWithProgress,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final goal = goalWithProgress.goal;
    final currentBalance = goalWithProgress.currentBalance;
    final progress = (goal.value > 0) ? (currentBalance / goal.value) : 0.0;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final remainingDays = goal.dateEnd.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress != null
            ? () => onLongPress!(const LongPressStartDetails(globalPosition: Offset.zero))
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Saldo: ${currencyFormat.format(currentBalance)}'),
                  Text('Meta: ${currencyFormat.format(goal.value)}'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: clampedProgress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('${(progress * 100).toStringAsFixed(1)}% alcançado', style: const TextStyle(fontSize: 14)),
                   Text('$remainingDays dias restantes', style: const TextStyle(fontSize: 14)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}