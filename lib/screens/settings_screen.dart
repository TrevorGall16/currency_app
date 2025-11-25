import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/currency_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Box settingsBox = Hive.box('settings');
  late String defaultCurrency;

  @override
  void initState() {
    super.initState();
    defaultCurrency = settingsBox.get('default_from', defaultValue: 'USD');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSectionHeader("Preferences"),
          _buildListTile(
            icon: Icons.flag,
            title: "Default 'From' Currency",
            subtitle: defaultCurrency,
            onTap: _showDefaultCurrencyPicker,
            textColor: textColor,
            iconColor: iconColor,
          ),
          const Divider(height: 40, color: Colors.grey),
          _buildSectionHeader("About"),
          _buildListTile(
            icon: Icons.info_outline,
            title: "Version",
            subtitle: "1.0.0 (MVP)",
            onTap: () {},
            textColor: textColor,
            iconColor: iconColor,
          ),
          _buildListTile(
            icon: Icons.cloud_outlined,
            title: "Data Source",
            subtitle: "Frankfurter API (Open Source)",
            onTap: () {},
            textColor: textColor,
            iconColor: iconColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey)),
        trailing: Icon(Icons.chevron_right, color: iconColor),
        onTap: onTap,
      ),
    );
  }

  void _showDefaultCurrencyPicker() {
    final currencies = [
      'USD', 'EUR', 'THB', 'JPY', 'GBP', 'CNY', 'SGD', 'AUD', 'CAD', 'CHF', 'HKD', 'KRW',
      'INR', 'BRL', 'RUB', 'ZAR', 'MXN', 'TRY', 'NZD', 'SEK'
    ];
    
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final code = currencies[index];
          return ListTile(
            title: Text(code),
            leading: Text(CurrencyUtils.getEmojiFlag(code)),
            onTap: () {
              setState(() => defaultCurrency = code);
              settingsBox.put('default_from', code);
              Navigator.pop(context);
            },
          );
        },
      )
    );
  }
}