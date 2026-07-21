import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/tasks/data/datasources/firestore_task_remote_data_source.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/task_usecases.dart';
import '../../features/tasks/presentation/bloc/tasks_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  sl
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => FirebaseAuthRemoteDataSource(sl()),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()))
    ..registerLazySingleton<TaskRemoteDataSource>(
      () => FirestoreTaskRemoteDataSource(sl()),
    )
    ..registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()))
    ..registerLazySingleton(() => WatchAuthState(sl()))
    ..registerLazySingleton(() => SignInWithEmail(sl()))
    ..registerLazySingleton(() => SignUpWithEmail(sl()))
    ..registerLazySingleton(() => SignOut(sl()))
    ..registerLazySingleton(() => WatchTasks(sl()))
    ..registerLazySingleton(() => CreateTask(sl()))
    ..registerLazySingleton(() => UpdateTask(sl()))
    ..registerLazySingleton(() => DeleteTask(sl()))
    ..registerLazySingleton(() => ChangeTaskStatus(sl()))
    ..registerFactory(() => AuthBloc(sl(), sl(), sl(), sl()))
    ..registerFactory(() => TasksBloc(sl(), sl(), sl(), sl(), sl()));
}
