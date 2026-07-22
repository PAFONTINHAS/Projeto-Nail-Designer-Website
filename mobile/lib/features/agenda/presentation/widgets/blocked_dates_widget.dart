import 'package:flutter/material.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:mobile/features/agenda/presentation/widgets/schedule_page_card_widget.dart';
import 'package:provider/provider.dart';

class BlockedDatesWidget extends StatelessWidget {
  const BlockedDatesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AgendaController>();
    return SchedulePageCardWidget(
      title: "Datas Bloqueadas",
      icon: Icons.event_busy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) controller.addDataBloqueada(date);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Adicionar Data"),
          ),
          
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.datasBloqueadas.map((dateStr) {
              // Formata para BR apenas na exibição
              final parts = dateStr.split('-');
              final displayDate = "${parts[2]}/${parts[1]}/${parts[0]}";

              return Chip(
                label: Text(displayDate, style: const TextStyle(fontSize: 12)),
                backgroundColor: const Color(0xFFFFF0F6),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                deleteIcon: const Icon(
                  Icons.cancel,
                  size: 16,
                  color: Color(0xFFEC489A),
                ),
                onDeleted: () => controller.removeDataBloqueada(dateStr),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
