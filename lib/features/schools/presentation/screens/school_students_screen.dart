import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcard/core/services/locator.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:quickcard/features/schools/data/models/student_model.dart';
import 'package:quickcard/features/schools/domain/usecases/remove_student_photo.dart';
import 'package:quickcard/features/schools/domain/usecases/upload_student_photo.dart';
import 'package:quickcard/features/schools/presentation/bloc/photo/photo_bloc.dart';
import 'package:quickcard/features/schools/presentation/bloc/photo/photo_event.dart';
import 'package:quickcard/features/schools/presentation/bloc/photo/photo_state.dart';
import 'package:quickcard/features/schools/presentation/bloc/student_bloc.dart';
import 'package:quickcard/features/schools/presentation/bloc/student_event.dart';
import 'package:quickcard/features/schools/presentation/bloc/student_state.dart';
import 'package:quickcard/shared/models/photo_upload.dart';

class SchoolStudentsScreen extends StatefulWidget {
  final int schoolId;
  const SchoolStudentsScreen({super.key, required this.schoolId});

  @override
  State<SchoolStudentsScreen> createState() => _SchoolStudentsScreenState();
}

class _SchoolStudentsScreenState extends State<SchoolStudentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _searchQuery;
  bool _tabListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchQuery = '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setupTabListener(BuildContext context) {
    if (_tabListenerAttached) return;
    _tabListenerAttached = true;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;

      final status = _getStatusFromTabIndex(_tabController.index);
      context.read<StudentBloc>().add(
        LoadStudents(widget.schoolId, status: status),
      );
    });
  }

  String _getStatusFromTabIndex(int index) {
    switch (index) {
      case 0:
        return 'missing';
      case 1:
        return 'uploaded';
      case 2:
        return 'all';
      default:
        return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolId = widget.schoolId;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => StudentBloc(getIt())
            ..add(
              LoadStudents(schoolId, status: 'missing'),
            ), // Only load Missing tab initially
        ),
        BlocProvider(
          create: (_) => PhotoBloc(
            uploadStudentPhoto: getIt<UploadStudentPhoto>(),
            removeStudentPhoto: getIt<RemoveStudentPhoto>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Setup tab listener after provider is available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _setupTabListener(context);
          });

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('School Students'),
                leading: const BackButton(),
                actions: [
                  BlocBuilder<StudentBloc, StudentState>(
                    builder: (context, state) {
                      if (state is StudentLoaded && state.canAddAuthority) {
                        return IconButton(
                          icon: const Icon(Icons.person_add),
                          tooltip: 'Add Authority',
                          onPressed: () {
                            context.push(
                              '/school/${schoolId.toString()}/add-authority',
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BlocBuilder<StudentBloc, StudentState>(
                          builder: (context, state) {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: (query) {
                                      _searchQuery = query;
                                      final currentStatus =
                                          _getStatusFromTabIndex(
                                            _tabController.index,
                                          );
                                      context.read<StudentBloc>().add(
                                        SearchStudents(
                                          schoolId,
                                          query,
                                          status: currentStatus,
                                        ),
                                      );
                                    },
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Search by name, udise, code...',
                                      hintStyle: TextStyle(
                                        color: Colors.deepOrange.withAlpha(150),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.deepOrange,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                        255,
                                        255,
                                        251,
                                        246,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.filter_list),
                                  color: Colors.white,
                                  onPressed: () {
                                    final bloc = context.read<StudentBloc>();
                                    final state = bloc.state;

                                    if (state is StudentLoaded) {
                                      final classList =
                                          state.students
                                              .map((s) => s.className)
                                              .whereType<String>()
                                              .toSet()
                                              .toList()
                                            ..sort();

                                      _openFilterSheet(
                                        context,
                                        schoolId,
                                        bloc,
                                        classList,
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        tabs: const [
                          Tab(text: "Missing"),
                          Tab(text: "Uploaded"),
                          Tab(text: "All"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  _StudentListView(schoolId: schoolId, status: 'missing'),
                  _StudentListView(schoolId: schoolId, status: 'uploaded'),
                  _StudentListView(schoolId: schoolId, status: 'all'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StudentListView extends StatefulWidget {
  final int schoolId;
  final String? status;

  const _StudentListView({required this.schoolId, this.status});

  @override
  State<_StudentListView> createState() => _StudentListViewState();
}

class _StudentListViewState extends State<_StudentListView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final bloc = context.read<StudentBloc>();
    final state = bloc.state;

    if (state is StudentLoaded && state.hasMore && !state.isLoading) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        bloc.add(
          LoadMoreStudents(
            schoolId: widget.schoolId,
            nextPage: state.currentPage + 1,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        if (state is StudentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StudentError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<StudentBloc>().add(
                      LoadStudents(widget.schoolId, status: widget.status),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is StudentLoaded) {
          // Check if this is the correct tab's data
          final isCorrectTab =
              (widget.status == 'missing' &&
                  state.currentStatus == 'missing') ||
              (widget.status == 'uploaded' &&
                  state.currentStatus == 'uploaded') ||
              (widget.status == 'all' && state.currentStatus == 'all');

          if (!isCorrectTab) {
            // Show loading while waiting for correct data
            return const Center(child: CircularProgressIndicator());
          }

          if (state.students.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: state.students.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.students.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final student = state.students[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: student.photo != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _resolvePhotoUrl(student.photo),
                            useOldImageOnUrlChange: false,
                            cacheManager: CacheManager(
                              Config(
                                'noCache',
                                stalePeriod: Duration.zero,
                                maxNrOfCacheObjects: 0,
                              ),
                            ),
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(strokeWidth: 2),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ),
                        )
                      : const Icon(Icons.person, size: 20),
                ),
                title: Text(student.name),
                subtitle: Text(
                  'Class: ${student.className ?? '-'} • DOB: ${_formatDob(student.dob)} ',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showStudentDetailsSheet(context, student),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

void _openFilterSheet(
  BuildContext context,
  int schoolId,
  StudentBloc bloc,
  List<String> classList,
) {
  String? selectedClass;
  String? selectedDobYear;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Students',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Class Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedClass,
                    hint: const Text("Select Class"),
                    onChanged: (value) => setState(() => selectedClass = value),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Classes'),
                      ),
                      ...classList.map(
                        (cls) => DropdownMenuItem(value: cls, child: Text(cls)),
                      ),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Class',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Year Input
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "DOB Year (e.g. 2010)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => selectedDobYear = value.trim(),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("Apply Filters"),
                      onPressed: () {
                        Navigator.pop(context);
                        bloc.add(
                          LoadStudents(
                            schoolId,
                            studentClass: selectedClass,
                            dob: selectedDobYear,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

void _showStudentDetailsSheet(BuildContext context, StudentModel student) {
  final bloc = context.read<StudentBloc>();
  final state = bloc.state;

  if (state is! StudentLoaded) return;

  final canUpload = state.canUploadImage;
  final canRemove = state.canRemoveImage;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (modalContext) {
      return BlocProvider(
        create: (_) => getIt<PhotoBloc>(),
        child: BlocListener<PhotoBloc, PhotoState>(
          listener: (context, photoState) {
            if (photoState is PhotoUploadSuccess ||
                photoState is PhotoRemoveSuccess) {
              ScaffoldMessenger.of(modalContext).showSnackBar(
                const SnackBar(
                  content: Text('Saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );

              bloc.add(
                LoadStudents(student.schoolId, status: state.currentStatus),
              );

              Future.delayed(const Duration(milliseconds: 300), () {
                if (Navigator.canPop(modalContext)) {
                  Navigator.pop(modalContext);
                }
              });
            }

            if (photoState is PhotoUploadFailure ||
                photoState is PhotoRemoveFailure) {
              final errorMessage = (photoState is PhotoUploadFailure)
                  ? photoState.error
                  : (photoState as PhotoRemoveFailure).error;

              final isInternetError =
                  errorMessage.contains('SocketException') ||
                  errorMessage.contains('Failed host lookup') ||
                  errorMessage.contains('Network');

              final box = Hive.box<PhotoUpload>('photo_uploads');
              final allPhotos = box.values.toList();
              debugPrint(
                "📦 Hive DB currently has ${allPhotos.length} photo(s)",
              );
              for (var p in allPhotos) {
                debugPrint(
                  "   - Photo in DB: ${p.studentId} - ${p.status} - ${p.filePath}",
                );
              }

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isInternetError
                        ? "Internet not turned on or weak internet connection"
                        : errorMessage,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Student Details",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      child: student.photo != null && student.photo!.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: _resolvePhotoUrl(student.photo),
                                useOldImageOnUrlChange: false,
                                cacheManager: CacheManager(
                                  Config(
                                    'noCache',
                                    stalePeriod: Duration.zero,
                                    maxNrOfCacheObjects: 0,
                                  ),
                                ),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person, size: 50),
                              ),
                            )
                          : const Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Class: ${student.className ?? "-"}'),
                            const SizedBox(width: 8),
                            const Text('•'),
                            const SizedBox(width: 8),
                            Text('DOB: ${_formatDob(student.dob)}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Last Updated: ${_formatDateTime(student.updatedAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),

                    if (canUpload && student.lock != 1)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.upload),
                          label: const Text("Upload Photo"),
                          onPressed: () async {
                            final source = await showImageSourceDialog(context);
                            if (!context.mounted) return;

                            if (source != null) {
                              final imageFile = await _pickImage(source);
                              if (!context.mounted) return;

                              if (imageFile != null) {
                                context.read<PhotoBloc>().add(
                                  UploadPhotoRequested(
                                    studentId: student.id.toString(),
                                    imageFile: imageFile,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    if (canRemove &&
                        student.photo != null &&
                        student.photo!.isNotEmpty &&
                        student.lock != 1)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text("Remove Photo"),
                          onPressed: () {
                            context.read<PhotoBloc>().add(
                              RemovePhotoRequested(student.id.toString()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.deepOrange,
                            elevation: 0,
                            side: const BorderSide(color: Colors.deepOrange),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

String _formatDob(String? dobString) {
  if (dobString == null || dobString.isEmpty) return '-';
  try {
    final dobDate = DateTime.tryParse(dobString);
    return dobDate != null
        ? DateFormat('MMM dd, yyyy').format(dobDate)
        : dobString;
  } catch (e) {
    return dobString;
  }
}

String _resolvePhotoUrl(String? photo) {
  if (photo == null || photo.isEmpty) return '';
  final baseUrl = photo.startsWith('http')
      ? photo
      : 'http://192.168.31.24:8000/uploads/images/students/$photo'; // http://192.168.31.24:8000

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return '$baseUrl?v=$timestamp';
}

String _formatDateTime(String? dateTimeString) {
  if (dateTimeString == null) return '-';
  try {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  } catch (_) {
    return dateTimeString;
  }
}

Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
  return await showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Image Source'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.camera),
          child: const Text('Camera'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
          child: const Text('Gallery'),
        ),
      ],
    ),
  );
}

Future<File?> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile != null) {
    return File(pickedFile.path);
  }
  return null;
}
