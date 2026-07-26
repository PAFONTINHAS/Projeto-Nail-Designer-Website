import 'package:flutter/material.dart';
import 'package:mobile/core/utils/helpers.dart';
import 'package:mobile/features/agenda/domain/entities/agenda.dart';
import 'package:mobile/features/agenda/domain/entities/dia_trabalho.dart';
import 'package:mobile/features/agenda/presentation/pages/agenda_config_page.dart';
import 'package:mobile/features/agendamento/domain/entities/agendamento_entity.dart';
import 'package:mobile/features/agendamento/domain/entities/horario_slot.dart';
import 'package:mobile/features/servico/domain/entities/servico.dart';

class AgendamentoFieldsController extends ChangeNotifier{

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  TextEditingController get nameController => _nameController;
  TextEditingController get phoneController => _phoneController;

  DateTime _dataSelecionada = DateTime.now();
  DateTime get dataSelecionada => _dataSelecionada;

  List<AgendamentoEntity> _agendamentosDoDia = [];
  List<AgendamentoEntity> get agendamentosDoDia => _agendamentosDoDia;


  String? _horarioSelecionado;
  String? get horarioSelecionado => _horarioSelecionado;

  Agenda? _agenda;
  Agenda? get agenda => _agenda;

  List<Servico> _servicosDisponiveis = [];
  List<Servico> get servicosDisponiveis {
    return _servicosDisponiveis.where(
      (servico) => 
        servico.servicoAtivo && 
        servico.categoria == _categoriaAtiva
      )
      .toList();
  }

  bool get isDayBlocked{
    
    if(agenda == null) return true;

    final dateString = "${_dataSelecionada.year}-${_dataSelecionada.month.toString().padLeft(2, '0')}-${_dataSelecionada.day.toString().padLeft(2, '0')}";

    for(final blockedDay in agenda!.datasBloqueadas ){
      if(dateString == blockedDay){
        return true;
      }
    }

   int weekday = _dataSelecionada.weekday;

   bool worksOnThisDay = agenda!.diasTrabalho.any((dia) => dia.diaSemana == weekday);

    return !worksOnThisDay;
  }

  String _categoriaAtiva = "Alongamento";
  String get categoriaAtiva => _categoriaAtiva;

  int get tempoTotal {
    return selecionados.fold(0, (sum, item) => sum + item.duracao);
  }

  double get valorTotal{
    return selecionados.fold(0.0, (sum, item) => sum + item.preco);
  }

  List<Servico> _selecionados = [];
  List<Servico> get selecionados => _selecionados;

  List<HorarioSlot> get gerarGradeHorarios{
    if(agenda == null) return [];

    final diaTrabalho = agenda!.diasTrabalho.where((dia) => dia.diaSemana == _dataSelecionada.weekday).firstOrNull;

    if(diaTrabalho == null) return [];

    List<HorarioSlot> slots = [];

    final int inicio = convertStringToTime(diaTrabalho.inicio);
    final int fim = convertStringToTime(diaTrabalho.fim);
    final int duracao = tempoTotal;

    for(int minutes = inicio; minutes < fim; minutes += 30){
      String horaFormatada = formatMinutes(minutes);

      bool estaOcupado = _verificarConflito(minutes, agendamentosDoDia) || _verificarConflitoPausa(minutes, diaTrabalho.pausas);

      bool cabeDuracao = _verificarSeCabe(minutes, duracao, agendamentosDoDia, fim) && _verificarSeCabeNaPausa(minutes, duracao, diaTrabalho.pausas);

      slots.add(HorarioSlot(hora: horaFormatada, ocupado: estaOcupado, disponivelPelaDuracao: cabeDuracao));
    }

    return slots;

  }

  bool _verificarConflitoPausa(int minutos, List<dynamic> pausas) {
    return pausas.any((pausa) {
      int inicioPausa = convertStringToTime(pausa.inicio);
      int fimPausa = convertStringToTime(pausa.fim);
      
      return minutos >= inicioPausa && minutos < fimPausa;
    });
  }

  bool _verificarSeCabeNaPausa(int momentoInicio, int duracaoNecessaria, List<dynamic> pausas) {
    int momentoFimProposto = momentoInicio + duracaoNecessaria;

    return !pausas.any((pausa) {
      int inicioPausa = convertStringToTime(pausa.inicio);
      int fimPausa = convertStringToTime(pausa.fim);
      
      // Existe conflito se o atendimento começar antes da pausa terminar e terminar depois da pausa começar
      return momentoInicio < fimPausa && momentoFimProposto > inicioPausa;
    });
  }

  bool _verificarConflito(int minutos, List<AgendamentoEntity> agendamentosDoDia){
    
    return agendamentosDoDia.any((agendamento){
      final dataAgendamento = agendamento.data;

      int inicioOcupado = (dataAgendamento.hour * 60) + dataAgendamento.minute;
      int fimOcupado = inicioOcupado + agendamento.duracaoTotal;

      return minutos >= inicioOcupado && minutos < fimOcupado;
     
    });

  }

