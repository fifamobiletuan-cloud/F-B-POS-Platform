import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/screens/customer/sparkle_background.dart';

void main() {
  testWidgets('SparkleBackground renders with custom settings', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SparkleBackground(
            isDark: true,
            repeat: false,
            sparkleCount: 12,
            orbCount: 2,
            shimmerParticles: 5,
          ),
        ),
      ),
    );

    expect(find.byType(SparkleBackground), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
