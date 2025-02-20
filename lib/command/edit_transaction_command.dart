import 'package:fin_fit_app_mobile/command/transaction_command.dart';
import 'package:fin_fit_app_mobile/ui/transaction_page.dart';
import 'package:flutter/material.dart';

import '../service/database.dart';

class EditTransactionCommand implements TransactionCommand {
  final BuildContext context;
  final TransactionPage page;
  final MovementData item;

  EditTransactionCommand(this.context, this.page, this.item);

  @override
  Future<void> execute() async {
    page.setFields(item);
    await page.showAddOrEditTransactionDialog(false, item);
  }
}
