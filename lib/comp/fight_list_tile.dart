import 'package:flag/flag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_live/comp/fights.dart';

class FightListTile extends StatelessWidget {
  final Fight fight;
  const FightListTile({this.fight, Key key}) : super(key: key);
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
  @override
  Widget build(BuildContext context) {
    try{
      final score=fight.score.split('-');
      return Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 1, horizontal: fight.isFavorite? 0:6),
        color: (fight.className[1]=='F')?Colors.red[colorGradient[fight.className[0]]]:Colors.blue[colorGradient[fight.className[0]]],
        child: Container(
          padding: EdgeInsets.all(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                color: (fight.isFavoriteClass)?Colors.black : Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: fight.isFavoriteClass?6:0, horizontal: 2),
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
                  padding: fight.isFavoriteChong? EdgeInsets.symmetric(vertical: 6) : EdgeInsets.all(0),
                  constraints: BoxConstraints(maxHeight: double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(alignment: Alignment.center, margin: EdgeInsets.only(right: 3), width: 20, height: 20, color: Colors.white, child: Text(score[0], style: TextStyle(color: Colors.blue[900], fontSize: 15, fontWeight: FontWeight.bold))),
                          Expanded(
                            child: Text(fight.chong, style: textListItemMain, overflow: TextOverflow.ellipsis,),
                          )
                        ]
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          fight.chongCountry.isNotEmpty?_fetchFlag(fight.chongCountry):Container(height:15),
                          Expanded(child: Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Text(fight.chongClub, overflow: TextOverflow.clip, style: textListItemSub, softWrap: false,),
                          ))
                        ]
                      )
                    ],
                  )
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.red[900],
                  padding: fight.isFavoriteHong? EdgeInsets.symmetric(vertical: 6) : EdgeInsets.all(0),
                  constraints: BoxConstraints(maxHeight: double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(child: Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Text(fight.hong, style: textListItemMain, overflow: TextOverflow.ellipsis,),
                          )),
                          Container(alignment: Alignment.center, width: 20, height: 20, color: Colors.white, child: Text(score[1], style: TextStyle(color: Colors.red[900], fontSize: 15, fontWeight: FontWeight.bold)))
                        ]
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(child: Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Text(fight.hongClub, overflow: TextOverflow.clip, style: textListItemSub, softWrap: false),
                          ),),
                          fight.hongCountry.isNotEmpty?_fetchFlag(fight.hongCountry):Container(height:15),
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
    }catch(ex){
      print('[${DateTime.now().millisecondsSinceEpoch}] Error creating tile: $ex => $fight');
    }
    return null;
  }
}