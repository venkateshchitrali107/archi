import 'dart:async';

import 'package:get_it/get_it.dart';

/// A typedef for a function that initializes the GetIt instance.
///
/// The function takes a [GetIt] instance and an optional [environment]
/// string as parameters and returns a [FutureOr<void>].
typedef GetItInitializer = FutureOr<void> Function(
  GetIt getIt,
  String? environment,
);

/// A class that initializes the GetIt instance using a provided initializer function.
class TideDIInitializer {
  /// Creates a [TideDiInitializer] with the given initializer function.
  ///
  /// The [_initializer] is a function that takes a [GetIt] instance and an
  /// optional [environment] string and returns a [FutureOr<void>].
  const TideDIInitializer(this._initializer);

  /// The initializer function that will be used to initialize the GetIt instance.
  final GetItInitializer _initializer;

  /// Initializes the GetIt instance using the provided initializer function.
  ///
  /// This method calls the [_initializer] function with the given [getIt]
  /// instance and a null environment.
  FutureOr<void> init(GetIt getIt) => _initializer(getIt, null);
}
