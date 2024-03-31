import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';

/// Class responsible for downloading media using the DownGram API.
class Downloader {
  String query = "";
  Map<String, dynamic> data = {};
  late int retries;
  int lastErrorCode = 0;
  String lastError = "";

  static String? apiUrl = dotenv.env['API_URL'];

  /// Constructor to initialize the Downloader with a [link] and default [retries].
  Downloader(String link) : retries = 10 {
    link = link.contains("?") ? link.split("?")[0] : link;
    query = link.endsWith("/") ? link : '$link/';
  }

  String a() {
    List<int> charCodes = [
      -9,
      0,
      42,
      24,
      21,
      0,
      23,
      66,
      74,
      65,
      26,
      69,
      52,
      64,
      21,
      76,
      20,
      53,
      59,
      60,
      22,
      69,
      52,
      54,
      62,
      56,
      69,
      3,
      3,
      4,
      0,
      -9
    ];

    List<int> modifiedCharCodes = charCodes.map((code) => (code + 45)).toList();

    return String.fromCharCodes(modifiedCharCodes);
  }

  String b() {
    return base64UrlEncode(utf8.encode(query));
  }

  /// Asynchronous function to fetch media information from the DownGram API.
  Future<bool> fetchMedia() async {
    // Check if retries are exhausted.
    if (retries == 0) {
      return false;
    }
    var Token = b();

    try {
      // Make a POST request to the DownGram API.
      var response = await http.post(
        Uri.parse(apiUrl!),
        headers: {
          'Token': Token,
        },
        body: const JsonCodec().encode({"url": query}),
      );

      // If the request is successful (status code 200), process the response.
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if(data == {}){
          lastError = "Try Again";
          return false;
        }
        // print(data);
        return true;
      } else if (response.statusCode == 500) {
        // Handle case where URL is invalid.
        lastError = "Invalid URL";
        return false;
      } else {
        // Handle other status codes.
        print(response.body);
        retries -= 1;
        Map<String, dynamic> tmp = jsonDecode(response.body);
        lastErrorCode = tmp['error_code'];
        lastError = tmp['error'];

        // Retry if the error code is not critical.
        if (lastErrorCode == 1) {
          return false;
        } else {
          // Introduce a delay before retrying.
          await Future.delayed(const Duration(milliseconds: 800));
          return fetchMedia();
        }
      }
    } catch (e) {
      // Handle exceptions and retry after a delay.
      retries -= 1;
      await Future.delayed(const Duration(milliseconds: 800));
      return fetchMedia();
    }
  }
}
