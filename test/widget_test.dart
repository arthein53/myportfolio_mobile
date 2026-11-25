import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/portfolio_api.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';

Future<void> pumpSignedIn(WidgetTester tester) async {
  final api = PortfolioApi(
    client: MockClient((request) async {
      if (request.url.path == '/auth/login/') {
        return http.Response('{"token":"fixture","can_write":true}', 200);
      }
      if (request.url.path == '/auth/logout/') return http.Response('', 204);
      return http.Response('[]', 200);
    }),
  );
  addTearDown(api.dispose);
  await api.login('tester', 'example-password');
  await tester.pumpWidget(MyApp(api: api));
}

void main() {
  testWidgets('homepage shows portfolio identity and menu actions', (
    WidgetTester tester,
  ) async {
    await pumpSignedIn(tester);

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('2506613514'), findsOneWidget);
    expect(find.text('Rafael Arlen Wijanarko'), findsOneWidget);
    expect(find.text('PBP B'), findsOneWidget);
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.byType(ItemCard), findsNWidgets(3));
  });

  for (final action in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
    testWidgets('$action shows the expected snackbar', (
      WidgetTester tester,
    ) async {
      await pumpSignedIn(tester);

      await tester.tap(find.text(action));
      await tester.pumpAndSettle();

      expect(find.text('Kamu telah menekan tombol $action!'), findsOneWidget);
    });
  }

  test('menu actions use three distinct colors', () {
    final colors = MyHomePage.items.map((item) => item.color).toSet();

    expect(colors, hasLength(3));
  });

  test('homepage is stateless', () {
    expect(const MyHomePage(), isA<StatelessWidget>());
  });

  for (final size in [const Size(375, 812), const Size(320, 568)]) {
    testWidgets('homepage does not overflow at ${size.width.toInt()}px', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await pumpSignedIn(tester);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('profile-cards-column')), findsOneWidget);
    });
  }
}
