class Event{
  final String endDate;
  final String eventLevel;
  final String id;
  final int athleteCount;
  final String venueAddress;
  final String timeZone;
  final String venueName;
  final String name;
  final String startDate;
  final String venueCountry;
  final String eventTypeString;
  final String venueCity;
  final String gRank;
  final String location;
  const Event(this.endDate, this.eventLevel, this.id, this.athleteCount, this.venueAddress, this.timeZone, this.venueName, this.name, this.startDate, this.venueCountry, this.eventTypeString, this.venueCity, this.gRank, this.location);
  Event.fromJson(Map<String,dynamic> json) : endDate=json['endDate'], eventLevel=json['eventLevel'], id=json['id'], athleteCount=int.tryParse(json['athleteCount']) ?? 0, venueAddress=json['venueAddress'], timeZone=json['timeZone'], venueName=json['venueName'], name=json['name'], startDate=json['startDate'], venueCountry=json['venueCountry'], eventTypeString=json['eventTypeString'], venueCity=json['venueCity'], gRank=json['gRank'], location=json['location'];
  Map<String,dynamic> toJson(){
    return{
      'endDate': endDate,
      'eventLevel': eventLevel,
      'id': id,
      'athleteCount': athleteCount,
      'venueAddress': venueAddress,
      'timeZone': timeZone,
      'venueName': venueName,
      'name': name,
      'startDate': startDate,
      'venueCountry': venueCountry,
      'eventTypeString': eventTypeString,
      'venueCity': venueCity,
      'gRank': gRank,
      'location': location,
    };
  }
}
