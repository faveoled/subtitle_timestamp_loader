import 'package:flutter/material.dart';
import 'package:subtitle_timestamp_loader/services/opensubtitles_api.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle_timestamp_loader/utils/parsing_utils.dart';

class SubtitleDisplayScreen extends StatefulWidget {
  final Map<String, dynamic> subtitle;
  final String timestamp;

  const SubtitleDisplayScreen({
    super.key,
    required this.subtitle,
    required this.timestamp,
  });

  @override
  _SubtitleDisplayScreenState createState() => _SubtitleDisplayScreenState();
}

class _SubtitleDisplayScreenState extends State<SubtitleDisplayScreen> {
  String _subtitleContent = '';
  String _fullSubtitleContent = '';
  bool _isLoading = true;
  final OpenSubtitlesApi _api = OpenSubtitlesApi();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubtitleContent();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadSubtitleContent() async {
    try {
      final fileId = widget.subtitle['files'][0]['file_id'];
      _fullSubtitleContent = await _api.downloadSubtitle(fileId);
      setState(() {
        _textController.text = _fullSubtitleContent;
        _isLoading = false;
      });
      _scrollToTimestamp(_fullSubtitleContent);
    } catch (e) {
      setState(() {
        _textController.text = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _scrollToTimestamp(String content) {
    final duration = ParsingUtils.parseTimestamp(widget.timestamp);
    final characterIndex =
        ParsingUtils.getCharacterIndexForDuration(content, duration);
    if (characterIndex != -1) {
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: characterIndex),
      );
    }
  }

  Future<void> _downloadSubtitle() async {
    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/${widget.subtitle['release']}.srt';
      final file = File(filePath);
      await file.writeAsString(_fullSubtitleContent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subtitle downloaded to $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading subtitle: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subtitle['release']),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadSubtitle,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
    );
  }
}
