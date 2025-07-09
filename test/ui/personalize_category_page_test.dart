import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:fin_fit_app_mobile/ui/personalize_category_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'personalize_category_page_test.mocks.dart';

Widget createTestScreen(CategoryTableHelper mockHelper) {
  return MaterialApp(
    home: Scaffold(
      body: PersonalizeCategoryPage(categoryTableHelper: mockHelper),
    ),
  );
}

@GenerateMocks([CategoryTableHelper])
void main() {
  late MockCategoryTableHelper mockCategoryHelper;

  final mockInitialCategories = [
    const CategoryData(id: 1, name: 'Moradia'),
    const CategoryData(id: 2, name: 'Saúde'),
  ];

  setUp(() {
    mockCategoryHelper = MockCategoryTableHelper();

    when(mockCategoryHelper.addCategory(any)).thenAnswer((_) async => 3);
    when(mockCategoryHelper.updateCategoryById(any, any)).thenAnswer((_) async {});
    when(mockCategoryHelper.deleteCategory(any)).thenAnswer((_) async {});
  });

  group('PersonalizeCategoryPage Widget Tests', () {

    testWidgets('deve exibir a lista de categorias ao carregar a página', (tester) async {
      // Given: O helper está configurado para retornar uma lista de categorias
      when(mockCategoryHelper.getAllCategories()).thenAnswer((_) async => mockInitialCategories);

      // When: A tela é construída
      await tester.pumpWidget(createTestScreen(mockCategoryHelper));
      await tester.pumpAndSettle(); // Espera o FutureBuilder resolver

      // Then: Os nomes das categorias devem estar na tela
      expect(find.text('Categorias'), findsOneWidget);
      expect(find.text('Moradia'), findsOneWidget);
      expect(find.text('Saúde'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    group('Adicionar Categoria', () {
      testWidgets('deve adicionar uma nova categoria com sucesso', (tester) async {
        // Given: A tela está carregada e o helper configurado
        when(mockCategoryHelper.getAllCategories()).thenAnswer((_) async => mockInitialCategories);
        when(mockCategoryHelper.getByName('Lazer')).thenAnswer((_) async => null); // Simula que "Lazer" não existe
        
        await tester.pumpWidget(createTestScreen(mockCategoryHelper));
        await tester.pumpAndSettle();

        // When: O usuário clica em Adicionar, preenche o nome e salva
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.text('Adicionar categoria'), findsOneWidget);
        await tester.enterText(find.widgetWithText(TextField, 'Nome da categoria'), 'Lazer');
        
        // Configura o mock para retornar a nova lista após a adição
        final newList = [...mockInitialCategories, const CategoryData(id: 3, name: 'Lazer')];
        when(mockCategoryHelper.getAllCategories()).thenAnswer((_) async => newList);
        
        await tester.tap(find.widgetWithText(TextButton, 'Adicionar'));
        await tester.pumpAndSettle();

        // Then: A lógica foi chamada e a UI atualizada
        verify(mockCategoryHelper.addCategory(any)).called(1);
        expect(find.text('Categoria adicionada!'), findsOneWidget);
        expect(find.text('Lazer'), findsOneWidget); // O novo item está na lista
      });

      testWidgets('deve exibir erro ao tentar adicionar uma categoria que já existe', (tester) async {
        // Given: A tela está carregada e o helper configurado para encontrar a categoria
        when(mockCategoryHelper.getAllCategories()).thenAnswer((_) async => mockInitialCategories);
        when(mockCategoryHelper.getByName('Moradia')).thenAnswer((_) async => mockInitialCategories.first);
        
        await tester.pumpWidget(createTestScreen(mockCategoryHelper));
        await tester.pumpAndSettle();

        // When: O usuário tenta adicionar a categoria "Moradia" novamente
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.enterText(find.widgetWithText(TextField, 'Nome da categoria'), 'Moradia');
        await tester.tap(find.widgetWithText(TextButton, 'Adicionar'));
        await tester.pumpAndSettle();

        // Then: Uma SnackBar de erro deve ser exibida e a adição não deve ocorrer
        verifyNever(mockCategoryHelper.addCategory(any));
        expect(find.text("Categoria 'Moradia' já existe!"), findsOneWidget);
        expect(find.byType(AlertDialog), findsOneWidget); // O diálogo não deve fechar
      });
    });

    group('Editar e Deletar Categoria', () {
      testWidgets('deve editar uma categoria com sucesso', (tester) async {
        // Given
        when(mockCategoryHelper.getAllCategories()).thenAnswer((_) async => mockInitialCategories);
        await tester.pumpWidget(createTestScreen(mockCategoryHelper));
        await tester.pumpAndSettle();
        
        // When: O usuário clica para editar "Saúde"
        final editIconFinder = find.descendant(of: find.widgetWithText(ListTile, 'Saúde'), matching: find.byIcon(Icons.edit));
        await tester.tap(editIconFinder);
        await tester.pumpAndSettle();

        expect(find.text('Editar categoria'), findsOneWidget);
        await tester.enterText(find.widgetWithText(TextField, 'Nome da categoria'), 'Saúde e Bem-Estar');

        final updatedList = [mockInitialCategories.first, const CategoryData(id: 2, name: 'Saúde e Bem-Estar')];
        when(mockCategoryHelper.getAllCategories()).thenAnswer((_) async => updatedList);

        await tester.tap(find.widgetWithText(TextButton, 'Editar'));
        await tester.pumpAndSettle();

        // Then
        final captured = verify(mockCategoryHelper.updateCategoryById(captureAny, 2)).captured;
        expect((captured.first as CategoryCompanion).name.value, 'Saúde e Bem-Estar');
        expect(find.text('Categoria editada!'), findsOneWidget);
        expect(find.text('Saúde e Bem-Estar'), findsOneWidget);
        expect(find.text('Saúde'), findsNothing);
      });

       testWidgets('deve deletar uma categoria com sucesso', (tester) async {
        // Given
        when(mockCategoryHelper.getAllCategories()).thenAnswer((_) async => mockInitialCategories);
        await tester.pumpWidget(createTestScreen(mockCategoryHelper));
        await tester.pumpAndSettle();

        // When: O usuário clica para deletar "Moradia"
        final deleteIconFinder = find.descendant(of: find.widgetWithText(ListTile, 'Moradia'), matching: find.byIcon(Icons.delete));
        await tester.tap(deleteIconFinder);
        await tester.pumpAndSettle();

        expect(find.text('Deletar categoria'), findsOneWidget);
        
        final updatedList = [mockInitialCategories.last]; // Apenas "Saúde" deve sobrar
        when(mockCategoryHelper.getAllCategories()).thenAnswer((_) async => updatedList);

        await tester.tap(find.widgetWithText(TextButton, 'Sim'));
        await tester.pumpAndSettle();

        // Then
        verify(mockCategoryHelper.deleteCategory(1)).called(1); // Verifica se chamou com o ID 1
        expect(find.text("Categoria 'Moradia' deletada!"), findsOneWidget);
        expect(find.text('Moradia'), findsNothing);
        expect(find.text('Saúde'), findsOneWidget);
      });
    });
  });
}