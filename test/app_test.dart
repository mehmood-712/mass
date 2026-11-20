import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mass/app.dart';

void main() {
  testWidgets('MASS application loads successfully', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MassApp()));

    expect(find.text('MASS is ready'), findsOneWidget);
  });
}
