import 'package:drift/drift.dart';
import 'package:fin_fit_app_mobile/model/transaction.dart';

import '../service/database.dart';

part 'transaction_table_helper.g.dart';

@DriftAccessor(tables: [Movement])
class TransactionTableHelper extends DatabaseAccessor<Database> with _$TransactionTableHelperMixin {
  TransactionTableHelper(super.db);

  Future<int> addTransaction(MovementCompanion entry) async {
    return await into(movement).insert(entry);
  }

  Future<List<MovementData>> getAllTransactions() async {
    return await select(movement).get();
  }
}