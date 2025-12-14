import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcard/core/services/locator.dart';
import 'package:quickcard/features/schools/presentation/bloc/school_bloc.dart';
import 'package:quickcard/features/schools/presentation/bloc/school_event.dart';
import 'package:quickcard/features/schools/presentation/bloc/school_state.dart';

class SchoolListScreen extends StatelessWidget {
  const SchoolListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SchoolBloc(getIt())..add(LoadSchools()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Schools'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<SchoolBloc, SchoolState>(
                builder: (context, state) {
                  return TextField(
                    onChanged: (query) {
                      context.read<SchoolBloc>().add(SearchSchools(query));
                    },
                    style: const TextStyle(color: Colors.deepOrange),
                    decoration: InputDecoration(
                      hintText: 'Search by name, udise, code...',
                      hintStyle: TextStyle(
                        color: Colors.deepOrange.withValues(alpha: 0.7),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.deepOrange,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 251, 246),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocBuilder<SchoolBloc, SchoolState>(
            builder: (context, state) {
              if (state is SchoolLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SchoolLoaded) {
                if (state.schools.isEmpty) {
                  return const Center(child: Text("No schools found."));
                }

                return ListView.builder(
                  itemCount: state.schools.length,
                  itemBuilder: (context, index) {
                    final school = state.schools[index];
                    return ListTile(
                      title: Text(school.schoolName),
                      subtitle: Text(
                        "${school.udiseNo} • ${school.blockName}, ${school.districtName}",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.push('/school/${school.id}/students');
                      },
                    );
                  },
                );
              } else if (state is SchoolError) {
                return Center(child: Text("Error: ${state.message}"));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
