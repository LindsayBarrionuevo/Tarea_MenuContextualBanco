class TransferenciaModelo {
  final double monto;
  final String cuenta_origen;
  final String cuenta_destino;
  final String nombre; // Nombre del beneficiario
  final String banco; // Banco del beneficiario
  final String tipoCuenta; // Tipo de cuenta: Ahorros o Corriente
  final double comision; // Comisión aplicada a la transferencia

  TransferenciaModelo({
    required this.monto,
    required this.cuenta_origen,
    required this.cuenta_destino,
    required this.nombre,
    required this.banco,
    required this.tipoCuenta,
    required this.comision,
  });
}
