class Intervalo {
  Intervalo(this.intervalId, this.inicio, this.fim);
  
  final int intervalId;
  final String inicio;
  final String fim;

  Map<String, dynamic> toMap(){

    return {
      'intervalId': intervalId,
      'inicio': inicio,
      'fim': fim
    };

  }
}