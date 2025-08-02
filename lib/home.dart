import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movesync/database/database.dart';
import 'package:movesync/model/AppInfo.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentPhone = "";
  String currentAddress = "";

  List<AppInfo> apps = [];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadAppsFromDB();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentPhone = prefs.getString('currentPhone') ?? currentPhone;
      currentAddress = prefs.getString('currentAddress') ?? currentAddress;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentPhone', currentPhone);
    await prefs.setString('currentAddress', currentAddress);
  }

  void _editPersonalDataDialog() {
    final phoneController = TextEditingController(text: currentPhone);
    final addressController = TextEditingController(text: currentAddress);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Modifica dati personali"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Numero di telefono"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: "Indirizzo"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Annulla"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text("Salva"),
            onPressed: () async {
              final newPhone = phoneController.text.trim();
              final newAddress = addressController.text.trim();

              if (newPhone.isNotEmpty && newAddress.isNotEmpty) {
                setState(() {
                  currentPhone = newPhone;
                  currentAddress = newAddress;
                });
                await _savePrefs();
                Navigator.of(context).pop();
              } else {
                // magari mostra errore per campi vuoti
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Compila entrambi i campi")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadAppsFromDB() async {
    final data = await DatabaseHelper.instance.getAllApps();
    setState(() {
      apps = data;
    });
  }

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
            onPressed: () async {
              final appName = nameController.text.trim();
              final url = urlController.text.trim().isNotEmpty ? urlController.text.trim() : null;

              if (appName.isNotEmpty) {
                final newApp = AppInfo(
                  appName: appName,
                  phone: currentPhone,
                  address: currentAddress,
                  url: url,
                );

                await DatabaseHelper.instance.insertApp(newApp);
                await _loadAppsFromDB();
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
            onPressed: () async {
              final appName = apps[index].appName;
              await DatabaseHelper.instance.deleteApp(appName);
              await _loadAppsFromDB();
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
      appBar: AppBar(title: Text('Le mie info'),
        actions: [
          IconButton(
          icon: Icon(Icons.edit),
          tooltip: "Modifica dati personali",
          onPressed: _editPersonalDataDialog,
          ),
        ],
      ),
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
                final isPhoneMatching = app.phone == currentPhone;
                final isAddressMatching = app.address == currentAddress;
                final isUpdated = isPhoneMatching && isAddressMatching;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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
                            color: isPhoneMatching ? null : textColorError,
                          ),
                        ),
                        Text(
                          "Indirizzo: ${app.address}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isAddressMatching ? null : textColorError,
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
