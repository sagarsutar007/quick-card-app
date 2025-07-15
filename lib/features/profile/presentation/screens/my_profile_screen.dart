import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcard/core/services/storage_service.dart';
import 'package:quickcard/shared/models/user_info.dart';
import 'package:quickcard/shared/widgets/profile_field_widget.dart';
import 'package:quickcard/shared/widgets/social_link_widget.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  UserInfo? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final fetchedUser = await GetIt.I<StorageService>().getUser();
    setState(() {
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 227, 208),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: Colors.deepOrange,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: user!.profileImage != null
                              ? CachedNetworkImage(
                                  imageUrl: user!.profileImage!,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person, size: 80),
                                )
                              : const Icon(Icons.person, size: 80),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user!.designation ?? 'No Designation',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildProfileField(
                              context: context,
                              label: 'Your Email',
                              value: user!.email,
                              icon: Icons.email,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            buildProfileField(
                              context: context,
                              label: 'Phone Number',
                              value: user!.phone,
                              icon: Icons.phone,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            buildProfileField(
                              context: context,
                              label: 'Date of Birth',
                              value: user!.dob ?? 'N/A',
                              icon: Icons.cake,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            buildProfileField(
                              context: context,
                              label: 'Gender',
                              value: user?.gender ?? '-',
                              icon: Icons.person_outline,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            buildProfileField(
                              context: context,
                              label: 'About',
                              value: user!.about ?? '',
                              icon: Icons.info_outline,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            buildProfileField(
                              context: context,
                              label: 'Address',
                              value: user!.address ?? '',
                              icon: Icons.location_on,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            buildProfileField(
                              context: context,
                              label: 'Website',
                              value: user!.website ?? '',
                              icon: Icons.language,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Social Links',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),

                            SocialLinkWidget(
                              label: user!.facebook ?? '',
                              url: user!.facebook,
                              icon: Icons.facebook,
                            ),
                            SocialLinkWidget(
                              label: user!.twitter ?? '',
                              url: user!.twitter,
                              icon: Icons.alternate_email,
                            ),
                            SocialLinkWidget(
                              label: user!.instagram ?? '',
                              url: user!.instagram,
                              icon: Icons.camera_alt,
                            ),
                            SocialLinkWidget(
                              label: user!.youtube ?? '',
                              url: user!.youtube,
                              icon: Icons.ondemand_video,
                            ),
                            SocialLinkWidget(
                              label: user!.whatsapp ?? '',
                              url: user!.whatsapp,
                              icon: Icons.chat,
                            ),
                            SocialLinkWidget(
                              label: user!.threads ?? '',
                              url: user!.threads,
                              icon: Icons.chat_bubble_outline,
                            ),
                            SocialLinkWidget(
                              label: user!.website ?? '',
                              url: user!.website,
                              icon: Icons.language,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await GetIt.I<StorageService>().clearAll();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
