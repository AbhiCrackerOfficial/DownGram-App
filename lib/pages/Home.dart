import 'package:downgram/downloader/downloader.dart';
import 'package:downgram/pages/DownloadableItem.dart'; // Use camelCase for file names
import 'package:downgram/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  final String url;
  const Home({Key? key, required this.url}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final TextEditingController _linkController =
      TextEditingController(text: widget.url);
  bool isLoading = false;
  Map<String, dynamic> data = {};
  var disData = [];
  String errorMessage = ""; // Use camelCase for variable names

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.url.isNotEmpty) {
      fetchData(context);
    }
  }

  void fetchData(ctx) {
    setState(() {
      isLoading = true;
      data = {};
      disData = [];
      String link = _linkController.text;
      Downloader obj = Downloader(link);
      obj.fetchMedia().then((value) {
        setState(() {
          data = value ? obj.data : {};
          errorMessage = value ? "" : obj.lastError;
          isLoading = false;
        });
        formatData(ctx); // Move this line here
      });
    });
  }

  void formatData(ctx) {
    if (data.length == 0) {
      return;
    } else {
      if (data['type'] == 'reels') {
        disData.add(downloadableItem(
          title: data['data'][0]['title'],
          tlink: data['data'][0]['thumbnail_url'],
          dlink: data['data'][0]['download_url'],
          type: 'video',
          ctx: ctx,
        ));
      } else if (data['type'] == 'profile') {
        disData.add(
          downloadableItem(
            title: data['data'][0]['title'],
            tlink: data['data'][0]['thumbnail_url'],
            dlink: data['data'][0]['download_url'],
            type: 'image',
            ctx: ctx,
          ),
        );
      } else if (data['type'] == 'igtv') {
        disData.add(
          downloadableItem(
            title: data['data'][0]['title'],
            tlink: data['data'][0]['thumbnail_url'],
            dlink: data['data'][0]['download_url'],
            type: 'video',
            ctx: ctx,
          ),
        );
      } else if (data['type'] == 'posts') {
        for (int i = 0; i < data['data'].length; i++) {
          disData.add(downloadableItem(
              title: data['data'][i]['title'],
              tlink: data['data'][i]['thumbnail_url'],
              dlink: data['data'][i]['download_url'],
              type: data['data'][i]['type'],
              ctx: ctx));
        }
      } else if (data['type'] == 'stories') {
        for (int i = 0; i < data['data'].length; i++) {
          disData.add(downloadableItem(
              title: data['data'][i]['title'],
              tlink: data['data'][i]['thumbnail_url'],
              dlink: data['data'][i]['download_url'],
              type: data['data'][i]['type'],
              ctx: ctx));
          print(data['data'][i]['type']);
        }
      } else if (data['type'] == 'highlights') {
        for (int i = 0; i < data['data'].length; i++) {
          disData.add(downloadableItem(
              title: data['data'][i]['title'],
              tlink: data['data'][i]['thumbnail_url'],
              dlink: data['data'][i]['download_url'],
              type: data['data'][i]['type'],
              ctx: ctx));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              child: TextField(
                controller: _linkController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Paste the URL here',
                  hintStyle: TextStyle(
                      color: Color.fromARGB(126, 255, 255, 255),
                      fontSize: 16,
                      fontFamily: 'Poppins'),
                ),
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontFamily: 'Poppins'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: ElevatedButton(
                      onPressed: () => fetchData(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: yellow,
                      ),
                      child: Text(
                        'Fetch Media',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Add spacing between the buttons
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _linkController.clear();
                          data = {};
                          disData = [];
                          errorMessage = "";
                          if (isLoading) {
                            isLoading = false;
                          }
                        });
                      },
                      hoverColor: purple.withAlpha(80),
                      splashRadius: 20.0,
                      color: yellow,
                      iconSize: 30.0,
                      padding: const EdgeInsets.all(0.0),
                      constraints: const BoxConstraints(),
                      alignment: Alignment.center,
                      icon: const Icon(Icons.clear_outlined),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.white,
            ),
            Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : disData.isNotEmpty
                        ? ListView.builder(
                            itemCount: disData.length,
                            itemBuilder: (context, index) {
                              return disData[index];
                            },
                          )
                        : Center(
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Monospace'),
                              textAlign: TextAlign.center,
                            ),
                          )),
          ],
        ),
      ),
    );
  }
}
