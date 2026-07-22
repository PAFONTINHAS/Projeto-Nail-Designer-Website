import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/agenda/presentation/pages/agenda_config_page.dart';

DateTime? toDate(dynamic timestamp) {
  // Se o valor for nulo, retorna nulo imediatamente.
  if (timestamp == null || timestamp is! Timestamp) {
    return null;
  }
  // Se for um Timestamp válido, converte.
  return timestamp.toDate();  
}

bool isInt(dynamic value){

  if(value is int) return true;

  return false;
}

double tranformIntoOneDecimal(double value){

  String formatedValue = value.toStringAsFixed(1);

  return double.parse(formatedValue);
}

int convertStringToTime(String timeString){ 

  final pieces = timeString.split(":");
  final hour = int.parse(pieces[0]);
  final minute = int.parse(pieces[1]);

  return (hour * 60) + minute;

}

String formatMinutes(int totalMinutes){
  
  final int hours = totalMinutes ~/ 60;
  final int minutes = totalMinutes % 60;

  return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";

}

