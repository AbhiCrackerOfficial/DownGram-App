import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/images/avatar.jpg"),
            ),
            const SizedBox(height: 16),
            const Text(
              "DownGram - Instagram Downloader",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "Made with 🧠 by ",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            InkWell(
              onTap: () {
                launch("https://github.com/AbhiCrackerOfficial");
              },
              child: const Text(
                "@AbhiCracker",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Powered by Flutter",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 36),
            const Text(
              "Api may not be accurate all time.\nYou can try again to fetch if not working.",
              style: TextStyle(
                  color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
