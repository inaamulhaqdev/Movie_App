import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_test_app/core/constants/app_assets.dart';
import 'package:provider/provider.dart';
import 'package:movie_test_app/core/routes/app_routes.dart';
import 'package:movie_test_app/core/widgets/custom_bottom_nav_bar.dart';
import 'package:movie_test_app/core/widgets/movie_card.dart';
import 'package:movie_test_app/core/widgets/optimized_selector.dart';
import 'package:movie_test_app/core/utils/state_handler.dart';
import 'package:movie_test_app/core/utils/resource_manager.dart';
import 'package:movie_test_app/core/utils/responsive_size_util.dart';
import 'package:movie_test_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_test_app/features/movies/domain/models/movie_model.dart';
import 'package:movie_test_app/core/utils/ui_state.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with ResourceManagerMixin<HomePage> {
  int _selectedIndex = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  final Map<int, MovieDetailsArguments> _cachedMovieArguments = {};

  @override
  void initState() {
    super.initState();
    _setupStatusBar();
    _setupScrollListener();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovies();
    });
  }

  @override
  void dispose() {
    _cachedMovieArguments.clear();
    super.dispose();
  }

  void _setupStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.darkPurple,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _setupScrollListener() {
    manageNotifier(_scrollController);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent -
              ResponsiveSizeUtil.adaptiveHeight(200)) {
        _loadMoreMovies();
      }
    });
  }

  Future<void> _loadMovies() async {
    await context.read<MovieProvider>().loadUpcomingMovies();
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await context.read<MovieProvider>().loadMoreUpcomingMovies();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  MovieDetailsArguments _getMovieDetailsArguments(
    MovieModel movie,
    MovieProvider provider,
  ) {
    if (_cachedMovieArguments.containsKey(movie.id)) {
      return _cachedMovieArguments[movie.id]!;
    }

    final args = MovieDetailsArguments.fromMovie(
      movie,
      movie.genreIds
          .map<String>(
            (id) =>
                provider.genresState is SuccessState
                    ? (provider.genresState as SuccessState).data[id] ?? ''
                    : '',
          )
          .where((genre) => genre.isNotEmpty)
          .toList(),
    );

    _cachedMovieArguments[movie.id] = args;
    return args;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dividerGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        toolbarHeight: ResponsiveSizeUtil.adaptiveHeight(80),
        elevation: 5,
        title: Padding(
          padding: ResponsiveSizeUtil.adaptivePadding(all: 8.0),
          child: Text(
            'Watch',
            style: TextStyle(
              color: AppColors.darkPurple,
              fontSize: ResponsiveSizeUtil.adaptiveFontSize(16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              AppAssets.searchIcon,
              height: ResponsiveSizeUtil.adaptiveHeight(18),
              width: ResponsiveSizeUtil.adaptiveWidth(18),
              color: AppColors.darkPurple,
            ),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
          ),
          SizedBox(width: ResponsiveSizeUtil.adaptiveWidth(8)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: ResponsiveSizeUtil.adaptivePadding(
            horizontal: 16,
            vertical: 16,
          ),
          child: OptimizedSelector<MovieProvider, UIState<List<MovieModel>>>(
            selector: (context, provider) => provider.upcomingMoviesState,
            builder: (context, state, child) {
              return StateHandler(
                state: state,
                onSuccess:
                    (movies) => RefreshIndicator(
                      onRefresh: _loadMovies,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: ResponsiveSizeUtil.adaptivePadding(
                          vertical: 0,
                        ),
                        itemCount: movies.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == movies.length) {
                            return Center(
                              child: Padding(
                                padding: ResponsiveSizeUtil.adaptivePadding(
                                  all: 16.0,
                                ),
                                child: const CircularProgressIndicator(),
                              ),
                            );
                          }

                          final movie = movies[index];
                          final provider = context.read<MovieProvider>();

                          return MovieCard(
                            movie: movie,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.movieDetails,
                                arguments: _getMovieDetailsArguments(
                                  movie,
                                  provider,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                onRetry: _loadMovies,
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
