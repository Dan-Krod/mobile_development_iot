class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть повне ім’я';
    }
    if (RegExp(r'[0-9]').hasMatch(value)) {
      return 'Ім’я не може містити цифри';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть Email';
    }
    if (!value.contains('@')) {
      return 'Email має містити символ @';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть ключ безпеки';
    }
    if (value.length < 6) {
      return 'Ключ має бути не менше 6 символів';
    }
    return null;
  }
}
