import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickcard/core/services/connectivity_service.dart';
import 'package:quickcard/core/config/app_config.dart';
import 'package:quickcard/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:quickcard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:quickcard/features/schools/data/usecases/remove_student_photo_impl.dart';
import 'package:quickcard/features/schools/domain/repositories/school_repository.dart';
import 'package:quickcard/features/schools/data/datasources/remote/student_remote_data_source_impl.dart';
import 'package:quickcard/features/schools/data/repositories/school_repository_impl.dart';
import 'package:quickcard/features/schools/domain/repositories/student_repository.dart';
import 'package:quickcard/features/schools/data/repositories/student_repository_impl.dart';
import 'package:quickcard/features/schools/domain/usecases/upload_student_photo.dart';
import 'package:quickcard/features/schools/domain/usecases/remove_student_photo.dart';
import 'package:quickcard/features/schools/data/usecases/upload_student_photo_impl.dart';
import 'package:quickcard/features/schools/presentation/bloc/photo/photo_bloc.dart';
import 'package:quickcard/features/schools/presentation/bloc/student_bloc.dart';
import 'package:quickcard/shared/models/photo_upload.dart';
import 'package:quickcard/shared/utils/photo_upload_queue.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../network/api_client.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PhotoUploadAdapter());
  final photoUploadBox = await Hive.openBox<PhotoUpload>('photo_uploads');
  getIt.registerSingleton<Box<PhotoUpload>>(photoUploadBox);

  // Dio instance
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = await getIt.getAsync<StorageService>();
          final token = storage.token;

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.type == DioExceptionType.badResponse) {
            if (e.response?.data != null &&
                e.response?.data is Map<String, dynamic>) {
              Map<String, dynamic> responseData = e.response!.data;
              if (responseData.containsKey('errors')) {
                (responseData['errors'] as Map<String, dynamic>).forEach((
                  field,
                  messages,
                ) {
                  List<String> errorMessages = (messages as List<dynamic>)
                      .map((m) => m.toString())
                      .toList();
                  print('$field: ${errorMessages.join(', ')}');
                });
              } else if (responseData.containsKey('message')) {
                print('Server Message: ${responseData['message']}');
              }
            }
          }

          return handler.next(e);
        },
      ),
    );
    return dio;
  });

  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));

  getIt.registerSingletonAsync<StorageService>(() async {
    final service = StorageService();
    await service.init();
    return service;
  });

  getIt.registerLazySingleton<UserService>(() => UserService());

  getIt.registerLazySingleton<SchoolRepository>(
    () => SchoolRepositoryImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(
      apiClient: getIt<ApiClient>(),
      remoteDataSource: StudentRemoteDataSourceImpl(getIt<ApiClient>()),
      pendingPhotosBox: getIt<Box<PhotoUpload>>(),
    ),
  );

  getIt.registerLazySingletonAsync<PhotoUploadQueue>(() async {
    final storage = await getIt.getAsync<StorageService>();
    final token = storage.token ?? '';
    return PhotoUploadQueue(getIt<Dio>(), AppConfig.baseUrl, token);
  });

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<UploadStudentPhoto>(
    () => UploadStudentPhotoImpl(getIt<StudentRepository>()),
  );

  getIt.registerLazySingleton<RemoveStudentPhoto>(
    () => RemoveStudentPhotoImpl(getIt<StudentRepository>()),
  );

  getIt.registerFactory<PhotoBloc>(
    () => PhotoBloc(
      uploadStudentPhoto: getIt<UploadStudentPhoto>(),
      removeStudentPhoto: getIt<RemoveStudentPhoto>(),
    ),
  );

  getIt.registerFactory<StudentBloc>(() => StudentBloc(getIt()));

  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  await getIt.allReady();

  await _initializeConnectivityAndPhotoUpload();
}

Future<void> _initializeConnectivityAndPhotoUpload() async {
  final photoUploadQueue = await getIt.getAsync<PhotoUploadQueue>();
  final connectivityService = getIt<ConnectivityService>();
  final studentRepository = getIt<StudentRepository>() as StudentRepositoryImpl;

  await studentRepository.retryPendingUploads();
  await photoUploadQueue.processQueue();

  connectivityService.startMonitoring(() async {
    await studentRepository.retryPendingUploads();
    await photoUploadQueue.processQueue();
  });
}
