import 'package:flutter/material.dart';

class AppColors {
  // Modern primary colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  // Background & Surface colors
  static const Color background = Color(0xFFFAFBFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFF8FAFF);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFF3F4F6);
  
  // Financial colors
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFF43F5E);
  static const Color savings = Color(0xFF06B6D4);
  static const Color investment = Color(0xFF8B5CF6);
  
  // Accent colors
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFEAB308);
  static const Color accentBlue = Color(0xFF0EA5E9);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentOrange = Color(0xFFF97316);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );
  
  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF22D3EE)],
  );
  
  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
  );
  
  static const LinearGradient savingsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
  );
  
  static const LinearGradient investmentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
  );
  
  // Category colors
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFFF97316),
    'transport': Color(0xFF3B82F6),
    'shopping': Color(0xFF8B5CF6),
    'health': Color(0xFFEF4444),
    'entertainment': Color(0xFFEC4899),
    'bills': Color(0xFF06B6D4),
    'others': Color(0xFF6B7280),
  };
  
  static const Map<String, IconData> categoryIcons = {
    'food': Icons.restaurant_rounded,
    'transport': Icons.directions_car_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'health': Icons.medical_services_rounded,
    'entertainment': Icons.movie_rounded,
    'bills': Icons.receipt_long_rounded,
    'others': Icons.shopping_cart_rounded,
  };
}