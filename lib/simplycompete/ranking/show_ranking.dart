import 'package:flutter/material.dart';
import 'package:tpss_live/simplycompete/ranking/fighter_list_tile.dart';
import 'package:tpss_live/simplycompete/model/fighter.dart';
import 'package:tpss_live/simplycompete/repo.dart';

class RankingView extends StatefulWidget {
  const RankingView({Key key, this.scEvent}) : super(key: key);
  final String scEvent;

  @override
  _RankingViewState createState() => _RankingViewState();
}
class DropDownDivisionItem{
  final String key;
  final String value;
  const DropDownDivisionItem(this.key, this.value);
}
class _RankingViewState extends State<RankingView> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final fighters=List<Fighter>();
  final _divisions=List<DropDownDivisionItem>();
  final _loadingDivisions=ValueNotifier<bool>(false);
  final fighterCount=ValueNotifier(0);
  _fetchAthletes(String scEvent, String scNode) async {
    fighters.forEach((index)=>_listKey.currentState.removeItem(0, (BuildContext context, Animation <double> animation){ return Container();}));
    fighters.clear();
    try{
      int pageNo=0;
      int participantTotalCount=0;
      do{
        final jsonData=await SimplyCompete.fetchJSONResponse(SimplyCompeteURL.fetchSCParticipants(scEvent, scNode ,pageNo));
        if(jsonData!=null && jsonData['data']!=null){
          if(participantTotalCount==0) participantTotalCount=jsonData['data']['data']['participantTotalCount'];
          if(jsonData['data']['data']!=null && jsonData['data']['data']['participantList']!=null){
            final jsonFighters=(jsonData['data']['data']['participantList'] as List<dynamic>).map((e) => Fighter.fromJson(e)).toList();
            for(Fighter jsonFighter in jsonFighters){
              await _updateRanking(jsonFighter);
              double worldRanking=jsonFighter.worldPoints;
              int pos=fighters.indexWhere((element) => worldRanking>element.worldPoints);
              if(pos>=0) fighters.insert(pos, jsonFighter);
              else fighters.add(jsonFighter);
              _listKey.currentState.insertItem(pos>=0?pos:fighters.length-1);
            }
          }
          pageNo++;
          print('[${DateTime.now().millisecondsSinceEpoch}] Fetched: ${fighters.length} of $participantTotalCount');
          fighterCount.value=fighters.length;
          await Future.delayed(Duration(seconds: 2));
        }else pageNo=99;
      }while(pageNo*10<participantTotalCount && pageNo<10);
      print('[${DateTime.now().millisecondsSinceEpoch}] Finished: $participantTotalCount, $pageNo');
    }catch(ex){
      print("[${DateTime.now().millisecondsSinceEpoch}] _fetchAthletes ex: $ex");
      throw ex;
    }
  }
  _updateRanking(Fighter fi) async {
    final jsonData=await SimplyCompete.fetchJSONResponse(SimplyCompeteURL.fetchSCAthleteRanking(fi.userId));
    if(jsonData!=null && jsonData['rankingTypeList'] is List){
      jsonData['rankingTypeList'].forEach((ranking) {
        if(RegExp("Olympic ", caseSensitive: false).hasMatch(ranking['rankingType'])) fi.olympic=(ranking['divisions'] as List).map((division) => Division.fromJson(division)).toList();
        else if(RegExp("World ", caseSensitive: false).hasMatch(ranking['rankingType'])) fi.world=(ranking['divisions'] as List).map((division) => Division.fromJson(division)).toList();
        else print('ERR!! Unknown ranking: ${ranking['rankingType']}');
      });
      if(fi.olympic==null) fi.olympic=[];
      if(fi.world==null) fi.world=[];
    }else{
      print('[${DateTime.now().millisecondsSinceEpoch}] No ranking for person');
      fi.olympic=[];
      fi.world=[];
    }
  }
  void _fetchDivisions(String scEvent) async{
    _loadingDivisions.value=true;
    _divisions.clear();
    final jsonData=await SimplyCompete.fetchJSONResponse(SimplyCompeteURL.fetchSCDivisionUrl(scEvent));//?.data?.divisionData as List ?? List();
    if(jsonData!=null && jsonData['data']!=null && jsonData['data']['divisionData'] is List){
      final list=(jsonData['data']['divisionData'] as List).where((division)=>division['subEventName']=="Senior Division").map((division) {
        print('DIVISION: $division => ${division['subEventName']} - ${division['divisionName']}');
        return DropDownDivisionItem(division['divisionId'], "${division['subEventName']} - ${division['divisionName']}");
      });
      print('list: ${list.runtimeType}, ${list.length}');
      _divisions.addAll(list);
    }else{
      print('No divisions for found');
    }
    _loadingDivisions.value=false;
  }
  @override
  void initState() { 
    super.initState();
    _fetchDivisions(widget.scEvent);
  }
  void _printIterate(Fight fight){
    if(fight.hong==null) print("WO: (${fight.chong})${fighters[fight.chong-1].preferredName}");
    else if(fight.hong is int) print("(${fight.chong})${fighters[fight.chong-1].preferredName} - (${fight.hong})${fighters[fight.hong-1].preferredName}");
    else if(fight.chong is int) print("(${fight.chong})${fighters[fight.chong-1].preferredName} - [(${fight.hong.chong})${fighters[fight.hong.chong-1].preferredName}/(${fight.hong.hong})${fighters[fight.hong.hong-1].preferredName}]");
    else{
      _printIterate(fight.chong);
      _printIterate(fight.hong);
    }
  }
  void _printDraw(){
    final all=Fight(1,2,2,fighters.length);
    print('Printed: $all');
    _printIterate(all);
  }
  void _removeItem(int index){
    print('Deleting ${fighters[index]}');
    final deleteFighter=fighters.removeAt(index);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      // A method to build the Card widget.
      return FighterListTile(fighter: deleteFighter, index: index, action: null, animation:animation);
    };
    _listKey.currentState.removeItem(index, builder);
    fighterCount.value=fighters.length;
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ValueListenableBuilder(valueListenable: fighterCount, builder: (context, value, child) => Text('Rankings ($value)')), actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: (){ _fetchDivisions(widget.scEvent); }),
          PopupMenuButton(
            onSelected: (command)=> _printDraw(),
            itemBuilder: (BuildContext context){
              return [PopupMenuItem(child: Text('Create draws'), value: 1,)];
            }
          )
        ],
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable:  _loadingDivisions,
              builder: (BuildContext context, dynamic value, Widget child) {
                return _loadingDivisions.value?CircularProgressIndicator() : DropdownButton<DropDownDivisionItem>(items: _divisions.map((div)=>
                  DropdownMenuItem(value: div, child: Text(div.value))).toList(), onChanged: (_selected){
                    _fetchAthletes(widget.scEvent, _selected.key);
                  }
                );
              },
            ),
            Expanded(
                child: AnimatedList(
                  key: _listKey, initialItemCount: 0, itemBuilder: (x,index, animation) => FighterListTile(fighter: fighters[index], index: index, action: (index)=>_removeItem(index), animation: animation),
                )
            
            )
          ]
        )
      ),
    );
  }
}