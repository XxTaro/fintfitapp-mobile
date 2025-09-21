import 'package:fin_fit_app_mobile/command/delete_popup_command.dart';
import 'package:fin_fit_app_mobile/command/edit_popup_command.dart';
import 'package:fin_fit_app_mobile/command/popup.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/model/movement.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class GoalDetailPage extends StatefulWidget {
  final GoalData goal;
  final VoidCallback onBack;
  final MovementTableHelper movementTableHelper;

  const GoalDetailPage({
    super.key,
    required this.goal,
    required this.onBack,
    required this.movementTableHelper,
  });

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> implements PopUp {
  static const int editGoal = 1;
  static const int deleteGoal = 2;

  late GoalData goal = widget.goal;
  late VoidCallback onBack = widget.onBack;
  late double? currentAmount;
  late MovementTableHelper movementTableHelper;

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

  Widget _fillTransactionContainer(List<MovementData> transactions) {
    if (transactions.isEmpty) {
      return const Center(
          child: Text('Não existem transações para o mês e ano selecionado!'));
    }

    return SingleChildScrollView(
      child:
          Column(mainAxisSize: MainAxisSize.min, children: _getTransactions(transactions)),
    );
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
                            await _showPopupMenu(details.globalPosition, item.id),
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
                                        overflow: TextOverflow
                                            .ellipsis,
                                      ))
                                    ]),
                                  ),
                                  const SizedBox(
                                      width:
                                          8),
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
          Text('Progresso: ${currentAmount != null && goal.value != 0 ? (currentAmount! / goal.value * 100).toStringAsFixed(2) : '0.00'}%',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          Text('Dias restantes: ${goal.dateEnd.difference(DateTime.now()).inDays} d',
              style: const TextStyle(fontSize: 20)),
          ...movements.map((movement) {
            return ListTile(
              title: Text(movement.description),
              subtitle: Text('R\$ ${movement.value.toStringAsFixed(2)}'),
            );
          }),
          _fillTransactionContainer(movements)
        ],
      ),
    );
  }
  
  @override
  Future<void> showAddOrEditDialog(bool isToAdd, int id) {
    // TODO: implement showAddOrEditDialog
    throw UnimplementedError();
  }
  
  @override
  Future<void> showDeleteDialog(int id) {
    // TODO: implement showDeleteDialog
    throw UnimplementedError();
  }

}