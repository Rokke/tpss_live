import 'package:flag/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_live/simplycompete/model/fighter.dart';

class FighterListTile extends StatelessWidget {
  final Fighter fighter;
  final int index;
  final Function (int) action;
  final Animation animation;
  const FighterListTile({this.fighter, this.index, this.action, this.animation, Key key}) : super(key: key);
  static const Map<String,int> colorGradient={'Y': 100, 'P': 200, 'C': 300, 'J': 500, 'S': 700, 'V': 900};
  static const TextStyle textListItemMain=TextStyle(color: Colors.white, fontSize: 12);
  static const TextStyle textListItemSub=TextStyle(color: Colors.white, fontSize: 10);
  static const TextStyle textListLeadingMain=TextStyle(color: Colors.lime, fontSize: 13, fontWeight: FontWeight.bold);
  static const TextStyle textListLeadingSub=TextStyle(color: Colors.white, fontSize: 10);

  String _fetch2CharacterCountryCode(String countrycode){
    switch (countrycode) {
      case 'BIH': return 'BA';
      case 'BLR': return 'BY';
      case 'BUL': return 'BG';
      case 'GER': return 'DE';
      case 'SER': return 'RS';
      case 'SVN': return 'SI';
      case 'SWE': return 'SE';
      case 'TUN': return 'TN';
      case 'TUR': return 'TR';
      case 'UAE': return 'AE';
      default: return countrycode.substring(0,2);
    }
  }
  Widget _safeFetchFlag(String country){
    try{
      return Flags.getMiniFlag(_fetch2CharacterCountryCode(country), 15, 21);
    }catch(ex){
      print('[${DateTime.now().millisecondsSinceEpoch}] Unknown country: $country');
      return Icon(Icons.error_outline);
    }
  }
  Widget _fetchFlag(String country){
    return Tooltip(
      message: country,
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: _safeFetchFlag(country),
      )
    );
  }
  Widget _fetchRankings(Fighter fighter){
    List<Widget> olympic, world;
    if(fighter.olympic!=null) olympic=fighter.olympic.isEmpty? [Text('No OL rank')] : fighter.olympic.map((e) => Text('OL(${e.rank}): ${e.division} - ${e.totalPoints}')).toList();
    if(fighter.world!=null) world=fighter.world.isEmpty? [Text('No WC rank')] : fighter.world.map((e) => Text('WC(${e.rank}): ${e.division} - ${e.totalPoints}')).toList();
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(child: Card(margin: EdgeInsets.all(1), elevation: 2, color: Colors.green, child: Column(children: olympic!=null?olympic:[Text(' ...fetching ')]))),
        Expanded(child: Card(margin: EdgeInsets.all(1), elevation: 2, color: Colors.greenAccent, child: Column(children: world!=null?world:[Text(' ...fetching ')]))),
      ],
    );
  }
  _removeItem(DragEndDetails ind){
    action(index);
  }
  @override
  Widget build(BuildContext context) {
    try{
      return SizeTransition(sizeFactor: animation, child: GestureDetector(
        onHorizontalDragEnd: (ind)=> _removeItem(ind),
        child: Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 1, horizontal: 6),
          color: Colors.purple[700],
          child: Container(
            padding: EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("${index+1} - ${fighter.preferredName}", style: textListLeadingMain),
                _fetchRankings(fighter)              
              ]
            )
          )
        ),
      ));
    }catch(ex){
      print('[${DateTime.now().millisecondsSinceEpoch}] Error creating tile: $ex => $fighter');
    }
    return null;
  }
}