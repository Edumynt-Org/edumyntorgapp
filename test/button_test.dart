import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edumyntorgapp/features/auth/presentation/widgets/app_button.dart';

void main() {
  testWidgets('AppButton shows loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(text: 'Test', isLoading: true, onPressed: () {}),
        ),
      ),
    );

    final textFinder = find.text('Log In');
    expect(textFinder, findsOneWidget);

    final Text textWidget = tester.widget(textFinder);
    debugPrint('Text color: ${textWidget.style?.color}');
    debugPrint('Text fontSize: ${textWidget.style?.fontSize}');
    debugPrint('Text fontWeight: ${textWidget.style?.fontWeight}');
  });
}
