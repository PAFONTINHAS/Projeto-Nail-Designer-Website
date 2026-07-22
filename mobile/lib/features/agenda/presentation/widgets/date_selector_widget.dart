import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:provider/provider.dart';

class DateSelectorWidget extends StatefulWidget {
  const DateSelectorWidget({super.key});

  @override
  State<DateSelectorWidget> createState() => _DiasSelectorState();
}

class _DiasSelectorState extends State<DateSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    final List<String> diasSemana = ["D", "S", "T", "Q", "Q", "S", "S"];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Selector<AgendaController, List<int>>(
        selector: (_, controller) => controller.selecionados,
        builder: (context, selecionados, child) {
          final controller = context.read<AgendaController>();
          controller.orderDiasSelecionados();

          Logger().i("Dias selecionados:  $selecionados");
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isSelected = selecionados.contains(index);
              return GestureDetector(
                onTap: () {
                  isSelected
                      ? controller.removeDiaSelecionado(index)
                      : controller.addDiaSelecionado(
                          index,
                        ); // selecionados.remove(index) : selecionados.add(index);
                },
                child: CircleAvatar(
                  backgroundColor: isSelected
                      ? const Color(0xFFEC489A)
                      : Colors.grey[200],
                  child: Text(
                    diasSemana[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
