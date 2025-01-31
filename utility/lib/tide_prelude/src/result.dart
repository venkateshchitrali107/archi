/// A sealed class representing a result that can either be a success or a failure.
///
/// The `Result` class is used to encapsulate the outcome of an operation that can
/// either succeed with a value of type `S` or fail with a value of type `F`.
///
/// Example usage:
/// ```dart
/// Result<int, String> result = someOperation();
/// result.fold(
///   (success) => print('Success: $success'),
///   (failure) => print('Failure: $failure'),
/// );
/// ```
import 'dart:async';

sealed class Result<S, F> {
  const Result._();

  /// Applies one of two functions to the value contained in the Result.
  ///
  /// If the Result is a success, the [ifSuccess] function is applied to the value.
  /// If the Result is a failure, the [ifFailure] function is applied to the value.
  ///
  /// Returns the result of the applied function.
  B fold<B>(B Function(S) ifSuccess, B Function(F) ifFailure);

  /// Transforms the successful value of this `Result` using the provided function `f`.
  ///
  /// If this `Result` is a `Success`, the function `f` is applied to the successful value,
  /// and a new `Success` containing the transformed value is returned.
  ///
  /// If this `Result` is a `Failure`, the failure value is propagated unchanged.
  ///
  /// - Parameter f: A function that takes the successful value of type `S` and returns a new value of type `S2`.
  /// - Returns: A new `Result` instance containing either the transformed success value or the original failure value.
  Result<S2, F> map<S2>(S2 Function(S s) f) {
    return fold((S s) {
      S2 transformedValue = f(s);
      return Success<S2, F>._(transformedValue);
    }, (F failureValue) {
      return Failure<S2, F>._(failureValue);
    });
  }

  /// Transforms the current `Result` by applying a function to the success value.
  ///
  /// If the current `Result` is a success, the provided function `f` is applied
  /// to the success value, and the resulting `Result` is returned.
  ///
  /// If the current `Result` is a failure, a new `Failure` with the same failure
  /// value is returned.
  ///
  /// - Parameter f: A function that takes the success value of type `S` and returns
  ///   a `Result` with a new success type `S2` and the same failure type `F`.
  /// - Returns: A new `Result` with the transformed success value or the same failure value.
  Result<S2, F> flatMap<S2>(Result<S2, F> Function(S s) f) {
    return fold((S s) {
      return f(s);
    }, (F failureValue) {
      return Failure<S2, F>._(failureValue);
    });
  }

  /// Transforms the successful result of this `Result` asynchronously using the provided `newFunction`.
  ///
  /// If this `Result` is a success, the `newFunction` is called with the success value, and its returned
  /// future is awaited and returned.
  ///
  /// If this `Result` is a failure, a new `Failure` with the same error is returned as a future.
  ///
  /// - Parameter newFunction: A function that takes the success value of this `Result` and returns a `Future` of a new `Result`.
  /// - Returns: A `Future` that completes with the transformed `Result`.
  Future<Result<S2, F>> asyncFlatMap<S2>(
      Future<Result<S2, F>> Function(S s) newFunction) {
    return fold((S s) {
      return newFunction(s);
    }, (F error) {
      return Future.value(Failure<S2, F>._(error));
    });
  }

  /// Applies the given function [f] to each element of type [S] in the result.
  ///
  /// This method uses the [fold] function to apply [f] to the element of type [S].
  /// If the result is of another type, the function does nothing.
  ///
  /// - Parameter f: A function that takes an element of type [S] and returns a
  ///   [FutureOr] of type [T].
  ///
  /// - Returns: A [FutureOr] of type [void].

  FutureOr<void> forEach<T>(FutureOr<T> Function(S) f) {
    return fold((S s) => f(s), (_) {});
  }

  /// Returns the success value if this is a `Success`, otherwise returns the result of the `defaultValue` function.
  ///
  /// This method can be used to provide a default value in case the result is a `Failure`.
  ///
  /// - Parameter defaultValue: A function that returns a default value of type `S`.
  /// - Returns: The success value if this is a `Success`, otherwise the result of the `defaultValue` function.
  S getOrElse(S Function() defaultValue) {
    return fold((S s) => s, (_) => defaultValue());
  }

  /// Returns the value of type `S` if the result is successful, otherwise returns `null`.
  ///
  /// This method uses the `fold` function to handle both success and failure cases.
  /// If the result is successful, it returns the value of type `S`.
  /// If the result is a failure, it returns `null`.
  ///
  /// Returns:
  /// - `S?`: The value of type `S` if successful, otherwise `null`.
  S? getOrNull() {
    return fold((S s) => s, (_) => null);
  }

  /// Executes an asynchronous function and returns a [Result] object.
  ///
  /// This method takes a function that returns a [Future] of type [T] and
  /// attempts to execute it. If the function completes successfully, a
  /// [Result] object containing the value is returned. If an exception
  /// occurs, a [Result] object containing the exception is returned.
  ///
  /// If an [Exception] is thrown, it is caught and wrapped in a [Result]
  /// object as a failure. If an [Error] is thrown, it is caught and wrapped
  /// in an [Exception] with the error's runtime type and stack trace, and
  /// then returned as a failure.
  ///
  /// - Parameter futureFunction: A function that returns a [Future] of type [T].
  /// - Returns: A [Future] that completes with a [Result] object containing
  ///   either the value or the exception.
  static Future<Result<T, Exception>> fromAsync<T>(
      Future<T> Function() futureFunction) async {
    try {
      T value = await futureFunction();
      return success(value);
    } on Exception catch (e) {
      return failure(e);
    } on Error catch (e) {
      return failure(Exception('${e.runtimeType}: ${e.stackTrace}'));
    }
  }

