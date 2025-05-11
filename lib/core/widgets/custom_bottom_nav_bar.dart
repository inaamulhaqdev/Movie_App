import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/app_assets.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';

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
      height: ResponsiveSizeUtil.adaptiveHeight(75),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: ResponsiveSizeUtil.adaptiveWidth(8),
            offset: Offset(0, ResponsiveSizeUtil.adaptiveHeight(4)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(24),
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
            selectedFontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
            unselectedFontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
            selectedLabelStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
            ),
            unselectedLabelStyle: TextStyle(
              color: AppColors.textGray,
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
            ),
            elevation: 0,
            onTap: onTap,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveSizeUtil.adaptiveHeight(8),
                  ),
                  child: Image.asset(
                    AppAssets.dashboardIcon,
                    width: ResponsiveSizeUtil.adaptiveWidth(16),
                    height: ResponsiveSizeUtil.adaptiveHeight(16),
                    color:
                        selectedIndex == 0 ? Colors.white : AppColors.textGray,
                  ),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveSizeUtil.adaptiveHeight(8),
                  ),
                  child: Image.asset(
                    AppAssets.watchIcon,
                    width: ResponsiveSizeUtil.adaptiveWidth(18),
                    height: ResponsiveSizeUtil.adaptiveHeight(18),
                    color:
                        selectedIndex == 1 ? Colors.white : AppColors.textGray,
                  ),
                ),
                label: 'Watch',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveSizeUtil.adaptiveHeight(8),
                  ),
                  child: Image.asset(
                    AppAssets.mediaLibraryIcon,
                    width: ResponsiveSizeUtil.adaptiveWidth(18),
                    height: ResponsiveSizeUtil.adaptiveHeight(18),
                    color:
                        selectedIndex == 2 ? Colors.white : AppColors.textGray,
                  ),
                ),
                label: 'Media Library',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveSizeUtil.adaptiveHeight(8),
                  ),
                  child: Image.asset(
                    AppAssets.moreIcon,
                    width: ResponsiveSizeUtil.adaptiveWidth(24),
                    height: ResponsiveSizeUtil.adaptiveHeight(24),
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
