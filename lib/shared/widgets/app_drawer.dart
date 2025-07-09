import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcard/core/services/storage_service.dart';
import 'package:quickcard/core/services/user_service.dart';
import 'package:quickcard/shared/models/user_info.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<UserInfo?>(
        future: UserService.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final user = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.deepOrange),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: user?.profileImage != null
                          ? CachedNetworkImageProvider(user!.profileImage!)
                          : const AssetImage('assets/images/user.jpg')
                                as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.name ?? 'Guest',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.designation != null &&
                        user!.designation!.isNotEmpty)
                      Text(
                        user.designation!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      )
                    else if (user?.gender != null)
                      Text(
                        user!.gender,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text("Dashboard"),
                onTap: () => context.push('/dashboard'),
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text("Schools"),
                onTap: () => context.push('/schools'),
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text("Students"),
                onTap: () => context.push('/students'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("My Profile"),
                onTap: () => context.push('/profile'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () {
                  StorageService().clearAll();
                  context.go('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
