import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/portfolio_api.dart';

void main() {
  testWidgets('sign in, open the drawer, validate, save, and open details', (
    tester,
  ) async {
    final projects = <Map<String, dynamic>>[];
    final api = PortfolioApi(
      client: MockClient((request) async {
        http.Response json(Object body, int status) =>
            http.Response(jsonEncode(body), status);
        switch ((request.method, request.url.path)) {
          case ('POST', '/auth/login/'):
            return json({
              'token': 'fixture',
              'username': 'tester',
              'can_write': true,
            }, 200);
          case ('POST', '/api/v1/projects/'):
            expect(request.headers['authorization'], 'Token fixture');
            final data = jsonDecode(request.body) as Map<String, dynamic>;
            expect(data.remove('write_secret'), 'example-code');
            projects.add({'id': 1, ...data});
            return json(projects.single, 201);
          case ('GET', '/api/v1/projects/'):
            return json(projects, 200);
          case ('GET', '/api/v1/projects/1/'):
            return json(projects.single, 200);
          case ('POST', '/auth/logout/'):
            return http.Response('', 204);
          default:
            fail('Unexpected request: ${request.method} ${request.url}');
        }
      }),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(MyApp(api: api));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'tester',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'example-password',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Tambah Proyek'));
    await tester.pumpAndSettle();
    final preview = find.widgetWithText(FilledButton, 'Tinjau');
    await tester.ensureVisible(preview);
    await tester.tap(preview);
    await tester.pumpAndSettle();
    expect(find.text('Judul wajib diisi.'), findsOneWidget);

    for (final (label, value) in [
      ('Judul', 'Proyek Uji'),
      ('Deskripsi', 'Deskripsi lengkap proyek uji.'),
      ('Periode', '2026'),
      ('Organisasi', 'Personal'),
      ('Label tautan', 'Buka proyek'),
      ('URL proyek', 'https://example.com/project'),
      ('Kode tulis', 'example-code'),
    ]) {
      final field = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(preview);
    await tester.pumpAndSettle();
    await tester.tap(preview);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('example-code'),
      ),
      findsNothing,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Proyek berhasil disimpan.'), findsOneWidget);

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proyek Uji'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Proyek'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.data == 'Deskripsi lengkap proyek uji.',
      ),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Beranda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Masuk'), findsOneWidget);
  });
}
