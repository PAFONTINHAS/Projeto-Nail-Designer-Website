import { last, Subscription } from 'rxjs';
import { NgxMaskDirective } from "ngx-mask";
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { Servico } from '../../shared/models/servico_model';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { Agendamento } from '../../shared/models/agendamento_model';
import { AgendaConfig } from '../../shared/models/agenda_config_model';
import { LucideAngularModule, CircleAlert, Clock } from 'lucide-angular';
import {MatSnackBar, MatSnackBarModule} from '@angular/material/snack-bar';
import { MatNativeDateModule, MAT_DATE_LOCALE } from '@angular/material/core';
import { ServicosService } from '../../shared/services/servicos-service/servicos-service';
import { Component, LOCALE_ID, OnDestroy, OnInit, ChangeDetectorRef } from '@angular/core';
import { AgendamentoService } from '../../shared/services/agendamento-service/agendamento-service';

@Component({
  selector: 'app-agendamentos',
  imports: [
    LucideAngularModule,
    CommonModule,
    MatCardModule,
    MatDatepickerModule,
    MatNativeDateModule,
    NgxMaskDirective,
    MatSnackBarModule,
  ],
  templateUrl: './agendamentos.html',
  styleUrls: [
    './css/agendamentos.css',
    './css/calendar.css',
    './css/dados-cliente.css',
    './css/servicos-grid.css',
    './css/horarios-coluna.css',
    './css/media-query.css',
  ],
})
export class Agendamentos implements OnInit, OnDestroy {
  constructor(
    private readonly agendamentoService: AgendamentoService,
    private readonly servicosService: ServicosService,
    private readonly changeDetectorRef: ChangeDetectorRef,
    private _snackBar: MatSnackBar,
  ) {}

  private agendaSubscription!: Subscription;
  private servicosSubscription!: Subscription;

  agendamentoSolicitado: boolean = false;

  horarioStatus: { hora: string; ocupado: boolean, label?: string}[] = [];

  readonly CircleAlert = CircleAlert;
  readonly Clock = Clock;

  servicos: Servico[] = [];

  gradeHorarios: string[] = [];

  agendaConfig!: AgendaConfig;

  renderizarCalendario: boolean = true;

  async ngOnInit() {
    // this.servicos = (await this.servicosService.getServicos()) as Servico[];

    this.servicosSubscription = this.servicosService
      .servicos$
      .subscribe((remoteServicos) =>{

        if(this.servicosSelecionados.length > 0 || this.dataSelecionada || this.horarioSelecionado){

          this.forcarMudancas();
        }
        
        this.servicos = remoteServicos as Servico[];
      });

    this.agendaSubscription = this.agendamentoService
      .getAgenda()
      .subscribe((config) => {
        if (this.agendaConfig) {
          // this.notificarMudancaEResetar();

          // this.renderizarCalendario = false;
          // this.changeDetectorRef.detectChanges();

          // setTimeout(() => {
          //   this.renderizarCalendario = true;
          //   this.changeDetectorRef.detectChanges();
          // }, 10);
          this.forcarMudancas();
        }

        this.agendaConfig = config;

        this.limparCampos();
        this.changeDetectorRef.detectChanges();
        console.log('Agenda atualizada em tempo real!');
      });
  }

  forcarMudancas(){

    this.notificarMudancaEResetar();
    this.renderizarCalendario = false;
    this.changeDetectorRef.detectChanges();

    setTimeout(() => {
      this.renderizarCalendario = true;
      this.changeDetectorRef.detectChanges();
    }, 10);

    this.limparCampos();
    this.changeDetectorRef.detectChanges();
  }

  notificarMudancaEResetar() {
    this._snackBar.open(
      'A disponibilidade da agenda foi atualizada. Suas seleções foram resetadas por segurança.',
      'Entendi',
      {
        duration: 5000,
        horizontalPosition: 'center',
        verticalPosition: 'bottom',
        panelClass: ['snackbar-aviso'], // Para estilizarmos depois
      },
    );

    // 2. Limpa tudo o que o usuário já tinha feito
    this.limparCampos();
  }

  ngOnDestroy(): void {
    if (this.agendaSubscription) {
      this.agendaSubscription.unsubscribe();
    }

    if(this.servicosSubscription){
      this.servicosSubscription.unsubscribe();
    }
  }


  async getAgendaConfig() {
    return await this.agendamentoService.getAgendaConfig();
  }

  get alongamento_unhas() {
    return this.servicos.filter((servico) => servico.categoria == 'Alongamento'  && servico.servicoAtivo);
  }

  get manutencoes() {
    return this.servicos.filter((servico) => servico.categoria == 'Manutencao' && servico.servicoAtivo);
  }

  get extras() {
    return this.servicos.filter((servico) => servico.categoria == 'Extras' && servico.servicoAtivo);
  }

  cliente: { nome: string; contato: string } = { nome: '', contato: '' };

