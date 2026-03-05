import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'failure.dart';

Failure mapDioErrorToFailure(DioException e) {
  //If the DioException is caught, return the error to the Left of the Either
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      return const NetworkFailure('Connection timeout');
    case DioExceptionType.sendTimeout:
      return const NetworkFailure('Send timeout');
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure('Receive timeout');
    case DioExceptionType.connectionError:
      return const NetworkFailure('Connection error');

    case DioExceptionType.badResponse:
      return ServerFailure(e.response?.statusMessage ?? 'Server error');

    case DioExceptionType.cancel:
      return const NetworkFailure('Request cancelled');

    case DioExceptionType.unknown:
    default:
      return const UnexpectedFailure('Unexpected error in Dio');
  }
}

Failure mapFirebaseErrorToFailure(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return const ServerFailure('Permission denied');

    case 'unavailable':
      return const NetworkFailure('Service unavailable');

    case 'not-found':
      return const ServerFailure('Document not found');

    case 'already-exists':
      return const ServerFailure('Document already exists');

    case 'deadline-exceeded':
      return const NetworkFailure('Request timeout');

    case 'resource-exhausted':
      return const ServerFailure('Quota exceeded');

    case 'unauthenticated':
      return const ServerFailure('User not authenticated');

    case 'invalid-argument':
      return const ServerFailure('Invalid argument provided');

    case 'aborted':
      return const ServerFailure('Operation aborted');

    case 'internal':
      return const ServerFailure('Internal server error');

    default:
      return UnexpectedFailure(
        e.message ?? 'Unexpected Firebase error',
      );
  }
}
