import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../utils/currency_utils.dart';
import '../widgets/app_background.dart';

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

  // --- PRIVACY POLICY LINK SECTION ---
  Future<void> _launchPrivacyPolicy() async {
    // 1. PASTE YOUR GOOGLE DOC LINK INSIDE THE QUOTES BELOW:
    const String yourLink = 'https://docs.google.com/document/d/1DjVQGE2OdD-FKqHKQyuPS0TyPKefsaPCg8yrgDObCrQ/edit?tab=t.0';
    
    final Uri url = Uri.parse(yourLink);
    
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open link. Please check internet.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "SETTINGS", 
          style: TextStyle(
            color: textColor, 
            fontFamily: Platform.isIOS ? 'Courier' : 'Roboto', 
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 1.0
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),

          ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
              left: 16,
              right: 16,
              bottom: 40
            ),
            children: [
              _buildSectionHeader("Preferences"),
              _buildSettingsGroup(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.currency_exchange,
                    iconColor: Colors.orange,
                    title: "Default Currency",
                    subtitle: defaultCurrency,
                    trailing: _buildCurrencyBadge(defaultCurrency, isDark),
                    onTap: _showDefaultCurrencyPicker,
                    showDivider: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionHeader("Information"),
              _buildSettingsGroup(
                context,
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_outline_rounded,
                    iconColor: Colors.blueAccent,
                    title: "Version",
                    subtitle: "1.0.0 (Pro)",
                    trailing: const SizedBox.shrink(), 
                    onTap: () {}, 
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.cloud_sync_rounded,
                    iconColor: Colors.purpleAccent,
                    title: "Data Source",
                    subtitle: "Frankfurter API",
                    trailing: const SizedBox.shrink(),
                    onTap: () {}, 
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.green,
                    title: "Privacy Policy",
                    subtitle: "Tap to view",
                    // Opens your Google Doc
                    onTap: _launchPrivacyPolicy,
                    showDivider: false,
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "Currency Pro © 2025",
                  style: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black26,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: 0.5
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey, 
          fontWeight: FontWeight.w700, 
          fontSize: 11,
          letterSpacing: 1.0
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E).withOpacity(0.6) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title, 
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: textColor,
              fontSize: 15
            )
          ),
          subtitle: Text(
            subtitle, 
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 13
            )
          ),
          trailing: trailing ?? Icon(Icons.chevron_right, color: isDark ? Colors.white30 : Colors.black26, size: 20),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1, 
            thickness: 1, 
            indent: 60, 
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)
          ),
      ],
    );
  }

  Widget _buildCurrencyBadge(String code, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(CurrencyUtils.getEmojiFlag(code), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            code, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87
            )
          ),
        ],
      ),
    );
  }

  void _showDefaultCurrencyPicker() {
    final currencies = [
      'USD', 'EUR', 'THB', 'JPY', 'GBP', 'CNY', 'SGD', 'AUD', 'CAD', 'CHF', 'HKD', 'KRW',
      'INR', 'BRL', 'RUB', 'ZAR', 'MXN', 'TRY', 'NZD', 'SEK'
    ];
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2)
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: currencies.length,
                separatorBuilder: (ctx, i) => Divider(
                  height: 1, 
                  indent: 16, 
                  endIndent: 16,
                  color: isDark ? Colors.white12 : Colors.black12
                ),
                itemBuilder: (context, index) {
                  final code = currencies[index];
                  final isSelected = defaultCurrency == code;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    title: Text(
                      code,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isDark ? Colors.white : Colors.black87
                      ),
                    ),
                    leading: Text(
                      CurrencyUtils.getEmojiFlag(code),
                      style: const TextStyle(fontSize: 24),
                    ),
                    trailing: isSelected 
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                    onTap: () {
                      setState(() => defaultCurrency = code);
                      settingsBox.put('default_from', code);
                      settingsBox.put('fromCurrency', code); 
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}