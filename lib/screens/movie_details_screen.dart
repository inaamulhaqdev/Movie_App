import 'package:flutter/material.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';
import 'package:movie_test_app/core/routes/app_routes.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';
import 'package:provider/provider.dart';
import 'package:movie_test_app/core/widgets/genre_chip.dart';
import 'package:movie_test_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_test_app/screens/video_player_screen.dart';
import 'package:movie_test_app/core/utils/ui_state.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String title;
  final String releaseDate;
  final String overview;
  final String imageUrl;
  final List<String> genres;
  final int movieId;

  const MovieDetailsScreen({
    super.key,
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.imageUrl,
    required this.genres,
    required this.movieId,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrailer();
    });
  }

  Future<void> _loadTrailer() async {
    if (!mounted) return;
    await context.read<MovieProvider>().loadMovieTrailer(widget.movieId);
  }

  void _handleWatchTrailer() {
    final movieProvider = context.read<MovieProvider>();
    if (movieProvider.trailerState is SuccessState) {
      final trailerUrl = (movieProvider.trailerState as SuccessState).data;
      if (trailerUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoUrl: trailerUrl),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          _BackdropImage(imageUrl: widget.imageUrl),
          _ContentOverlay(
            title: widget.title,
            releaseDate: widget.releaseDate,
            overview: widget.overview,
            genres: widget.genres,
            onWatchTrailer: _handleWatchTrailer,
          ),
        ],
      ),
    );
  }
}

class _BackdropImage extends StatelessWidget {
  final String imageUrl;

  const _BackdropImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveSizeUtil.hp(60), // 60% of screen height
      decoration: BoxDecoration(
        color: Colors.grey[900],
        image:
            imageUrl.isNotEmpty
                ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError:
                      (exception, stackTrace) =>
                          debugPrint('Error loading image: $exception'),
                )
                : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppColors.black.withOpacity(0.8)],
          ),
        ),
      ),
    );
  }
}

class _ContentOverlay extends StatelessWidget {
  final String title;
  final String releaseDate;
  final String overview;
  final List<String> genres;
  final VoidCallback onWatchTrailer;

  const _ContentOverlay({
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.genres,
    required this.onWatchTrailer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeader(context),
        SizedBox(height: ResponsiveSizeUtil.hp(22)), // 22% of screen height
        _buildMovieTitle(),
        if (releaseDate.isNotEmpty) _buildReleaseDate(),
        _buildActionButtons(context),
        Expanded(child: _buildDetailsCard()),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: ResponsiveSizeUtil.screenPadding.top,
        left: ResponsiveSizeUtil.adaptiveWidth(16),
        right: ResponsiveSizeUtil.adaptiveWidth(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.white,
              size: ResponsiveSizeUtil.adaptiveWidth(20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: ResponsiveSizeUtil.adaptiveWidth(16)),
          Text(
            'Watch',
            style: TextStyle(
              color: AppColors.white,
              fontSize: ResponsiveSizeUtil.adaptiveFontSize(18),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: ResponsiveSizeUtil.adaptiveWidth(40)),
        ],
      ),
    );
  }

  Widget _buildMovieTitle() {
    return Padding(
      padding: ResponsiveSizeUtil.adaptivePadding(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.accentBlue,
          fontSize: ResponsiveSizeUtil.adaptiveFontSize(28),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildReleaseDate() {
    return Padding(
      padding: ResponsiveSizeUtil.adaptivePadding(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Text(
        "In Theaters $releaseDate",
        style: TextStyle(
          color: AppColors.white,
          fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: ResponsiveSizeUtil.adaptivePadding(
        horizontal: 40.0,
        vertical: 20.0,
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.movieTicket,
                arguments: MovieTicketArguments(title: title, movieId: 123),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              minimumSize: Size(
                double.infinity,
                ResponsiveSizeUtil.adaptiveHeight(50),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(8),
              ),
            ),
            child: Text(
              'Get Tickets',
              style: TextStyle(
                color: AppColors.white,
                fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(12)),
          Consumer<MovieProvider>(
            builder: (context, provider, child) {
              final bool hasTrailer =
                  provider.trailerState is SuccessState &&
                  (provider.trailerState as SuccessState).data != null;

              return OutlinedButton(
                onPressed: hasTrailer ? onWatchTrailer : null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.white),
                  minimumSize: Size(
                    double.infinity,
                    ResponsiveSizeUtil.adaptiveHeight(50),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: ResponsiveSizeUtil.adaptiveBorderRadius(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: AppColors.white,
                      size: ResponsiveSizeUtil.adaptiveWidth(24),
                    ),
                    SizedBox(width: ResponsiveSizeUtil.adaptiveWidth(8)),
                    Text(
                      provider.trailerState is LoadingState
                          ? 'Loading...'
                          : hasTrailer
                          ? 'Watch Trailer'
                          : 'No Trailer Available',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.white),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveSizeUtil.adaptiveWidth(20)),
        ),
        child: SizedBox.expand(
          child: SingleChildScrollView(
            child: Padding(
              padding: ResponsiveSizeUtil.adaptivePadding(all: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (genres.isNotEmpty) ...[
                    Text(
                      'Genres',
                      style: TextStyle(
                        fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(8)),
                    Wrap(
                      spacing: ResponsiveSizeUtil.adaptiveWidth(8),
                      runSpacing: ResponsiveSizeUtil.adaptiveHeight(8),
                      children:
                          genres
                              .map((genre) => GenreChip(genre: genre))
                              .toList(),
                    ),
                    Divider(color: AppColors.lightGray, thickness: 1),
                  ],
                  Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(8)),
                  Text(
                    overview,
                    style: TextStyle(
                      fontSize: ResponsiveSizeUtil.adaptiveFontSize(12),
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: ResponsiveSizeUtil.adaptiveHeight(24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
