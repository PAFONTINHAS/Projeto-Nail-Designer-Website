import 'package:mobile/features/agenda/domain/entities/intervalo.dart';

class IntervaloModel extends Intervalo{

  IntervaloModel(super.intervalId, super.inicio, super.fim);


  factory IntervaloModel.fromMap(Map<String, dynamic> map){

    return IntervaloModel(map['intervalId'], map['inicio'], map['fim']);
  }

}