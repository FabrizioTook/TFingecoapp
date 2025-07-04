// servicio_financiero_americano.dart
import 'dart:math';
import 'package:finanzas/shared/models/finance_input.dart';

class MetodoAmericanoService {
  final FinanceInput input;

  MetodoAmericanoService(this.input);

  // ---------------------------------------------------------------------------
  // Datos básicos
  // ---------------------------------------------------------------------------

  double get montoPrestamo => input.precioVenta - input.cuotaInicial;

  int get numeroPeriodos => input.numeroAnios * 12;

  // ---------------------------------------------------------------------------
  // Tasas de descuento y tasas de interés (ambas usan periodoTasa)
  // ---------------------------------------------------------------------------

  double get cokMensual {
    switch (input.periodoTasa.toLowerCase()) {
      case 'mensual':
        return input.tasaDescuento / 100;
      case 'anual':
        return pow(1 + (input.tasaDescuento / 100), 1 / 12) - 1;
      case 'semestral':
        return pow(1 + (input.tasaDescuento / 200), 1 / 6) - 1;
      case 'trimestral':
        return pow(1 + (input.tasaDescuento / 400), 1 / 3) - 1;
      default:
        throw Exception('Periodo de tasa no reconocido: ${input.periodoTasa}');
    }
  }

  double get tasaInteresMensual {
    switch (input.periodoTasa.toLowerCase()) {
      case 'mensual':
        return input.tasaInteres / 100;
      case 'anual':
        return pow(1 + (input.tasaInteres / 100), 1 / 12) - 1;
      case 'semestral':
        return pow(1 + (input.tasaInteres / 200), 1 / 6) - 1;
      case 'trimestral':
        return pow(1 + (input.tasaInteres / 400), 1 / 3) - 1;
      default:
        throw Exception('Periodo de tasa no reconocido: ${input.periodoTasa}');
    }
  }

  // ---------------------------------------------------------------------------
  // Flujos y precio
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> calcularFlujoAmericano() {
    final List<Map<String, dynamic>> flujo = [];
    final double interes = montoPrestamo * tasaInteresMensual;

    // Flujo de caja inicial negativo
    flujo.add({'periodo': 0, 'cuota': -montoPrestamo});

    for (int i = 1; i <= numeroPeriodos; i++) {
      final double cuota =
          (i == numeroPeriodos) ? interes + montoPrestamo : interes;
      flujo.add({'periodo': i, 'cuota': cuota});
    }

    return flujo;
  }

  double get precioActual {
    final flujo = calcularFlujoAmericano();
    final r = cokMensual;
    double total = 0.0;

    for (final f in flujo) {
      final int t = f['periodo'];
      final double cuota = f['cuota'];
      total += cuota / pow(1 + r, t);
    }
    return total;
  }

  double get utilidad => precioActual - montoPrestamo;

  // ---------------------------------------------------------------------------
  // Rentabilidad
  // ---------------------------------------------------------------------------

  double calcularTIR({double guess = 0.01}) {
    final flujo = calcularFlujoAmericano();
    const double precision = 1e-9;
    const int maxIter = 1000;
    double tir = guess;

    for (int i = 0; i < maxIter; i++) {
      double f = 0;
      double df = 0;

      for (final p in flujo) {
        final int t = p['periodo'];
        final double c = p['cuota'];

        final descuento = pow(1 + tir, t);
        if (descuento == 0) continue;

        f += c / descuento;
        df -= t * c / pow(1 + tir, t + 1);
      }

      final double newTir = tir - f / df;
      if ((newTir - tir).abs() < precision) return newTir;
      if (1 + newTir <= 0) break; // protección contra dominio inválido
      tir = newTir;
    }
    return tir;
  }

  double get tcea => pow(1 + calcularTIR(), 12) - 1;

  // ---------------------------------------------------------------------------
  // Riesgo
  // ---------------------------------------------------------------------------

  double calcularDuracion() {
    final flujo = calcularFlujoAmericano();
    final r = cokMensual;
    double suma = 0;
    final double precio = precioActual;

    for (final f in flujo) {
      final int t = f['periodo'];
      final double c = f['cuota'];
      suma += t * c / pow(1 + r, t);
    }
    return suma / precio;
  }

  double calcularConvexidad() {
    final flujo = calcularFlujoAmericano();
    final r = cokMensual;
    double suma = 0;
    final double precio = precioActual;

    for (final f in flujo) {
      final int t = f['periodo'];
      final double c = f['cuota'];
      suma += c * t * (t + 1) / pow(1 + r, t + 2);
    }
    return suma / precio;
  }

  double get duracionModificada => calcularDuracion() / (1 + cokMensual);

  // ---------------------------------------------------------------------------
  // Resumen
  // ---------------------------------------------------------------------------

  Map<String, dynamic> calcularResumen() {
    final double van = utilidad;
    final double tir = calcularTIR();
    final double dur = calcularDuracion();
    final double conv = calcularConvexidad();
    final double durMod = duracionModificada;

    return {
      'prestamo': montoPrestamo,
      'nTotalPeriodos': numeroPeriodos,
      'cokMensual': cokMensual * 100,
      'precioActual': precioActual,
      'utilidadPerdida': van,
      'tir': tir * 100,
      'tcea': tcea * 100,
      'duracion': dur,
      'convexidad': conv,
      'totalDurConv': dur + conv,
      'duracionModificada': durMod,
    };
  }

  // ---------------------------------------------------------------------------
  // Tabla de amortización
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> calcularTablaAmortizacion() {
    final List<Map<String, dynamic>> tabla = [];

    final prestamo = montoPrestamo;
    final n = numeroPeriodos;
    final tasa = tasaInteresMensual;

    final interes = prestamo * tasa;
    final cuotaFinal = interes + prestamo;

    for (int i = 1; i <= n; i++) {
      final saldoInicial = prestamo;
      final interesPago = saldoInicial * tasa;
      final esUltimo = i == n;

      final amortizacion = esUltimo ? prestamo : 0;
      final pagoCuota = esUltimo ? cuotaFinal : interes;
      final saldoFinal = esUltimo ? 0 : saldoInicial;

      final flujoActivo = pagoCuota;
      final flujoActivoPorPlazo = flujoActivo / pow(1 + cokMensual, i);

      tabla.add({
        'periodo': i,
        'saldoInicial': saldoInicial,
        'interes': interesPago,
        'cuota': pagoCuota,
        'amortizacion': amortizacion,
        'saldoFinal': saldoFinal,
        'flujoActivo': flujoActivo,
        'flujoActivoPorPlazo': flujoActivoPorPlazo,
      });
    }

    return tabla;
  }
}
