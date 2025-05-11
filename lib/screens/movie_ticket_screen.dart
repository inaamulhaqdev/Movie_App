import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/app_assets.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';
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
        toolbarHeight: 100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkPurple),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.white,
        title: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.darkPurple,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'In theaters december 22, 2021',
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontSize: 12,
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
            const SizedBox(height: 40),
            _buildDateSelector(),
            const SizedBox(height: 40),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Date",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkPurple,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final isSelected = index == selectedDateIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDateIndex = index;
                    });
                  },
                  child: Container(
                    width: 70,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.accentBlue
                              : AppColors.dividerGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      dates[index],
                      style: TextStyle(
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
      height: MediaQuery.of(context).size.height * 0.3,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildShowtime("12:30", "Cinetech + Hall 1", 50, 2500),
          const SizedBox(width: 12),
          _buildShowtime("13:30", "Cinetech", 75, 3000),
        ],
      ),
    );
  }

  Widget _buildShowtime(String time, String hallName, int price, int bonus) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.darkPurple,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hallName,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: MediaQuery.of(context).size.height * 0.20,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accentBlue, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _buildSeatMap(),
          ),
          const SizedBox(height: 10),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "From ",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: "$price\$ ",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "or ",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: "$bonus bonus",
                  style: const TextStyle(
                    fontSize: 12,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 36.0,
              vertical: 36.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScreenIndicator(constraints.maxWidth * 0.8),
                const SizedBox(height: 10),
                Expanded(child: _buildSeatGrid()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreenIndicator(double width) {
    return Image.asset(AppAssets.border);
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 14,
        childAspectRatio: 1.8,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: seatLayout.length * seatLayout[0].length,
      itemBuilder: (context, index) {
        final row = index ~/ seatLayout[0].length;
        final col = index % seatLayout[0].length;
        final seatType = seatLayout[row][col];

        return Image.asset(
          AppAssets.seat,
          width: 8,
          height: 8,
          color: seatColors[seatType],
          colorBlendMode: BlendMode.srcIn,
        );
      },
    );
  }

  Widget _buildSelectSeatsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
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
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Select Seats",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
