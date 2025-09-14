import 'package:fin_fit_app_mobile/command/delete_popup_command.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:fin_fit_app_mobile/ui/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'delete_transaction_command_test.mocks.dart';

@GenerateMocks([TransactionPage, BuildContext])
void main() {
  late MockTransactionPage mockTransactionPage;
  late MockBuildContext mockBuildContext;
  
  late MovementData testMovementData;

  setUp(() {
    mockTransactionPage = MockTransactionPage();
    mockBuildContext = MockBuildContext();
    
    testMovementData = MovementData(
      id: 1,
      description: 'Teste',
      isIncome: false,
      value: 100.0,
      categoryId: 1,
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  test('verificando se o método showDeleteTransactionDialog foi chamado com o item correto', () async {
    // Given
    when(mockTransactionPage.showDeleteDialog(any))
        .thenAnswer((_) async {});

    final command = DeletePopUpCommand(
      mockBuildContext,
      mockTransactionPage,
      testMovementData.id,
    );

    // When
    await command.execute();

    // Then
    verify(mockTransactionPage.showDeleteDialog(testMovementData.id)).called(1);
  });
}