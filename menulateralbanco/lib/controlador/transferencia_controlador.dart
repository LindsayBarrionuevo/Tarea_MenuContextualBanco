import '../modelo/transferencia_modelo.dart';

class TransferenciaControlador {
  double saldo = 1000.0; // Saldo inicial

  String realizarTransferencia(TransferenciaModelo transferencia) {
    if (transferencia.monto > saldo) {
      return 'Saldo insuficiente';
    }

    saldo -= transferencia.monto;
    return 'Transferencia realizada. Saldo actual: \$${saldo.toStringAsFixed(2)}';
  }
}