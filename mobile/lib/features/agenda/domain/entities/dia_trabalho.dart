import 'package:equatable/equatable.dart';
import 'package:mobile/features/agenda/domain/entities/intervalo.dart';

class DiaTrabalho extends Equatable {
  final int diaSemana; // 1 (Seg) a 6 (Sab)
  final String inicio;
  final String fim;
  final List<Intervalo> pausas; // Ex: Almoço das 12:00 às 13:30

  const DiaTrabalho({required this.diaSemana, required this.inicio, required this.fim, this.pausas = const []});

  Map<String, dynamic> toMap(){
    return {
      'diaSemana': diaSemana,
      'inicio': inicio,
      'fim': fim,
      'pausas': pausas.map((pausa) => pausa.toMap())
    };
  }

  DiaTrabalho copyWith ({
    int? diaSemana,
    String? inicio,
    String? fim,
    List<Intervalo>? pausas 
  }){

    return DiaTrabalho(
      diaSemana: diaSemana ?? this.diaSemana,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
      pausas: pausas ?? this.pausas,
    );

  }

  @override
  List<Object?> get props => [
    diaSemana,
    inicio,
    fim,
    pausas
  ];
}

