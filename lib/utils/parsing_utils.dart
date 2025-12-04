import 'package:intl/intl.dart';

class ParsingUtils {
  static Duration parseTimestamp(String timestamp) {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    final parts = timestamp.split(' ');
    for (final part in parts) {
      if (part.endsWith('h')) {
        hours = int.parse(part.substring(0, part.length - 1));
      } else if (part.endsWith('m')) {
        minutes = int.parse(part.substring(0, part.length - 1));
      } else if (part.endsWith('s')) {
        seconds = int.parse(part.substring(0, part.length - 1));
      }
    }

    if (timestamp.contains(':')) {
      final timeParts = timestamp.split(':');
      if (timeParts.length == 2) {
        minutes = int.parse(timeParts[0]);
        seconds = int.parse(timeParts[1]);
      } else if (timeParts.length == 3) {
        hours = int.parse(timeParts[0]);
        minutes = int.parse(timeParts[1]);
        seconds = int.parse(timeParts[2]);
      }
    }

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  static String parseSrt(String srtContent, Duration timestamp) {
    final lines = srtContent.split('\n');
    final dateFormat = DateFormat("HH:mm:ss,SSS");

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('-->')) {
        final timeParts = lines[i].split(' --> ');
        final startTime = dateFormat.parse(timeParts[0].trim(), true);
        final endTime = dateFormat.parse(timeParts[1].trim(), true);
        final subtitleDuration = Duration(
          hours: startTime.hour,
          minutes: startTime.minute,
          seconds: startTime.second,
          milliseconds: startTime.millisecond,
        );

        final subtitleEndDuration = Duration(
          hours: endTime.hour,
          minutes: endTime.minute,
          seconds: endTime.second,
          milliseconds: endTime.millisecond,
        );

        if (timestamp >= subtitleDuration && timestamp <= subtitleEndDuration) {
          return lines[i + 1];
        }
      }
    }
    return 'No subtitle found for the given timestamp.';
  }

  static int getCharacterIndexForDuration(
      String srtContent, Duration timestamp) {
    final lines = srtContent.split('\n');
    final dateFormat = DateFormat("HH:mm:ss,SSS");
    int characterIndex = 0;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('-->')) {
        final timeParts = lines[i].split(' --> ');
        final startTime = dateFormat.parse(timeParts[0].trim(), true);
        final endTime = dateFormat.parse(timeParts[1].trim(), true);
        final subtitleDuration = Duration(
          hours: startTime.hour,
          minutes: startTime.minute,
          seconds: startTime.second,
          milliseconds: startTime.millisecond,
        );

        final subtitleEndDuration = Duration(
          hours: endTime.hour,
          minutes: endTime.minute,
          seconds: endTime.second,
          milliseconds: endTime.millisecond,
        );

        if (subtitleDuration >= timestamp) {
          int prevTimestampLineIndex = -1;
          for (int j = i - 1; j >= 0; j--) {
            if (lines[j].contains('-->')) {
              prevTimestampLineIndex = j;
              break;
            }
          }

          if (prevTimestampLineIndex != -1) {
            final prevTimeParts =
                lines[prevTimestampLineIndex].split(' --> ');
            final prevEndTime =
                dateFormat.parse(prevTimeParts[1].trim(), true);
            final prevSubtitleEndDuration = Duration(
              hours: prevEndTime.hour,
              minutes: prevEndTime.minute,
              seconds: prevEndTime.second,
              milliseconds: prevEndTime.millisecond,
            );
            if (timestamp > prevSubtitleEndDuration) {
              return characterIndex;
            }
          } else {
            return characterIndex;
          }
        }

        if (timestamp >= subtitleDuration && timestamp <= subtitleEndDuration) {
          if (i + 1 < lines.length) {
            return characterIndex + lines[i].length + 1;
          }
        }
      }
      characterIndex += lines[i].length + 1;
    }
    return -1;
  }
}
