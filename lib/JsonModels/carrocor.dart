class CarroCor {
  final int? id; // Identificador único da relação
  final int carroId; // ID do carro
  final int corId; // ID da cor

  CarroCor({
    this.id,
    required this.carroId,
    required this.corId,
  });

  // Método para converter CarroCor em um mapa para armazenamento no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carroId': carroId,
      'corId': corId,
    };
  }
}
