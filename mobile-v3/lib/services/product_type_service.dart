// =======================>> Third-party Packages
import 'package:dio/dio.dart';

// =======================>> Local Utilities
import 'package:calendar/utils/dio.client.dart';
// import 'package:calendar/utils/help_util.dart';

// =======================>> Shared Components
// import 'package:calendar/shared/error/error_type.dart';

class ProductTypeService {
  Future<Map<String, dynamic>> getData() async {
    try {
      final response = await DioClient.dio.get("/admin/product/types");
      print("API Response: ${response.data}");
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print("DioException: ${e.response?.data ?? e.message}");
      rethrow;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }
  // Future<Map<String, dynamic>> getDetailProduct({
  //   required String id
  // }) async {
  //   try {
  //     final response = await DioClient.dio.get(
  //       "/admin/products/$id",
  //     );
  //     // log("${response}");
  //     return response.data as Map<String, dynamic>;
  //   } on DioException catch (_) {
  //     rethrow;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> deleteProductType(int id) async {
    try {
      await DioClient.dio.delete("/admin/product/types/$id");
    } on DioException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
