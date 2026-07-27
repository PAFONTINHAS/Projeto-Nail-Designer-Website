import { Timestamp } from "firebase/firestore";

export interface Intervalo {
  inicio: string;
  fim: string;
}

export interface DiaTrabalho {
  diaSemana: number; // 1 a 7 (ou 0 a 6 dependendo de como o Angular/JS lê)
  inicio: string;
  fim: string;
  pausas: Intervalo[];
}

export interface AgendaConfig {
  agendaAtiva: boolean;
  datasBloqueadas: string[];
  diasTrabalho: DiaTrabalho[];
}