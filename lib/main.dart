import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/account.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/projects.dart';
import 'package:myportofolio_mobile/services/portfolio_api.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.api});

  final PortfolioApi? api;

  @override
  Widget build(BuildContext context) {
    if (api case final provided?) {
      return ChangeNotifierProvider.value(
        value: provided,
        child: const _PortfolioApp(),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => PortfolioApi(),
      child: const _PortfolioApp(),
    );
  }
}

class _PortfolioApp extends StatelessWidget {
  const _PortfolioApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.amber.shade700,
        ),
        useMaterial3: true,
      ),
      home: Consumer<PortfolioApi>(
        builder: (_, api, _) =>
            api.signedIn ? const MyHomePage() : const AccountPage(),
      ),
      routes: {
        '/register': (_) => const AccountPage(register: true),
        '/projects': (context) => context.read<PortfolioApi>().signedIn
            ? const ProjectsPage()
            : const AccountPage(),
        '/projects/new': (context) => context.read<PortfolioApi>().canWrite
            ? const ProjectFormPage()
            : const Scaffold(
                body: Center(
                  child: Text('Tidak punya akses untuk menambah proyek.'),
                ),
              ),
      },
    );
  }
}
