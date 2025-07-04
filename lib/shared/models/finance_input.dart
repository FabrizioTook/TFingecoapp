/// Modelo de datos financieros
class FinanceInput {
  String? id;
  String userId;
  double precioVenta;
  double cuotaInicial;
  DateTime fechaEmision;
  int numeroAnios;
  double tasaInteres;
  double tasaDescuento;
  String periodoTasa;

  FinanceInput({
    this.id,
    required this.userId,
    required this.precioVenta,
    required this.cuotaInicial,
    required this.fechaEmision,
    required this.numeroAnios,
    required this.tasaInteres,
    required this.tasaDescuento,
    required this.periodoTasa,
  });

  factory FinanceInput.fromJson(Map<String, dynamic> json) => FinanceInput(
        id: json['id'],
        userId: json['userId'],
        precioVenta: (json['precio_venta'] as num).toDouble(),
        cuotaInicial: (json['cuota_inicial'] as num).toDouble(),
        fechaEmision: DateTime.parse(json['fecha_emision']),
        numeroAnios: json['numero_anios'],
        tasaInteres: (json['tasa_interes'] as num).toDouble(),
        tasaDescuento: (json['tasa_descuento'] as num).toDouble(),
        periodoTasa: json['periodo_tasa'],
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'precio_venta': precioVenta,
      'cuota_inicial': cuotaInicial,
      'fecha_emision': fechaEmision.toIso8601String(),
      'numero_anios': numeroAnios,
      'tasa_interes': tasaInteres,
      'tasa_descuento': tasaDescuento,
      'periodo_tasa': periodoTasa,
    };
  }
}
