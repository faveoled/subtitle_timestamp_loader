import 'package:flutter/material.dart';
import 'package:subtitle_timestamp_loader/screens/settings_screen.dart';
import 'package:subtitle_timestamp_loader/services/opensubtitles_api.dart';
import 'package:subtitle_timestamp_loader/screens/subtitle_display_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _movieNameController = TextEditingController();
  final _timestampController = TextEditingController();
  String _selectedLanguage = 'en';
  List<dynamic> _subtitles = [];
  bool _isLoading = false;
  final OpenSubtitlesApi _api = OpenSubtitlesApi();

  @override
  void initState() {
    super.initState();
    _api.login();
  }

  Future<void> _searchSubtitles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final subtitles = await _api.searchSubtitles(
        _movieNameController.text,
        _selectedLanguage,
      );
      setState(() {
        _subtitles = subtitles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subtitle App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _movieNameController,
              decoration: const InputDecoration(labelText: 'Movie Name'),
            ),
            TextField(
              controller: _timestampController,
              decoration: const InputDecoration(labelText: 'Timestamp (e.g., 5m 4s or 5:04)'),
            ),
            DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              items: <String>['en', 'es', 'fr', 'de', 'it', 'pt']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _searchSubtitles,
              child: const Text('Search'),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _subtitles.isEmpty
                      ? const Center(child: Text('No subtitles found'))
                      : ListView.builder(
                          itemCount: _subtitles.length,
                          itemBuilder: (context, index) {
                            final subtitle = _subtitles[index]['attributes'];
                            return ListTile(
                              title: Text(subtitle['release']),
                              subtitle: Text(subtitle['language']),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubtitleDisplayScreen(
                                      subtitle: subtitle,
                                      timestamp: _timestampController.text,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
