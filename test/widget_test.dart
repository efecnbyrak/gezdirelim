import 'package:flutter_test/flutter_test.dart';
import 'package:gezdirelim/main.dart';

void main() {
  testWidgets('App starts and shows navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const GezdirelimApp());
    expect(find.text('Anasayfa'), findsWidgets);
  });
}
