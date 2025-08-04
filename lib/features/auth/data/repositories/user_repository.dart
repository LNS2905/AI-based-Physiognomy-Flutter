import '../../../../core/network/api_result.dart';
import '../../../../core/network/http_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/update_user_dto.dart';
import '../models/general_response_model.dart';

/// User management repository
class UserRepository {
  final HttpService _httpService;

  UserRepository({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  /// Update current user profile
  Future<ApiResult<UserModel>> updateProfile({
    required UpdateUserDTO updateUserDto,
  }) async {
    try {
      final accessToken = await StorageService.getSecure(AppConstants.accessTokenKey);
      if (accessToken == null) {
        throw const AuthException(
          message: 'No access token found',
          code: 'NO_ACCESS_TOKEN',
        );
      }

      final response = await _httpService.put(
        AppConstants.updateProfileEndpoint,
        body: updateUserDto.toJson(),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      final generalResponse = GeneralResponse<Map<String, dynamic>>.fromJson(
        response,
        (json) => json as Map<String, dynamic>,
      );

      final user = UserModel.fromJson(generalResponse.data);
      
      // Update stored user data
      await StorageService.store(
        AppConstants.userDataKey,
        user.toJson(),
      );
      
      AppLogger.info('User profile updated successfully');
      return Success(user);
    } on AuthException catch (e) {
      AppLogger.error('Update profile failed: Authentication error', e);
      return Error(AuthFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      AppLogger.error('Update profile failed: Validation error', e);
      return Error(ValidationFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      AppLogger.error('Update profile failed: Network error', e);
      return Error(NetworkFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      AppLogger.error('Update profile failed: Server error', e);
      return Error(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } catch (e) {
      AppLogger.error('Update profile failed: Unknown error', e);
      return Error(UnknownFailure(
        message: 'Đã xảy ra lỗi không mong muốn trong quá trình cập nhật thông tin',
        code: 'UNKNOWN_ERROR',
      ));
    }
  }

  /// Get current user from storage
  Future<ApiResult<UserModel>> getCurrentUserFromStorage() async {
    try {
      final userData = await StorageService.get(AppConstants.userDataKey);
      if (userData == null) {
        throw const CacheException(
          message: 'No user data found in storage',
          details: 'USER_DATA_NOT_FOUND',
        );
      }

      final user = UserModel.fromJson(userData);
      AppLogger.info('User data retrieved from storage');
      return Success(user);
    } on CacheException catch (e) {
      AppLogger.error('Get user from storage failed: Cache error', e);
      return Error(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Get user from storage failed: Unknown error', e);
      return Error(UnknownFailure(
        message: 'Failed to get user data from storage',
        code: 'STORAGE_ERROR',
      ));
    }
  }

  /// Store user data to storage
  Future<void> storeUserData(UserModel user) async {
    try {
      await StorageService.store(AppConstants.userDataKey, user.toJson());
      AppLogger.info('User data stored to storage');
    } catch (e) {
      AppLogger.error('Failed to store user data to storage', e);
    }
  }

  /// Clear user data from storage
  Future<void> clearUserData() async {
    try {
      await StorageService.remove(AppConstants.userDataKey);
      AppLogger.info('User data cleared from storage');
    } catch (e) {
      AppLogger.error('Failed to clear user data from storage', e);
    }
  }
}
