import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:mobile/features/agenda/presentation/widgets/blocked_dates_widget.dart';
import 'package:mobile/features/agenda/presentation/widgets/business_hours_widget.dart';
import 'package:mobile/features/agenda/presentation/widgets/change_based_button_widget.dart';
import 'package:mobile/features/agenda/presentation/widgets/schedule_activity_status_card_widget.dart';
import 'package:provider/provider.dart';

final logger = Logger();

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {

  @override
  Widget build(BuildContext context) {

    final controller = context.watch<AgendaController>();

    logger.i("\nDias de trabalho: ${controller.diasTrabalho}. \nAgenda atual: ${controller.agenda}");
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Fundo levemente acinzentado para destacar os cards
      appBar: AppBar(
        title: const Text(
          "Configurações de Agenda",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [

              // SEÇÃO 1: STATUS DA AGENDA
              const ScheduleActivityStatusCardWidget(),

              const SizedBox(height: 20),

              // SEÇÃO 2: DIAS E HORÁRIOS
              if(controller.agendaAtiva) const BusinessHoursWidget(),

              const SizedBox(height: 20),

              // SEÇÃO 3: BLOQUEIO DE DATAS
              if(controller.agendaAtiva) const BlockedDatesWidget(),

              const SizedBox(height: 30),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      // floatingActionButton: Center(child: ChangeBasedButtonWidget(),)
      persistentFooterButtons: [

        if(controller.haveAgendaChanged) ChangeBasedButtonWidget()
        
      ],
      persistentFooterDecoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
    );
  }
}
