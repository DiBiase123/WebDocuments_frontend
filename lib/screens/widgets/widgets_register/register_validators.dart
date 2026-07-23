class RegisterValidators {
  static bool isValidEmail(String email) => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);

  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Inserisci e-mail';
    if (!isValidEmail(v.trim())) return 'Formato e-mail errato';
    return null;
  }

  static String? validateUsername(String? v) {
    if (v == null || v.trim().isEmpty) return 'Inserisci username';
    if (v.trim().length < 3) return 'Minimo 3 caratteri';
    return null;
  }

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
