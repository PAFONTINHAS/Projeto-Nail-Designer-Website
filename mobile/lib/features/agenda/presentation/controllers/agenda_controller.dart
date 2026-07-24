import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/agenda/domain/entities/agenda.dart';
import 'package:mobile/features/agenda/domain/entities/dia_trabalho.dart';
import 'package:mobile/features/agenda/domain/entities/intervalo.dart';
import 'package:mobile/features/agenda/domain/usecases/get_agenda_usecase.dart';
import 'package:mobile/features/agenda/domain/usecases/update_agenda_usecase.dart';
import 'package:mobile/features/agenda/presentation/pages/agenda_config_page.dart';

class AgendaController extends ChangeNotifier{

  final GetAgendaUsecase _getAgendaUsecase;
  final UpdateAgendaUsecase _updateAgendaUsecase;

  AgendaController(this._getAgendaUsecase,  this._updateAgendaUsecase);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Agenda? _agenda;
  Agenda? get agenda => _agenda;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<DiaTrabalho> _diasTrabalho = [];
  List<DiaTrabalho> get diasTrabalho => _diasTrabalho;
  
  String _horarioInicio = "";
  String get horarioInicio => _horarioInicio;
  
  String _horarioFim = "";
  String get horarioFim => _horarioFim;

  List<int> _selecionados  = [];
  List<int> get selecionados => _selecionados;

  List<String> _datasBloqueadas = [];
  List<String> get datasBloqueadas => _datasBloqueadas;

  late DiaTrabalho _selectedDiaTrabalho;
  DiaTrabalho get selectedDiaTrabalho => _selectedDiaTrabalho;

  bool _agendaAtiva = true;
  bool get agendaAtiva => _agendaAtiva;

  bool get haveAgendaChanged => verifyAgendaChanges();

  Future<void> fillAgenda() async{

    _diasTrabalho = agenda?.diasTrabalho ?? [];
    _datasBloqueadas = agenda?.datasBloqueadas ?? _datasBloqueadas;
    _agendaAtiva = agenda?.agendaAtiva ?? _agendaAtiva;

    notifyListeners();
  }

  bool verifyAgendaChanges(){

    if (agenda == null) return false;


    if(_agendaAtiva != agenda!.agendaAtiva) return true;

    if(!_islistsEqual(_diasTrabalho, agenda!.diasTrabalho)) return true;

    
    if(!_islistsEqual(_datasBloqueadas, agenda!.datasBloqueadas)) return true;

    return false;
  }

  bool _islistsEqual(List a, List b){
    if(a.length != b.length) return false;

    for(int i = 0; i<a.length; i++){
      if(a[i] != b[i]) return false;
    }

    return true;
  }

  void toggleWorkDay(int weekday, bool value){

    logger.i("Toggling workday. Weekday: $weekday, active: $value");

    if(!value){

      logger.i("Toggling workday. Weekday: $weekday, active: $value");

      _diasTrabalho.removeWhere((dia) => dia.diaSemana == weekday);

      notifyListeners();

      return;
    }

    DiaTrabalho diaTrabalho = generateGenericWorkDay(weekday);

    _addNewWorkday(diaTrabalho);

    notifyListeners();
  }

  void _addNewWorkday(DiaTrabalho workDay){

    logger.i("Dia a ser adicionado: $workDay");

    bool alreadyIn = _diasTrabalho.any((day) => day.diaSemana == workDay.diaSemana);

    logger.i("Lista já possui o dia inserido: $alreadyIn");

    if(alreadyIn){

      int index = _diasTrabalho.indexWhere((day) => day.diaSemana == workDay.diaSemana);

      List<DiaTrabalho> workdays = _diasTrabalho;

      workdays[index] = workDay;

      _diasTrabalho = workdays;

      logger.i("Dia alterado com sucesso");

      logger.i("Agenda atual: $_diasTrabalho");


      return;
    }

    _diasTrabalho = List.from(_diasTrabalho)..add(workDay);

    logger.i("Dia adicionado com sucesso");

    logger.i("Agenda atual: $_diasTrabalho");
  }

  void changeOpeningHour(int weekday, String openingHour){
    
    logger.i("Alterando o horário de inicio para o dia: $weekday. Horário de inicio: $openingHour");

    final DiaTrabalho outdatedWorkday = _diasTrabalho.firstWhere((day) => day.diaSemana == weekday);

    final DiaTrabalho updatedWorkday = outdatedWorkday.copyWith(inicio: openingHour);

    _addNewWorkday(updatedWorkday);

    setSelectedDiaTrabalho(updatedWorkday);

    notifyListeners();  

  }

  void setSelectedDiaTrabalho (DiaTrabalho diaTrabalho){
    _selectedDiaTrabalho = diaTrabalho;
    notifyListeners();
  }

