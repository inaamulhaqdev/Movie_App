import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/app_assets.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';

class TheaterSeatSelectionScreen extends StatefulWidget {
  const TheaterSeatSelectionScreen({super.key});

  @override
  TheaterSeatSelectionScreenState createState() =>
      TheaterSeatSelectionScreenState();
}

class TheaterSeatSelectionScreenState
    extends State<TheaterSeatSelectionScreen> {
  final List<String> selectedSeats = ['4-3'];
  final double totalPrice = 50.0;

  // Zoom scale factor - controls the size of seats
  double _zoomScale = 1.0;
  // Min and max zoom limits
  final double _minZoom = 0.8;
  final double _maxZoom = 2.0;
  // Zoom step amount
  final double _zoomStep = 0.2;

  // Create a ScrollController to link with the scrollbar
  final ScrollController _scrollController = ScrollController();

  // Function to increase zoom
  void _zoomIn() {
    setState(() {
      if (_zoomScale < _maxZoom) {
        _zoomScale += _zoomStep;
      }
    });
  }

  // Function to decrease zoom
  void _zoomOut() {
    setState(() {
      if (_zoomScale > _minZoom) {
        _zoomScale -= _zoomStep;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
              'The King\'s Man',
              style: const TextStyle(
                color: AppColors.darkPurple,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'March 5, 2021 | 12:30 Hall 1',
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildSeatSelection()),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatSelection() {
    return Container(
      color: AppColors.lightGray,
      child: Column(
        children: [
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Image.asset(AppAssets.screen),
          ),
          const Text(
            "SCREEN",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    for (int row = 1; row <= 10; row++) _buildSeatRow(row),
                  ],
                ),
              ),
            ),
          ),
          // Zoom buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildZoomButton(Icons.add, _zoomIn),
                SizedBox(width: 10),
                _buildZoomButton(Icons.remove, _zoomOut),
                SizedBox(width: 12),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 6,
              radius: const Radius.circular(50.0),
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.dividerGray,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSeatRow(int rowNumber) {
    int totalColumns = 18;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$rowNumber',
              style: TextStyle(
                fontSize: 6,
                fontWeight: FontWeight.w700,
                color: AppColors.darkPurple,
              ),
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int col = 1; col <= totalColumns; col++)
                _buildSeat(rowNumber, col),
            ],
          ),

          const SizedBox(width: 20),
        ],
      ),
    );
  }

  SeatType _getSeatType(int row, int col) {
    if (row == 10) {
      return SeatType.vip;
    }

    if (row <= 2) {
      if ((col % 5 == 2 || col % 5 == 3) && (col >= 3 && col <= 16)) {
        return SeatType.regular;
      }
    } else if (row <= 4) {
      if (col % 3 != 0) {
        return SeatType.regular;
      }
    } else {
      if ((row % 2 == 1 && col % 2 == 0) || (row % 2 == 0 && col % 3 == 1)) {
        return SeatType.regular;
      }
    }

    return SeatType.notAvailable;
  }

  Widget _buildSeat(int row, int col) {
    bool isGap = (col == 3 || col == 9 || col == 15);

    if (isGap) {
      return SizedBox(width: 20 * _zoomScale);
    }

    String seatId = '$row-$col';
    SeatType type = _getSeatType(row, col);
    bool isSelected = selectedSeats.contains(seatId);

    Color seatColor;
    if (isSelected) {
      seatColor = Colors.amber;
    } else {
      switch (type) {
        case SeatType.regular:
          seatColor = AppColors.accentBlue;
          break;
        case SeatType.vip:
          seatColor = Colors.deepPurple;
          break;
        case SeatType.notAvailable:
        default:
          seatColor = Colors.grey.shade300;
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        if (type != SeatType.notAvailable) {
          setState(() {
            if (selectedSeats.contains(seatId)) {
              selectedSeats.remove(seatId);
            } else {
              selectedSeats.add(seatId);
            }
          });
        }
      },
      child: Image.asset(
        AppAssets.seat,
        height: 12 * _zoomScale,
        width: 16 * _zoomScale,
        color: seatColor,
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        height: 40,
        width: 40,
        child: IconButton(
          icon: Icon(icon, color: AppColors.black, size: 18),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSeatLegend(AppColors.gold, "Selected"),
                _buildSeatLegend(AppColors.textGray, "Not available  "),
                SizedBox(width: 40),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSeatLegend(Colors.deepPurple, "VIP (150\$)"),
                _buildSeatLegend(AppColors.accentBlue, "Regular (50 \$)"),
                SizedBox(width: 40),
              ],
            ),
          ),

          const SizedBox(height: 10),
          if (selectedSeats.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "4 / ",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.darkPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: "3 row",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSeats.remove('4-3');
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.darkPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Price",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Text(
                        "\$ 50",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedSeats.isNotEmpty ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Proceed to pay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSeatLegend(Color color, String label) {
    return Row(
      children: [
        Image.asset(AppAssets.seat, color: color, height: 16, width: 17),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

enum SeatType { regular, vip, notAvailable, selected }