  servicosSelecionados: Servico[] = [];
  dataSelecionada: Date | null = null;
  horarioSelecionado: string | null = null;

  categoriaAtiva: string = 'Alongamento';

  get servicosDisponiveis() {
    return this.servicos.filter((s) => s.categoria == this.categoriaAtiva && s.servicoAtivo);
  }

  get servicosIndisponiveis(){
    return this.servicos.filter((s) => s.categoria == this.categoriaAtiva && !s.servicoAtivo)
  }

  toggleServico(servico: Servico) {
    const index = this.servicosSelecionados.findIndex(
      (s) => s.id === servico.id,
    );

    if (index > -1) {
      this.servicosSelecionados.splice(index, 1);
    } else {
      this.servicosSelecionados.push(servico);
    }

    this.horarioSelecionado = null;
  }

  selecionarData(data: Date | null) {
    if (!data) return;

    this.dataSelecionada = data;
    this.horarioSelecionado = null;

    this.agendamentoService
      .getAgendamentosDoDia(data)
      .subscribe((agendamentos) => {
        console.log('Agendamentos ocupados: ', agendamentos);
        this.atualizarHorariosDisponiveis(agendamentos);
      });
  }

  prosseguirAgendamento() {
    this.agendamentoSolicitado = true;
  }

  limparCampos() {
    this.agendamentoSolicitado = false;
    this.dataSelecionada = null;
    this.horarioSelecionado = null;
    this.servicosSelecionados = [];
    this.horarioStatus = [];
    this.categoriaAtiva = 'Alongamento';
    this.changeDetectorRef.detectChanges();
  }

  async finalizarAgendamento(nome: string, contato: string) {
    if (!this.dataSelecionada || !this.horarioSelecionado) return;

    const dataFinal = new Date(this.dataSelecionada);

    const [horas, minutos] = this.horarioSelecionado.split(':').map(Number);
    dataFinal.setHours(horas, minutos);

    const novoAgendamento : Agendamento = {
      data: dataFinal, // O SDK do Firebase converterá automaticamente para Timestamp
      nomeCliente: nome,
      status: 'agendado',
      contatoCliente: contato, 
      notificacaoEnviada: false,
      valorTotal: this.totalPreco,
      duracaoTotal: this.totalDuracao,
      servicos: this.servicosSelecionados.map((s) => s.id),
    };

    try {
      await this.agendamentoService.salvarAgendamento(novoAgendamento as Agendamento);
      alert('Agendamento realizado com sucesso!');
      this.limparCampos();
    } catch (error) {
      console.error('Erro ao salvar: ', error);
    }
  }

