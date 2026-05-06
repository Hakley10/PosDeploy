import 'package:dio/dio.dart';
import 'package:calendar/utils/dio.client.dart';

class UserService {
  Future<Map<String, dynamic>> getData({
    String? key,
    String? sortBy,
    String? order,
    int? role,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': 1, 'limit': 20};

      // Add non-null parameters
      if (key != null && key.isNotEmpty) queryParams['key'] = key;
      if (sortBy != null) {
        queryParams['sort'] = sortBy; // Changed from 'sort_by' to 'sort'
        if (order != null) queryParams['order'] = order;
      }
      if (role != null && role != 0) {
        queryParams['role'] = role; // Skip if role is 0 (All)
      }

      print('API Query Params: $queryParams'); // Debug print

      final response = await DioClient.dio.get(
        "/admin/users",
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('API Error: ${e.response?.data}'); 
      throw Exception(e.response?.data?['message'] ?? 'Failed to load users');
    } catch (e) {
      print('Network Error: $e'); 
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final response = await DioClient.dio.get("/admin/users/setup");
      if (response.data == null || response.data['roles'] == null) {
        throw Exception('Empty response from server');
      }
      return List<Map<String, dynamic>>.from(response.data['roles']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to load roles');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }


  Future<Map<String, dynamic>> getUserDetail({required String id}) async {
  try {
    final response = await DioClient.dio.get("/admin/users/$id");
    if (response.data == null) {
      throw Exception('Empty response from server');
    }
    return response.data as Map<String, dynamic>;
  } on DioException catch (e) {
    print('API Error: ${e.response?.data}'); 
    throw Exception(e.response?.data?['message'] ?? 'Failed to load user details');
  } catch (e) {
    print('Network Error: $e'); 
    throw Exception('Network error: ${e.toString()}');
  }
}
}
