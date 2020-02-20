import 'package:tpss_live/comp/match_filter.dart';

enum FightMatch{
  UNKNOWN,
  HIDE,
  FAVORITE,
  FAV_CHONG,
  FAV_HONG,
  FAV_CHONG_HONG
}
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
  FightMatch fightMatch=FightMatch.UNKNOWN;
  Fight(this.chong, this.chongCountry, this.chongClub, this.hong, this.hongCountry, this.hongClub, this.score, this.result, this.chongWinner, this.className, this.roundNo, this.roundName, this.fightTime);
  static String _fetchClassName(String clsName){
    try{
      var m=RegExp(r"^(?<type>\w+)[,\s]+(?<gen>[\w-]+)[^-+]+(?<kg>[-+\d]+) Kg", caseSensitive: false).firstMatch(clsName);
      return "${m.namedGroup('type')[0]}${m.namedGroup('gen')[0]}${m.namedGroup('kg')}";
    }catch(ex){
      print('[${DateTime.now().millisecondsSinceEpoch}] Invalid class: $ex => clsName');
      throw ex;
    }
  }
  get isFavoriteClass=>fightMatch==FightMatch.FAVORITE;
  get isFavoriteChong=>fightMatch==FightMatch.FAV_CHONG || fightMatch==FightMatch.FAV_CHONG_HONG;
  get isFavoriteHong=>fightMatch==FightMatch.FAV_HONG || fightMatch==FightMatch.FAV_CHONG_HONG;
  get isFavorite=>(fightMatch!=FightMatch.UNKNOWN && fightMatch!=FightMatch.HIDE);
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
      case 'Disqualification':
        return 'DSQ';
      default:
        print('[${DateTime.now().millisecondsSinceEpoch}] ERR unknown: $result');
        return result;
    }
  }
  /// Translates the fight text in the HTML to a fight class
  /// 01/02/2020 at 15:53	
  static Fight fromRegex(String text, FilterConfig config){
    var match=RegExp('(?<=TD)[^>]*>(.*?)<\/TD>', dotAll: true, multiLine: true).allMatches(text).toList();
    try{
      var stra=(match[1].groupCount>0)? match[1][1].split(' at '):[""];
      var strd=stra[0].split('/');
      stra=stra.length>1 && stra[1].isNotEmpty? stra[1].split(':'):["12","0"];
      DateTime dt=DateTime(int.parse(strd[2]),int.parse(strd[1]),int.parse(strd[0]),int.parse(stra[0]),int.parse((stra.length>1)?stra[1]:"0"));
      Fight f=Fight(match[6][1], match[17][1], match[18][1], match[9][1], match[20][1], match[21][1], match[10][1], _fetchResult(match[11][1]), RegExp("liveblue").hasMatch(match[6][0]), _fetchClassName(match[13][1]), match[3][1], match[2][1], dt);
      if(config!=null) f.fightMatch=config.updateFight(f);
      return f;
    }catch(ex){
      int i=0;
      match.map((x)=>"${i++} = ${x[0]} / ${x[1]}").forEach((element) {print(element);});
      print('[${DateTime.now().millisecondsSinceEpoch}] Error: $ex, res: ${text.length}, end: ${text.substring(text.length-10)}, match: ${match.length}');
      throw ex;
    }
  }
  static List<Fight> fromHTML(String content, FilterConfig config){
    content=content.substring(content.indexOf("Table4")).split('\r\n')[1]+"<TR b";
    RegExp rx=RegExp(r"(?<=TR bg)[^>]*>(.*?)<TR b", multiLine: true, dotAll: true);
    print("Fights: ${content.length} bytes");
    return rx.allMatches(content).map((f)=> Fight.fromRegex(f[1], config)).toList();
  }
  @override
  String toString() {
    return "Fight $chong - $hong => $score($result)${chongWinner?'B':'R'} - $fightTime";
  }
}