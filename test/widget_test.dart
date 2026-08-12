import 'package:flutter_test/flutter_test.dart';
import 'package:edumyntorgapp/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EdumyntApp());

    // Verify that the title is present
    expect(find.text('Welcome to Edumynt!'), findsOneWidget);
    
    // Verify that the continue button is present
    expect(find.text('Continue'), findsOneWidget);
  });
}
