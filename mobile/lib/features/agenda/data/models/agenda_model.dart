import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/utils/helpers.dart';
import 'package:mobile/features/agenda/data/models/dia_trabalho_model.dart';
import 'package:mobile/features/agenda/domain/entities/agenda.dart';
import 'package:mobile/features/agenda/domain/entities/dia_trabalho.dart';
import 'package:mobile/features/agenda/presentation/pages/agenda_config_page.dart';

class AgendaModel extends Agenda{

  const AgendaModel({
    required super.diasTrabalho,
    required super.datasBloqueadas,
    super.agendaAtiva
  });

  factory AgendaModel.fromSnapshot(DocumentSnapshot doc){

    final data = doc.data() as Map<String, dynamic>;

    logger.i("Data: $data");
    logger.i("Dias de trabalho: ${data['diasTrabalho']}");

    final List<dynamic> diasTrabalhoList = data['diasTrabalho'] as List<dynamic>;

    final List<Map<String, dynamic>> typedList = List<Map<String, dynamic>>.from(diasTrabalhoList);

    final List<DiaTrabalho> diasTrabalho = typedList.map((dia) => DiaTrabalhoModel.fromMap(dia)).toList();


    return AgendaModel(
      agendaAtiva: data['agendaAtiva'],
      diasTrabalho: diasTrabalho,
      datasBloqueadas: List<String>.from(data['datasBloqueadas'] ?? []),
    );
  }

}




extension ListDateExtension on List<Timestamp>{
  
  List<DateTime> converterDatas(){

    if(isEmpty) return [];

    final List<DateTime> datas = [];

    for(final timestamp in this){

      final dataConvertida = toDate(timestamp);

      if(dataConvertida == null) continue;

      datas.add(dataConvertida);
    }

    return datas;

  }

}