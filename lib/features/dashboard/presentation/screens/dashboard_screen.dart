import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:quickcard/core/services/locator.dart';
import 'package:quickcard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:quickcard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:quickcard/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:quickcard/features/dashboard/presentation/bloc/dashboard_state.dart';

import 'package:quickcard/shared/widgets/app_drawer.dart';
import 'package:quickcard/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:quickcard/features/dashboard/presentation/widgets/school_banners.dart';
import 'package:quickcard/features/dashboard/presentation/widgets/status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DashboardBloc(getIt<DashboardRepository>())..add(LoadDashboard()),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF1EE),
        drawer: const AppDrawer(),
        body: SafeArea(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DashboardError) {
                return Center(child: Text("Error: ${state.message}"));
              }

              if (state is DashboardLoaded) {
                final dashboard = state.dashboard;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<DashboardBloc>().add(LoadDashboard());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DashboardHeader(),
                        const SizedBox(height: 12),

                        /// School banners
                        SchoolBanners(schools: dashboard.schoolBasicInfo),

                        const SizedBox(height: 24),

                        /// Progress section
                        Text(
                          "My Progress",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        const SizedBox(height: 16),

                        /// Horizontal Status Cards
                        SizedBox(
                          height: 125,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _StatCardWrapper(
                                child: StatusCard(
                                  title: "Schools",
                                  count: dashboard.schoolCount,
                                  icon: Icons.school_outlined,
                                  onTap: () => context.push('/schools'),
                                ),
                              ),
                              _StatCardWrapper(
                                child: StatusCard(
                                  title: "Students",
                                  count: dashboard.studentCount,
                                  icon: Icons.people_outline,
                                  onTap: () => context.push('/students'),
                                ),
                              ),
                              _StatCardWrapper(
                                child: StatusCard(
                                  title: "With Photo",
                                  count: dashboard.studentsWithPhoto,
                                  icon: Icons.photo_camera_front_outlined,
                                  onTap: () =>
                                      context.push('/students?status=uploaded'),
                                ),
                              ),
                              _StatCardWrapper(
                                child: StatusCard(
                                  title: "Without Photo",
                                  count: dashboard.studentsWithoutPhoto,
                                  icon: Icons.photo_camera_back_outlined,
                                  onTap: () => context.push(
                                    '/students?status=not_uploaded',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// Latest activities
                        Text(
                          "Latest Activities",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        const SizedBox(height: 12),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dashboard.latestActivities.length,
                          itemBuilder: (context, index) {
                            final activity = dashboard.latestActivities[index];

                            return ListTile(
                              leading: const Icon(Icons.history),
                              title: Text(
                                "${activity.action} - ${activity.description}",
                              ),
                              subtitle: Text(
                                "IP: ${activity.ipAddress} | "
                                "${DateFormat.yMMMd().add_jm().format(activity.createdAt.toLocal())}",
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _StatCardWrapper extends StatelessWidget {
  final Widget child;

  const _StatCardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(width: 120, child: child),
    );
  }
}
