import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quickcard/core/services/user_service.dart';
import 'package:quickcard/shared/models/user_info.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserInfo?>(
      future: UserService.getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Row(
          children: [
            /// Left: User info
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: user?.profileImage != null
                        ? CachedNetworkImageProvider(user!.profileImage!)
                        : const AssetImage('assets/images/user.jpg')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.name ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.role ?? 'Administrator',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Right: Action buttons
            _HeaderActionButton(
              icon: Icons.notifications_outlined,
              onTap: () {
                // TODO: Notifications
              },
            ),
            const SizedBox(width: 10),
            _HeaderActionButton(
              icon: Icons.article_outlined, // logs
              onTap: () {
                // TODO: Logs
              },
            ),
          ],
        );
      },
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 255, 233, 233),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }
}
