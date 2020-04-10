import 'dart:convert';

import 'package:SMSRouter/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsModel with ChangeNotifier {
  SmsModel() {
    _init();
  }

  void _init() async {
    final preferences = await SharedPreferences.getInstance();
    List<String> payloads = preferences.getStringList(SmsPayload.savedKey);
    if (payloads != null) {
      this.payloads = payloads.map((str) => SmsPayload.fromJson(jsonDecode(str))).toList();
    }
  }

  final List<SmsPayload> _payloads = [];

  List<SmsPayload> get payloads => _payloads;

  void add(SmsPayload payload) {
    _payloads.add(payload);
    notifyListeners();
    save();
  }

  void save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      SmsPayload.savedKey, _payloads.map((p) => jsonEncode(p.toJson())).toList());
  }

  set payloads(List<SmsPayload> payloads) {
    this._payloads.addAll(payloads);
    this.notifyListeners();
    save();
  }

  void removeAll() {
    _payloads.clear();
    notifyListeners();
    save();
  }
}

class SmsPayload {
  DateTime date;
  String smsBody;
  String transactionAmount;
  String balance;

  SmsPayload(this.date, this.smsBody, this.transactionAmount, this.balance);
  SmsPayload._();

  static String savedKey = 'smsPayloads';

  /// Nullable
  static Future<SmsPayload> from(String sms) async {
    final mapping = await rootBundle.loadString('assets/sms_mapping.json');
    final json = jsonDecode(mapping);
    final transactionRegex = json['transactionMoney'];
    final balanceRegex = json['balance'];
    final transactionMoney = RegExp(r'' + transactionRegex + '').firstMatch(sms)?.group(1);
    final balance = RegExp(r'' + balanceRegex + '').firstMatch(sms)?.group(1);
    if (transactionMoney == null || balance == null) return null;
    return SmsPayload(DateTime.now(), sms, transactionMoney, balance);
  }

  factory SmsPayload.fromJson(Map<String, dynamic> json) {
    return SmsPayload._()
      ..date = DateTime.parse(json['date'])
      ..smsBody = json['smsBody']
      ..transactionAmount = json['transactionAmount']
      ..balance = json['balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date.toUtc().toIso8601String();
    data['smsBody'] = this.smsBody;
    data['transactionAmount'] = this.transactionAmount;
    data['balance'] = this.balance;
    return data;
  }

  String toParams() {
    return '?date=${date.toIso8601String()}&smsBody=$smsBody&transactionAmount=$transactionAmount&balance=$balance';
  }




}