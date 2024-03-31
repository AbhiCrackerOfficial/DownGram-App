import 'dart:ui';
import 'package:downgram/pages/about.dart'; // Use camelCase for file names
import 'package:downgram/pages/downloads.dart'; // Use camelCase for file names
import 'package:downgram/pages/home.dart'; // Use camelCase for file names
import 'package:downgram/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

/// Asynchronous function to create a folder with the given [name].
/// Returns the path of the created folder.
Future<String> createFolder(String name) async {
  final directory = Directory('/storage/emulated/0/Download/DownGram/');

  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }

  if (!(await directory.exists())) {
    directory.createSync(recursive: true);
  }

  return directory.path;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  try {
    await FlutterDownloader.initialize();
  } catch (e) {
    // print('Flutter Downloader initialization failed: $e');
  }

  createFolder("DownGram").then(
    (value) => {
      runApp(const MyApp()),
      // print('Folder created at: $value'),
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomNavBar(),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  final PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    // Handle shared intents here if the app is opened from a shared intent
    FlutterSharingIntent().getInitialSharing().then((value) {
      if (value.isNotEmpty) {
        _handleSharedIntent(value[0].value as String);
      }
    });
  }

  /// Callback function when a bottom navigation item is tapped.
  void onItemTapped(int index) {
    setState(() {
      pageController.jumpToPage(index);
      _selectedIndex = index;
    });
  }

  var activeScreen = [
    const Text("Home"),
    const Text("Downloads"),
    const Text("About"),
  ];

  /// Switches the screen based on the provided [index].
  void switchScreen(int index) {
    setState(() {
      activeScreen[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(.5),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(29, 255, 255, 255),
                    Color.fromARGB(0, 0, 0, 0),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),
        title: StyledText(
          text: "DownGram",
          color: yellow, // Change to yellow
          size: 25,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: purple,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              gap: 8,
              activeColor: yellow,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              duration: const Duration(milliseconds: 300),
              tabBackgroundColor: Colors.black,
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                  iconColor: Colors.white,
                  textStyle: TextStyle(
                    color: yellow,
                    fontSize: 15,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GButton(
                  icon: Icons.download,
                  text: 'Downloads',
                  textStyle: TextStyle(
                    color: yellow,
                    fontSize: 15,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                  iconColor: Colors.white,
                ),
                GButton(
                  icon: Icons.info,
                  textStyle: TextStyle(
                    color: yellow,
                    fontSize: 15,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                  text: 'About',
                  iconColor: Colors.white,
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: onItemTapped,
            ),
          ),
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (value) => setState(() => _selectedIndex = value),
        children: const [
          Home(
            url: '',
          ),
          Downloads(),
          About(),
        ],
      ),
    );
  }

  void _handleSharedIntent(String url) {
    print("Shared Intent: $url");
    if (url.contains("instagram.com")) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            url: url,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Invalid URL"),
          content: const Text("Please enter a valid Instagram URL"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}
