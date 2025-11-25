import 'package:hive/hive.dart';

// unique ID for the TypeAdapter (must be unique per class)
part 'currency_card.g.dart'; 

@HiveType(typeId: 0)
class CurrencyCard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String base; // The foreign currency (e.g., 'THB')

  @HiveField(2)
  final String target; // The home currency (e.g., 'EUR')

  @HiveField(3)
  double rate; // The stored exchange rate (e.g., 0.025)

  @HiveField(4)
  DateTime lastUpdated;

  @HiveField(5)
  List<double>? historicalData; // Nullable: strictly for Premium features later

  CurrencyCard({
    required this.id,
    required this.base,
    required this.target,
    required this.rate,
    required this.lastUpdated,
    this.historicalData,
  });

  // Helper to update the rate easily
  void updateRate(double newRate) {
    rate = newRate;
    lastUpdated = DateTime.now();
    save(); // HiveObject method to auto-persist changes
  }
}