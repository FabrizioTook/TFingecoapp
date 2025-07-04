import 'package:finanzas/presentation/home/services/american_finance_service.dart';
import 'package:finanzas/shared/leave_widget.dart';
import 'package:flutter/material.dart';
import 'package:finanzas/shared/models/finance_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AmericanFinanceService _service = AmericanFinanceService();
  late Future<List<FinanceInput>> _financeRecords = Future.value([]);

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  void _fetchRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    setState(() {
      _financeRecords = _service.getRecords(userId: userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (didPop) {
          return;
        }
        await leaveWidget(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registros Financieros'),
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder<List<FinanceInput>>(
          future: _financeRecords,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return const Center(child: Text('No hay registros aún.'));
            }

            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return financeItem(
                  context,
                  record,
                  () async {
                    await _service.deleteRecord(record.id!);
                    _fetchRecords();
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddFinanceDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget financeItem(
      BuildContext context, FinanceInput record, VoidCallback onDelete) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/see-finance', arguments: record.id);
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0XFFf7e4e1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${record.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Precio venta: ${record.precioVenta.toStringAsFixed(2)}'),
                // Agrega más campos si deseas mostrar más detalles
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.red,
              heroTag: record.id, // evita conflictos si hay varios botones
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirmar eliminación'),
                    content: const Text(
                        '¿Estás seguro de que quieres eliminar este registro?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  onDelete();
                }
              },
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFinanceDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id') ?? '';

    final TextEditingController precioVentaCtrl = TextEditingController();
    final TextEditingController cuotaInicialCtrl = TextEditingController();
    final TextEditingController fechaCtrl = TextEditingController();
    final TextEditingController numeroAniosCtrl = TextEditingController();
    final TextEditingController tasaInteresCtrl = TextEditingController();
    final TextEditingController tasaDescuentoCtrl = TextEditingController();
    String periodoTasa = 'Anual';

    DateTime? selectedDate;
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Nuevo Registro Financiero'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  TextFormField(
                    controller: precioVentaCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Valor Nominal'),
                  ),

                  TextFormField(
                    controller: fechaCtrl,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Fecha de Emisión'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        selectedDate = date;
                        fechaCtrl.text =
                            date.toLocal().toString().split(' ')[0];
                      }
                    },
                  ),
                  TextFormField(
                    controller: numeroAniosCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Número de Años'),
                  ),
                  TextFormField(
                    controller: tasaInteresCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Tasa de Interés (%)'),
                  ),
                  TextFormField(
                    controller: tasaDescuentoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Tasa de Descuento (%)'),
                  ),
                  DropdownButtonFormField<String>(
                    value: periodoTasa,
                    items: const [
                      DropdownMenuItem(
                          value: 'Mensual', child: Text('Mensual')),
                      DropdownMenuItem(value: 'Anual', child: Text('Anual')),
                      DropdownMenuItem(
                          value: 'Trimestral', child: Text('Trimestral')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        periodoTasa = value;
                      }
                    },
                    decoration:
                        const InputDecoration(labelText: 'Periodo de Tasa'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final record = FinanceInput(
                      userId: userId,
                      precioVenta: double.parse(precioVentaCtrl.text),
                      cuotaInicial: 0,
                      fechaEmision: selectedDate!,
                      numeroAnios: int.parse(numeroAniosCtrl.text),
                      tasaInteres: double.parse(tasaInteresCtrl.text),
                      tasaDescuento: double.parse(tasaDescuentoCtrl.text),
                      periodoTasa: periodoTasa,
                    );

                    await _service.createRecord(record);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    _fetchRecords(); // recargar lista
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    }
  }
}