  bool _verificarSeCabe(int momentoInicio, int duracaoNecessaria, List<AgendamentoEntity> agendamentosOcupados, int limiteFechamento) {
    int momentoFimProposto = momentoInicio + duracaoNecessaria;

    // 1. Verifica se ultrapassa o horário de fechar o Studio
    if (momentoFimProposto > limiteFechamento) return false;

    // 2. Verifica se algum agendamento existente começa antes de terminarmos o atual
    return !agendamentosOcupados.any((agendamento) {
      DateTime dataAgendada = agendamento.data;
      int inicioOcupado = (dataAgendada.hour * 60) + dataAgendada.minute;
      int fimOcupado = inicioOcupado + agendamento.duracaoTotal;

      // Existe conflito se o nosso atendimento proposto "atropelar" um que já existe
      bool sobrepoeInicio = momentoInicio < fimOcupado && momentoFimProposto > inicioOcupado;
      
      return sobrepoeInicio;
    });
  }

  // Retorna o minuto final do agendamento baseado no horário selecionado
  int? get minutoFinalSelecionado {
    if (horarioSelecionado == null) return null;
    int inicio = convertStringToTime(horarioSelecionado!);
    return inicio + tempoTotal;
  }

  // Verifica se um slot específico faz parte do tempo do serviço selecionado
  bool isNoIntervalo(String horaSlot) {
    if (horarioSelecionado == null) return false;

    int inicio = convertStringToTime(horarioSelecionado!);
    int fim = minutoFinalSelecionado!;
    int atual = convertStringToTime(horaSlot);

    return atual >= inicio && atual < fim;
  }


  AgendamentoEntity? buildNewAgendamento(BuildContext context){

    if (horarioSelecionado == null) {
      mostrarFeedback(context, "Selecione um horário", Colors.red);
      return null;
    }

    final splitedHorario = horarioSelecionado!.split(":");

    final int hora = int.parse(splitedHorario[0]);
    final int minuto = int.parse(splitedHorario[1]);

    logger.i("$hora:$minuto");

    final finalDate = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day, hora, minuto);

    logger.i("data final: $finalDate");

    final List<String> servicos = _selecionados.map((servico){
      return servico.id;
    }).toList(); 

    return AgendamentoEntity(
      id: "",
      data: finalDate,
      status: "agendado",
      servicos: servicos,
      valorTotal: valorTotal,
      nomeCliente: nameController.text.trim(),
      duracaoTotal: tempoTotal,
      contatoCliente: phoneController.text,
      notificacaoEnviada: false,
    );

  }

  void clearForm(){

    _horarioSelecionado = null;
    _dataSelecionada = DateTime.now();
    _selecionados = [];
    phoneController.text = "";
    nameController.text = "";
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    phoneController.dispose();
  }

  void mostrarFeedback(BuildContext context, String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating, // Dá um ar mais moderno/mobile
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void setDataSelecionada(DateTime novaData){
    _dataSelecionada = novaData;

    notifyListeners();
  }

  void setAgendamentosDoDia(List<AgendamentoEntity> agendamentos){
    _agendamentosDoDia = agendamentos;

    logger.i("Agendamentos: ${agendamentos.length}");

    notifyListeners();
  }

  void setAgenda(Agenda agenda){
    _agenda = agenda;
  }


  void setCategoriaAtiva(String categoria){

    _categoriaAtiva = categoria;
    notifyListeners();
  }

  setServicosDisponiveis(List<Servico> servicos){

    _servicosDisponiveis = servicos;
    notifyListeners();
  }
  
  void addServico(Servico servico,BuildContext context){
    
    _selecionados = List.from(_selecionados)..add(servico);
    _validarHorarioAposMudanca(context); 
    notifyListeners();
  }

  void removeServico(Servico servico,BuildContext context){
    _selecionados = List.from(_selecionados)..remove(servico);
    _validarHorarioAposMudanca(context); 
    notifyListeners();
  }

  void _validarHorarioAposMudanca(BuildContext context) {
    if (_horarioSelecionado == null || agenda == null) return;

    final diaTrabalho = agenda!.diasTrabalho.where((d) => d.diaSemana == _dataSelecionada.weekday).firstOrNull;
    if (diaTrabalho == null) return;

    int momentoInicio = convertStringToTime(_horarioSelecionado!);
    int limiteFim = convertStringToTime(diaTrabalho.fim);  

    bool cabeNosAgendamentos = _verificarSeCabe(momentoInicio, tempoTotal, _agendamentosDoDia, limiteFim);
    bool cabeNasPausas = _verificarSeCabeNaPausa(momentoInicio, tempoTotal, diaTrabalho.pausas);

    if (!cabeNosAgendamentos || !cabeNasPausas) {
      _horarioSelecionado = null;
      mostrarFeedback(context, "O horário selecionado não comporta a nova duração.", Colors.orange);
    }
  }

  void setName(String name){
    _nameController.text = name;
    notifyListeners();
  }

  void setPhone(String phone){
    _phoneController.text = phone;
    notifyListeners();
  }

  void setHorarioSelecionado(String? horario){
    _horarioSelecionado = horario;
    notifyListeners();
  }



  List<String> get horariosVagos{
    return ["08:00", "08:30", "09:00", "10:30", "14:00", "15:30"];
  }



}