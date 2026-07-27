import 'package:flutter/material.dart';
import 'package:mobile/core/utils/time_picker_helper.dart';
import 'package:mobile/features/agenda/domain/entities/intervalo.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:provider/provider.dart';

class DayConfigBottomSheetWidget extends StatelessWidget {
  // final DiaTrabalho diaTrabalho;
  final AgendaController controller; 
  final String selectedDay;

  const DayConfigBottomSheetWidget({super.key, required this.controller, required this.selectedDay});

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
                "Configurar Dia - $selectedDay",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  controller.addInterval(controller.selectedDiaTrabalho.diaSemana);
                },
                icon: const Icon(Icons.add, color: Color(0xFFEC489A)),
                label: const Text("ADICIONAR", style: TextStyle(color: Color(0xFFEC489A))),
              )
            ],
          ),

            Selector<AgendaController, List<Intervalo>>(
              selector: (_, controller) => controller.selectedDiaTrabalho.pausas,
              builder: (context, pausas, child) {
                return ListView.builder(
                  itemCount: pausas.isEmpty ? 0 : pausas.length ,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    final pausa = pausas[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.free_breakfast_outlined, color: Colors.grey),
                          const SizedBox(width: 12),
                          // BOTÃO DE INÍCIO DA PAUSA
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                String? pickedTime = await TimePickerHelper.selectTime(context, pausa.inicio);
                                if (pickedTime != null) {
                                  controller.updateInterval(controller.selectedDiaTrabalho.diaSemana, pausa.intervalId, novoInicio: pickedTime);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Início", 
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Deixa menorzinho
                                ),
                                child: Text(pausa.inicio),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // BOTÃO DE FIM DA PAUSA
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                String? pickedTime = await TimePickerHelper.selectTime(context, pausa.fim);
                                if (pickedTime != null) {
                                  controller.updateInterval(controller.selectedDiaTrabalho.diaSemana, pausa.intervalId, novoFim: pickedTime);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Fim", 
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                ),
                                child: Text(pausa.fim),
                              ),
                            ),
                          ),
                          // BOTÃO DE EXCLUIR
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => controller.removeInterval(controller.selectedDiaTrabalho.diaSemana, pausa.intervalId),
                          ),
                        ],
                      ),
                    );
                  },

                );
              },
            ),

          const SizedBox(height: 30),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}