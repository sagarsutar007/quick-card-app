import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialLinkWidget extends StatelessWidget {
  final String? url;
  final String label;
  final IconData icon;

  const SocialLinkWidget({
    super.key,
    required this.url,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) return const SizedBox.shrink();

    final formattedUrl = url!.startsWith('http') ? url! : 'https://${url!}';
    final uri = Uri.tryParse(formattedUrl);
    if (uri == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
          }
        },
        child: Row(
          children: [
            Icon(icon, color: Colors.deepOrange),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
