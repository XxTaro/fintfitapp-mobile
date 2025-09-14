import 'package:fin_fit_app_mobile/command/edit_popup_command.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:fin_fit_app_mobile/ui/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'edit_transaction_command_test.mocks.dart';

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
      description: 'Item para Editar',
      isIncome: false,
      value: 123.45,
      categoryId: 2,
      timestamp: DateTime(2025, 6, 22),
      createdAt: DateTime(2025, 6, 22),
      updatedAt: DateTime(2025, 6, 22),
    );
  });

  test('verificando se os métodos setFields e showAddOrEditTransactionDialog foram chamados corretamente',
      () async {
    // Given
    when(mockTransactionPage.showAddOrEditDialog(any, any))
        .thenAnswer((_) async {});

    final command = EditPopUpCommand(
      mockBuildContext,
      mockTransactionPage,
      testMovementData.id,
    );

    // When
    await command.execute();

    // Then
    verify(mockTransactionPage.setFields(testMovementData)).called(1);
    verify(mockTransactionPage.showAddOrEditDialog(false, testMovementData.id)).called(1);
    verifyNoMoreInteractions(mockTransactionPage);
  });
}