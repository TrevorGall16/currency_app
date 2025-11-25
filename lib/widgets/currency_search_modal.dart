import 'package:flutter/material.dart';
import '../utils/currency_utils.dart';

class CurrencySearchModal extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> currencies;
  final Function(String) onSelect;

  const CurrencySearchModal({
    super.key,
    required this.scrollController,
    required this.currencies,
    required this.onSelect,
  });

  @override
  State<CurrencySearchModal> createState() => _CurrencySearchModalState();
}

class _CurrencySearchModalState extends State<CurrencySearchModal> {
  String query = "";

  // P0 Feature: Favorites List (Most common currencies)
  final List<String> _favorites = ['USD', 'EUR', 'GBP', 'JPY', 'THB', 'CNY', 'KRW', 'AUD', 'CAD', 'SGD'];

  @override
  Widget build(BuildContext context) {
    // 1. Filter logic
    final filteredList = widget.currencies.where((code) {
      final name = CurrencyUtils.getCurrencyName(code).toLowerCase();
      final c = code.toLowerCase();
      final q = query.toLowerCase();
      return c.contains(q) || name.contains(q);
    }).toList();

    // 2. Build the list
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          
          // Search Bar
          TextField(
            onChanged: (val) => setState(() => query = val),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: "Search currency",
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),

          // List Content
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                // A. SHOW FAVORITES (Only when not searching)
                if (query.isEmpty) ...[
                  const Text(
                    "POPULAR",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  // Horizontal Favorites for speed
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _favorites.map((code) => _buildFavoriteChip(code)).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "ALL CURRENCIES",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                ],

                // B. ALL CURRENCIES LIST
                ...filteredList.map((code) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(CurrencyUtils.getEmojiFlag(code), style: const TextStyle(fontSize: 24)),
                    title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(CurrencyUtils.getCurrencyName(code)),
                    onTap: () => widget.onSelect(code),
                  );
                }),
                
                // Empty State
                if (filteredList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("No currency found")),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteChip(String code) {
    return GestureDetector(
      onTap: () => widget.onSelect(code),
      child: Container(
        width: 80, // Fixed width for grid look
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(CurrencyUtils.getEmojiFlag(code), style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}