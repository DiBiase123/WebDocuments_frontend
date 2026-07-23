class LoginValidators {
  static bool isValidEmail(String email) => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);

  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Inserisci e-mail';
    if (!isValidEmail(v.trim())) return 'Formato e-mail errato';
    return null;
  }

  static String? validatePassword(String? v) =>
      (v == null || v.isEmpty) ? 'Inserisci password' : null;
}
