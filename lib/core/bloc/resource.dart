/// Replaces Riverpod's `AsyncValue<T>` for Bloc states: wraps a value that's
/// either not yet requested, in flight, loaded, or failed.
sealed class Resource<T> {
  const Resource();

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) data,
    required R Function(Object error, StackTrace? stackTrace) error,
  }) {
    final self = this;
    return switch (self) {
      ResourceInitial<T>() => initial(),
      ResourceLoading<T>() => loading(),
      ResourceData<T>(:final value) => data(value),
      ResourceError<T>(error: final err, :final stackTrace) => error(err, stackTrace),
    };
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? data,
    R Function(Object error, StackTrace? stackTrace)? error,
    required R Function() orElse,
  }) {
    return when(
      initial: initial ?? orElse,
      loading: loading ?? orElse,
      data: data ?? (_) => orElse(),
      error: error ?? (_, _) => orElse(),
    );
  }

  T? get valueOrNull => switch (this) {
    ResourceData<T>(:final value) => value,
    _ => null,
  };
}

class ResourceInitial<T> extends Resource<T> {
  const ResourceInitial();
}

class ResourceLoading<T> extends Resource<T> {
  const ResourceLoading();
}

class ResourceData<T> extends Resource<T> {
  final T value;
  const ResourceData(this.value);
}

class ResourceError<T> extends Resource<T> {
  final Object error;
  final StackTrace? stackTrace;
  const ResourceError(this.error, [this.stackTrace]);
}
