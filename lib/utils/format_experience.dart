  String getExperience(int minExpMonths, int maxExpMonths, String label) {
    
    String minExp = (minExpMonths / 12).toStringAsFixed(1);
    String maxExp = (maxExpMonths / 12).toStringAsFixed(1);

    if (maxExpMonths != 0) {
      return '$label: $minExp to $maxExp yrs';
    } else {
      return '$label: $minExp yrs';
    }
  }