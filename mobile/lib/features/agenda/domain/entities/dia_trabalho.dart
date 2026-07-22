import 'package:equatable/equatable.dart';
import 'package:mobile/features/agenda/domain/entities/intervalo.dart';

class DiaTrabalho extends Equatable {
  final int diaSemana; // 1 (Seg) a 6 (Sab)
  final String inicio;
  final String fim;
  final List<Intervalo> pausas; // Ex: Almoço das 12:00 às 13:30

  const DiaTrabalho({required this.diaSemana, required this.inicio, required this.fim, this.pausas = const []});

  @override
  List<Object?> get props => [
    diaSemana,
    inicio,
    fim,
    pausas
  ];
}

