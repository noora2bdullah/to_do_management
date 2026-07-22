import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_man_management/core/widgets/flashing_value.dart';

const _flashingValueKey = ValueKey<String>('flashing-value');

void main() {
  testWidgets('does not flash on initial paint', (tester) async {
    await tester.pumpWidget(const _FlashingValueHarness(value: 1));

    expect(_flashAlpha(tester), 0);
  });

  testWidgets('flashes when the value changes, then settles', (tester) async {
    await tester.pumpWidget(const _FlashingValueHarness(value: 1));

    await tester.pumpWidget(const _FlashingValueHarness(value: 2));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('2'), findsOneWidget);
    expect(_flashAlpha(tester), greaterThan(0));

    await tester.pump(const Duration(milliseconds: 700));

    expect(_flashAlpha(tester), 0);
  });
}

double _flashAlpha(WidgetTester tester) {
  final decoratedBox = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byKey(_flashingValueKey),
      matching: find.byType(DecoratedBox),
    ),
  );
  final decoration = decoratedBox.decoration as BoxDecoration;

  return decoration.color?.a ?? 0;
}

class _FlashingValueHarness extends StatelessWidget {
  const _FlashingValueHarness({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlashingValue<int>(
            key: _flashingValueKey,
            value: value,
            flashColor: Colors.orange,
            builder: (context, value) => Text('$value'),
          ),
        ),
      ),
    );
  }
}
