import 'package:flutter/material.dart';

class CategoryConstants {
  static const Map<String, IconData> icons = {
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Bills & Utilities': Icons.receipt_long,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Healthcare': Icons.local_hospital,
    'Education': Icons.school,
    'Groceries': Icons.local_grocery_store,
    'Fuel & Gas': Icons.local_gas_station,
    'Coffee & Drinks': Icons.local_cafe,
    'Fitness & Gym': Icons.fitness_center,
    'Beauty & Personal Care': Icons.face_retouching_natural,
    'Travel': Icons.flight,
    'Home & Garden': Icons.home,
    'Technology': Icons.devices,
    'Clothing': Icons.checkroom,
    'Gifts & Donations': Icons.card_giftcard,
    'Insurance': Icons.security,
    'Subscriptions': Icons.subscriptions,
    'Other': Icons.more_horiz,
  };

  static final Map<String, Color> colors = {
    'Food & Dining': Colors.orange,
    'Transportation': Colors.blue,
    'Bills & Utilities': Colors.amber.shade700,
    'Shopping': Colors.purple,
    'Entertainment': Colors.pink,
    'Healthcare': Colors.red,
    'Education': Colors.indigo,
    'Groceries': Colors.green,
    'Fuel & Gas': Colors.grey.shade700,
    'Coffee & Drinks': Colors.brown,
    'Fitness & Gym': Colors.teal,
    'Beauty & Personal Care': Colors.pinkAccent,
    'Travel': Colors.cyan,
    'Home & Garden': Colors.lightGreen,
    'Technology': Colors.deepPurple,
    'Clothing': Colors.deepOrange,
    'Gifts & Donations': Colors.lime,
    'Insurance': Colors.blueGrey,
    'Subscriptions': Colors.indigo.shade300,
    'Other': Colors.grey,
  };

  static IconData getIcon(String category) => icons[category] ?? Icons.category;
  static Color getColor(String category) => colors[category] ?? Colors.grey;
}
