import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/portfolio_api.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daftar Proyek')),
    drawer: const LeftDrawer(),
    body: _ProjectLoader<List<Project>>(
      load: context.read<PortfolioApi>().listProjects,
      builder: (context, projects) => projects.isEmpty
          ? const Center(child: Text('Belum ada proyek.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  child: ListTile(
                    title: Text(project.title),
                    subtitle: Text(
                      project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ProjectDetailPage(id: project.id),
                      ),
                    ),
                  ),
                );
              },
            ),
    ),
  );
}

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail Proyek')),
    body: _ProjectLoader<Project>(
      load: () => context.read<PortfolioApi>().getProject(id),
      builder: (context, project) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(project.title, style: Theme.of(context).textTheme.headlineSmall),
          Text('${project.organization} • ${project.period}'),
          const SizedBox(height: 16),
          SelectableText(project.description),
          const SizedBox(height: 16),
          if (project.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                for (final tag in project.tags) Chip(label: Text(tag)),
              ],
            ),
          SelectableText('${project.linkLabel}: ${project.linkUrl}'),
        ],
      ),
    ),
  );
}

class _ProjectLoader<T> extends StatefulWidget {
  const _ProjectLoader({required this.load, required this.builder});
  final Future<T> Function() load;
  final Widget Function(BuildContext, T) builder;

  @override
  State<_ProjectLoader<T>> createState() => _ProjectLoaderState<T>();
}

class _ProjectLoaderState<T> extends State<_ProjectLoader<T>> {
  late Future<T> _result;

  @override
  void initState() {
    super.initState();
    _result = widget.load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _result,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        final error = snapshot.error;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is ApiException
                      ? error.message
                      : 'Gagal membuka data proyek.',
                ),
                TextButton(
                  onPressed: () => setState(() => _result = widget.load()),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        );
      }
      return widget.builder(context, snapshot.data as T);
    },
  );
}
