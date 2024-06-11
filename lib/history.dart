import 'package:hive/hive.dart';

part 'history.g.dart';

@HiveType(typeId: 1)
class History {
  History({
    required this.date,
    required this.sessionSecsMeditated,
    required this.heatMapShadeVal,
  });

  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int sessionSecsMeditated;

  @HiveField(2)
  int heatMapShadeVal;
}
