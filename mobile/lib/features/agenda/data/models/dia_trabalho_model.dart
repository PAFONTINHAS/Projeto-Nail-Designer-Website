import 'package:mobile/features/agenda/data/models/intervalo_model.dart';
import 'package:mobile/features/agenda/domain/entities/dia_trabalho.dart';

class DiaTrabalhoModel extends DiaTrabalho{

  const DiaTrabalhoModel({
    required super.diaSemana,
    required super.fim,
    required super.inicio,
    required super.pausas
  });


  factory DiaTrabalhoModel.fromMap(Map<String, dynamic> map){

    final pausasList = map['pausas'] as List<dynamic>;

    final typedList = List<Map<String, dynamic>>.from(pausasList);

    final intervalos = typedList.map((pausa) => IntervaloModel.fromMap(pausa)).toList();

    return DiaTrabalhoModel(
      diaSemana: map['diaSemana'],
      fim: map['fim'],
      inicio: map['inicio'],
      pausas: intervalos,
    );


  }


}