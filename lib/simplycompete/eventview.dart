import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tpss_live/simplycompete/model/event.dart';
import 'package:tpss_live/simplycompete/ranking/show_ranking.dart';
import 'package:tpss_live/simplycompete/repo.dart';

class EventView extends StatefulWidget {
  EventView({Key key}) : super(key: key);

  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final _events=List<Event>();
  final _loadingEvents=ValueNotifier<bool>(false);
  @override
  void initState() { 
    super.initState();
    _fetchEvents();
  }
  _fetchEvents() async{
    _loadingEvents.value=false;
    final jsonData=(await SimplyCompete.fetchJSONResponse(SimplyCompeteURL.fetchEvents));
    if(jsonData!=null && jsonData['data']!=null && jsonData['data']['event'] != null){
      (jsonData['data']['event'] as List).forEach((element) {
        print("El: ${element.runtimeType}");
        _events.add(Event.fromJson(element));
      });
      print('Received ${jsonData.length} events');
    }else print('Error no data received');
    _loadingEvents.value=true;
  }
  Widget _eventListTile(int index, Animation animation){
    return SizeTransition(sizeFactor: animation, child: GestureDetector(
      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>RankingView(scEvent: _events[index].id))),//'11ea171f-4c0f-56e0-a3a9-0232a54f5d94'))),
      onHorizontalDragEnd: (ind)=> print(ind),
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
              Text("${index+1} - ${_events[index].name}"),
            ]
          )
        )
      ),
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events'), actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: (){ _fetchEvents(); }),
        ],
      ),
      body: Container(
        child: ValueListenableBuilder(
          valueListenable: _loadingEvents,
          builder: (BuildContext context, dynamic value, Widget child) {
            return value? Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: AnimatedList(
                      key: _listKey, initialItemCount: _events.length, itemBuilder: (x,index, animation) => _eventListTile(index, animation),
                    )
                
                )
              ]
            ):CircularProgressIndicator();
          }
        ),
      )
    );
  }
}