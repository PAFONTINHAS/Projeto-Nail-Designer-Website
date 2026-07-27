import 'package:flutter/material.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:provider/provider.dart';

class ScheduleActivityStatusCardWidget extends StatelessWidget {
  const ScheduleActivityStatusCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AgendaController>();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: controller.agendaAtiva
              ? [const Color(0xFFEC489A), Colors.pinkAccent]
              : [Colors.grey, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SwitchListTile(
        value: controller.agendaAtiva,
        onChanged: (val) => controller.toggleAgendaAtiva(val),
        title: const Text(
          "Agenda Online",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          controller.agendaAtiva
              ? "Clientes podem agendar agora"
              : "Agendamentos pausados no site",
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        activeThumbColor: Colors.white,
      ),
    );
  }
}