  atualizarHorariosDisponiveis(agendamentosOcupados: any[]) {
    if (!this.dataSelecionada || !this.agendaConfig) return;

    // Converte o dia do JS (0-6) para o padrão Dart (1-7)
    const diaSemanaJS = this.dataSelecionada.getDay();
    const diaSemanaDart = diaSemanaJS === 0 ? 7 : diaSemanaJS;

    const diaTrabalho = this.agendaConfig.diasTrabalho.find(d => d.diaSemana === diaSemanaDart);
    if (!diaTrabalho) {
      this.horarioStatus = [];
      return;
    }

    const converterParaMinutos = (h: string) => {
      const [horas, minutos] = h.split(':').map(Number);
      return horas * 60 + minutos;
    };

    const inicioDia = converterParaMinutos(diaTrabalho.inicio);
    const fimDia = converterParaMinutos(diaTrabalho.fim);
    const duracaoDesejada = this.totalDuracao;
    
    // MUDANÇA: Intervalos de 30 minutos
    const intervalo = 30; 
    this.horarioStatus = [];

    for (let minutos = inicioDia; minutos < fimDia; minutos += intervalo) {
      const h = Math.floor(minutos / 60);
      const m = minutos % 60;
      const horarioFormatado = `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;

      const inicioProposto = minutos;
      const fimProposto = inicioProposto + duracaoDesejada;

      // 1. Verifica se ultrapassa o fim do expediente
      if (fimProposto > fimDia) {
        this.horarioStatus.push({ hora: horarioFormatado, ocupado: true, label: 'Indisponível' });
        continue;
      }

      // 2. Verifica conflito com outros clientes
      const conflitoAgendamento = agendamentosOcupados.some((agendamento) => {
        const dataAgendada: Date = agendamento.data.toDate();
        const inicioOcupado = dataAgendada.getHours() * 60 + dataAgendada.getMinutes();
        const fimOcupado = inicioOcupado + agendamento.duracaoTotal;

        // O slot em si começa durante um agendamento? (Resolve o problema do tempo zero)
        const slotDentro = inicioProposto >= inicioOcupado && inicioProposto < fimOcupado;
        // A duração do serviço vai atropelar um agendamento?
        const atravessa = inicioProposto < fimOcupado && fimProposto > inicioOcupado;

        return slotDentro || atravessa;
      });

      // 3. Verifica conflito com as pausas de descanso/almoço
      const conflitoPausa = diaTrabalho.pausas?.some((pausa) => {
        const inicioPausa = converterParaMinutos(pausa.inicio);
        const fimPausa = converterParaMinutos(pausa.fim);

        // O slot em si começa durante uma pausa? (Bloqueia as 10:00 certinho)
        const slotDentro = inicioProposto >= inicioPausa && inicioProposto < fimPausa;
        // A duração do serviço vai invadir a pausa?
        const atravessa = inicioProposto < fimPausa && fimProposto > inicioPausa;

        return slotDentro || atravessa;
      });

      let textoLabel = '';

      if(conflitoAgendamento){
        textoLabel = 'Ocupado';
      } else if(conflitoPausa){
        textoLabel = 'Indisponível';
      }

      this.horarioStatus.push({
        hora: horarioFormatado,
        ocupado: conflitoAgendamento || conflitoPausa || false,
        label: textoLabel
      });
    }

    this.changeDetectorRef.detectChanges();
  }

  selecionarHorario(hora: string) {
    if (!this.agendaConfig || !this.dataSelecionada) return;

    const diaSemanaJS = this.dataSelecionada.getDay();
    const diaSemanaDart = diaSemanaJS === 0 ? 7 : diaSemanaJS;
    const diaTrabalho = this.agendaConfig.diasTrabalho.find(d => d.diaSemana === diaSemanaDart);

    if (!diaTrabalho) return;

    const [h, m] = hora.split(':').map(Number);
    const inicio = h * 60 + m;
    const fim = inicio + this.totalDuracao;

    // Lê o horário de fim específico daquele dia
    const [hFim, mFim] = diaTrabalho.fim.split(':').map(Number);
    const limiteFechamento = hFim * 60 + mFim;

    if (fim > limiteFechamento) {
      alert('Este serviço termina após o horário de fechamento. Escolha um horário mais cedo.');
      return;
    }

    const conflitoNoIntervalo = this.horarioStatus.some((item) => {
      const [hItem, mItem] = item.hora.split(':').map(Number);
      const minutoItem = hItem * 60 + mItem;
      const estariaNoCaminho = minutoItem >= inicio && minutoItem < fim;

      return item.ocupado && estariaNoCaminho;
    });

    if (conflitoNoIntervalo) {
      alert('A duração deste serviço conflita com uma pausa ou horário já reservado.');
      return;
    }

    this.horarioSelecionado = hora;
  }

  isNoIntervaloSelecionado(horaCard: string): boolean {
    if (!this.horarioSelecionado) return false;

    const [hsel, mSel] = this.horarioSelecionado.split(':').map(Number);
    const inicioMinutos = hsel * 60 + mSel;

    const fimMinutos = inicioMinutos + this.totalDuracao;

    const [hCard, mCard] = horaCard.split(':').map(Number);
    const cardMinutos = hCard * 60 + mCard;

    return cardMinutos >= inicioMinutos && cardMinutos < fimMinutos;
  }

  toggleCategoria(categoria: string) {
    this.categoriaAtiva = categoria;
  }

  isServicoSelecionado(servicoId: string): boolean {
    return this.servicosSelecionados.some((s) => s.id === servicoId);
  }

  isCategoriaSelecionada(categoriaNome: string): boolean {
    return this.categoriaAtiva == categoriaNome;
  }

  get totalPreco() {
    return this.servicosSelecionados.reduce(
      (total, servico) => total + servico.preco,
      0,
    );
  }

  get totalDuracao() {
    return this.servicosSelecionados.reduce(
      (total, servico) => total + servico.duracao,
      0,
    );
  }

  filtroDeDatas = (d: Date | null): boolean => {
    const data = d || new Date();
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);

    // 1. Bloqueia se a agenda estiver desativada globalmente
    if (!this.agendaConfig?.agendaAtiva) return false;

    // 2. Bloqueia dias passados
    if (data < hoje) return false;

    // 3. Bloqueia dias da semana (Segunda, Terça...)
    const diaSemanaJs = data.getDay();
    const diaSemanaDart = diaSemanaJs === 0 ? 7 : diaSemanaJs;

    const trabalhaNesteDia = this.agendaConfig.diasTrabalho.some(dia => dia.diaSemana === diaSemanaDart);
    if (!trabalhaNesteDia) return false;

    // 4. Bloqueia Datas Específicas (Feriados/Folgas)
    // Ajustando fuso para comparação de String ISO
    const offset = data.getTimezoneOffset();
    const dataAjustada = new Date(data.getTime() - offset * 60 * 1000);
    const dataString = dataAjustada.toISOString().split('T')[0];

    if (this.agendaConfig.datasBloqueadas?.includes(dataString)) {
      return false;
    }

    return true;
  };
}
  