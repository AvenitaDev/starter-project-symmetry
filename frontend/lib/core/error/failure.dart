abstract class Failure {
  final String message;
  const Failure(this.message);
}
//This failure is used when the server returns an error
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

//This failure is used when an unexpected error is caught
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

//This failure is used when the network is not available
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

//This failure is used when the cache is not available
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

//This failure is used when the user is not authorized
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}