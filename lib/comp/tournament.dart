class Tournament{
  final String name;
  final String key;
  List<String> dates;
  String place, country;
  bool _readHTML=false;
  get hasReadHTML=>_readHTML;
  get tournamentDates=>"${dates.first}${dates.length>1?dates.last:''}";
  Tournament(this.name, this.key);
  @override
  String toString() {
    return "$name (key: $key, place: $place, country: $country, dates: $dates)";
  }
  fromHTML(String content){
    print('fromHTML(${content.length} bytes)');
    _readHTML=true;
    RegExpMatch dateMatch=RegExp(r"(?<=cmbDatum)[^<]*(.*?)[^>]*<\/SELECT>", dotAll: true).firstMatch(content);
    if(dateMatch!=null){
      dates=RegExp(r"OPTION VALUE=\'(\d*)\' (\w*)", dotAll: true).allMatches(dateMatch[1]).map((regMatch)=>regMatch.group(1)).toList();
      print('Dates: $dates');
    }else print('No dates found');
    RegExpMatch rm=RegExp(r'txtPlaats\" VALUE=\"([^\"]*)', dotAll: true).firstMatch(content);
    if(rm!=null) place=rm[1];
    print('Place: $place');
    rm=RegExp(r'txtCountry\" VALUE=\"([^\"]*)', dotAll: true).firstMatch(content);
    if(rm!=null) country=rm[1];
    print('Country: $country');
  }
}