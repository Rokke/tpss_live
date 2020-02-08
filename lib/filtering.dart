import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'comp/match_filter.dart';

class FilterMatches extends StatefulWidget {
  FilterMatches({Key key}) : super(key: key);

  @override
  _FilterMatchesState createState() => _FilterMatchesState();
}
class _FilterMatchesState extends State<FilterMatches> {
  final listSelected=List<MatchFilter>();
  final listUnselected=List<MatchFilter>();
  final ValueNotifier<bool> selectedType=ValueNotifier(true);
  final ValueNotifier<int> _favoriteVersion=ValueNotifier(0);
  final ValueNotifier<int> _ignoreVersion=ValueNotifier(0);
  @override
  void initState() { 
    super.initState();
    _openFilter();
  }
  Card _fetchListTile(int index, bool favorite){
    final list=favorite?listSelected:listUnselected;
    return Card(
      color: favorite?Colors.greenAccent:Colors.redAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
//        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 26,
            width: 26,
            margin: EdgeInsets.symmetric(horizontal: 4),
            color: favorite?Colors.green[900]:Colors.red[900],
            child: IconButton(
              padding: EdgeInsets.all(0),
              color: favorite?Colors.green[200]:Colors.red[200],
              icon: Icon(Icons.delete_forever),
              onPressed: (){
                list.removeAt(index);
                favorite?_favoriteVersion.value++:_ignoreVersion.value++;
              }
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(list[index].value),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('')),
                    Container(padding: EdgeInsets.symmetric(horizontal: 4), color: favorite?Colors.green[100]:Colors.red[100], child: Text(list[index].matchTypeName,)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  _showWeightMenu(BuildContext context, bool favorites) async{
    Size _size=MediaQuery.of(context).size;
    print('Show popup($favorites), $_size');
    List<PopupMenuItem<MainClass>> mainCategory=List<PopupMenuItem<MainClass>>();
    MainClassType.values.forEach((element) {
      Gender.values.map((genderType)=>MainClass(genderType, element, "")).forEach(
        (genderCls) {
          mainCategory.add(PopupMenuItem(child: Text("${genderCls.mainClassTypeName} - ${genderCls.genderName}"), value: genderCls,));
        });
    });
    MainClass mainSelectedCategory=await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(favorites?0:_size.width, 80, _size.height,_size.width),
      items: mainCategory
    );
    if(mainSelectedCategory!=null){
      final List<MainClass> list=MainClass.fetchWeighs(Gender.male, mainSelectedCategory.mainClass);
      list.insert(0, mainSelectedCategory);
      list.removeWhere((valid) => (listSelected.any((lst)=>(lst.matchType==MatchType.className && lst.value.contains(valid.toValue))) || listUnselected.any((lst)=>(lst.matchType==MatchType.className && lst.value.contains(valid.toValue)))) );
      MainClass cls=await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(favorites?0:_size.width, 80, _size.height,_size.width),
        items: list.map((cls)=>PopupMenuItem(
          child: Text(cls.toString()),
          value: cls
        )).toList()
      );
      if(cls!=null){
        if(favorites){
          listSelected.add(MatchFilter(cls.toValue, MatchType.className));
          _favoriteVersion.value++;
        }else{
          listUnselected.add(MatchFilter(cls.toValue, MatchType.className));
          _ignoreVersion.value++;
        }
        print('Selected $cls');
      }
    }
  }
  _openFilter() async {
    final config=await FilterConfig.loadConfig();
    if(config!=null){
      print('Config loaded: $config');
      listSelected.clear();
      listSelected.addAll(config.selectedFilters);
      listUnselected.clear();
      listUnselected.addAll(config.unselectedFilters);
      _favoriteVersion.value++;
      _ignoreVersion.value++;
    }else print('No default filter exist');
  }
  Future<void> _saveFilter() async {
    FilterConfig config=FilterConfig(listSelected, listUnselected);
    print('CONFIG: ${jsonEncode(config)}');
    final file=File((await getApplicationDocumentsDirectory()).path + "/filter.json");
    await file.create();
    await file.writeAsString(jsonEncode(config));
    print('File saved: ${file.path}');
  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: Text('Filtrering'),
        actions: [
          IconButton(icon: Icon(Icons.save, color: Colors.lightBlue[100],), onPressed: ()=>_saveFilter()),
        ],
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: ()=>Navigator.pop(context),),
      ),
      body: Container(
        color: Colors.yellow,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              color: Colors.grey,
              child: ValueListenableBuilder(
                valueListenable:  selectedType,
                builder: (BuildContext context, dynamic value, Widget child) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:[
                      Expanded(
                        child: Container(color: Colors.green, child: Center(
                          child: RaisedButton(
                            color: Colors.green,
                            elevation: 20,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.visibility,
                                  color: Colors.green[100],
                                ),
                                Text('  Favorite '),
                                Icon(
                                  Icons.add,
                                  color: Colors.green[100],
                                ),
                              ],
                            ),
                            onPressed: ()=> _showWeightMenu(this.context, true),
                          )
                        )),
                      ),
                      Expanded(
                        child: Container(color: Colors.red, child: Center(
                          child: RaisedButton(
                            color: Colors.red,
                            elevation: 20,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.visibility_off, color: Colors.red[100]),
                                Text('  Ignore '),
                                Icon(
                                  Icons.add,
                                  color: Colors.red[100],
                                ),
                              ],
                            ),
                            onPressed: ()=> _showWeightMenu(context, false)
                          )
                        )),
                      ),
                    ]
                  );
                }
              )
            ),
            Expanded(
              child: Row(
              mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
                  Expanded(
                      child: Container(
                        color: Colors.green,
                        child: ValueListenableBuilder(
                          valueListenable: _favoriteVersion,
                          builder: (BuildContext context, dynamic value, Widget child) {
                            return ListView.builder(
                              itemCount: listSelected.length, itemBuilder: (x, index)=> _fetchListTile(index, true)
                            );
                          }
                        )
                      ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.red,
                      child: ValueListenableBuilder(
                        valueListenable: _ignoreVersion,
                        builder: (BuildContext context, dynamic value, Widget child) {
                          return ListView.builder(
                            itemCount: listUnselected.length, itemBuilder: (x, index)=> _fetchListTile(index, false)
                          );
                        }
                      )
                    ),
                  ),
                ]
              ),
            )
          ],
        )
      )
   );
  }
}