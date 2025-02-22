import '../modelo/transferencia_modelo.dart';

class TransferenciaControlador {
  double saldo = 1000.0; // Saldo inicial

  String realizarTransferencia(TransferenciaModelo transferencia) {
    final double montoTotal = transferencia.monto + transferencia.comision;

    if (montoTotal > saldo) {
      return 'Saldo insuficiente. Saldo disponible: \$${saldo.toStringAsFixed(2)}';
    }

    saldo -= montoTotal; // Resta el monto total (monto + comisión)
    return 'Transferencia realizada. Saldo actual: \$${saldo.toStringAsFixed(2)}';
  }
}
