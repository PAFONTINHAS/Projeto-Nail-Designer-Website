import 'package:mobile/features/agenda/data/datasource/agenda_remote_datasource.dart';
import 'package:mobile/features/agenda/data/datasource/agenda_remote_datasource_impl.dart';
import 'package:mobile/features/agenda/data/repository/agenda_repository_impl.dart';
import 'package:mobile/features/agenda/domain/repository/agenda_repository.dart';
import 'package:mobile/features/agenda/domain/usecases/get_agenda_usecase.dart';
import 'package:mobile/features/agenda/domain/usecases/update_agenda_usecase.dart';
import 'package:mobile/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ConfiguracoesProvider {
  ConfiguracoesProvider._();

  static final ConfiguracoesRemoteDatasource configuracoesRemoteDatasource = ConfiguracoesRemoteDatasourceImpl();
  static final ConfiguracoesRepository configuracoesRepository = ConfiguracoesRepositoryImpl(configuracoesRemoteDatasource);
  static final GetAgendaUsecase getAgendaUsecase = GetAgendaUsecase(configuracoesRepository);
  static final UpdateAgendaUsecase updateAgendaUsecase = UpdateAgendaUsecase(configuracoesRepository);

  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => AgendaController(getAgendaUsecase, updateAgendaUsecase))
  ];
}