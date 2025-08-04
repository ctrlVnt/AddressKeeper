import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'giordanobruno227@gmail.com',
      queryParameters: {
        'subject': 'report for AddressKeeper',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw Exception('Could not launch email client');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicTheme(
      themeMode: ThemeMode.system,
      child: NeumorphicBackground(
        child: Scaffold(
          appBar: NeumorphicAppBar(
            title: const Text("Information"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                    "This application works entirely offline and does not collect any personal data. "
                        "All your information remains stored only on your device.",
                    style: TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 32),

                NeumorphicButton(
                  onPressed: () => _openUrl("https://play.google.com/store/apps/details?id=com.ctrlvnt.addresskeeper"),
                  padding: const EdgeInsets.all(12),
                  child: const Text("Rate on Play Store ⭐"),
                ),
                const SizedBox(height: 12),

                NeumorphicButton(
                  onPressed: () => _openUrl("https://riccardoventurini.dev"),
                  padding: const EdgeInsets.all(12),
                  child: const Text("Visit My Website 🌐"),
                ),
                const SizedBox(height: 12),

                NeumorphicButton(
                  onPressed: () => _openUrl("https://buymeacoffee.com/v3ntuz"),
                  padding: const EdgeInsets.all(12),
                  child: const Text("Buy Me a Coffee ☕"),
                ),
                const SizedBox(height: 12),
                NeumorphicButton(
                  onPressed: () => _openUrl("https://github.com/ctrlVnt/addresskeeper"),
                  padding: const EdgeInsets.all(12),
                  child: const Text("See the code source 👀"),
                ),
                const SizedBox(height: 12),
                NeumorphicButton(
                  onPressed: () => _openUrl("https://riccardoventurini.dev/privacy/addresskeeper"),
                  padding: const EdgeInsets.all(12),
                  child: const Text("Privacy Policy 👤"),
                ),
                const SizedBox(height: 20),
                NeumorphicButton(
                  onPressed: sendEmail,
                  padding: const EdgeInsets.all(12),
                  child: const Text("Send me bug or suggestions ✉"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
