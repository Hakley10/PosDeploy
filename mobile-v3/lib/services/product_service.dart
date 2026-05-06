// =======================>> Third-party Packages
import 'package:dio/dio.dart';

// =======================>> Local Utilities
import 'package:calendar/utils/dio.client.dart';
// import 'package:calendar/utils/help_util.dart';

// =======================>> Shared Components
// import 'package:calendar/shared/error/error_type.dart';

class ProductService {
  Future<Map<String, dynamic>> dataSetup() async {
    try {
      final response = await DioClient.dio.get("/admin/products/setup-data");
      // log("${response}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // product_service.dart
  Future<Map<String, dynamic>> getData({
    String? key,
    String? sortBy,
    String? order,
    int? type,
    int? creator,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': 1, 'limit': 20};

      if (key != null && key.isNotEmpty) {
        queryParams['key'] = key;
      }
      if (sortBy != null) {
        queryParams['sort_by'] = sortBy;
      }
      if (order != null) {
        queryParams['order'] = order;
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (creator != null) {
        queryParams['creator'] = creator;
      }

      final response = await DioClient.dio.get(
        "/admin/products",
        queryParameters: queryParams,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDetailProduct({required String id}) async {
    try {
      final response = await DioClient.dio.get("/admin/products/$id");
      // log("${response}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await DioClient.dio.delete("/admin/products/$id");
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
