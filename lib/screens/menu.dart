import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/services/portfolio_api.dart';
import 'package:myportofolio_mobile/widgets/item_card.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static const String npm = '2506613514';
  static const String nama = 'Rafael Arlen Wijanarko';
  static const String kelas = 'PBP B';

  static const List<ItemHomepage> items = [
    ItemHomepage(
      'Lihat Proyek',
      Icons.folder,
      Color(0xFF4F46E5),
      route: '/projects',
    ),
    ItemHomepage(
      'Tambah Proyek',
      Icons.add_circle,
      Color(0xFFD97706),
      route: '/projects/new',
    ),
    ItemHomepage('Logout', Icons.logout, Color(0xFF7C3AED)),
  ];

  @override
  Widget build(BuildContext context) {
    final api = context.watch<PortfolioApi>();
    return Scaffold(
      drawer: const LeftDrawer(),
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return const Column(
                    key: Key('profile-cards-column'),
                    children: [
                      InfoCard(title: 'NPM', content: npm),
                      InfoCard(title: 'Name', content: nama),
                      InfoCard(title: 'Class', content: kelas),
                    ],
                  );
                }

                return const Row(
                  children: [
                    Expanded(
                      child: InfoCard(title: 'NPM', content: npm),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: InfoCard(title: 'Name', content: nama),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: InfoCard(title: 'Class', content: kelas),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Selamat datang di MyPortfolio Mobile!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final childAspectRatio = constraints.maxWidth <= 340
                    ? 0.5
                    : constraints.maxWidth <= 400
                    ? 0.7
                    : constraints.maxWidth <= 700
                    ? 1.0
                    : 1.6;

                return GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  childAspectRatio: childAspectRatio,
                  shrinkWrap: true,
                  children: [
                    for (final item in items)
                      if (item.route != '/projects/new' || api.canWrite)
                        ItemCard(
                          item,
                          onTap: api.signingOut
                              ? null
                              : () => _onTap(context, api, item),
                        ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _onTap(
  BuildContext context,
  PortfolioApi api,
  ItemHomepage item,
) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('Kamu telah menekan tombol ${item.name}!')),
    );
  if (item.route case final route?) {
    Navigator.pushNamed(context, route);
    return;
  }
  try {
    await api.logout();
  } on ApiException catch (error) {
    if (!context.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error.message)));
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FittedBox(child: Text(content)),
          ],
        ),
      ),
    );
  }
}
