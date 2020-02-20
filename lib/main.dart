import 'package:flutter/material.dart';
import 'package:tpss_live/show_tournament.dart';
import 'package:tpss_live/simplycompete/eventview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print('[${DateTime.now().millisecondsSinceEpoch}] Starting');
    return MaterialApp(
      title: 'TPSS Live',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: StartPage(),
//      home: RankingView(scEvent: '11ea171f-4c0f-56e0-a3a9-0232a54f5d94'),
//      home: LiveTournament(tournamentKey: '92023433'),
    );
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TPSS Live')),
      body: Container(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('TPSS Live', style: TextStyle(color: Colors.purple[900], fontSize: 35, shadows: [Shadow(color: Colors.white, blurRadius: 15)])),
              decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.rectangle, boxShadow: [BoxShadow(color: Colors.blue[600], blurRadius: 30),BoxShadow(color: Colors.blue[200], blurRadius: 30)]),
            ),
            ListTile(
              leading: Icon(Icons.list, color: Colors.red),
              title: Text('Live tournaments'),
              subtitle: Text('TPSS Live tournaments'),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LiveTournament()));
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.blue),
              subtitle: Text('SimplyCompete events'),
              title: Text('Upcomming events'),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EventView()));//scEvent: '11ea171f-4c0f-56e0-a3a9-0232a54f5d94')));
              },
            ),
          ],
        ),
      ),
    );
  }
}