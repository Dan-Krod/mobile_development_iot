import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_development_iot/main.dart';

void main() {
  testWidgets('Initial route smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartFluidApp(isLoggedIn: false));

    expect(find.text('SMART FLUID'), findsOneWidget);
    expect(find.text('MANAGEMENT SYSTEM'), findsOneWidget);

    expect(find.text('AUTHENTICATE'), findsOneWidget);
    
    expect(find.text('NODE STATUS'), findsNothing);
  });

  testWidgets('Session persistence smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartFluidApp(isLoggedIn: true));

    await tester.pumpAndSettle();
    expect(find.text('SMART FLUID SYSTEM'), findsOneWidget);
    expect(find.text('NODE STATUS'), findsOneWidget);
    
    expect(find.text('AUTHENTICATE'), findsNothing);
  });
}
