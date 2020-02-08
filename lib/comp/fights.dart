class Fight{
  final String chong;
  final String chongCountry;
  final String chongClub;
  final String hong;
  final String hongCountry;
  final String hongClub;
  final String score;
  final String result;
  final bool chongWinner;
  final String className;
  final String roundNo;
  final String roundName;
  final DateTime fightTime;
  Fight(this.chong, this.chongCountry, this.chongClub, this.hong, this.hongCountry, this.hongClub, this.score, this.result, this.chongWinner, this.className, this.roundNo, this.roundName, this.fightTime);
  static String _fetchClassName(String clsName){
    var m=RegExp(r"^(?<type>\w+)[,\s]+(?<gen>[\w-]+)[^-+]+(?<kg>[-+\d]+) Kg").firstMatch(clsName);
    return "${m.namedGroup('type')[0]}${m.namedGroup('gen')[0]}${m.namedGroup('kg')}";
  }
  /// "Translates the results to the more common shortterm description"
  static String _fetchResult(String result){
    switch (result) {
      case 'Points Gap':
        return 'PTG';
      case 'Withdrawal':
        return 'WDR';
      case 'On points':
        return 'PTF';
      case 'Superiority':
        return 'SUP';
      case 'R.S.C.':
        return 'RSC';
      case 'Penalty':
        return 'PUN';
      case 'Golden point':
        return 'GDP';
      default:
        print('ERR unknown: $result');
        return result;
    }
  }
  /// Translates the fight text in the HTML to a fight class
  /// 01/02/2020 at 15:53	
  static Fight fromRegex(String text){
    var match=RegExp('(?<=TD)[^>]*>(.*?)<\/TD>', dotAll: true).allMatches(text).toList();
    var stra=(match[1].groupCount>0)? match[1][1].split(' at '):[""];
    var strd=stra[0].split('/');
    stra=strd.length>1? stra[1].split(':'):["00:00"];
    DateTime dt=DateTime(int.parse(strd[2]),int.parse(strd[1]),int.parse(strd[0]),int.parse(stra[0]),int.parse(stra[1]));
//    print('fromRegec($text) => ${match.length}');
    return Fight(match[6][1], match[17][1], match[18][1], match[9][1], match[20][1], match[21][1], match[10][1], _fetchResult(match[11][1]), RegExp("liveblue").hasMatch(match[6][0]), _fetchClassName(match[13][1]), match[3][1], match[2][1], dt);
  }
  @override
  String toString() {
    return "Fight $chong - $hong => $score($result)${chongWinner?'B':'R'} - $fightTime";
  }
}