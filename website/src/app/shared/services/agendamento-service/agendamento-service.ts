import { from, Observable } from 'rxjs';
import { Injectable } from '@angular/core';
import { FirebaseServerApp } from 'firebase/app';
import { Agendamento } from '../../models/agendamento_model';
import { AgendaConfig } from '../../models/agenda_config_model';
import { FirebaseService } from '../firebase-service/firebase-service';
import { collection, Firestore, query, where, onSnapshot, addDoc, Timestamp, doc, getDoc} from 'firebase/firestore';

@Injectable({
  providedIn: 'root',
})
export class AgendamentoService {
  constructor(private readonly firebaseService: FirebaseService) {}

  async getAgendaConfig() {
    const docRef = doc(this.firebaseService.db, 'configuracoes', 'agenda');
    const snap = await getDoc(docRef);

    let data = snap.data();

    if (!data) {
      console.error('Erro ao pegar o documento da agenda');
      return null;
    }

    const configModel: AgendaConfig = {
      agendaAtiva: data['agendaAtiva'],
      diasTrabalho: data['diasTrabalho'],
      datasBloqueadas: data['datasBloqueadas']
    };

    console.log('Configuração da agenda capturada com sucesso!');

    return configModel;
  }

  getAgenda(): Observable<AgendaConfig> {
    const db = this.firebaseService.db;

    const docRef = doc(db, 'configuracoes', 'agenda');

    return new Observable((sub) => {
      const unsubscribe = onSnapshot(
        docRef,
        (snap) => {
          const data = snap.data();

          if (data) {
            const configModel: AgendaConfig = {
              agendaAtiva: data['agendaAtiva'],
              diasTrabalho: data['diasTrabalho'],
              datasBloqueadas: data['datasBloqueadas']
            };

            sub.next(configModel);
          }
        },
        (error) => {
          sub.error(error);
        },
      );

      return () => unsubscribe();
    });
  }

  getAgendamentosDoDia(data: Date): Observable<any[]> {
    const db = this.firebaseService.db;
    const inicioDia = new Date(data);
    inicioDia.setHours(0, 0, 0, 0);

    const fimDia = new Date(data);
    fimDia.setHours(23, 59, 59, 999);

    const q = query(
      collection(db, 'agendamentos'),
      where('data', '>=', Timestamp.fromDate(inicioDia)),
      where('data', '<=', Timestamp.fromDate(fimDia)),
    );

    return new Observable((subscriber) => {
      const unsubscribe = onSnapshot(
        q,
        (snapshot) => {
          const agendamentos = snapshot.docs.map((doc) => ({
            id: doc.id,
            ...doc.data(),
          }));
          subscriber.next(agendamentos);
        },
        (error) => {
          subscriber.error(error);
        },
      );

      return () => unsubscribe();
    });
  }

  salvarAgendamento(agendamento: Agendamento) {
    const agendamentosRef = collection(this.firebaseService.db, 'agendamentos');

    return addDoc(agendamentosRef, agendamento);
  }
}
