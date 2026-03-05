abstract class UseCase<Type,Params> {
  //The params are required because the use case cannot be called without a parameter
  Future<Type> call({required Params params});
}

//This class is used to pass no parameters to the use case
class NoParams {
  const NoParams();
}