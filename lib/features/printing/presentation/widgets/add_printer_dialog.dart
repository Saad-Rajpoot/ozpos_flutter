import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/printing_entities.dart';
import '../bloc/printing_bloc.dart';
import '../bloc/printing_event.dart';
import 'printer_dialog_components.dart';

Future<void> showAddPrinterDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final portController = TextEditingController(text: '9100');
  String stepLabel(int idx) {
    switch (idx) {
      case 0:
        return 'Role';
      case 1:
        return 'Connection';
      case 2:
        return 'Details';
      case 3:
        return 'Functions';
      case 4:
        return 'Review';
      default:
        return '';
    }
  }

  Widget bullet(int idx, ThemeData theme, int currentStep) {
    final active = currentStep >= idx;
    return CircleAvatar(
      radius: 16,
      backgroundColor: active ? theme.colorScheme.primary : Colors.grey[300],
      child: Text('${idx + 1}',
          style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700)),
    );
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => BlocProvider(
      create: (_) => AddPrinterDialogCubit(),
      child: BlocBuilder<AddPrinterDialogCubit, AddPrinterDialogState>(
        builder: (dialogContext, state) {
          final theme = Theme.of(dialogContext);
          final cubit = dialogContext.read<AddPrinterDialogCubit>();
          Widget content;
          switch (state.step) {
            case 0:
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final t in PrinterType.values)
                        SelectableTile(
                          selected: state.selectedType == t,
                          onTap: () => cubit.updateSelectedType(t),
                          icon: Icons.print,
                          title: _getPrinterTypeName(t),
                          subtitle: t == PrinterType.kitchen
                              ? 'Kitchen order tickets'
                              : t == PrinterType.receipt
                                  ? 'Receipt and order printing'
                                  : _getPrinterTypeName(t),
                        ),
                    ],
                  )
                ],
              );
              break;
            case 1:
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final c in PrinterConnection.values)
                        SelectableTile(
                          selected: state.selectedConnection == c,
                          onTap: () => cubit.updateSelectedConnection(c),
                          icon: c == PrinterConnection.network
                              ? Icons.wifi
                              : c == PrinterConnection.usb
                                  ? Icons.usb
                                  : Icons.bluetooth,
                          title: _getConnectionName(c),
                          subtitle: c == PrinterConnection.network
                              ? 'Ethernet or WiFi'
                              : c == PrinterConnection.usb
                                  ? 'Direct USB cable'
                                  : 'Wireless pairing',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.search),
                        label: const Text('Detect Devices'),
                      ),
                    ],
                  )
                ],
              );
              break;
            case 2:
              String addressLabel;
              String addressHint;
              switch (state.selectedConnection) {
                case PrinterConnection.usb:
                  addressLabel = 'USB Port *';
                  addressHint = 'USB001';
                  break;
                case PrinterConnection.bluetooth:
                  addressLabel = 'Bluetooth Address *';
                  addressHint = 'e.g. 00:11:22:33:44:55';
                  break;
                default:
                  addressLabel = 'IP Address *';
                  addressHint = '192.168.1.100';
              }
              content = Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Printer Name *',
                        hintText: 'e.g., Main Kitchen Printer'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                        labelText: addressLabel, hintText: addressHint),
                  ),
                  const SizedBox(height: 12),
                  if (state.selectedConnection == PrinterConnection.network)
                    TextField(
                      controller: portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Port', hintText: '9100'),
                    ),
                  if (state.selectedConnection == PrinterConnection.network)
                    const SizedBox(height: 4),
                  if (state.selectedConnection == PrinterConnection.network)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Default: 9100 (ESC/POS printers)',
                          style: theme.textTheme.bodySmall),
                    ),
                ],
              );
              break;
            case 3:
              content = Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  FunctionCard(
                    title: 'Customer Receipts',
                    subtitle: 'Print customer receipts',
                    value: state.fnReceipts,
                    onChanged: (v) => cubit.updateFnReceipts(v),
                  ),
                  FunctionCard(
                    title: 'Order Tickets',
                    subtitle: 'Print order tickets',
                    value: state.fnTickets,
                    onChanged: (v) => cubit.updateFnTickets(v),
                  ),
                  FunctionCard(
                    title: 'Reports',
                    subtitle: 'Print reports',
                    value: state.fnReports,
                    onChanged: (v) => cubit.updateFnReports(v),
                  ),
                ],
              );
              break;
            default:
              content = ReviewCard(
                role: _getPrinterTypeName(state.selectedType),
                connection: _getConnectionName(state.selectedConnection),
                name: nameController.text,
                address: addressController.text,
                port: portController.text,
                functions: [
                  if (state.fnReceipts) 'Receipts',
                  if (state.fnTickets) 'Tickets',
                  if (state.fnReports) 'Reports',
                ],
              );
          }

          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.print_outlined),
                SizedBox(width: 8),
                Text('Add New Printer')
              ],
            ),
            content: SizedBox(
              width: 700,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 5; i++) ...[
                        bullet(i, theme, state.step),
                        if (i != 4)
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              height: 4,
                              decoration: BoxDecoration(
                                color: state.step > i
                                    ? theme.colorScheme.primary
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(stepLabel(state.step),
                      style: theme.textTheme.labelLarge),
                  const SizedBox(height: 12),
                  Flexible(child: SingleChildScrollView(child: content)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (state.step == 0) {
                    Navigator.of(dialogContext).pop();
                  } else {
                    cubit.previousStep();
                  }
                },
                child: Text(state.step == 0 ? 'Cancel' : 'Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (state.step < 4) {
                    if (state.step == 2 && nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter printer name')));
                      return;
                    }
                    cubit.nextStep();
                  } else {
                    final printer = PrinterEntity(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      type: state.selectedType,
                      connection: state.selectedConnection,
                      address: addressController.text.trim().isEmpty
                          ? null
                          : addressController.text.trim(),
                      port: int.tryParse(portController.text.trim()),
                      isConnected: false,
                      isDefault: false,
                    );
                    Navigator.of(dialogContext).pop();
                    dialogContext
                        .read<PrintingBloc>()
                        .add(AddPrinter(printer: printer));
                  }
                },
                child: Text(state.step < 4 ? 'Next' : 'Add Printer'),
              ),
            ],
          );
        },
      ),
    ),
  );
}

