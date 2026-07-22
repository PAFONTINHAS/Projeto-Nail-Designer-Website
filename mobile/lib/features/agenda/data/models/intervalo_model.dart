import 'package:mobile/features/agenda/domain/entities/intervalo.dart';

class IntervaloModel extends Intervalo{

  IntervaloModel(super.inicio, super.fim);


  factory IntervaloModel.fromMap(Map<String, dynamic> map){

    return IntervaloModel(map ['inicio'], map ['fim']);
  }

}