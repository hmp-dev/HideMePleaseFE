class TranslationHelper {
  static String extractEnglishFromCombinedText(String? combinedText) {
    if (combinedText == null || combinedText.isEmpty) {
      return '';
    }

    // Check if text contains comma (indicating Korean, English format)
    if (combinedText.contains(',')) {
      // Split by comma and take the second part (English)
      final parts = combinedText.split(',');
      if (parts.length >= 2) {
        // Return the English part, trimmed
        return parts.sublist(1).join(',').trim();
      }
    }

    // If no comma found, return original text
    return combinedText;
  }

  static String getBenefitDescriptionForLocale({
    required String? benefitDescription,
    required String? benefitDescriptionEn,
    required bool isEnglish,
  }) {
    if (!isEnglish) {
      // For Korean, return the original description or extract Korean part
      if (benefitDescription == null || benefitDescription.isEmpty) {
        return '';
      }
      // If it contains comma, return only Korean part
      if (benefitDescription.contains(',')) {
        return benefitDescription.split(',').first.trim();
      }
      return benefitDescription;
    }

    // For English
    // First try the dedicated English field
    if (benefitDescriptionEn != null && benefitDescriptionEn.isNotEmpty) {
      return benefitDescriptionEn;
    }

    // If English field is empty, try to extract from combined field
    return extractEnglishFromCombinedText(benefitDescription);
  }
}