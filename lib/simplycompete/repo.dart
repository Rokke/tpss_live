import 'dart:convert';

import 'package:http/http.dart';

abstract class SimplyCompeteURL{
  static get fetchArchivedEvents=>"https://worldtkd.simplycompete.com/events/eventList?archived=true&calendarView=0&eventType=all&invitationStatus=all";
  static get fetchEvents=>"https://worldtkd.simplycompete.com/events/eventList?calendarView=0&eventType=all&invitationStatus=all";
  static String fetchSCDivisionUrl(scEvent)=>"https://worldtkd.simplycompete.com/matchResults/getEventDivisions?eventId=$scEvent";
  static String fetchSCParticipants(scEvent, scNode, pageNo)=>"https://worldtkd.simplycompete.com/events/getEventParticipant?eventId=$scEvent&nodeId=$scNode&nodeLevel=Division&pageNo=$pageNo";
  static String fetchSCAthleteRanking(scAthlete)=>"https://worldtkd.simplycompete.com/user/rankingProfileData?id=$scAthlete";
}
abstract class SimplyCompete{
  static dynamic fetchJSONResponse(String url) async{
    print("[${DateTime.now().millisecondsSinceEpoch}] fetch: $url");
    Response response=await get(url);
    print("response: ${response.statusCode}");
    print("response: ${response.body.length} bytes");
    if(response.statusCode==200 && response.body!=null) return jsonDecode(response.body);
    else print("ERROR, no JSON");
    return null;
  }
}