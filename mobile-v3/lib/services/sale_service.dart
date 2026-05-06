// =======================>> Third-party Packages
import 'package:dio/dio.dart';

// =======================>> Shared Components
import 'package:calendar/shared/error/error_type.dart';

// =======================>> Local Utilities
import 'package:calendar/utils/dio.client.dart';
import 'package:calendar/utils/help_util.dart';

class SaleService {
  // admin sale service
  Future<Map<String, dynamic>> getData({
    String? cashier,
    String? platform,
    String? sort,
    String? order,
    String? limit,
    String? page,
    String? key,
  }) async {
    try {
      final response = await DioClient.dio.get(
        "/admin/sales?limit=${limit ?? '20'}&page=${page ?? '1'}",
        queryParameters: {
          if (cashier != null) 'cashier': cashier,
          if (platform != null) 'platform': platform,
          if (sort != null) 'sort': sort,
          if (order != null) 'order': order,
          if (key != null) 'key': key,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        printError(
          errorMessage: ErrorType.requestError,
          statusCode: dioError.response!.statusCode,
        );
        throw Exception(ErrorType.requestError);
      } else {
        printError(
          errorMessage: ErrorType.networkError,
          statusCode: null,
        );
        throw Exception(ErrorType.networkError);
      }
    } catch (e) {
      printError(errorMessage: 'Something went wrong.', statusCode: 500);
      throw Exception(ErrorType.unexpectedError);
    }
  }

  // cashier sale service
  Future<Map<String, dynamic>> getDataCashier({
    String? cashier,
    String? platform,
    String? sort,
    String? order,
    String? limit,
    String? page,
    String? key,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await DioClient.dio.get(
        "/cashier/sales?limit=${limit ?? '20'}&page=${page ?? '1'}",
        queryParameters: {
          if (cashier != null) 'cashier': cashier,
          if (platform != null) 'platform': platform,
          if (sort != null) 'sort': sort,
          if (order != null) 'order': order,
          if (key != null) 'key': key,
          if (startDate != null) 'startDate': startDate, 
          if (endDate != null) 'endDate': endDate,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        printError(
          errorMessage: ErrorType.requestError,
          statusCode: dioError.response!.statusCode,
        );
        throw Exception(ErrorType.requestError);
      } else {
        printError(
          errorMessage: ErrorType.networkError,
          statusCode: null,
        );
        throw Exception(ErrorType.networkError);
      }
    } catch (e) {
      printError(errorMessage: 'Something went wrong.', statusCode: 500);
      throw Exception(ErrorType.unexpectedError);
    }
  }

  Future<void> deleteSale(int id) async {
    try {
      await DioClient.dio.delete("/admin/sales/$id");
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}