import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:limited_lands/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LimitedLandsApp(),
      ),
    );
    expect(find.text('Limited Lands'), findsOneWidget);
  });
}
