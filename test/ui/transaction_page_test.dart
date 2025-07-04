import 'package:clock/clock.dart';
import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:fin_fit_app_mobile/ui/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'transaction_page_test.mocks.dart';

Widget createTransactionPageScreen({
  required MovementTableHelper movementHelper,
  required CategoryTableHelper categoryHelper,
}) {
  return MaterialApp(
    home: TransactionPageStateful(
      movementTableHelper: movementHelper,
      categoryTableHelper: categoryHelper,
      locale: 'pt_BR',
    ),
  );
}

@GenerateMocks([MovementTableHelper, CategoryTableHelper])
void main() {
  late MockMovementTableHelper mockMovementHelper;
  late MockCategoryTableHelper mockCategoryHelper;

  final mockCategories = [
    const CategoryData(id: 1, name: 'Salário'),
    const CategoryData(id: 2, name: 'Moradia'),
  ];

  final mockMovementsJuly = [
    MovementData(
        id: 1,
        description: 'Salário de Julho',
        isIncome: true,
        value: 5000.0,
        categoryId: 1,
        timestamp: DateTime(2025, 7, 5),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()),
    MovementData(
        id: 2,
        description: 'Aluguel',
        isIncome: false,
        value: 1500.0,
        categoryId: 2,
        timestamp: DateTime(2025, 7, 10),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()),
  ];

  setUpAll(() {
    initializeDateFormatting('pt_BR');
  });

  setUp(() {
    mockMovementHelper = MockMovementTableHelper();
    mockCategoryHelper = MockCategoryTableHelper();

    when(mockCategoryHelper.getAllCategories())
        .thenAnswer((_) async => mockCategories);
    when(mockMovementHelper.addTransaction(any)).thenAnswer((_) async => 1);
  });

  withClock(Clock.fixed(DateTime(2025, 7, 15)), () {
    testWidgets('deve exibir as transações do mês atual ao carregar a página',
        (tester) async {
      // Given: O helper está configurado para retornar transações para o mês atual (Julho)
      when(mockMovementHelper.getByMonth(any))
          .thenAnswer((_) async => mockMovementsJuly);

      // When: A tela é construída
      await tester.pumpWidget(createTransactionPageScreen(
        movementHelper: mockMovementHelper,
        categoryHelper: mockCategoryHelper,
      ));
      await tester.pumpAndSettle();

      // Then: O título do mês e as transações devem estar visíveis
      expect(find.text('julho de 2025'),
          findsOneWidget); // Verificar o localeName do teste
      expect(find.text('Salário de Julho'), findsOneWidget);
      expect(find.textContaining(RegExp(r'R\$\s*5000,00')), findsOneWidget);
      expect(find.text('Aluguel'), findsOneWidget);
    });

    testWidgets('deve exibir mensagem quando não há transações para o mês',
        (tester) async {
      // Given
      when(mockMovementHelper.getByMonth(any)).thenAnswer((_) async => []);

      // When
      await tester.pumpWidget(createTransactionPageScreen(
        movementHelper: mockMovementHelper,
        categoryHelper: mockCategoryHelper,
      ));
      await tester.pumpAndSettle();

      // Then
      expect(find.text('Não existem transações para o mês e ano selecionado!'),
          findsOneWidget);
    });

    testWidgets(
        'deve buscar e exibir transações do mês seguinte ao clicar na seta',
        (tester) async {
      // Given: A tela está exibindo as transações de Julho
      when(mockMovementHelper.getByMonth(any))
          .thenAnswer((_) async => mockMovementsJuly);
      await tester.pumpWidget(createTransactionPageScreen(
        movementHelper: mockMovementHelper,
        categoryHelper: mockCategoryHelper,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Salário de Julho'), findsOneWidget);

      // O helper é reconfigurado para retornar dados diferentes para Agosto
      final mockMovementsAugust = [
        MovementData(
            id: 3,
            description: 'Férias',
            isIncome: true,
            value: 1000.0,
            categoryId: 1,
            timestamp: DateTime(2025, 8, 1),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now())
      ];
      when(mockMovementHelper.getByMonth(any))
          .thenAnswer((_) async => mockMovementsAugust);

      // When: O usuário clica na seta de avançar mês
      await tester.tap(find.byIcon(Icons.arrow_forward_ios));
      await tester.pumpAndSettle();

      // Then: O título e a lista de transações devem ser atualizados para Agosto
      expect(find.text('agosto de 2025'), findsOneWidget);
      expect(find.text('Férias'), findsOneWidget);
      expect(find.text('Salário de Julho'), findsNothing);
    });

    testWidgets(
        'deve filtrar a lista de transações ao digitar no campo de busca',
        (tester) async {
      // Given: A tela exibe a lista completa de Julho
      when(mockMovementHelper.getByMonth(any))
          .thenAnswer((_) async => mockMovementsJuly);
      await tester.pumpWidget(createTransactionPageScreen(
        movementHelper: mockMovementHelper,
        categoryHelper: mockCategoryHelper,
      ));
      await tester.pumpAndSettle();

      // O helper é configurado para retornar uma lista filtrada quando a busca for acionada
      when(mockMovementHelper.getByContainsNameAndDate('Aluguel', any))
          .thenAnswer((_) async => [mockMovementsJuly.last]);

      // When: O usuário digita "Aluguel" no campo de busca
      await tester.enterText(find.byType(TextFormField), 'Aluguel');
      await tester.pumpAndSettle();

      // Then: Apenas a transação "Aluguel" deve estar visível
      expect(find.text('Aluguel'),
          findsExactly(2)); // Uma na barra de busca e outra na lista
      expect(find.text('Salário de Julho'), findsNothing);
    });

    testWidgets(
        'deve abrir um diálogo e adicionar uma nova transação com sucesso',
        (tester) async {
      // Given: A tela está aberta e os helpers configurados
      when(mockMovementHelper.getByMonth(any)).thenAnswer((_) async => []);
      await tester.pumpWidget(createTransactionPageScreen(
        movementHelper: mockMovementHelper,
        categoryHelper: mockCategoryHelper,
      ));
      await tester.pumpAndSettle();

      // When: O usuário clica no botão de adicionar
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Then: O diálogo de adicionar deve aparecer
      expect(find.text('Adicionar transação'), findsOneWidget);

      // When: O usuário preenche os campos e salva
      await tester.enterText(
          find.widgetWithText(TextField, 'Descrição'), 'Compra Online');
      await tester.enterText(find.widgetWithText(TextField, 'Valor'), '123,45');

      // Seleciona uma categoria no dropdown
      await tester.tap(find.text('Categoria'));
      await tester.pumpAndSettle(); // Abre as opções
      await tester.tap(find
          .text('Moradia')
          .last); // .last para pegar o item do menu e não do dropdown
      await tester.pumpAndSettle(); // Fecha o menu

      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      // Then: O método do helper para adicionar transação deve ter sido chamado
      final captured =
          verify(mockMovementHelper.addTransaction(captureAny)).captured;
      final MovementCompanion addedItem = captured.first;

      expect(addedItem.description.value, 'Compra Online');
      expect(addedItem.value.value, 123.45);
      expect(addedItem.categoryId.value, 2); // ID de 'Moradia'
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  testWidgets('deve abrir menu, deletar transação e atualizar a UI',
      (tester) async {
    // Given: A tela está exibindo a lista de transações de Julho
    when(mockMovementHelper.getByMonth(any))
        .thenAnswer((_) async => mockMovementsJuly);
    await tester.pumpWidget(createTransactionPageScreen(
      movementHelper: mockMovementHelper,
      categoryHelper: mockCategoryHelper,
    ));
    await tester.pumpAndSettle();

    // Configura o mock para a ação de deletar
    when(mockMovementHelper.deleteTransaction(2)).thenAnswer((_) async => 1);

    // When: O usuário clica no item "Aluguel" para abrir o menu
    await tester.tap(find.text('Aluguel'));
    await tester.pumpAndSettle(); // Espera o menu aparecer

    // Then: O menu de opções deve ser exibido
    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Deletar'), findsOneWidget);

    // When: O usuário clica em "Deletar"
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle(); // Espera o diálogo de confirmação aparecer

    // Then: O diálogo de confirmação deve ser exibido
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'Você deseja realmente deletar essa transação?\n\nEssa ação não poderá ser desfeita.'),
        findsOneWidget);

    // Configura o mock para retornar uma lista vazia após a exclusão para testar a atualização da UI
    when(mockMovementHelper.getByMonth(any)).thenAnswer((_) async => []);

    // When: O usuário clica em "Sim" para confirmar a exclusão
    await tester.tap(find.text('Sim'));
    await tester
        .pumpAndSettle(); // Espera o diálogo fechar e a UI ser reconstruída

    // Then: O método do helper foi chamado e a UI foi atualizada
    // 1. Verifica se a função de deletar do helper foi chamada com o ID correto (2, do Aluguel)
    verify(mockMovementHelper.deleteTransaction(2)).called(1);

    // 2. Verifica se a SnackBar de sucesso foi exibida
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Transação deletada!'), findsOneWidget);

    // 3. Verifica se a lista de transações agora está vazia
    expect(find.text('Não existem transações para o mês e ano selecionado!'),
        findsOneWidget);
    expect(find.text('Aluguel'), findsNothing); // Garante que o item sumiu
  });

  testWidgets('deve pré-preencher, editar e salvar uma transação com sucesso',
      (tester) async {
    // Given: A tela está exibindo a lista e os helpers estão configurados
    when(mockMovementHelper.getByMonth(any))
        .thenAnswer((_) async => mockMovementsJuly);
    when(mockCategoryHelper.getById(2))
        .thenAnswer((_) async => mockCategories.last);
    when(mockMovementHelper.updateTransaction(any)).thenAnswer((_) async => 1);

    await tester.pumpWidget(createTransactionPageScreen(
      movementHelper: mockMovementHelper,
      categoryHelper: mockCategoryHelper,
    ));
    await tester.pumpAndSettle();

    // When: O usuário clica no item "Aluguel" e depois em "Editar"
    await tester.tap(find.text('Aluguel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    // Then: O diálogo de edição deve aparecer com os campos pré-preenchidos
    expect(find.text('Editar transação'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Aluguel'), findsOneWidget);
    expect(find.widgetWithText(TextField, '1500,00'), findsOneWidget);

    // When: O usuário altera os dados e salva
    await tester.enterText(
        find.widgetWithText(TextField, 'Aluguel'), 'Aluguel Atualizado');
    await tester.enterText(
        find.widgetWithText(TextField, '1500,00'), '1550,50');

    // Configura o mock para retornar a lista atualizada após a edição
    final updatedMovement = mockMovementsJuly.last
        .copyWith(description: 'Aluguel Atualizado', value: 1550.50);
    when(mockMovementHelper.getByMonth(any))
        .thenAnswer((_) async => [mockMovementsJuly.first, updatedMovement]);

    await tester.tap(find.widgetWithText(TextButton, 'Editar'));
    await tester.pumpAndSettle();

    // Then: A lógica de negócio e a UI devem ser atualizadas
    // 1. Verifica se `updateTransaction` foi chamado com os dados corretos
    final captured =
        verify(mockMovementHelper.updateTransaction(captureAny)).captured;
    final MovementCompanion updatedItem = captured.first;
    expect(updatedItem.id.value, 2);
    expect(updatedItem.description.value, 'Aluguel Atualizado');
    expect(updatedItem.value.value, 1550.50);

    // 2. Verifica a atualização da UI
    expect(find.text('Aluguel Atualizado'), findsOneWidget);
    expect(find.textContaining(RegExp(r'R\$\s*1550,50')), findsOneWidget);
    expect(find.text('Aluguel'), findsNothing);
  });

  testWidgets('deve filtrar a lista de transações por categoria com sucesso',
      (tester) async {
    // Given: A tela exibe a lista completa e o ícone de filtro está "desligado"
    when(mockMovementHelper.getByMonth(any))
        .thenAnswer((_) async => mockMovementsJuly);
    await tester.pumpWidget(createTransactionPageScreen(
      movementHelper: mockMovementHelper,
      categoryHelper: mockCategoryHelper,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Salário de Julho'), findsOneWidget);
    expect(find.text('Aluguel'), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt_off), findsOneWidget);

    // Configura o mock para retornar a lista filtrada quando a ação ocorrer
    when(mockMovementHelper.getByMonthAndCategory(any, any))
        .thenAnswer((_) async => [mockMovementsJuly.last]);

    // When: O usuário clica no ícone de filtro, seleciona "Moradia" e salva
    await tester.tap(find.byIcon(Icons.filter_alt_off));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar transações'), findsOneWidget);

    await tester.tap(find.text('Categoria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moradia').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Salvar'));
    await tester.pumpAndSettle();

    // Then: A UI deve ser atualizada para mostrar apenas a transação filtrada
    // 1. Verifica se o helper foi chamado com a categoria correta
    verify(mockMovementHelper.getByMonthAndCategory(
      any,
      argThat(isA<CategoryData>()..having((c) => c.id, 'id', 2)),
    )).called(1);

    // 2. Verifica a UI
    expect(find.text('Aluguel'), findsOneWidget);
    expect(find.text('Salário de Julho'), findsNothing);
    expect(
        find.byIcon(Icons.filter_alt_rounded), findsOneWidget); // Ícone mudou
    expect(find.byIcon(Icons.filter_alt_off), findsNothing);
  });
}
