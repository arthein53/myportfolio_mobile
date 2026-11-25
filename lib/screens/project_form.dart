import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/services/portfolio_api.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  static const _fields = {
    'title': 'Judul',
    'description': 'Deskripsi',
    'period': 'Periode',
    'organization': 'Organisasi',
    'link_label': 'Label tautan',
    'link_url': 'URL proyek',
    'tags': 'Tag (pisahkan dengan koma)',
    'write_secret': 'Kode tulis',
  };
  final _form = GlobalKey<FormState>();
  final _controllers = {
    for (final key in _fields.keys) key: TextEditingController(),
  };
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _preview() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final payload = <String, dynamic>{
      for (final entry in _controllers.entries)
        entry.key: entry.key == 'write_secret'
            ? entry.value.text
            : entry.value.text.trim(),
    };
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tinjau proyek'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              for (final entry in payload.entries)
                if (entry.key != 'write_secret' && entry.value != '')
                  Text('${_fields[entry.key]}: ${entry.value}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    payload['tags'] = (payload['tags'] as String)
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<PortfolioApi>().createProject(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Proyek berhasil disimpan.')),
        );
      Navigator.popUntil(context, (route) => route.isFirst);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validate(String key, String label, String? value) {
    if (key == 'tags') return null;
    if (value == null || value.trim().isEmpty) return '$label wajib diisi.';
    if (key == 'link_url') {
      final url = Uri.tryParse(value.trim());
      if (url == null ||
          url.host.isEmpty ||
          !['https', 'http'].contains(url.scheme)) {
        return 'Masukkan URL HTTP atau HTTPS yang valid.';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Proyek')),
      drawer: const LeftDrawer(),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in _fields.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _controllers[entry.key],
                    enabled: !_busy,
                    obscureText: entry.key == 'write_secret',
                    maxLines: entry.key == 'description' ? 4 : 1,
                    keyboardType: entry.key == 'link_url'
                        ? TextInputType.url
                        : null,
                    validator: (value) =>
                        _validate(entry.key, entry.value, value),
                    decoration: InputDecoration(
                      labelText: entry.value,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              if (_error case final error?)
                Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              FilledButton(
                onPressed: _busy ? null : _preview,
                child: Text(_busy ? 'Menyimpan…' : 'Tinjau'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
