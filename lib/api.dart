import 'dart:convert';

import 'package:SMSRouter/main.dart';
import 'package:SMSRouter/model/SmsPayload.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Api {
  static Future<Response> submit(SmsPayload payload) async {
    final mapping = await rootBundle.loadString('assets/sms_mapping.json');
    final url = jsonDecode(mapping)['api'];
    final response = await Dio().get(url,
      queryParameters: {
        'date': DateFormat('yyyy-MM-dd HH:mm').format(payload.date),
        'smsBody': payload.smsBody,
        'transactionAmount': payload.transactionAmount,
        'balance': payload.balance
      });

    print(response.data);
    if (response.data['status'] == 'SUCCESS') {
      smsModel.add(payload);
    }
    return response;
  }
}