import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _userAgentController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _apiKeyController.text = await _storage.read(key: 'opensubtitles_api_key') ?? '';
    _userAgentController.text = await _storage.read(key: 'opensubtitles_user_agent') ?? '';
    _usernameController.text = await _storage.read(key: 'opensubtitles_username') ?? '';
    _passwordController.text = await _storage.read(key: 'opensubtitles_password') ?? '';
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      await _storage.write(key: 'opensubtitles_api_key', value: _apiKeyController.text);
      await _storage.write(key: 'opensubtitles_user_agent', value: _userAgentController.text);
      await _storage.write(key: 'opensubtitles_username', value: _usernameController.text);
      await _storage.write(key: 'opensubtitles_password', value: _passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(labelText: 'OpenSubtitles API Key'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your API key';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userAgentController,
                decoration: const InputDecoration(labelText: 'User-Agent'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your User-Agent';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
