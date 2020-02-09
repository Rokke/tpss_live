import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

String capitalize(String text) => text.isEmpty?"":"${text[0].toUpperCase()}${text.substring(1)}";

enum MatchType{
  className,
  name,
  country
}
class MatchFilter{
  final String value;
  final MatchType matchType;
  String get matchTypeName{
    return matchType.toString().split('.').last;
  }
  MatchFilter(this.value, this.matchType);
  @override
  String toString() {
    return '$value ($matchTypeName)';
  }
  Map<String, dynamic> toJson() {
    print('toJson()');
    return {
      'value': value,
      'matchType': matchType.toString()
    };
  }
  MatchFilter.fromJson(Map<String,dynamic> json) : value=json['value'], matchType=MatchType.values.firstWhere((element) => element.toString() == json['matchType']);
}
class FilterConfig{
  final List<MatchFilter> selectedFilters;
  final List<MatchFilter> unselectedFilters;
  FilterConfig(this.selectedFilters, this.unselectedFilters);
  static Future<FilterConfig> loadConfig({String filename="filter.json"}) async {
    print('loadConfig()');
    final file=File((await getApplicationDocumentsDirectory()).path + "/$filename");
    if(await file.exists()){
      print('Config file exist! ${file.path}');
      await file.open();
      final config=jsonDecode(await file.readAsString());
      return FilterConfig((config['selectedFilters'] as List<dynamic>).map((x)=>MatchFilter.fromJson(x)).toList(), (config['unselectedFilters'] as List<dynamic>).map((x)=>MatchFilter.fromJson(x)).toList());
    }else print('No existing filter');
    return null;
  }
  FilterConfig.fromJson(Map<String, List<MatchFilter>> json) : selectedFilters = json['selectedFilters'], unselectedFilters=json['unselectedFilters'];
  Map<String, dynamic> toJson() {
    print('FilterConfig - toJson()');
    return {
      'selectedFilters': selectedFilters,
      'unselectedFilters': unselectedFilters
    };
  }
}
enum MainClassType{
  children,
  cadet,
  junior,
  senior,
  veteran
}
enum Gender{
  male,
  female
}
class MainClass{
  //TODO: Children and Veteran classes are wrong
  static const _childrenFemale=['-29','-33','-37'];
  static const _childrenMale=['-33','-37','-41'];
  static const _cadetFemale=['-29','-33','-37','-41','-44','-47','-51','-55','-59','+59'];
  static const _cadetMale=['-33','-37','-41','-45','-49','-53','-57','-61','-65','+65'];
  static const _juniorFemale=['-42','-44','-46','-49','-52','-55','-59','-63','-68','+68'];
  static const _juniorMale=['-45','-48','-51','-55','-59','-63','-68','-73','-78','+78'];
  static const _seniorFemale=['-46','-49','-53','-57','-62','-67','-73','+73'];
  static const _seniorMale=['-54','-58','-63','-68','-74','-80','-87','+87'];
  static const _veteranFemale=['-46','-49','-53','-57','-62','-67','-73','+73'];
  static const _veteranMale=['-54','-58','-63','-68','-74','-80','-87','+87'];
  final Gender gender;
  final MainClassType mainClass;
  final String weight;
  get toValue => "$mainClassString${gender==Gender.male?'M':'F'}$weight";
  Gender _stringToGender(String text) => text=='M'?Gender.male:Gender.female;
  MainClassType _stringToMainClassType(String text) => MainClassType.values.firstWhere((element) => element.toString().split(".").last==text.toLowerCase());
  MainClass fromValue(String value) => MainClass(_stringToGender(value[0]), _stringToMainClassType(value.substring(1,2)), value.substring(3));
  MainClass(this.gender, this.mainClass, this.weight);
  static List<MainClass> fetchWeighs(Gender gender, MainClassType mainClassType){
    switch(mainClassType){
      case MainClassType.children: return gender==Gender.male?MainClass.maleChildrens:MainClass.femaleChildrens;
      case MainClassType.cadet: return gender==Gender.male?MainClass.maleCadets:MainClass.femaleCadets;
      case MainClassType.junior: return gender==Gender.male?MainClass.maleJuniors:MainClass.femaleJuniors;
      case MainClassType.senior: return gender==Gender.male?MainClass.maleSeniors:MainClass.femaleSeniors;
      case MainClassType.veteran: return gender==Gender.male?MainClass.maleVeterans:MainClass.femaleVeterans;
    }
    return List<MainClass>();
  }
  get mainClassTypeName => capitalize(mainClass.toString().split(".").last);
  get genderName => capitalize(gender.toString().split(".").last);
  get mainClassString {
    switch(mainClass){
      case MainClassType.children: return 'K';
      case MainClassType.cadet: return 'C';
      case MainClassType.junior: return 'J';
      case MainClassType.senior: return 'S';
      case MainClassType.veteran: return 'V';
    }
    print('Error, shouldn\'t happen: $mainClass');
    return '?';
  }
  static List<MainClass> get maleChildrens=>_childrenMale.map((cls)=>MainClass(Gender.male, MainClassType.children, cls)).toList();
  static List<MainClass> get femaleChildrens=>_childrenFemale.map((cls)=>MainClass(Gender.female, MainClassType.children, cls)).toList();
  static List<MainClass> get maleCadets=>_cadetMale.map((cls)=>MainClass(Gender.male, MainClassType.cadet, cls)).toList();
  static List<MainClass> get femaleCadets=>_cadetFemale.map((cls)=>MainClass(Gender.female, MainClassType.cadet, cls)).toList();
  static List<MainClass> get maleJuniors=>_juniorMale.toList().map((cls)=>MainClass(Gender.male, MainClassType.junior, cls)).toList();
  static List<MainClass> get femaleJuniors=>_juniorFemale.map((cls)=>MainClass(Gender.female, MainClassType.junior, cls)).toList();
  static List<MainClass> get maleSeniors=>_seniorMale.map((cls)=>MainClass(Gender.male, MainClassType.senior, cls)).toList();
  static List<MainClass> get femaleSeniors=>_seniorFemale.map((cls)=>MainClass(Gender.female, MainClassType.senior, cls)).toList();
  static List<MainClass> get maleVeterans=>_veteranMale.map((cls)=>MainClass(Gender.male, MainClassType.veteran, cls)).toList();
  static List<MainClass> get femaleVeterans=>_veteranFemale.map((cls)=>MainClass(Gender.female, MainClassType.veteran, cls)).toList();
  @override
  String toString() {
    return (weight.isEmpty?"":"$weight - ") + "$mainClassTypeName - $genderName";
  }
}