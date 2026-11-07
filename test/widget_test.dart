import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynex_manager/main.dart';

void main() {
  testWidgets('Vynex App smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VynexApp());
    expect(find.textContaining('Vynex'), findsWidgets);
  });
}
