import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_development_iot/main.dart';
import 'package:mobile_development_iot/repositories/alarm_repository.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:mobile_development_iot/repositories/tank_repository.dart';

void main() {
  final authRepository = SecureAuthRepository();
  final tankRepository = SecureTankRepository();
  final alarmRepository = SecureAlarmRepository();

  testWidgets('Initial route smoke test (Not Logged In)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      SmartFluidApp(
        isLoggedIn: false,
        authRepository: authRepository,
        tankRepository: tankRepository,
        alarmRepository: alarmRepository,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SMART FLUID'), findsOneWidget);
    expect(find.text('MANAGEMENT SYSTEM'), findsOneWidget);

    expect(find.text('DISPATCHER CENTER'), findsNothing);
  });

  testWidgets('Session persistence smoke test (Logged In)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      SmartFluidApp(
        isLoggedIn: true,
        authRepository: authRepository,
        tankRepository: tankRepository,
        alarmRepository: alarmRepository,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SMART FLUID MANAGEMENT'), findsOneWidget);

    expect(find.text('SMART FLUID'), findsNothing);
    expect(find.text('MANAGEMENT SYSTEM'), findsNothing);
  });
}
