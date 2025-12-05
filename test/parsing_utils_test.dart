import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_timestamp_loader/utils/parsing_utils.dart';

void main() {
  group('getCharacterIndexForDuration', () {
    const srtContent = """
1
00:00:01,000 --> 00:00:02,000
Hello

2
00:00:03,000 --> 00:00:04,000
World
""";

    test('should return correct index for timestamp within a subtitle', () {
      final timestamp = Duration(seconds: 1, milliseconds: 500);
      final result =
          ParsingUtils.getCharacterIndexForDuration(srtContent, timestamp);
      expect(result, 39);
    });

    test('should return correct index for timestamp between subtitles', () {
      final timestamp = Duration(seconds: 2, milliseconds: 500);
      final result =
          ParsingUtils.getCharacterIndexForDuration(srtContent, timestamp);
      expect(result, 39);
    });

    test('should return correct index for timestamp at the beginning', () {
      final timestamp = Duration(seconds: 0, milliseconds: 500);
      final result =
          ParsingUtils.getCharacterIndexForDuration(srtContent, timestamp);
      expect(result, 0);
    });

    test('should return -1 for timestamp after all subtitles', () {
      final timestamp = Duration(seconds: 5);
      final result =
          ParsingUtils.getCharacterIndexForDuration(srtContent, timestamp);
      expect(result, 0);
    });
  });
}
