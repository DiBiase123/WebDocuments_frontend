class ResetValidators {
  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Inserisci password';
    if (v.length < 8) return 'Minimo 8 caratteri';
    return null;
  }

  static String? validateConfirmPassword(String? v, String password) {
    if (v == null || v.isEmpty) return 'Conferma password';
    if (v != password) return 'Le password non coincidono';
    return null;
  }
}
