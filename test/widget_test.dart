import 'package:flutter_test/flutter_test.dart';
import 'package:vynex_web/main.dart';

void main() {
  testWidgets('Vynex App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VynexApp());
    expect(find.textContaining('VYNEX'), findsWidgets);
  });
}
