import 'package:flutter/material.dart';


class TimePickerHelper {

  static Future<String?> selectTime(BuildContext context, String horario) async {

    final TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(horario.split(":")[0]),
      minute: int.parse(horario.split(":")[1]),
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
      final String formattedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

      return formattedTime;
    }

    return null;
  }


}



