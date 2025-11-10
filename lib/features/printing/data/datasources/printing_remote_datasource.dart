import '../../../../core/network/api_client.dart' as api_client;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/printer_model.dart';
import 'printing_data_source.dart';
import '../../../../core/utils/exception_helper.dart';

/// Remote data source implementation for printing
/// Simple CRUD operations via API
class PrintingRemoteDataSourceImpl implements PrintingDataSource {
  final api_client.ApiClient apiClient;

  PrintingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PrinterModel>> getPrinters() async {
    try {
      final response = await apiClient.get(AppConstants.getPrintersEndpoint);
      final data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching printers',
      );
      return data
          .map((json) => PrinterModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PrinterModel> getPrinterById(String printerId) async {
    try {
      final response =
          await apiClient.get('${AppConstants.getPrintersEndpoint}/$printerId');
      final payload = ExceptionHelper.validateResponseData(
        response.data,
        'fetching printer by ID',
      );
      if (payload is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Invalid response format during fetching printer by ID: expected Map, got ${payload.runtimeType}',
        );
      }
      return PrinterModel.fromJson(payload);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PrinterModel> addPrinter(PrinterModel printer) async {
    try {
      final response = await apiClient.post(
        AppConstants.getPrintersEndpoint,
        data: printer.toJson(),
      );
      final payload = ExceptionHelper.validateResponseData(
        response.data,
        'adding printer',
      );
      if (payload is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Invalid response format during adding printer: expected Map, got ${payload.runtimeType}',
        );
      }
      return PrinterModel.fromJson(payload);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PrinterModel> updatePrinter(PrinterModel printer) async {
    try {
      final response = await apiClient.put(
        '${AppConstants.getPrintersEndpoint}/${printer.id}',
        data: printer.toJson(),
      );
      final payload = ExceptionHelper.validateResponseData(
        response.data,
        'updating printer',
      );
      if (payload is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Invalid response format during updating printer: expected Map, got ${payload.runtimeType}',
        );
      }
      return PrinterModel.fromJson(payload);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deletePrinter(String printerId) async {
    try {
      await apiClient.delete('${AppConstants.getPrintersEndpoint}/$printerId');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
