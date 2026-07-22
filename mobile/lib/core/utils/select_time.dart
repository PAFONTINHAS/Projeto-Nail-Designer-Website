import 'package:flutter/material.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:provider/provider.dart';


class TimePickerHelper {

  static Future<void> selectTime(BuildContext context, bool isInicio) async {
    final controller = context.read<AgendaController>();

    final String horaAtual = isInicio
        ? controller.horarioInicio
        : controller.horarioFim;

    final TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(horaAtual.split(":")[0]),
      minute: int.parse(horaAtual.split(":")[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEC489A), // cor dos ponteiros e seleção
              onPrimary: Colors.white,
              onSurface: Colors.black, // cor dos números
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

      if (isInicio) {
        controller.setHorarioInicio(formattedTime);
      } else {
        controller.setHorarioFim(formattedTime);
      }
    }
  }


}