  void addInterval(int weekday){

    List<Intervalo> intervalos = List.from(selectedDiaTrabalho.pausas)
      ..sort((a, b) => a.intervalId.compareTo(b.intervalId));


    int intervalId = intervalos.isEmpty ? 0 : intervalos.last.intervalId + 1;

    Intervalo intervalo = Intervalo(intervalId, "10:00", "11:00");

    intervalos.add(intervalo);

    DiaTrabalho outdatedWorkday = getWorkDayByWeekDay(weekday);

    DiaTrabalho updatedWorkday = outdatedWorkday.copyWith(pausas: intervalos);
    setSelectedDiaTrabalho(updatedWorkday);

    _addNewWorkday(updatedWorkday);

    notifyListeners();
  }

  void removeInterval(int weekday, int intervalId){

    List<Intervalo> intervalos = List.from(selectedDiaTrabalho.pausas)..removeWhere((pausa) => pausa.intervalId == intervalId);

    DiaTrabalho outdatedWorkday = getWorkDayByWeekDay(weekday);

    DiaTrabalho updatedWorkday = outdatedWorkday.copyWith(pausas: intervalos);
    setSelectedDiaTrabalho(updatedWorkday);

    _addNewWorkday(updatedWorkday);

    notifyListeners();
  }

  DiaTrabalho getWorkDayByWeekDay(int weekday){

    return _diasTrabalho.firstWhere((day) => day.diaSemana == weekday);

  }

  void changeClosingHour(int weekday, String closingHour){

    final DiaTrabalho outdatedWorkday = _diasTrabalho.firstWhere((day) => day.diaSemana == weekday);

    final DiaTrabalho updatedWorkday = outdatedWorkday.copyWith(fim: closingHour);

    _addNewWorkday(updatedWorkday);

    setSelectedDiaTrabalho(updatedWorkday);

    notifyListeners();  
  }

  DiaTrabalho generateGenericWorkDay(int weekday){

    return DiaTrabalho(diaSemana: weekday, inicio: "09:00", fim: "18:00");
  }

  void orderDiasSelecionados(){
    
    if(_selecionados.isEmpty) return;
  
    _selecionados.sort();
  }
  
  void setHorarioInicio (String novoHorario){
    _horarioInicio = novoHorario;
    Logger().i("Horário selecionado: $_horarioInicio");
    notifyListeners();
  }

  void setHorarioFim (String novoHorario){
    _horarioFim = novoHorario;
    Logger().i("Horário selecionado: $_horarioFim");
    notifyListeners();
  }

  void addDiaSelecionado(int novoDia){
    _selecionados = List.from(_selecionados)..add(novoDia);

    orderDiasSelecionados();
    notifyListeners();
  }

  void removeDiaSelecionado(int dia){
    _selecionados = List.from(_selecionados)..removeWhere((diaAntigo) => dia == diaAntigo);
    
    orderDiasSelecionados();
    notifyListeners();
  }

  void toggleAgendaAtiva(bool value){
    _agendaAtiva = value;
    notifyListeners();
  }

  void addDataBloqueada(DateTime date){

    List<String> updatedDates = List.from(_datasBloqueadas);

    String dataFormatada = date.toIso8601String().split('T')[0];

    if(!_datasBloqueadas.contains(dataFormatada)){
      
      updatedDates.add(dataFormatada);
    }

    updatedDates.sort();

    _datasBloqueadas = updatedDates;
    notifyListeners();
  }

  void removeDataBloqueada(String date){
    List<String> updatedDates = List.from(_datasBloqueadas);

    updatedDates.remove(date);

    _datasBloqueadas = updatedDates;

    notifyListeners();

  }

  Future<void> getAgenda() async{

    final fetchedAgenda = await _getAgendaUsecase.call();

    _agenda = fetchedAgenda;

    notifyListeners();

  }


  Future<Agenda> buildUpdatedAgenda() async{
    
    return Agenda(
      agendaAtiva: agendaAtiva,
      diasTrabalho: _diasTrabalho,
      datasBloqueadas: datasBloqueadas,
    );
  }  

  void locallyUpdateAgenda(Agenda updatedAgenda){

    _agenda = updatedAgenda;
    notifyListeners();
  }

  Future<void> updateAgenda(Agenda agenda, BuildContext context) async{

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      await _updateAgendaUsecase.call(agenda);

      locallyUpdateAgenda(agenda);

      if(context.mounted){
        _mostrarFeedback(context, "Configurações salvas com sucesso! 💅", Colors.green);
      }
    } catch (e) {
    _errorMessage = "Erro ao salvar: $e";
    if (context.mounted) {
      _mostrarFeedback(context, "Erro ao salvar configurações", Colors.red);
    }
  } finally {
    _isLoading = false;
    notifyListeners();
  }
  }

}

void _mostrarFeedback(BuildContext context, String mensagem, Color cor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensagem, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: cor,
      behavior: SnackBarBehavior.floating, // Dá um ar mais moderno/mobile
      duration: const Duration(seconds: 2),
    ),
  );
}