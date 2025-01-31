import 'package:get_it/get_it.dart';

import 'tide_di_initializer.dart';

final diContainer = _TideDIContainer(_getIt);

Future<DIContainer> initializeDIContainer(
  List<TideDIInitializer> initializers,
) async {
  for (final initializer in initializers) {
    await initializer.init(_getIt);
  }
  return diContainer;
}

abstract class DIContainer {
  T call<T extends Object>({dynamic parameter, String? name});

  bool isRegistered<T extends Object>({String? name});
}

final _getIt = GetIt.instance;

class _TideDIContainer implements DIContainer {
  const _TideDIContainer(this._getIt);

  final GetIt _getIt;

  @override
  T call<T extends Object>({dynamic parameter, String? name}) =>
      _getIt<T>(param1: parameter, instanceName: name);

  @override
  bool isRegistered<T extends Object>({String? name}) =>
      _getIt.isRegistered<T>(instanceName: name);
}
