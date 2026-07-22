import 'package:flutter/material.dart';

class DayConfigBottomSheetWidget extends StatelessWidget {
  final dynamic diaTrabalho;
  final dynamic controller;

  const DayConfigBottomSheetWidget({super.key, required this.diaTrabalho, required this.controller});

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
                  onTap: () { /* Abrir TimePicker e atualizar diaTrabalho.inicio */ },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Início", border: OutlineInputBorder()),
                    child: Text(diaTrabalho.inicio),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: () { /* Abrir TimePicker e atualizar diaTrabalho.fim */ },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: "Fim", border: OutlineInputBorder()),
                    child: Text(diaTrabalho.fim),
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
          ...diaTrabalho.pausas.map((pausa) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.free_breakfast_outlined),
            title: Text("${pausa.inicio} até ${pausa.fim}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => controller.removerPausa(diaTrabalho.diaSemana, pausa),
            ),
          )),
          
          const SizedBox(height: 30),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}