import 'package:flutter/material.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:mobile/features/agendamento/presentation/controllers/agendamento_fields_controller.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/servico/presentation/pages/servicos_page.dart';
import 'package:mobile/features/home/presentation/widgets/empty_list_widget.dart';
import 'package:mobile/features/agenda/presentation/pages/agenda_config_page.dart';
import 'package:mobile/features/agendamento/domain/entities/agendamento_entity.dart';
import 'package:mobile/features/relatorios/presentation/pages/relatorios_page.dart';
import 'package:mobile/features/agendamento/presentation/pages/agendamento_page.dart';
import 'package:mobile/features/home/presentation/widgets/agendamento_card_widget.dart';
import 'package:mobile/features/servico/presentation/controllers/servico_controller.dart';
import 'package:mobile/features/home/presentation/pages/agendamentos_atrasados_page.dart';
import 'package:mobile/features/relatorios/presentation/controllers/relatorio_controller.dart';
import 'package:mobile/features/agendamento/presentation/controllers/agendamento_controller.dart';
import 'package:mobile/features/relatorios/presentation/controllers/relatorio_fields_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // home_page.dart

@override
Widget build(BuildContext context) {
  final controller = context.watch<AgendamentoController>();
  final String dataVisualizada = "${controller.dataVisualizada.day.toString().padLeft(2, '0')}/${controller.dataVisualizada.month.toString().padLeft(2, '0')}";

  return SafeArea(
    top: false,
    left: false,
    right: false,
    child: Scaffold(

    backgroundColor: const Color(0xFFF8F9FA),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        final agendamentoController=  context.read<AgendamentoController>();
        final agendaController = context.read<AgendaController>();
        final agendamentoFieldsController = context.read<AgendamentoFieldsController>();

        agendamentoFieldsController.setAgendamentosDoDia(agendamentoController.agendamentos);

        if(agendaController.agenda != null){

          agendamentoFieldsController.setAgenda(agendaController.agenda!);
        }
        
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendamentoPage()));
      } ,
      backgroundColor: const Color(0xFFEC489A), // O pink do Studio
      icon: const Icon(Icons.add_task, color: Colors.white),
      label: const Text("Novo Agendamento", style: TextStyle(color: Colors.white)),
    ),
    body: CustomScrollView( // Usando CustomScrollView para um efeito de scroll mais fluido
      slivers: [
        // 1. TÍTULO E HEADER PERSONALIZADO
        SliverAppBar(
          expandedHeight: 120.0,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: const Text(
              "Studio Natália", 
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 2. GRID DE AÇÕES RÁPIDAS (Onde entram Serviços e Agenda)
                const Text("Gerenciamento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                // const SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3, // 3 colunas para caber Relatórios depois
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 15,
                  children: [
                    _buildMenuCard(
                      context, 
                      "Agenda", 
                      Icons.calendar_month, 
                      const Color(0xFFEC489A),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigPage())),
                    ),
                    _buildMenuCard(
                      context, 
                      "Serviços", 
                      Icons.apps, 
                      Colors.purpleAccent,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicosPage())), // Página que vamos criar
                    ),
                    _buildMenuCard(
                      context, 
                      "Relatórios", 
                      Icons.bar_chart_rounded, 
                      Colors.blueAccent,
                      () async{
                        
                        final relatorioFieldsController = context.read<RelatorioFieldsController>();
                        final relatorioController = context.read<RelatorioController>();
                        final agendamentoController = context.read<AgendamentoController>();
                        final agendamentos = agendamentoController.agendamentos;
                        final servicos = context.read<ServicoController>().servicos.values.toList();
                        
                        relatorioFieldsController.updateData(agendamentos);
                        relatorioFieldsController.calcularDistribuicaoPorCategoria(servicos);

                        final newRelatorio = await relatorioFieldsController
                            .verifyAndConsolidatePreviousMonth(
                              todosAgendamentos: agendamentos,
                              todosServicos: servicos,
                              agendamentoController: agendamentoController,
                            );

                        if(newRelatorio != null) await relatorioController.addRelatorio(newRelatorio);

                        if(!context.mounted) return;
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RelatoriosPage()));

                      }  // Página que vamos criar
                    ),
                  ],
                ),

              
                const SizedBox(height: 30),

                if (controller.agendamentosAtrasados.isNotEmpty)

                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendamentosAtrasadosPage())), // Leva para a lista filtrada
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            "Você tem ${controller.agendamentosAtrasados.length} pendências passadas!",
                            style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),



                // 3. SELETOR DE DATA PARA AGENDAMENTOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Próximos Clientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Visualizando dia $dataVisualizada", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: controller.dataVisualizada,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) controller.setDataVisualizada(date);
                      },
                      icon: const Icon(Icons.filter_list, color: Color(0xFFEC489A)),
                      label: const Text("Mudar Data", style: TextStyle(color: Color(0xFFEC489A))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // 4. LISTA DE AGENDAMENTOS (SliverList para performance)
        const SliverFillRemaining(
          hasScrollBody: true,
          child: AgendamentosListWidget(),
        ),
      ],
    ),
  ),


    
    
    
    );
  
}

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback? onTap, {bool isLocked = false}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
            if (isLocked) const Text("Breve", style: TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
}
}

class AgendamentosListWidget extends StatelessWidget {
  const AgendamentosListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AgendamentoController, List<AgendamentoEntity>>(
      selector: (_, controller) => controller.agendamentosDataSelecionada,
      builder: (context, agendamentos, _) {
       return agendamentos.isEmpty
            ? const EmptyListWidget()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: agendamentos.length,
                itemBuilder: (context, index) {
                  final agendamento = agendamentos[index];
                  return AgendamentoCard(agendamento: agendamento);
                },
              );
      },
    );
  }
}
