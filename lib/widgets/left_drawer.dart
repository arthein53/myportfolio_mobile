import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/services/portfolio_api.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;
    final canWrite = context.watch<PortfolioApi>().canWrite;
    void go(String route) {
      final navigator = Navigator.of(context);
      navigator.pop();
      if (route == current) return;
      if (route == '/') {
        navigator.popUntil((route) => route.isFirst);
      } else if (current == '/') {
        navigator.pushNamed(route);
      } else {
        navigator.pushReplacementNamed(route);
      }
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'MyPortfolio',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Beranda'),
            onTap: () => go('/'),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Lihat Proyek'),
            onTap: () => go('/projects'),
          ),
          if (canWrite)
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Tambah Proyek'),
              onTap: () => go('/projects/new'),
            ),
        ],
      ),
    );
  }
}
