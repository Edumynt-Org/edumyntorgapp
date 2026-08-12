import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edumyntorgapp/features/auth/presentation/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Log In',
            onPressed: () {},
          ),
        ),
      ),
    );

    final textFinder = find.text('Log In');
    expect(textFinder, findsOneWidget);

    final Text textWidget = tester.widget(textFinder);
    print('Text color: ${textWidget.style?.color}');
    print('Text fontSize: ${textWidget.style?.fontSize}');
    print('Text fontWeight: ${textWidget.style?.fontWeight}');
  });
}
