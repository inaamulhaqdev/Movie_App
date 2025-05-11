import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/app_assets.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';
import 'package:movie_test_app/screens/theater_seat_selection.dart';

class MovieTicketScreen extends StatefulWidget {
  final String title;
  final int movieId;
  const MovieTicketScreen({
    super.key,
    required this.title,
    required this.movieId,
  });

  @override
  State<MovieTicketScreen> createState() => _MovieTicketScreenState();
}

class _MovieTicketScreenState extends State<MovieTicketScreen> {
  int selectedDateIndex = 0;
  final List<String> dates = ['5 Mar', '6 Mar', '7 Mar', '8 Mar', '9 Mar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: ResponsiveSizeUtil.adaptiveHeight(100),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.darkPurple,
            size: ResponsiveSizeUtil.adaptiveWidth(20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.white,
        title: Column(
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: AppColors.darkPurple,
                fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(5)),
            Text(
              'In theaters december 22, 2021',
              style: TextStyle(
                color: AppColors.accentBlue,
                fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(40)),
            _buildDateSelector(),
            SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(40)),
            _buildShowtimes(),
            const Spacer(),
            _buildSelectSeatsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: ResponsiveSizeUtil.adaptivePadding(horizontal: 16.0),
          child: Text(
            "Date",
            style: TextStyle(
              fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
              fontWeight: FontWeight.w500,
              color: AppColors.darkPurple,
            ),
          ),
        ),
        SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(10)),
        SizedBox(
          height: ResponsiveSizeUtil.adaptiveHeight(40),
          child: ListView.builder(
            padding: ResponsiveSizeUtil.adaptivePadding(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final isSelected = index == selectedDateIndex;
              return Padding(
                padding: EdgeInsets.only(
                  right: ResponsiveSizeUtil.adaptiveWidth(8.0),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDateIndex = index;
                    });
                  },
                  child: Container(
                    width: ResponsiveSizeUtil.adaptiveWidth(70),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.accentBlue
                              : AppColors.dividerGray,
                      borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(10),
                    ),
                    child: Text(
                      dates[index],
                      style: TextStyle(
                        fontSize: ResponsiveSizeUtil.adaptiveFontSize(14),
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShowtimes() {
    return SizedBox(
      height: ResponsiveSizeUtil.hp(30), // 30% of screen height
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: ResponsiveSizeUtil.adaptivePadding(horizontal: 16.0),
        children: [
          _buildShowtime("12:30", "Cinetech + Hall 1", 50, 2500),
          SizedBox(width: ResponsiveSizeUtil.adaptiveWidth(12)),
          _buildShowtime("13:30", "Cinetech", 75, 3000),
        ],
      ),
    );
  }

  Widget _buildShowtime(String time, String hallName, int price, int bonus) {
    return SizedBox(
      width: ResponsiveSizeUtil.wp(70), // 70% of screen width
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
                  color: AppColors.darkPurple,
                ),
              ),
              SizedBox(width: ResponsiveSizeUtil.adaptiveWidth(8)),
              Text(
                hallName,
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(8)),
          Container(
            height: ResponsiveSizeUtil.hp(20), // 20% of screen height
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accentBlue, width: 1),
              borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(10),
            ),
            child: _buildSeatMap(),
          ),
          SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(10)),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "From ",
                  style: TextStyle(
                    fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: "$price\$ ",
                  style: TextStyle(
                    fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
                    color: AppColors.darkPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "or ",
                  style: TextStyle(
                    fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: "$bonus bonus",
                  style: TextStyle(
                    fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
                    color: AppColors.darkPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMap() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: ResponsiveSizeUtil.adaptivePadding(
              horizontal: 36.0,
              vertical: 36.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScreenIndicator(constraints.maxWidth * 0.8),
                SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(10)),
                Expanded(child: _buildSeatGrid()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreenIndicator(double width) {
    return Image.asset(
      AppAssets.border,
      width: width,
      height: ResponsiveSizeUtil.adaptiveHeight(10),
    );
  }

  Widget _buildSeatGrid() {
    List<List<int>> seatLayout = [
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0],
      [1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0],
      [0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1],
      [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1],
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1],
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1],
      [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
      [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0],
    ];

    Map<int, Color> seatColors = {
      0: Colors.grey.shade300,
      1: AppColors.accentBlue,
      2: AppColors.teal,
      3: AppColors.pink,
      4: AppColors.purple,
    };

    seatLayout[2][5] = 2;
    seatLayout[2][6] = 2;
    seatLayout[6][5] = 2;
    seatLayout[6][6] = 2;

    seatLayout[4][4] = 3;
    seatLayout[4][5] = 3;
    seatLayout[4][8] = 3;
    seatLayout[4][9] = 3;

    seatLayout[3][6] = 4;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 14,
        childAspectRatio: 1.8,
        crossAxisSpacing: ResponsiveSizeUtil.adaptiveWidth(4),
        mainAxisSpacing: ResponsiveSizeUtil.adaptiveHeight(4),
      ),
      itemCount: seatLayout.length * seatLayout[0].length,
      itemBuilder: (context, index) {
        final row = index ~/ seatLayout[0].length;
        final col = index % seatLayout[0].length;
        final seatType = seatLayout[row][col];

        return Image.asset(
          AppAssets.seat,
          width: ResponsiveSizeUtil.adaptiveWidth(8),
          height: ResponsiveSizeUtil.adaptiveHeight(8),
          color: seatColors[seatType],
          colorBlendMode: BlendMode.srcIn,
        );
      },
    );
  }

  Widget _buildSelectSeatsButton() {
    return Padding(
      padding: ResponsiveSizeUtil.adaptivePadding(
        horizontal: 26.0,
        vertical: 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveSizeUtil.adaptiveHeight(50),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TheaterSeatSelectionScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            shape: RoundedRectangleBorder(
              borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(8),
            ),
          ),
          child: Text(
            "Select Seats",
            style: TextStyle(
              fontSize: ResponsiveSizeUtil.adaptiveFontSize(14),
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
