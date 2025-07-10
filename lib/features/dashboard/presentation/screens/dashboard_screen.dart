import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quickcard/core/services/locator.dart';
import 'package:quickcard/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:quickcard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:quickcard/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:quickcard/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:quickcard/features/dashboard/data/models/dashboard_model.dart';
import 'package:quickcard/shared/widgets/app_drawer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quickcard/core/services/user_service.dart';
import 'package:quickcard/shared/models/user_info.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DashboardBloc(getIt<DashboardRepository>())..add(LoadDashboard()),
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const AppDrawer(),
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Home"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardError) {
              return Center(child: Text("Error: ${state.message}"));
            } else if (state is DashboardLoaded) {
              final dashboard = state.dashboard;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(LoadDashboard());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<UserInfo?>(
                        future: UserService.getUser(),
                        builder: (context, snapshot) {
                          final user = snapshot.data;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreetingMessage(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.name ?? 'Guest',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: user?.profileImage != null
                                    ? CachedNetworkImageProvider(
                                        user!.profileImage!,
                                      )
                                    : const AssetImage('assets/images/user.jpg')
                                          as ImageProvider,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildSchoolBanners(dashboard.schoolBasicInfo),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                        children: [
                          _buildStatCard(
                            "Schools",
                            dashboard.schoolCount,
                            [Color(0xFF1C5858), Color(0xFF3BAEA0)],
                            () {
                              context.push('/schools');
                            },
                          ),
                          _buildStatCard(
                            "Students",
                            dashboard.studentCount,
                            [Color(0xFFF69000), Color(0xFFFFA947)],
                            () {
                              context.push('/students');
                            },
                          ),
                          _buildStatCard(
                            "With Photo",
                            dashboard.studentsWithPhoto,
                            [Color(0xFF01619E), Color(0xFF00B4DB)],
                            () {
                              context.push('/students?with_photo=true');
                            },
                          ),
                          _buildStatCard(
                            "Without Photo",
                            dashboard.studentsWithoutPhoto,
                            [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                            () {
                              context.push('/students?with_photo=false');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Latest Activities",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
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
                              "IP: ${activity.ipAddress} | ${DateFormat.yMMMd().add_jm().format(activity.createdAt)}",
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    int count,
    List<Color> gradientColors, // Accepts gradient colors
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$count",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolBanners(List<SchoolBasicInfo> schools) {
    if (schools.isEmpty) {
      return const Text(
        "No schools assigned.",
        style: TextStyle(color: Colors.grey),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: schools.length,
        itemBuilder: (context, index) {
          final school = schools[index];
          return Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6A00), Color.fromARGB(255, 255, 50, 50)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (school.address != null)
                  Text(
                    school.address!,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                const SizedBox(height: 2),
                Text(
                  "Missing Photos: ${school.missingPhotosCount}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black.withValues(alpha: 0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    onPressed: () {
                      context.push('/school/${school.id}/students');
                    },
                    child: const Text("View Students"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
