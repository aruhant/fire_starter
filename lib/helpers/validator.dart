import 'package:fire_starter/localizations.dart';

// matching various patterns for kinds of data

class Validator {
  AppLocalizationsData labels;
  Validator(this.labels);

  String? email(String? value) {
    if (value == null) value = '';
    String pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return labels.validator.email;
    else
      return null;
  }

  String? password(String? value) {
    if (value == null) value = '';
    String pattern = r'^.{6,}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return labels.validator.password;
    else
      return null;
  }

  String? name(String? value) {
    if (value == null) value = '';
    String pattern = r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return labels.validator.name;
    else
      return null;
  }

  String? phoneNumber(String? value) {
    if (value == null) value = '';
    String pattern = r'^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return labels.validator.number;
    else
      return null;
  }

  String? number(String? value) {
    if (value == null) value = '';
    String pattern = r'^\d+$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return labels.validator.amount;
    else
      return null;
  }

  String? notEmpty(String? value) {
    if (value == null) value = '';
    String pattern = r'^\S+$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return labels.validator.notEmpty;
    else
      return null;
  }
}
