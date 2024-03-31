import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/functions.dart';
import 'package:open_file/open_file.dart';

class Downloads extends StatefulWidget {
  const Downloads({Key? key}) : super(key: key);

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  Directory? tmpdirectory;
  List<File> mediaFiles = [];

  @override
  void initState() {
    super.initState();
    loadMediaFiles();
  }

  /// Asynchronous function to load media files from the DownGram folder.
  Future<void> loadMediaFiles() async {
    tmpdirectory = await getTemporaryDirectory();
    final directory = Directory('/storage/emulated/0/Download/DownGram/');
    List<FileSystemEntity> files = directory.listSync(recursive: true);
    List<File> mediaFiles = [];

    for (FileSystemEntity file in files) {
      if (file is File) {
        mediaFiles.add(file);
      }
    }

    // Sort the mediaFiles list in descending order based on last modified timestamp
    mediaFiles
        .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    setState(() {
      this.mediaFiles = mediaFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ListView.builder(
          itemCount: mediaFiles.length,
          itemBuilder: (context, index) {
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
                      child: IconButton(
                        hoverColor: purple.withAlpha(80),
                        splashRadius: 20.0,
                        icon: mediaFiles[index].path.endsWith('.mp4')
                            ? Icon(
                                Icons.videocam,
                                color: yellow,
                              )
                            : Icon(
                                Icons.image,
                                color: yellow,
                              ),
                        onPressed: () {
                          OpenFile.open(mediaFiles[index].path);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      child: Text(
                        mediaFiles[index].path.split('/').last,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      hoverColor: purple.withAlpha(80),
                      splashRadius: 20.0,
                      icon: Icon(
                        Icons.delete,
                        color: yellow,
                      ),
                      onPressed: () {
                        setState(() {
                          mediaFiles[index].deleteSync();
                          loadMediaFiles();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      hoverColor: purple.withAlpha(80),
                      splashRadius: 20.0,
                      icon: Icon(
                        Icons.share,
                        color: yellow,
                      ),
                      onPressed: () async {
                        await Share.shareFiles([mediaFiles[index].path],
                            text: '[Downloaded using DownGram-AbhiCracker]');
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
