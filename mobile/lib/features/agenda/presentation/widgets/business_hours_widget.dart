import 'package:flutter/material.dart';
import 'package:mobile/features/agenda/presentation/widgets/day_config_bottom_sheet_widget.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:mobile/features/agenda/presentation/widgets/schedule_page_card_widget.dart';

class BusinessHoursWidget extends StatelessWidget {
  const BusinessHoursWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AgendaController>();

    final List<String> days = const [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira', 
      'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'
    ];

    final configuredDays = controller.agenda?.diasTrabalho ?? [];

    return SchedulePageCardWidget(
      title: "Horários por Dia",
      icon: Icons.calendar_month,
      child: Column(
        children: List.generate(7, (index) {

          final weekday = index + 1;

          final workDay = configuredDays.where((day) => day.diaSemana == weekday).firstOrNull;

          final isActive = workDay != null;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(days[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              isActive 
                ? "${workDay.inicio} às ${workDay.fim} • ${workDay.pausas.length} pausa(s)" 
                : "Fechado",
              style: TextStyle(color: isActive ? Colors.green : Colors.grey),
            ),
            trailing: Switch(
              value: isActive,
              activeThumbColor: const Color(0xFFEC489A),
              onChanged: (value) {
                // Aqui você chama a lógica para ativar/desativar o dia vazio
                // controller.toggleWorkDay(weekday, value);
              },
            ),
            onTap: isActive 
              ? () => _abrirConfiguracaoDoDia(context, workDay, controller)
              : null,
          );

        }),
      ),
    );
  }

  void _abrirConfiguracaoDoDia(BuildContext context, dynamic diaTrabalho, dynamic controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DayConfigBottomSheetWidget(diaTrabalho: diaTrabalho, controller: controller),
    );
  }
}


