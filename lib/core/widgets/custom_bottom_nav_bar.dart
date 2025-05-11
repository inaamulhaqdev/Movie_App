import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/app_assets.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: AppColors.darkPurple,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedItemColor: Colors.white,
            unselectedItemColor: AppColors.textGray,
            currentIndex: selectedIndex,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: TextStyle(
              color: AppColors.textGray,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            onTap: onTap,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.asset(
                    AppAssets.dashboardIcon,
                    width: 16,
                    height: 16,
                    color:
                        selectedIndex == 0 ? Colors.white : AppColors.textGray,
                  ),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.asset(
                    AppAssets.watchIcon,
                    width: 18,
                    height: 18,
                    color:
                        selectedIndex == 1 ? Colors.white : AppColors.textGray,
                  ),
                ),
                label: 'Watch',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.asset(
                    AppAssets.mediaLibraryIcon,
                    width: 18,
                    height: 18,
                    color:
                        selectedIndex == 2 ? Colors.white : AppColors.textGray,
                  ),
                ),
                label: 'Media Library',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.asset(
                    AppAssets.moreIcon,
                    width: 24,
                    height: 24,
                    color:
                        selectedIndex == 3 ? Colors.white : AppColors.textGray,
                  ),
                ),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
