import 'dart:io';
import 'package:excel/excel.dart';
import 'package:finanzas/presentation/see_finance/methods/result.dart';
import 'package:flutter/material.dart';
import 'package:finanzas/shared/models/finance_input.dart';
import 'package:finanzas/presentation/home/services/american_finance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class SeeFinanceScreen extends StatefulWidget {
  final String recordId;
  const SeeFinanceScreen({super.key, required this.recordId});

  @override
  State<SeeFinanceScreen> createState() => _SeeFinanceScreenState();
}

class _SeeFinanceScreenState extends State<SeeFinanceScreen> {
  final AmericanFinanceService _service = AmericanFinanceService();
  late Future<FinanceInput> _financeInput = Future<FinanceInput>.value(
    FinanceInput(
      userId: '',
      precioVenta: 0.0,
      cuotaInicial: 0.0,
      fechaEmision: DateTime.now(),
      numeroAnios: 0,
      tasaInteres: 0.0,
      tasaDescuento: 0.0,
      periodoTasa: '',
    ),
  );

  @override
  void initState() {
    super.initState();
    _fetchRecord();
  }

  void _fetchRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    setState(() {
      _financeInput = _service
          .getRecords(recordId: widget.recordId, userId: userId)
          .then((list) => list.first);
    });
  }

  Future<void> exportToExcel(List<Map<String, dynamic>> tabla) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Encabezados
    sheet.appendRow([
      'Periodo',
      'Saldo Inicial',
      'Interés',
      'Cuota',
      'Amortización',
      'Saldo Final',
      'Flujo Activo',
      'Flujo Activo por Plazo',
    ]);

    // Datos
    for (var fila in tabla) {
      sheet.appendRow([
        fila['periodo'],
        fila['saldoInicial'],
        fila['interes'],
        fila['cuota'],
        fila['amortizacion'],
        fila['saldoFinal'],
        fila['flujoActivo'],
        fila['flujoActivoPorPlazo'],
      ]);
    }

    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/tabla_amortizacion.xlsx';
    final fileBytes = excel.encode();
    final file = File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    await Share.shareXFiles([XFile(file.path)], text: 'Tabla de amortización generada.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Financiero')),
      body: FutureBuilder<FinanceInput>(
        future: _financeInput,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final input = snapshot.data!;
          final metodo = MetodoAmericanoService(input);
          final resumen = metodo.calcularResumen();
          final tabla = metodo.calcularTablaAmortizacion();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📋 Datos ingresados:", style: Theme.of(context).textTheme.titleLarge),
                Text("Precio de venta: S/ ${input.precioVenta.toStringAsFixed(2)}"),
                Text("Fecha de emisión: ${input.fechaEmision.toLocal()}"),
                Text("Años: ${input.numeroAnios}"),
                Text("Tasa interés: ${input.tasaInteres.toStringAsFixed(2)}%"),
                Text("Tasa descuento: ${input.tasaDescuento.toStringAsFixed(2)}%"),
                Text("Periodo tasa: ${input.periodoTasa}"),
                const SizedBox(height: 20),
                Text("📈 Resultados del Método Americano:", style: Theme.of(context).textTheme.titleLarge),
                Text("Monto del préstamo: S/ ${resumen['prestamo'].toStringAsFixed(2)}"),
                Text("Número total de periodos: ${resumen['nTotalPeriodos']}"),
                Text("COK mensual: ${resumen['cokMensual'].toStringAsFixed(4)}%"),
                Text("Precio actual del bono: S/ ${resumen['precioActual'].toStringAsFixed(2)}"),
                Text("Utilidad/Pérdida: S/ ${resumen['utilidadPerdida'].toStringAsFixed(2)}"),
                Text("TIR: ${resumen['tir'].toStringAsFixed(6)}%"),
                Text("TCEA: ${resumen['tcea'].toStringAsFixed(6)}%"),
                Text("Duración: ${resumen['duracion'].toStringAsFixed(4)}"),
                Text("Convexidad: ${resumen['convexidad'].toStringAsFixed(4)}"),
                Text("Duración modificada: ${resumen['duracionModificada'].toStringAsFixed(4)}"),
                Text("Duración + Convexidad: ${resumen['totalDurConv'].toStringAsFixed(4)}"),
                const SizedBox(height: 20),
                Text("📊 Tabla de Amortización:", style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => exportToExcel(tabla),
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar a Excel'),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Periodo')),
                      DataColumn(label: Text('Saldo Inicial')),
                      DataColumn(label: Text('Interés')),
                      DataColumn(label: Text('Cuota')),
                      DataColumn(label: Text('Amortización')),
                      DataColumn(label: Text('Saldo Final')),
                      DataColumn(label: Text('Flujo Activo')),
                      DataColumn(label: Text('Flujo Activo por Plazo')),
                    ],
                    rows: tabla.map((fila) {
                      return DataRow(cells: [
                        DataCell(Text('${fila['periodo']}')),
                        DataCell(Text('S/ ${fila['saldoInicial'].toStringAsFixed(2)}')),
                        DataCell(Text('S/ ${fila['interes'].toStringAsFixed(2)}')),
                        DataCell(Text('S/ ${fila['cuota'].toStringAsFixed(2)}')),
                        DataCell(Text('S/ ${fila['amortizacion'].toStringAsFixed(2)}')),
                        DataCell(Text('S/ ${fila['saldoFinal'].toStringAsFixed(2)}')),
                        DataCell(Text('S/ ${fila['flujoActivo'].toStringAsFixed(2)}')),
                        DataCell(Text('S/ ${fila['flujoActivoPorPlazo'].toStringAsFixed(2)}')),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}