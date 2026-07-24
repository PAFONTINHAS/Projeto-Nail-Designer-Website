import 'package:flutter/material.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:mobile/features/agenda/presentation/handlers/agenda_actions_handler.dart';
import 'package:provider/provider.dart';

class ChangeBasedButtonWidget extends StatelessWidget {
  const ChangeBasedButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AgendaController, bool>(
      selector: (_, controller) => controller.haveAgendaChanged,
      builder: (context, value, child) {

        
        if(!value){
          return SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: value ? const Color(0xFFEC489A) : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () async => value
                ? await AgendaActionsHandler.handleUpdateAgenda(context)
                : {},
            child: const Text(
              "SALVAR CONFIGURAÇÕES",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
