// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// class FileDownloader {
//   final String url;
//   final String savePath;
//   final FlutterLocalNotificationsPlugin notifications;

//   FileDownloader({
//     required this.url,
//     required this.savePath,
//     required this.notifications,
//   });

//   Future<void> downloadFileWithNotification() async {
//     try {
//       // Start the download
//       final response = await http.get(Uri.parse(url));
//       final file = File(savePath);

//       // Save the downloaded file
//       await file.writeAsBytes(response.bodyBytes);

//       // Show a notification
//        android = AndroidNotificationDetails(
//         'channel id',
//         'channel name',
//         'channel description',
//         priority: Priority.high,
//         importance: Importance.max,
//       );

//     } catch (e) {
//       print('Error downloading file: $e');
//     }
//   }
// }