String _getPrinterTypeName(PrinterType type) {
  switch (type) {
    case PrinterType.receipt:
      return 'Receipt';
    case PrinterType.kitchen:
      return 'Kitchen';
    case PrinterType.label:
      return 'Label';
    case PrinterType.invoice:
      return 'Invoice';
    case PrinterType.barista:
      return 'Barista';
  }
}

String _getConnectionName(PrinterConnection connection) {
  switch (connection) {
    case PrinterConnection.bluetooth:
      return 'Bluetooth';
    case PrinterConnection.network:
      return 'Network';
    case PrinterConnection.usb:
      return 'USB';
  }
}

class AddPrinterDialogState extends Equatable {
  const AddPrinterDialogState({
    required this.step,
    required this.selectedType,
    required this.selectedConnection,
    required this.fnReceipts,
    required this.fnTickets,
    required this.fnReports,
  });

  final int step;
  final PrinterType selectedType;
  final PrinterConnection selectedConnection;
  final bool fnReceipts;
  final bool fnTickets;
  final bool fnReports;

  AddPrinterDialogState copyWith({
    int? step,
    PrinterType? selectedType,
    PrinterConnection? selectedConnection,
    bool? fnReceipts,
    bool? fnTickets,
    bool? fnReports,
  }) {
    return AddPrinterDialogState(
      step: step ?? this.step,
      selectedType: selectedType ?? this.selectedType,
      selectedConnection: selectedConnection ?? this.selectedConnection,
      fnReceipts: fnReceipts ?? this.fnReceipts,
      fnTickets: fnTickets ?? this.fnTickets,
      fnReports: fnReports ?? this.fnReports,
    );
  }

  @override
  List<Object> get props => [
        step,
        selectedType,
        selectedConnection,
        fnReceipts,
        fnTickets,
        fnReports
      ];
}

class AddPrinterDialogCubit extends Cubit<AddPrinterDialogState> {
  AddPrinterDialogCubit()
      : super(const AddPrinterDialogState(
          step: 0,
          selectedType: PrinterType.receipt,
          selectedConnection: PrinterConnection.network,
          fnReceipts: true,
          fnTickets: true,
          fnReports: false,
        ));

  void updateSelectedType(PrinterType type) =>
      emit(state.copyWith(selectedType: type));

  void updateSelectedConnection(PrinterConnection connection) =>
      emit(state.copyWith(selectedConnection: connection));

  void updateFnReceipts(bool value) => emit(state.copyWith(fnReceipts: value));

  void updateFnTickets(bool value) => emit(state.copyWith(fnTickets: value));

  void updateFnReports(bool value) => emit(state.copyWith(fnReports: value));

  void nextStep() {
    if (state.step < 4) {
      emit(state.copyWith(step: state.step + 1));
    }
  }

  void previousStep() {
    if (state.step > 0) {
      emit(state.copyWith(step: state.step - 1));
    }
  }
}
