import 'package:equatable/equatable.dart';
import 'package:mobile/features/agenda/domain/entities/dia_trabalho.dart';

class Agenda extends Equatable {
  final List<DiaTrabalho> diasTrabalho;
  final List<String> datasBloqueadas;
  final bool agendaAtiva;
  

  const Agenda({
    required this.diasTrabalho,
    required this.datasBloqueadas,
    this.agendaAtiva = true
  });

  Map<String, dynamic> toMap() => {
    'diasTrabalho': diasTrabalho.map((dia) => dia.toMap()),
    'agendaAtiva': agendaAtiva,
    'datasBloqueadas': datasBloqueadas
  };

  Agenda copyWith({
    List<DiaTrabalho>? diasTrabalho,
    String? horarioInicio,
    String? horarioFim,
    List<String>? datasBloqueadas,
    bool? agendaAtiva,
  }){
    return Agenda(
      diasTrabalho: diasTrabalho ?? this.diasTrabalho,
      datasBloqueadas: datasBloqueadas ?? this.datasBloqueadas,
      agendaAtiva: agendaAtiva ?? this.agendaAtiva
    );
  }


  @override
  List<Object?> get props => [
    agendaAtiva,
    diasTrabalho,
    datasBloqueadas,
  ];
}