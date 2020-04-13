import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ConfigModel with ChangeNotifier {
  ConfigModel() {
    init();
  }

  Config _config = Config();

  init() async {
    final mapping = await rootBundle.loadString('assets/sms_mapping.json');
    final json = jsonDecode(mapping);
    this._config = Config.fromJson(json);
  }

  Config get config => _config;
  set config(Config config) {
    this.config = config;
    this.notifyListeners();
  }
}

class Config {
  String api;
  String transactionMoney;
  String balance;
  String senderAddress;

  Config({this.api, this.transactionMoney, this.balance, this.senderAddress});

  Config.fromJson(Map<String, dynamic> json) {
    api = json['api'];
    transactionMoney = json['transactionMoney'];
    balance = json['balance'];
    senderAddress = json['senderAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['api'] = this.api;
    data['transactionMoney'] = this.transactionMoney;
    data['balance'] = this.balance;
    data['senderAddress'] = this.senderAddress;
    return data;
  }
}
