import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mass/app.dart';

void main() {
  testWidgets('MASS login screen loads successfully', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MassApp()));

    expect(find.text('MASS Login Screen'), findsOneWidget);
    expect(find.text('Test Teacher Dashboard'), findsOneWidget);
    expect(find.text('Test Student Dashboard'), findsOneWidget);
  });

  testWidgets('Teacher dashboard navigation works', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MassApp()));

    await tester.tap(find.text('Test Teacher Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Teacher Dashboard'), findsOneWidget);
  });

  testWidgets('Student dashboard navigation works', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MassApp()));

    await tester.tap(find.text('Test Student Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Student Dashboard'), findsOneWidget);
  });
}
