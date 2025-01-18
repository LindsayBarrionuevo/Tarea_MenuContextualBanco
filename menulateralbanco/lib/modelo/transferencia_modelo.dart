class TransferenciaModelo {
  final double monto;
  final String cuenta;
  final String nombre; // Nombre del beneficiario
  final String cedula; // Cédula del beneficiario
  final String banco; // Banco del beneficiario
  final String tipoCuenta; // Tipo de cuenta: Ahorros o Corriente
  final String? descripcion; // Descripción opcional
  final String? correo; // Correo electrónico opcional
  final double comision; // Comisión aplicada a la transferencia

  TransferenciaModelo({
    required this.monto,
    required this.cuenta,
    required this.nombre,
    required this.cedula,
    required this.banco,
    required this.tipoCuenta,
    this.descripcion,
    this.correo,
    required this.comision,
  });
}
