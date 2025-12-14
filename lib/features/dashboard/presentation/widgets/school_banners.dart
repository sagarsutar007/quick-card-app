import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:quickcard/features/dashboard/data/models/dashboard_model.dart';

class SchoolBanners extends StatefulWidget {
  final List<SchoolBasicInfo> schools;

  const SchoolBanners({super.key, required this.schools});

  @override
  State<SchoolBanners> createState() => _SchoolBannersState();
}

class _SchoolBannersState extends State<SchoolBanners> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schools.isEmpty) {
      return const Text(
        "No schools assigned.",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.schools.length,
            itemBuilder: (context, index) {
              final school = widget.schools[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: _SchoolBannerCard(school: school),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        SmoothPageIndicator(
          controller: _pageController,
          count: widget.schools.length,
          effect: ExpandingDotsEffect(
            activeDotColor: const Color(0xFFFF3D3D),
            dotColor: Colors.grey.shade300,
            dotHeight: 8,
            dotWidth: 8,
            expansionFactor: 3,
            spacing: 6,
          ),
        ),
      ],
    );
  }
}

class _SchoolBannerCard extends StatelessWidget {
  final SchoolBasicInfo school;

  const _SchoolBannerCard({required this.school});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3D3D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  school.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.photo_camera_front_outlined,
                size: 18,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                '${school.havingPhotosCount} / ${school.studentsCount} Students',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('/schools/${school.id}/students');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF3D3D),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              child: const Text("View Students"),
            ),
          ),
        ],
      ),
    );
  }
}
