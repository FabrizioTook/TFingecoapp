class ApiResult<T> {
  final T? data;
  final String? error;

  ApiResult._({this.data, this.error});

  factory ApiResult.success(T data) => ApiResult._(data: data);
  factory ApiResult.failure(String error) => ApiResult._(error: error);

  bool get isSuccess => error == null;
}