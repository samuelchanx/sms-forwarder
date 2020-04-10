
import 'package:SMSRouter/api.dart';
import 'package:SMSRouter/model/SmsPayload.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_maintained/sms.dart';

void main() {
  runApp(MyApp());
  SmsReceiver receiver = SmsReceiver();
  receiver.onSmsReceived.listen((SmsMessage msg) async {
    final smsPayload = await SmsPayload.from(msg.body);
    if (smsPayload != null) {
      await Api.submit(smsPayload);
      smsModel.add(smsPayload);
    }
  });
}

final globalKey = GlobalKey<NavigatorState>();
final smsModel = SmsModel();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => smsModel,
      child: MaterialApp(
        title: 'Sms Forwarder',
        navigatorKey: globalKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Sms Forwarder'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  /// testing
  void init() async {
    final sms =
        await SmsPayload.from('xxxxxxx');
    if (sms != null) {
      await Api.submit(sms);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sms Forwarder', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        brightness: Brightness.light,
      ),
      body: Container(
        color: Colors.white,
        child: Consumer<SmsModel>(
          builder: (context, model, child) {
            return ListView.builder(
                itemCount: model.payloads.length,
                itemBuilder: (BuildContext context, int index) {
                  final payload = model.payloads[index];
                  return ListTile(
                    title: Text('test, ${payload.transactionAmount}'),
                    trailing: Text('test, ${payload.date.toIso8601String()}'),
                  );
                });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
