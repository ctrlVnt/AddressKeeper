import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfo {
  final String appName;
  final String phone;
  final String address;
  final bool isPhoneUpdated;
  final bool isAddressUpdated;
  final String? url;

  AppInfo({
    required this.appName,
    required this.phone,
    required this.address,
    required this.isPhoneUpdated,
    required this.isAddressUpdated,
    this.url,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String currentPhone = "+39 333 1234567";
  final String currentAddress = "Via Roma 1, Milano";

  List<AppInfo> apps = [
    AppInfo(
      appName: "Amazon",
      phone: "+39 333 1234567",
      address: "Via Roma 1, Milano",
      isPhoneUpdated: true,
      isAddressUpdated: true,
      url: "https://www.amazon.it",
    ),
    AppInfo(
      appName: "Netflix",
      phone: "+39 333 9876543",
      address: "Via Vecchia 10, Torino",
      isPhoneUpdated: false,
      isAddressUpdated: false,
      url: "https://www.netflix.com",
    ),
  ];

  void _addAppDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Nuova registrazione"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nome dell'app o sito"),
            ),
            TextField(
              controller: urlController,
              decoration: InputDecoration(labelText: "Link (opzionale)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Annulla"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text("Aggiungi"),
            onPressed: () {
              final appName = nameController.text.trim();
              final url = urlController.text.trim().isNotEmpty ? urlController.text.trim() : null;

              if (appName.isNotEmpty) {
                setState(() {
                  apps.add(
                      AppInfo(
                    appName: appName,
                    phone: currentPhone,
                    address: currentAddress,
                    isPhoneUpdated: true,
                    isAddressUpdated: true,
                    url: url,
                  ));
                });
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmRemoveApp(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Conferma eliminazione"),
        content: Text("Vuoi rimuovere '${apps[index].appName}'?"),
        actions: [
          TextButton(
            child: Text("Annulla"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text("Elimina"),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              setState(() {
                apps.removeAt(index);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Link non valido")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColorError = theme.colorScheme.error;

    return Scaffold(
      appBar: AppBar(title: Text('Le mie info')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Numero di telefono: $currentPhone", style: theme.textTheme.bodyLarge),
                SizedBox(height: 8),
                Text("Indirizzo: $currentAddress", style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("App collegate", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final isUpdated = app.isPhoneUpdated && app.isAddressUpdated;
                final tileColor = isUpdated
                    ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
                    : theme.colorScheme.errorContainer.withOpacity(0.3);

                return Container(
                  color: tileColor,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(12), // smussa gli angoli
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(app.appName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Telefono: ${app.phone}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: app.isPhoneUpdated ? null : textColorError,
                          ),
                        ),
                        Text(
                          "Indirizzo: ${app.address}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: app.isAddressUpdated ? null : textColorError,
                          ),
                        ),
                        if (app.url != null)
                          GestureDetector(
                            onTap: () => _launchURL(app.url!),
                            child: Text(
                              app.url!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: theme.colorScheme.error),
                      onPressed: () => _confirmRemoveApp(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppDialog,
        child: Icon(Icons.add),
        tooltip: "Nuova registrazione",
      ),
    );
  }
}
