import 'package:flutter/material.dart';
import 'package:mobile/features/agenda/domain/entities/agenda.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:provider/provider.dart';

class HandleUpdateAgenda {
  HandleUpdateAgenda ._();

  static Future<void> call(BuildContext context) async{

    final controller = context.read<AgendaController>();

    final Agenda updatedAgenda = await controller.buildUpdatedAgenda();

    if(!context.mounted) return;
    
    await controller.updateAgenda(updatedAgenda, context);

  }
}