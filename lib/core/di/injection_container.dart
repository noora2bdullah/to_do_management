import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_account_local_data_source.dart';
import '../../features/auth/data/datasources/auth_credential_local_data_source.dart';
import '../../features/auth/data/datasources/firebase_account_session_manager.dart';
import '../../features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/onboarding_usecases.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/tasks/data/datasources/firestore_task_remote_data_source.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/task_usecases.dart';
import '../../features/tasks/presentation/bloc/tasks_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  sl
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<SharedPreferences>(() => sharedPreferences)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<AuthAccountLocalDataSource>(
      () => SharedPreferencesAuthAccountLocalDataSource(sl()),
    )
    ..registerLazySingleton<AuthCredentialLocalDataSource>(
      () => SecureStorageAuthCredentialLocalDataSource(sl()),
    )
    ..registerLazySingleton(() => FirebaseAccountSessionManager(sl()))
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => FirebaseAuthRemoteDataSource(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl()),
    )
    ..registerLazySingleton<OnboardingLocalDataSource>(
      () => SharedPreferencesOnboardingLocalDataSource(sl()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(sl()),
    )
    ..registerLazySingleton<TaskRemoteDataSource>(
      () => FirestoreTaskRemoteDataSource(sl()),
    )
    ..registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()))
    ..registerLazySingleton(() => WatchAuthState(sl()))
    ..registerLazySingleton(() => SignInWithEmail(sl()))
    ..registerLazySingleton(() => SignUpWithEmail(sl()))
    ..registerLazySingleton(() => GetSavedAccounts(sl()))
    ..registerLazySingleton(() => ForgetSavedAccount(sl()))
    ..registerLazySingleton(() => SwitchToSavedAccount(sl()))
    ..registerLazySingleton(() => SignOut(sl()))
    ..registerLazySingleton(() => IsOnboardingCompleted(sl()))
    ..registerLazySingleton(() => CompleteOnboarding(sl()))
    ..registerLazySingleton(() => WatchTasks(sl()))
    ..registerLazySingleton(() => RefreshTasks(sl()))
    ..registerLazySingleton(() => CreateTask(sl()))
    ..registerLazySingleton(() => UpdateTask(sl()))
    ..registerLazySingleton(() => DeleteTask(sl()))
    ..registerLazySingleton(() => ChangeTaskStatus(sl()))
    ..registerLazySingleton(() => ReorderTasks(sl()))
    ..registerFactory(() => AuthBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl()))
    ..registerFactory(() => OnboardingBloc(sl(), sl()))
    ..registerFactory(
      () => TasksBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
    );
}
