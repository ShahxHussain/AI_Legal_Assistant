import 'package:court_companion/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads home screen with main options', (WidgetTester tester) async {
    await tester.pumpWidget(const CourtCompanionApp());
    expect(find.text('Court Companion'), findsOneWidget);
    expect(find.text('Type your question'), findsOneWidget);
    expect(find.text('Ask by voice'), findsOneWidget);
    expect(find.text('Analyze a document'), findsOneWidget);
  });
}
