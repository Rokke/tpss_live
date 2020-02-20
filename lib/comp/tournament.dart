class Tournament{
  final String name;
  final String key;
  List<String> dates;
  String place, country;
  bool _readHTML=false;
  get hasReadHTML=>_readHTML;
  get isLiveToday{
    final dt=DateTime.now();
    final dtTxt='${dt.year}${dt.month.toString().padLeft(2, "0")}${dt.day.toString().padLeft(2,"0")}';
    return dates.any((element) => element==dtTxt);
  }
  get tournamentDates=>"${dates.first}${dates.length>1?dates.last:''}";
  Tournament(this.name, this.key);
  @override
  String toString() {
    return "$name (key: $key, place: $place, country: $country, dates: $dates)";
  }
  fromHTML(String content){
    print('[${DateTime.now().millisecondsSinceEpoch}] fromHTML(${content.length} bytes)');
    _readHTML=true;
    RegExpMatch dateMatch=RegExp(r"(?<=cmbDatum)[^<]*(.*?)[^>]*<\/SELECT>", dotAll: true).firstMatch(content);
    if(dateMatch!=null){
      dates=RegExp(r"OPTION VALUE=\'(\d*)\' (\w*)", dotAll: true).allMatches(dateMatch[1]).map((regMatch)=>regMatch.group(1)).toList();
      print('[${DateTime.now().millisecondsSinceEpoch}] Dates: $dates');
    }else print('[${DateTime.now().millisecondsSinceEpoch}] No dates found');
    RegExpMatch rm=RegExp(r'txtPlaats\" VALUE=\"([^\"]*)', dotAll: true).firstMatch(content);
    if(rm!=null) place=rm[1];
    print('[${DateTime.now().millisecondsSinceEpoch}] Place: $place');
    rm=RegExp(r'txtCountry\" VALUE=\"([^\"]*)', dotAll: true).firstMatch(content);
    if(rm!=null) country=rm[1];
    print('[${DateTime.now().millisecondsSinceEpoch}] Country: $country');
  }
}