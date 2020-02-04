class Tournament{
  final String name;
  final String key;
  Tournament(this.name, this.key);
  @override
  String toString() {
    return "$name - $key";
  }
}