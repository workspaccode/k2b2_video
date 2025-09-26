import 'package:get_it/get_it.dart';
import '../features/auth/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit());
}
