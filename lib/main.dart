
import 'package:SMSRouter/api.dart';
import 'package:SMSRouter/model/Config.dart';
import 'package:SMSRouter/model/SmsPayload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
final configModel = ConfigModel();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => smsModel),
        ChangeNotifierProvider(create: (_) => configModel),
      ],
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
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(
            builder: (_) => SmsList()
          ));
        },
        tooltip: 'Manual edit',
        child: Icon(Icons.edit),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SmsList extends StatefulWidget {
  @override
  _SmsListState createState() => _SmsListState();
}

class _SmsListState extends State<SmsList> {
  
  @override
  Widget build(BuildContext context) {
    final smsQuery = SmsQuery();
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        brightness: Brightness.light,
      ),
      body: Material(
        child: FutureBuilder(
          future: smsQuery.querySms(
            kinds: [SmsQueryKind.Inbox],
          ),
          builder: (context, AsyncSnapshot<List<SmsMessage>> snapshot) {
            if (snapshot.hasData) {
              final smss = snapshot.data.where((sms) {
                return RegExp(r'' + configModel.config.transactionMoney + '').hasMatch(sms.body) &&
                  RegExp(r'' + configModel.config.balance + '').hasMatch(sms.body) &&
                  sms.address == configModel.config.senderAddress;
              }).toList();
              print('Total length: ${smss.length}');
              return ListView.builder(
                itemCount: smss.length,
                itemBuilder: (context, index) {
                  final sent = Provider.of<SmsModel>(context).payloads.firstWhere((payload) =>
                  payload.smsBody == smss[index].body, orElse: () => null) == null;
                  return InkWell(
                    onTap: () {},
                    child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actions: <Widget>[
                        IconSlideAction(
                          caption: 'Send',
                          color: Colors.blue,
                          icon: Icons.send,
                          onTap: () async {
                            await Api.submit(await SmsPayload.from(smss[index].body));
                            setState(() {

                            });
                          },
                        ),
                      ],
                      child: ListTile(
                        title: Text('${smss[index].body}'),
                        subtitle: Text(smss[index].dateSent.toIso8601String()),
                        trailing: sent
                          ? Text('')
                          : Icon(Icons.check_circle),
                      ),
                    ),
                  );
                }
              );
              return Text('Sms count: ${smss.length}, ${smss[0].body}');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
