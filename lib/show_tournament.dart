//import 'dart:io';
//import 'package:dio/dio.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tpss_live/comp/fights.dart';
import 'package:tpss_live/comp/tournament.dart';

class LiveTournament extends StatefulWidget {
  final String tournamentKey;
  LiveTournament({Key key, @required this.tournamentKey}) : super(key: key);

  @override
  LiveTournamentState createState() => LiveTournamentState();
}

class LiveTournamentState extends State<LiveTournament> {
  final Map<String,int> colorGradient={'Y': 100, 'P': 200, 'C': 300, 'J': 500, 'S': 700, 'V': 900};
  final TextStyle textListItemMain=TextStyle(color: Colors.white, fontSize: 12);
  final TextStyle textListItemSub=TextStyle(color: Colors.white, fontSize: 10);
  final TextStyle textListLeadingMain=TextStyle(color: Colors.white, fontSize: 12, backgroundColor: Colors.purple);
  final TextStyle textListLeadingSub=TextStyle(color: Colors.white, fontSize: 10);
  final fights=List<Fight>();
  final tournaments=List<Tournament>();
  String _selectedTournament;
  String _myCookie;
  final loading=ValueNotifier<bool>(false);
  final updater=ValueNotifier(0);
  final tournamentVersion=ValueNotifier(0);
  Future<void> _updateActiveTournaments() async{
    loading.value=true;
    final startTime=DateTime.now().millisecondsSinceEpoch;
    Response response=await get("https://tpss.eu/liveresults.asp?AR=1");
    print('Downloaded new tournaments: ${response.body.length} bytes in ${DateTime.now().millisecondsSinceEpoch-startTime} ms, ${response.headers}');
    if(_myCookie==null) _myCookie=response.headers['set-cookie'];
    var activeTournamentOption=RegExp(r"(?<=cmbToer)[^<]*(.*?)[^>]*<\/SELE", dotAll: true).firstMatch(response.body);
    print('Active: ${activeTournamentOption[1]}');
    var activeTournaments=RegExp(r"(?<=OPTION)[^\']*\'(?<key>\d{8})[^>]*>(?<name>[^<]*)[^<\s]*", dotAll: true).allMatches(activeTournamentOption[1]).map((match)=> Tournament(match.namedGroup("name"), match.namedGroup("key"))).where((tour)=>!tour.name.toLowerCase().contains("poomsa"));
    var newTournaments=activeTournaments.where((selected)=>!tournaments.contains(selected.key));
    print('Nye turneringer: $newTournaments');
    if(newTournaments.isNotEmpty){
      tournaments.addAll(newTournaments);
      tournamentVersion.value++;
    }
    loading.value=false;
  }
  Future<String> _postInfo(String key) async{
    final startTime=DateTime.now().millisecondsSinceEpoch;
    print('_postInfo($key)');
    try {
      Response response=await post("https://tpss.eu/LiveResults.asp", headers: {'content-type':'application/x-www-form-urlencoded', 'cookie': _myCookie}, body: {'cmbToernooi':key});
      print('Downloaded: ${response.body.length} bytes in ${DateTime.now().millisecondsSinceEpoch-startTime} ms');
      return response.body;
    } catch (err, s) {
      print('Error: $err, $s');
      throw err;
    }
  }
  void _refreshTournamentInfo(String tournamentKey) async{
    if(tournamentKey!=_selectedTournament){
      _selectedTournament=tournamentKey;
      fights.clear();
    }
    loading.value=true;
    var resp=await _postInfo(tournamentKey);
    print('Lengde: ${resp.length} bytes');
    if(resp.indexOf("Table4")>0){
      resp=resp.substring(resp.indexOf("Table4")).split('\r\n')[1]+"<TR b";
      RegExp rx=RegExp(r"(?<=TR bg)[^>]*>(.*?)<TR b", multiLine: true, dotAll: true);
      print("Fights: ${resp.length} bytes");
      var mat=rx.allMatches(resp).toList().map((f)=> Fight.fromRegex(f[1]));
      print('Matches: ${mat.length} treff');
      if(fights.length<1) fights.addAll(mat);
      else{
        print('Just updating...');
        var nyListe=mat.where((f)=>!fights.any((e)=>e.roundNo.contains(f.roundNo)));
        print('Ny liste: $nyListe');
      }
    }else print('!!! ERROR: no TABLE4: $resp');
    updater.value++;
    loading.value=false;
  }
  @override
  void initState() { 
    super.initState();
    _selectedTournament=widget.tournamentKey;
    _updateActiveTournaments();
    print('initState finished');
  }
  String _fetch2CharacterCountryCode(String countrycode){
    switch (countrycode) {
      case 'BLR': return 'BY';
      default: return countrycode.substring(0,2);
    }
  }
  Widget _fetchFlag(String country){
    return Tooltip(
          message: country,
          child: Flags.getMiniFlag(_fetch2CharacterCountryCode(country), 15, 21)
    );
  }
  Card _listTileBuilder(Fight fight){
    final score=fight.score.split('-');
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(3),
      color: (fight.className[1]=='F')?Colors.red[colorGradient[fight.className[0]]]:Colors.blue[colorGradient[fight.className[0]]],
      child: Container(
        padding: EdgeInsets.all(6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              color: Colors.deepPurple,
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${fight.roundNo}", style: textListLeadingMain),
                  Text("${fight.className}", style: textListLeadingSub),
                  Text("${fight.result}", style: textListLeadingSub)
                ]
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.blue[900],
                constraints: BoxConstraints(maxHeight: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(alignment: Alignment.center, width: 20, height: 20, color: Colors.white, child: Text(score[0], style: TextStyle(color: Colors.blue[900], fontSize: 15, fontWeight: FontWeight.bold))),
                        Center(child: Text(fight.chong, style: textListItemMain,))
                      ]
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _fetchFlag(fight.chongCountry),
                        Expanded(child: Text(fight.chongClub, overflow: TextOverflow.clip, style: textListItemSub, softWrap: false,))
                      ]
                    )
                  ],
                )
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.red[900],
                constraints: BoxConstraints(maxHeight: double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: Text(fight.hong, style: textListItemMain,)),
                        Container(alignment: Alignment.center, width: 20, height: 20, color: Colors.white, child: Text(score[1], style: TextStyle(color: Colors.red[900], fontSize: 15, fontWeight: FontWeight.bold)))
                      ]
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _fetchFlag(fight.hongCountry),
                        Expanded(child: Text(fight.hongClub, overflow: TextOverflow.clip, style: textListItemSub, softWrap: false),)
                      ]
                    )
                  ],
                )
              ),
            ),
          ]
        )
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    print('build');
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable:  loading,
            builder: (BuildContext context, dynamic value, Widget child) {
              return loading.value?CircularProgressIndicator() :
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(child: Text(_selectedTournament), onPressed: () {_refreshTournamentInfo(widget.tournamentKey);},color: Colors.blue),
                  Expanded(child: DropdownButton<String>(isExpanded: true, items: tournaments.map((t)=>DropdownMenuItem<String>(value: t.key, child: Text("${t.name}", overflow: TextOverflow.clip, softWrap: false,))).toList(), onChanged: (selectedTournament)=>_refreshTournamentInfo(selectedTournament)))
                ],
              );
            },
          ),
          Expanded(child: ValueListenableBuilder(
            valueListenable: updater,
            builder: (BuildContext context, dynamic value, Widget child) {
              return ListView.builder(itemCount: fights.length, itemBuilder: (x,index) => _listTileBuilder(fights[index]));
            },
          ))
        ])
      );
  }
}