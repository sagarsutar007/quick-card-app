import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class SchoolStudentsScreen extends StatelessWidget {
  final int schoolId;
  const SchoolStudentsScreen({super.key, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              StudentBloc(getIt())
                ..add(LoadStudents(schoolId, status: 'missing')),
        ),
        BlocProvider(
          create: (_) => PhotoBloc(
            uploadStudentPhoto: getIt<UploadStudentPhoto>(),
            removeStudentPhoto: getIt<RemoveStudentPhoto>(),
          ),
        ),
      ],
      child: DefaultTabController(
        length: 3,
        child: Builder(
          builder: (context) => GestureDetector(
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
                                    onChanged: (query) => context
                                        .read<StudentBloc>()
                                        .add(SearchStudents(schoolId, query)),
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Search by name, udise, code...',
                                      hintStyle: TextStyle(
                                        color: Colors.deepOrange.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.deepOrange,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                        255,
                                        255,
                                        251,
                                        246,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
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
                                    _openFilterSheet(context, schoolId, bloc);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        tabs: [
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
                children: [
                  _StudentListView(
                    schoolId: schoolId,
                    status: 'missing',
                    onTabActive: () => context.read<StudentBloc>().add(
                      LoadStudents(schoolId, status: 'missing'),
                    ),
                  ),
                  _StudentListView(
                    schoolId: schoolId,
                    status: 'uploaded',
                    onTabActive: () => context.read<StudentBloc>().add(
                      LoadStudents(schoolId, status: 'uploaded'),
                    ),
                  ),
                  _StudentListView(
                    schoolId: schoolId,
                    status: 'all',
                    onTabActive: () => context.read<StudentBloc>().add(
                      LoadStudents(schoolId, status: 'all'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentListView extends StatefulWidget {
  final int schoolId;
  final String? status;
  final VoidCallback? onTabActive;

  const _StudentListView({
    required this.schoolId,
    this.status,
    this.onTabActive,
  });

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final tabController = DefaultTabController.of(context);
    if (!_tabControllerAttached) {
      _tabControllerAttached = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        tabController.addListener(() {
          if (tabController.index == _getTabIndex() &&
              widget.onTabActive != null) {
            widget.onTabActive!();
          }
        });
      });
    }
  }

  bool _tabControllerAttached = false;

  int _getTabIndex() {
    return widget.status == null
        ? 0
        : widget.status == 'uploaded'
        ? 1
        : 2;
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
                      LoadStudents(
                        widget.schoolId,
                        status: widget.status == 'missing'
                            ? 'not uploaded'
                            : widget.status,
                      ),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is StudentLoaded) {
          final filteredStudents = widget.status == null
              ? state.students
              : state.students.where((student) {
                  final hasPhoto =
                      student.photo != null && student.photo!.isNotEmpty;
                  return widget.status == 'uploaded' ? hasPhoto : !hasPhoto;
                }).toList();

          if (filteredStudents.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: filteredStudents.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= filteredStudents.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final student = filteredStudents[index];

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

void _openFilterSheet(BuildContext context, int schoolId, StudentBloc bloc) {
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
                    items: List.generate(
                      12,
                      (index) => DropdownMenuItem(
                        value: '${index + 1}',
                        child: Text('Class ${index + 1}'),
                      ),
                    ),
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
              bloc.add(
                LoadStudents(student.schoolId, status: state.currentStatus),
              );

              if (Navigator.canPop(modalContext)) {
                Navigator.pop(modalContext);
              }
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
      : 'https://thequickcard.com/api/uploads/images/students/$photo';
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
