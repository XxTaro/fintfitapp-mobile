// test/commands/delete_transaction_command_test.dart

import 'package:fin_fit_app_mobile/command/delete_transaction_command.dart'; // Corrija o import se o nome do arquivo for diferente
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
    when(mockTransactionPage.showDeleteTransactionDialog(any))
        .thenAnswer((_) async {});

    final command = DeleteTransactionCommand(
      mockBuildContext,
      mockTransactionPage,
      testMovementData,
    );

    // When
    await command.execute();

    // Then
    verify(mockTransactionPage.showDeleteTransactionDialog(testMovementData)).called(1);
  });
}