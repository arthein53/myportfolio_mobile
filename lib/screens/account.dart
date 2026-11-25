import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/services/portfolio_api.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, this.register = false});

  final bool register;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    final api = context.read<PortfolioApi>();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.register) {
        await api.register(
          _username.text.trim(),
          _password.text,
          _confirmation.text,
        );
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        await api.login(_username.text.trim(), _password.text);
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool password = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      enabled: !_busy,
      obscureText: password,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null ||
            (password ? value.isEmpty : value.trim().isEmpty)) {
          return '$label wajib diisi.';
        }
        if (controller == _confirmation && value != _password.text) {
          return 'Password tidak cocok.';
        }
        return null;
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final label = widget.register ? 'Daftar' : 'Masuk';
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field('Username', _username),
                  _field('Password', _password, password: true),
                  if (widget.register)
                    _field(
                      'Konfirmasi password',
                      _confirmation,
                      password: true,
                    ),
                  if (_error case final error?)
                    Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_busy ? 'Memproses…' : label),
                  ),
                  if (!widget.register)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              final registered =
                                  await Navigator.pushNamed<bool>(
                                    context,
                                    '/register',
                                  );
                              if (registered == true && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Akun dibuat. Silakan masuk.',
                                    ),
                                  ),
                                );
                              }
                            },
                      child: const Text('Buat akun'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
