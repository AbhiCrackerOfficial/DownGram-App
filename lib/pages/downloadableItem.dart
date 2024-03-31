import 'dart:io';

import 'package:downgram/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:media_scanner/media_scanner.dart';

class downloadableItem extends StatefulWidget {
  final String tlink;
  final String dlink;
  final String title;
  final String type;
  final ctx;

  const downloadableItem({
    Key? key,
    required this.title,
    required this.tlink,
    required this.dlink,
    required this.type,
    required this.ctx,
  }) : super(key: key);

  @override
  _downloadableItemState createState() => _downloadableItemState();
}

class _downloadableItemState extends State<downloadableItem> {
  bool isLoading = false;
  bool isDownloaded = false;
  MethodChannel _channel = const MethodChannel('downgram_scan');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: purple, width: 2.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(4.0),
              child: CachedNetworkImage(
                imageUrl:
                    "https://proxy.mediadownloader.abhicracker.com/?url=${widget.tlink}",
                placeholder: (context, url) => SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: yellow,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: 100,
                height: 100,
              ),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 3,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 1,
            child: buildDownloadButton(),
          ),
        ],
      ),
    );
  }

  Widget buildDownloadButton() {
    if (!isLoading && !isDownloaded) {
      return IconButton(
        hoverColor: purple.withAlpha(80),
        splashRadius: 20.0,
        icon: Icon(
          Icons.download,
          color: yellow,
        ),
        onPressed: () {
          downloadFile(widget.dlink, widget.title);
        },
      );
    } else if (isDownloaded) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    } else {
      return CircularProgressIndicator(
        color: yellow,
      );
      // return SizedBox(
      //   width: 8,
      //   height: 15,
      //   child: CircularProgressIndicator(
      //     color: yellow,
      //   ),
      // );
    }
  }

  Future<String?> getDownloadPath(String type) async {
    Directory? downloadDirectory = await getDownloadsDirectory();
    String? basePath = downloadDirectory?.path;
    return basePath;
  }

  String getFileName() {
    String name =
        "${widget.title.replaceAll(RegExp(r'[\n!.]'), '').replaceAll(' ', '_').replaceAll("#", "").replaceAll(RegExp(r'\n'), ' ').substring(0, 20)}-${widget.title.substring(widget.title.length - 5)}";

    if (widget.type == "image") {
      return name.isEmpty ? "[DownGram]-Image.jpg" : "[DownGram]-$name.jpg";
    }
    if (widget.type == "video") {
      return name.isEmpty ? "[DownGram]-Video.mp4" : "[DownGram]-$name.mp4";
    }
    return "[DownGram]-$name";
  }

  Future<void> sendBroadcast(String filePath) async {
    try {
      await _channel.invokeMethod('sendBroadcast', {'filePath': filePath});
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  Future<void> moveFile(String sourcePath, String destinationPath) async {
    try {
      // Check if the source file exists
      File sourceFile = File(sourcePath);
      if (!(await sourceFile.exists())) {
        throw const FileSystemException("Source file doesn't exist");
      }

      // Move the file
      await sourceFile.rename(destinationPath);
      print('File moved successfully');
      // use method channel
      await sendBroadcast(destinationPath);
    } catch (e) {
      print('Error while moving the file: $e');
    }
  }

  void downloadFile(String dlink, String title) {
    try {
      setState(() {
        isLoading = true;
      });

      FileDownloader.downloadFile(
        url: dlink,
        name: getFileName(),
        downloadDestination: DownloadDestinations.publicDownloads,
        notificationType: NotificationType.all,
        onProgress: (receivedBytes, totalBytes) {
          double progress = double.parse(receivedBytes!) /
              double.parse(totalBytes as String) *
              100;
          print(
              "receivedBytes: $receivedBytes, totalBytes: $totalBytes, progress: $progress%");
        },
        onDownloadCompleted: (path) async => {
          setState(() {
            isDownloaded = true;
            isLoading = false;
          }),
          await moveFile(
              Uri.decodeFull(path),
              Uri.decodeFull(
                  "/storage/emulated/0/Download/DownGram/${path.split("/").last}")),
          print(
              "File downloaded to: ${Uri.decodeFull("/storage/emulated/0/Download/DownGram/${path.split("/").last}")}"),
          ScaffoldMessenger.of(widget.ctx).showSnackBar(
            SnackBar(
              content: Text(
                  "Downloaded to: ${Uri.decodeFull("/storage/emulated/0/Download/DownGram/${path.split("/").last}")}",
                  style: const TextStyle(color: Colors.green)),
            ),
          ),
        },
        onDownloadError: (errorMessage) => {
          setState(() {
            isLoading = false;
          }),
          print("Error occurred while downloading: $errorMessage"),
          ScaffoldMessenger.of(widget.ctx).showSnackBar(
            SnackBar(
              content: Text("Download failed: $errorMessage",
                  style: const TextStyle(color: Colors.red)),
            ),
          ),
        },
      );
    } catch (e) {
      print(e);
    }
  }
}
