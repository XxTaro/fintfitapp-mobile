import 'package:fin_fit_app_mobile/command/popup.dart';
import 'package:fin_fit_app_mobile/command/popup_command.dart';
import 'package:flutter/material.dart';

class DeletePopUpCommand implements PopUpCommand {
  final BuildContext context;
  final PopUp page;
  final int id;

  DeletePopUpCommand(this.context, this.page, this.id);

  @override
  Future<void> execute() async {
    await page.showDeleteDialog(id);
  }
}
