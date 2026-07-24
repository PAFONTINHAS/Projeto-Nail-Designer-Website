import 'package:flutter/material.dart';
import 'package:mobile/core/utils/time_picker_helper.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:provider/provider.dart';

class DayConfigBottomSheetWidget extends StatelessWidget {
  // final DiaTrabalho diaTrabalho;
  final AgendaController controller;

  const DayConfigBottomSheetWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {

    return Padding(
      // Evita que o teclado/bottom de navegação cubra o conteúdo
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [ 
              Text(
                "Configurar Dia",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Fechar",
                  style: TextStyle(color: Color(0xFFEC489A)),
                ),
              ),

            ],
          ),
          const SizedBox(height: 20),
          
          // HORÁRIO PRINCIPAL
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async { 
                    String? pickedTime = await TimePickerHelper.selectTime(context, controller.selectedDiaTrabalho.inicio);

                    if(pickedTime != null){
                      
                      controller.changeOpeningHour(controller.selectedDiaTrabalho.diaSemana, pickedTime);
                    }

                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Início", border: OutlineInputBorder()),
                    child: Selector<AgendaController, String>(
                      selector: (context, controller) => controller.selectedDiaTrabalho.inicio,
                      builder: (context, value, child) => Text(value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    String? pickedTime = await TimePickerHelper.selectTime(context, controller.selectedDiaTrabalho.inicio);

                    if(pickedTime != null){
                      
                      controller.changeClosingHour(controller.selectedDiaTrabalho.diaSemana, pickedTime);
                    }

                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Fim", border: OutlineInputBorder()),
                    child: Selector<AgendaController, String>(
                      selector: (context, controller) => controller.selectedDiaTrabalho.fim,
                      builder: (context, value, child) => Text(value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const Divider(height: 40),

          // PAUSAS / INTERVALOS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Pausas / Almoço", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () { 
                  // Adicionar novo Intervalo('12:00', '13:00') na lista do diaTrabalho
                  // controller.adicionarPausa(diaTrabalho.diaSemana);
                },
                icon: const Icon(Icons.add, color: Color(0xFFEC489A)),
                label: const Text("ADICIONAR", style: TextStyle(color: Color(0xFFEC489A))),
              )
            ],
          ),
          
          // LISTA DE PAUSAS
          ...controller.selectedDiaTrabalho.pausas.map((pausa) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.free_breakfast_outlined),
            title: Text("${pausa.inicio} até ${pausa.fim}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () =>{} // controller.removerPausa(diaTrabalho.diaSemana, pausa),
            ),
          )),
          
          const SizedBox(height: 30),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}