class Division{
  final String division;
  final String subEventName;
  final double totalPoints;
  final int rank;
  const Division(this.division, this.subEventName, this.totalPoints, this.rank);
  Division.fromJson(Map<String,dynamic> json) : division=json['division'], subEventName=json['subEventName'], totalPoints=double.parse(json['totalPoints']), rank=json['rank'];
  Map<String,dynamic> toJson(){
    return{
      'division': division,
      'subEventName': subEventName,
      'totalPoints': totalPoints,
      'rank': rank
    };
  }
}
class Fighter{
  final String teamCountryLovDetailsId;
  final String teamName;
  final String customGuestName;
  final String preferredFirstName;
  final String wtfLicenseId;
  final int subEventMinCnt;
  final String divisionId;
  final String userId;
  final String subeventId;
  final String role;
  final String countryFlagUrl;
  final String clubName;
  final int partnersCount;
  final int subEventMaxCnt;
  final String subeventName;
  final String preferredName;
  final String customClubName;
  final String preferredLastName;
  final String avatar;
  final String country;
  final String nationality;
  final String divisionName;
  final String deviceToken;
  final String teamOrganizationName;
  final String profilePicId;
  List<Division> olympic;
  List<Division> world;
  get worldPoints=>world==null?-1:world.firstWhere((element) => element.division==divisionName, orElse: ()=>Division(divisionName, '', 0, 0)).totalPoints;
//  double fetchWorldPoints(String divisionName)=>world==null?-1:world.firstWhere((element) => element.division==divisionName, orElse: ()=>Division(divisionName, '', 0, 0)).totalPoints;
  Fighter(this.teamCountryLovDetailsId, this.teamName, this.customGuestName, this.preferredFirstName, this.wtfLicenseId, this.subEventMinCnt, this.divisionId, this.userId, this.subeventId, this.role, this.countryFlagUrl, this.clubName, this.partnersCount, this.subEventMaxCnt, this.subeventName, this.preferredName, this.customClubName, this.preferredLastName, this.avatar, this.country, this.nationality, this.divisionName, this.deviceToken, this.teamOrganizationName, this.profilePicId);
  Fighter.fromJson(Map<String,dynamic> json) : teamCountryLovDetailsId=json['teamCountryLovDetailsId'], teamName=json['teamName'], customGuestName=json['customGuestName'], preferredFirstName=json['preferredFirstName'], wtfLicenseId=json['wtfLicenseId'], subEventMinCnt=json['subEventMinCnt'], divisionId=json['divisionId'], userId=json['userId'], subeventId=json['subeventId'], role=json['role'], countryFlagUrl=json['countryFlagUrl'], clubName=json['clubName'], partnersCount=json['partnersCount'], subEventMaxCnt=json['subEventMaxCnt'], subeventName=json['subeventName'], preferredName=json['preferredName'], customClubName=json['customClubName'], preferredLastName=json['preferredLastName'], avatar=json['avatar'], country=json['country'], nationality=json['nationality'], divisionName=json['divisionName'], deviceToken=json['deviceToken'], teamOrganizationName=json['teamOrganizationName'], profilePicId=json['profilePicId'];
  @override
  String toString() {
    return "Fighter: $preferredName";
  }
/*  static List<Fighter> fetchFighters(dynamic jsonData){
    print("[${DateTime.now().millisecondsSinceEpoch}] fetchFighter(${jsonData.length} bytes)");
    try{
      print('1: ${jsonData.runtimeType}');
      print('2: ${jsonData['data'].runtimeType}');
      print('3: ${jsonData['data']['participantList'].runtimeType}');
      print('3: ${jsonData['data']['participantList'].length}');
      if(jsonData['data']!=null && jsonData['data']['participantList']!=null){
        (jsonData['data']['participantList'] as List<dynamic>).forEach((e) => print(Fighter.fromJson(e)));
        final fighters=(jsonData['data']['participantList'] as List<dynamic>).map((e) => Fighter.fromJson(e)).toList();
        return fighters;//['participantList'] as List<dynamic>).toList().map((e) => Fighter.fromJson(e)).toList();
      }
      print("!OK: ${jsonData['data']}");
      return null;
      print('x key: ${(x as LinkedHashMap).entries.join(',')}');
      print("X map=${x['data']['participantList'].runtimeType}");
      print('2.5: ${jsonDecode(jsonDecode(jsonData)['data'])}');
      print('3: ${jsonDecode(jsonDecode(jsonData)['data'])['data']}');
      print('4: ${jsonDecode(jsonDecode(jsonDecode(jsonData)['data'])['data'])}');
    }catch(ex){
      print("[${DateTime.now().millisecondsSinceEpoch}] fetchFighter ex: $ex");
      throw ex;
    }
  }*/
  Map<String, dynamic> toJson(){
    return{
      'teamCountryLovDetailsId': teamCountryLovDetailsId,
      'teamName': teamName,
      'customGuestName': customGuestName,
      'preferredFirstName': preferredFirstName,
      'wtfLicenseId': wtfLicenseId,
      'subEventMinCnt': subEventMinCnt,
      'divisionId': divisionId,
      'userId': userId,
      'subeventId': subeventId,
      'role': role,
      'countryFlagUrl': countryFlagUrl,
      'clubName': clubName,
      'partnersCount': partnersCount,
      'subEventMaxCnt': subEventMaxCnt,
      'subeventName': subeventName,
      'preferredName': preferredName,
      'customClubName': customClubName,
      'preferredLastName': preferredLastName,
      'avatar': avatar,
      'country': country,
      'nationality': nationality,
      'divisionName': divisionName,
      'deviceToken': deviceToken,
      'teamOrganizationName': teamOrganizationName,
      'profilePicId': profilePicId,
      'olympic': olympic,
      'world': world
    };
  }
}
class Fight{
  dynamic chong;
  dynamic hong;
  Fight(chong, hong, ant, max){
    var length=ant*2+1;
    this.chong=length-chong<=max?Fight(chong, length-chong, ant*2, max):chong;
    this.hong=length-hong<=max?Fight(hong, length-hong, ant*2, max):hong;
  }
  @override toString(){
    return "[$chong - $hong]";
  }
}