sealed class FetchResponse<T> {
  
}

class FetchListSuccess<T> extends FetchResponse<T> {
  final List<T> items;
  FetchListSuccess(this.items);
}

class FetchListFailure<T> extends FetchResponse<T> {
  final String message;
  FetchListFailure(this.message);
}

class FetchOneSuccess<T> extends FetchResponse<T> {
  final T item;
  FetchOneSuccess(this.item);
}

class FetchOneFailure<T> extends FetchResponse<T> {
  final String message;
  FetchOneFailure(this.message);
}