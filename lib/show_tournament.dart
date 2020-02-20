import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tpss_live/comp/fight_list_tile.dart';
import 'package:tpss_live/comp/fights.dart';
import 'package:tpss_live/comp/match_filter.dart';
import 'package:tpss_live/comp/tournament.dart';
import 'package:tpss_live/comp/alert_input.dart';
import 'package:tpss_live/filtering.dart';

class LiveTournament extends StatefulWidget {
  const LiveTournament({Key key, this.tournamentKey}) : super(key: key);
  final String tournamentKey;

  @override
  LiveTournamentState createState() => LiveTournamentState();
}

enum PopupCommands{
  AUTO_UPDATE,
  ADD_TOURNAMENT
}
class LiveTournamentState extends State<LiveTournament> {
  final fights=List<Fight>();
  FilterConfig filterConfig;
  bool _autoUpdate=false;
  final tournaments=List<Tournament>();
  Tournament _selectedTournament;
  String _myCookie;
  final loading=ValueNotifier<bool>(false);
  final updater=ValueNotifier(0);
  final tournamentVersion=ValueNotifier(0);
  Future<void> _updateActiveTournaments() async{
    loading.value=true;
    final startTime=DateTime.now().millisecondsSinceEpoch;
    try {
      Response response=await get("https://tpss.eu/liveresults.asp?AR=1");
      print('[${DateTime.now().millisecondsSinceEpoch}] Downloaded new tournaments: ${response.body.length} bytes in ${DateTime.now().millisecondsSinceEpoch-startTime} ms, ${response.headers}');
      if(response.headers.containsKey('set-cookie')) _myCookie=response.headers['set-cookie'];
      var activeTournamentOption=RegExp(r"(?<=cmbToer)[^<]*(.*?)[^>]*<\/SELE", dotAll: true).firstMatch(response.body);
      print('[${DateTime.now().millisecondsSinceEpoch}] Active: ${activeTournamentOption[1]}');
      var activeTournaments=RegExp(r"(?<=OPTION)[^\']*\'(?<key>\d{8})[^>]*>(?<name>[^<]*)[^<\s]*", dotAll: true).allMatches(activeTournamentOption[1]).map((match)=> Tournament(match.namedGroup("name"), match.namedGroup("key"))).where((tour)=>!tour.name.toLowerCase().contains("poomsa"));
      var newTournaments=activeTournaments.where((selected)=>!tournaments.contains(selected.key));
      print('[${DateTime.now().millisecondsSinceEpoch}] New tournaments: $newTournaments');
      if(newTournaments.isNotEmpty){
        tournaments.addAll(newTournaments);
        tournamentVersion.value++;
      }
      print('[${DateTime.now().millisecondsSinceEpoch}] tournament: ${tournaments.length}');
      if(widget.tournamentKey.isNotEmpty) _selectedTournament = tournaments.firstWhere((element) => element.key == widget.tournamentKey, orElse: (){
        final t=Tournament(widget.tournamentKey, widget.tournamentKey);
        tournaments.add(t);
        return t;
      });
      if(_selectedTournament!=null) _refreshTournamentInfo(true);
      print('[${DateTime.now().millisecondsSinceEpoch}] Selected tournament: $_selectedTournament');
    } catch (err) {
      print('[${DateTime.now().millisecondsSinceEpoch}] Error fetching URL: $err');
    }
    loading.value=false;
  }
  void _loadInitial() async{
    await _readFilter();
    print('[${DateTime.now().millisecondsSinceEpoch}] Config loaded: $filterConfig');
    _updateActiveTournaments();
  }
  Future<String> _postInfo(String key) async{
    final startTime=DateTime.now().millisecondsSinceEpoch;
    print('[${DateTime.now().millisecondsSinceEpoch}] _postInfo($key)');
    try {
      Response response=await post("https://tpss.eu/LiveResults.asp", headers: {'content-type':'application/x-www-form-urlencoded', 'cookie': _myCookie}, body: {'cmbToernooi':key});
      if(response.headers.containsKey('set-cookie')) _myCookie=response.headers['set-cookie'];
      print('[${DateTime.now().millisecondsSinceEpoch}] Downloaded: ${response.body.length} bytes in ${DateTime.now().millisecondsSinceEpoch-startTime} ms');
      return response.body;
    } catch (err, s) {
      print('[${DateTime.now().millisecondsSinceEpoch}] Error: $err, $s');
      throw err;
    }
  }
  void _refreshTournamentInfo(bool changed) async{
    print('[${DateTime.now().millisecondsSinceEpoch}] _refreshTournamentInfo($changed)-$_selectedTournament');
    loading.value=true;
    var resp=await _postInfo(_selectedTournament.key);
    if(changed){         // Changed tournament so need to clear the list
      fights.clear();
      if(!_selectedTournament.hasReadHTML){
        _selectedTournament.fromHTML(resp);
        print('[${DateTime.now().millisecondsSinceEpoch}] Tournament read: isLive: ${_selectedTournament.isLiveToday}');
      }else print('[${DateTime.now().millisecondsSinceEpoch}] Allready fetch TournamentInfo, isLive: ${_selectedTournament.isLiveToday}');
    }
    print('[${DateTime.now().millisecondsSinceEpoch}] Lengde: ${resp.length} bytes');
    if(resp.indexOf("Table4")>0){
      print('[${DateTime.now().millisecondsSinceEpoch}] Is config null: $filterConfig');
      var mat=Fight.fromHTML(resp, filterConfig);
      int iPrev=mat.length;
      mat.removeWhere((element) => element.fightMatch == FightMatch.HIDE);
      print('[${DateTime.now().millisecondsSinceEpoch}] New fights: ${mat.length} / $iPrev => removed: ${iPrev-mat.length}');
      if(fights.length<1) fights.addAll(mat);
      else{
        print('[${DateTime.now().millisecondsSinceEpoch}] Just updating...');
        var nyListe=mat.where((f)=>!fights.any((e)=>e.roundNo.contains(f.roundNo)));
        print('[${DateTime.now().millisecondsSinceEpoch}] New list: $nyListe');
      }
    }else print('[${DateTime.now().millisecondsSinceEpoch}] !!! ERROR: no TABLE4: $resp');     // The HTML received are not valid
    updater.value++;
    loading.value=false;
    if(_autoUpdate) Future.delayed(Duration(seconds: 30), (){ if(_autoUpdate) _refreshTournamentInfo(false); });
  }
  @override
  void initState() { 
    super.initState();
    _loadInitial();
    print('[${DateTime.now().millisecondsSinceEpoch}] initState finished');
  }
  _readFilter() async {
    filterConfig=await FilterConfig.loadConfig();
    if(filterConfig!=null){
      print('[${DateTime.now().millisecondsSinceEpoch}] Config loaded: $filterConfig');
      if(updater.value>0) updater.value++;
    }else print('[${DateTime.now().millisecondsSinceEpoch}] No default filter exist');
  }
  _toggleAutoUpdate(){
    _autoUpdate=!_autoUpdate;
    print('[${DateTime.now().millisecondsSinceEpoch}] Toggling autoupdate $_autoUpdate');
    if(_autoUpdate) _refreshTournamentInfo(false);
  }
  _fetchNewTournament() async{
    final String response = await asyncInputDialog(context);
    print("[${DateTime.now().millisecondsSinceEpoch}] fetchNewTournament $response" );
  }
  List<Widget> _actionWidgets(){
    return [
      CircularProgressIndicator(),
      ValueListenableBuilder(
        valueListenable: loading,
        builder: (BuildContext context, dynamic value, _) {
          return Row(
            children: [
              IconButton(icon: Icon(value?Icons.arrow_downward:Icons.refresh), onPressed: (value || _selectedTournament==null || !_selectedTournament.isLiveToday)?null:(){ _refreshTournamentInfo(false); }),
              value? Container():IconButton(icon: Icon(Icons.filter_list), onPressed: value?null:(){Navigator.push(context, MaterialPageRoute(builder: (context)=>FilterMatches()));})
            ]
          );
        },
      ),
      PopupMenuButton(
        onSelected: (PopupCommands command){
          switch (command) {
            case PopupCommands.AUTO_UPDATE:
              _toggleAutoUpdate();
              break;
            case PopupCommands.ADD_TOURNAMENT:
              _fetchNewTournament();
              break;
            default:
              print('[${DateTime.now().millisecondsSinceEpoch}] ERR: Not handled command $command');
          }
        },
        itemBuilder: (BuildContext context){
          return [
            CheckedPopupMenuItem(
              value: PopupCommands.AUTO_UPDATE,
              checked: _autoUpdate,
              child: Text('Auto refresh'),
            ),
            CheckedPopupMenuItem(
              value: PopupCommands.ADD_TOURNAMENT,
              checked: false,
              child: Text('Add tournament'),
            ),
          ];
        }
      )
    ];
  }
  Widget _fetchTournamentDropDown(){
    return DropdownButton<Tournament>(
      isExpanded: true,
      items: tournaments.map((t)=>DropdownMenuItem<Tournament>(value: t, child: Text(" ${t.name}", overflow: TextOverflow.clip, softWrap: false,))).toList(),
      value: _selectedTournament,
      onChanged: (selected){
        _selectedTournament=selected;
        _refreshTournamentInfo(true);
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    print('[${DateTime.now().millisecondsSinceEpoch}] LiveTournament-build()');
    return Scaffold(
      appBar: AppBar(title: Text('TPSS Live'),actions: _actionWidgets(),),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable:  loading,
              builder: (BuildContext context, dynamic value, Widget child) {
                return loading.value?CircularProgressIndicator() :
                _fetchTournamentDropDown();
              },
            ),
            Expanded(child: ValueListenableBuilder(
              valueListenable: updater,
              builder: (BuildContext context, dynamic value, Widget child) {
                return ListView.builder(itemCount: fights.length, itemBuilder: (x,index) => FightListTile(fight: fights[index]));
              },
            ))
          ]
        )
      ),
    );
  }
}