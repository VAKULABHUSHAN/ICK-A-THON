import 'package:flutter_test/flutter_test.dart';
import 'package:expiry_chain/app.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpiryChainApp());
    expect(find.byType(ExpiryChainApp), findsOneWidget);
  });
}
