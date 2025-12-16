import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove all non-digit characters
    String digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 8 digits (DDMMYYYY)
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }
    
    String formatted = '';
    
    // Add day (DD)
    if (digitsOnly.isNotEmpty) {
      formatted += digitsOnly.substring(0, digitsOnly.length >= 2 ? 2 : digitsOnly.length);
      
      // Add first slash after day
      if (digitsOnly.length >= 2) {
        formatted += '/';
        
        // Add month (MM)
        formatted += digitsOnly.substring(2, digitsOnly.length >= 4 ? 4 : digitsOnly.length);
        
        // Add second slash after month
        if (digitsOnly.length >= 4) {
          formatted += '/';
          
          // Add year (YYYY)
          formatted += digitsOnly.substring(4);
        }
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
