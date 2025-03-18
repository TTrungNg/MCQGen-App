import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ModelApi {
  final http.Client client;

  ModelApi(this.client);

  Future<List<String>> processMultipleContexts(List<String> contexts) async {
    try {
      // Use Future.wait to process all contexts concurrently
      return await Future.wait(contexts.map((context) async {
        String? eventId = await fetchEventId(context);
        if (eventId != null) {
          return await fetchResult(eventId) ??
              "Error fetching result for $eventId";
        } else {
          return "Error fetching EVENT_ID for context: $context";
        }
      }));
    } catch (error) {
      print("Error in processMultipleContexts: $error");
      return contexts
          .map((context) => "Error processing context: $context")
          .toList();
    }
  }

  Future<String?> fetchEventId(String inputContext) async {
    var url = Uri.parse(
        "https://ca0e9bbaec18694080.gradio.live/gradio_api/call/predict");

    try {
      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "data": [inputContext]
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse["event_id"];
      } else {
        print("Failed to fetch EVENT_ID: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error occurred while fetching EVENT_ID: $error");
      return null;
    }
  }

  Future<String?> fetchResult(String eventId) async {
    var url = Uri.parse(
        "https://ca0e9bbaec18694080.gradio.live/gradio_api/call/predict/$eventId");
    return _polling(url);
  }

  Future<String?> _polling(Uri url) async {
    int maxAttempts = 30; // Limit the number of polling attempts
    int attempts = 0;
    String completeData = '';

    while (attempts < maxAttempts) {
      try {
        // Send GET request to fetch the result
        var response = await client.get(url);

        if (response.statusCode == 200) {
          // Split the response into lines
          List<String> lines = response.body.split('\n');

          for (String line in lines) {
            // Parse Server-Sent Events (SSE)
            if (line.startsWith('event:')) {
              String eventType = line.substring(6).trim();
              print("Event type: $eventType");

              if (eventType == 'complete') {
                // Find the next line that starts with 'data:'
                int dataIndex = lines.indexOf(line) + 1;
                if (dataIndex < lines.length &&
                    lines[dataIndex].startsWith('data:')) {
                  completeData = lines[dataIndex].substring(5).trim();
                  break;
                }
              }
            }
          }

          // If we found complete data, process and return it
          if (completeData.isNotEmpty) {
            // Decode Unicode characters
            final Pattern unicodePattern = RegExp(r'\\u([0-9A-Fa-f]{4})');
            String decodedData =
                completeData.replaceAllMapped(unicodePattern, (Match match) {
              final int hexCode = int.parse(match.group(1)!, radix: 16);
              return String.fromCharCode(hexCode);
            });

            return jsonDecode(decodedData)[0];
          }

          // If not complete, wait and retry
          print("Model not completed yet, waiting...");
          await Future.delayed(const Duration(seconds: 2));
          attempts++;
        } else {
          print("Failed to fetch result: ${response.statusCode}");
          return null;
        }
      } catch (error) {
        print("Error occurred during polling: $error");
        return null;
      }
    }

    print("Max polling attempts reached");
    return null;
  }
}
