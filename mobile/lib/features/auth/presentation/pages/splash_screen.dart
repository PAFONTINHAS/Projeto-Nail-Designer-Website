import 'package:flutter/material.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/features/agendamento/presentation/controllers/agendamento_fields_controller.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/home/presentation/pages/home_page.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:mobile/features/servico/presentation/controllers/servico_controller.dart';
import 'package:mobile/features/relatorios/presentation/controllers/relatorio_controller.dart';
import 'package:mobile/features/relatorios/presentation/controllers/relatorio_fields_controller.dart';
import 'package:mobile/features/agendamento/presentation/controllers/agendamento_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _prepareUserApp();
    }); 
  }

  Future<void> _prepareUserApp() async{

    final servicoController = context.read<ServicoController>();
    final relatorioController = context.read<RelatorioController>();
    final agendamentoController = context.read<AgendamentoController>();
    final configuracoesController = context.read<AgendaController>();
    final relatorioFieldsController = context.read<RelatorioFieldsController>();
    final agendamentoFieldsController = context.read<AgendamentoFieldsController>();

    await NotificationService().init();

    await Future.wait([
      servicoController.getServicos(),
      configuracoesController.getAgenda(),
      agendamentoController.listenAgendamentos(),
      relatorioController.getRelatorios()
    ]);

    await Future.wait([
      configuracoesController.fillAgenda(),
      relatorioFieldsController.updateRelatorios(relatorioController.relatorios),
    ]);

    if(configuracoesController.agenda != null){

      agendamentoFieldsController.setAgenda(configuracoesController.agenda!);
    }
    agendamentoFieldsController.setServicosDisponiveis(servicoController.servicosList);

    if(!mounted) return;
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false
    );

  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Text("Preparando seu aplicativo"),
        ],
      )

    ));
  }
}