  /// Executes a synchronous function and returns a `Result` object representing
  /// either a success or a failure.
  ///
  /// If the function executes successfully, a `Success` object containing the
  /// result is returned. If an `Exception` is thrown, a `Failure` object
  /// containing the exception is returned. If an `Error` is thrown, it is
  /// caught and wrapped in an `Exception` object, which is then returned as a
  /// `Failure`.
  ///
  /// - Parameter syncFunction: The synchronous function to be executed.
  /// - Returns: A `Result` object containing either the result of the function
  ///   or an exception if an error occurred.
  static Result<T, Exception> fromSync<T>(T Function() syncFunction) {
    try {
      T value = syncFunction();
      return Success<T, Exception>._(value);
    } on Exception catch (e) {
      return Failure<T, Exception>._(e);
    } on Error catch (e) {
      return Failure<T, Exception>._(
          Exception('${e.runtimeType}: ${e.stackTrace}'));
    }
  }

  /// Constructs a Result from a value that may be null. If the value is non-null,
  /// the Result is a success with that value. If the value is null, the Result
  /// is an error.
  static Result<T, Exception> fromNullable<T>(
    T? value,
    Exception Function() onError,
  ) {
    if (value != null) {
      return success(value);
    } else {
      return failure(onError());
    }
  }

  /// Constructs a Result by testing a condition. If the condition is true,
  /// the Result is a success with a certain value. If the condition is false,
  /// the Result is an error with a certain error.
  static Result<T, Exception> fromPredicate<T>(
    bool condition,
    T Function() onSuccess,
    Exception Function() onError,
  ) =>
      condition ? success(onSuccess()) : failure(onError());
}

/// A class representing a failure result in an operation.
///
/// The `Failure` class is a subclass of `Result` that encapsulates a failure value.
/// It is used to indicate that an operation has failed and provides access to the failure value.
///
/// Type Parameters:
/// - `S`: The type of the success value.
/// - `F`: The type of the failure value.
///
/// Example usage:
/// ```dart
/// final failure = Failure<int, String>._('An error occurred');
/// print(failure.value); // Output: An error occurred
/// ```
///
/// Properties:
/// - `_f` (`F`): The failure value.
///
/// Methods:
/// - `value`: Returns the failure value.
/// - `fold<B>`: Applies the given function to the failure value.
/// - `operator ==`: Compares this `Failure` instance with another for equality.
/// - `hashCode`: Returns the hash code for this `Failure` instance.
class Failure<S, F> extends Result<S, F> {
  /// Creates a `Failure` instance with the given failure value.
  ///
  /// This constructor is private and is used internally to create a `Failure` result.
  const Failure._(this._f) : super._();
  final F _f;

  /// Returns the failure value.
  F get value => _f;

  /// Applies the given function to the failure value.
  ///
  /// If the Result is a failure, the [ifFailure] function is applied to the value.
  /// The [ifSuccess] function is ignored.
  ///
  /// Returns the result of the [ifFailure] function.
  @override
  B fold<B>(B Function(S) ifSuccess, B Function(F) ifFailure) {
    return ifFailure(_f);
  }

  /// Compares this `Failure` instance with another for equality.
  ///
  /// Two `Failure` instances are considered equal if their failure values are equal.
  @override
  bool operator ==(Object other) => other is Failure<S, F> && other._f == _f;

  /// Returns the hash code for this `Failure` instance.
  ///
  /// The hash code is based on the failure value.
  @override
  int get hashCode => _f.hashCode;
}

/// A class representing a successful result in a computation that can either
/// succeed or fail.
///
/// The [Success] class is a subclass of [Result] and holds a value of type [S]
/// which represents the successful outcome of the computation.
///
/// Example usage:
/// ```dart
/// final result = Success<int, String>._(42);
/// print(result.value); // Outputs: 42
/// ```
///
/// Type Parameters:
/// - `S`: The type of the successful result.
/// - `F`: The type of the failure result.
class Success<S, F> extends Result<S, F> {
  /// Creates a [Success] instance with the given successful value.
  ///
  /// This constructor is private and should be used internally within the
  /// library.
  const Success._(this._s) : super._();

  /// The successful value of the computation.
  final S _s;

  /// Returns the successful value.
  S get value => _s;

  /// Applies the appropriate function based on whether the result is a success
  /// or a failure.
  ///
  /// In the case of [Success], it applies the [ifSuccess] function to the
  /// successful value.
  ///
  /// - `ifSuccess`: A function to apply if the result is a success.
  /// - `ifFailure`: A function to apply if the result is a failure.
  ///
  /// Returns the result of applying the [ifSuccess] function to the successful
  /// value.
  @override
  B fold<B>(B Function(S) ifSuccess, B Function(F) ifFailure) {
    return ifSuccess(_s);
  }

  /// Compares this [Success] instance with another object for equality.
  ///
  /// Two [Success] instances are considered equal if their successful values
  /// are equal.
  @override
  bool operator ==(Object other) => other is Success<S, F> && other._s == _s;

  /// Returns the hash code of the successful value.
  @override
  int get hashCode => _s.hashCode;
}

Result<S, F> success<S, F>(S value) => Success._(value);
Result<S, F> failure<S, F>(F value) => Failure._(value);
