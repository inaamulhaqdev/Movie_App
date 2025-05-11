import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_test_app/core/constants/app_assets.dart';
import 'package:movie_test_app/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:movie_test_app/core/routes/app_routes.dart';
import 'package:movie_test_app/core/widgets/category_card.dart';
import 'package:movie_test_app/core/widgets/custom_bottom_nav_bar.dart';
import 'package:movie_test_app/core/widgets/search_result_card.dart';
import 'package:movie_test_app/core/utils/state_handler.dart';
import 'package:movie_test_app/features/movies/presentation/providers/movie_provider.dart';
import 'package:movie_test_app/core/utils/ui_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  int _selectedIndex = 1;
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _setupListeners() {
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChange);
    _scrollController.addListener(_onScroll);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    final provider = context.read<MovieProvider>();
    await provider.loadGenres();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      isKeyboardVisible = _searchFocusNode.hasFocus;
    });
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<MovieProvider>().loadMoreSearchResults();
    }
  }

  void _onSearchChanged() {
    if (!mounted) return;
    final provider = context.read<MovieProvider>();

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.isNotEmpty) {
        provider.searchMovies(_searchController.text);
      } else {
        provider.clearSearchResults();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEF0)),
              Expanded(
                child:
                    _searchController.text.isNotEmpty
                        ? _buildSearchResults()
                        : _buildCategories(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final provider = context.watch<MovieProvider>();
    final bool showResults =
        _searchController.text.isNotEmpty &&
        !_searchFocusNode.hasFocus &&
        provider.searchResultsState is SuccessState;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Row(
        children: [
          if (_searchController.text.isNotEmpty && !_searchFocusNode.hasFocus)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                _searchController.clear();
                FocusScope.of(context).unfocus();
                context.read<MovieProvider>().clearSearchResults();
                setState(() {});
              },
            ),
          if (_searchController.text.isNotEmpty) const SizedBox(width: 8),
          Expanded(
            child:
                showResults
                    ? Text(
                      '${(provider.searchResultsState as SuccessState).data.length} Results Found',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    )
                    : Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.searchBar,
                        borderRadius: BorderRadius.circular(22.5),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Image.asset(
                            AppAssets.searchIcon,
                            height: 20,
                            width: 20,
                            color: AppColors.black,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: const InputDecoration(
                                hintText: 'TV shows, movies and more',
                                hintStyle: TextStyle(
                                  color: AppColors.darkGray,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          IconButton(
                            icon: Image.asset(
                              AppAssets.closeIcon,
                              color: AppColors.black,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _searchFocusNode.requestFocus();
                              context
                                  .read<MovieProvider>()
                                  .clearSearchResults();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<MovieProvider>(
      builder: (context, provider, _) {
        final bool shouldShowCount =
            _searchFocusNode.hasFocus ||
            (_searchController.text.isEmpty &&
                provider.searchResultsState is SuccessState);

        return Column(
          children: [
            if (shouldShowCount && provider.searchResultsState is SuccessState)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${(provider.searchResultsState as SuccessState).data.length} Results Found',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: StateHandler(
                state: provider.searchResultsState,
                onLoading:
                    () => const Center(child: CircularProgressIndicator()),
                onError: (error) => Center(child: Text('Error: $error')),
                onSuccess:
                    (movies) =>
                        movies.isEmpty
                            ? const Center(child: Text('No results found'))
                            : Container(
                              color: AppColors.lightGray,
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount:
                                    movies.length +
                                    (provider.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == movies.length) {
                                    return Container(
                                      padding: const EdgeInsets.all(16.0),
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(),
                                    );
                                  }

                                  final movie = movies[index];
                                  final category =
                                      provider.genresState is SuccessState &&
                                              movie.genreIds.isNotEmpty
                                          ? (provider.genresState
                                                      as SuccessState)
                                                  .data[movie.genreIds.first] ??
                                              (movie.mediaType == 'movie'
                                                  ? 'Movie'
                                                  : 'TV Series')
                                          : movie.mediaType == 'movie'
                                          ? 'Movie'
                                          : 'TV Series';

                                  return SearchResultCard(
                                    movie: movie,
                                    category: category,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.movieDetails,
                                        arguments: MovieDetailsArguments.fromMovie(
                                          movie,
                                          movie.genreIds
                                              .map<String>(
                                                (id) =>
                                                    provider.genresState
                                                            is SuccessState
                                                        ? (provider.genresState
                                                                    as SuccessState)
                                                                .data[id] ??
                                                            ''
                                                        : '',
                                              )
                                              .where(
                                                (genre) => genre.isNotEmpty,
                                              )
                                              .toList(),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategories() {
    return Consumer<MovieProvider>(
      builder: (context, provider, _) {
        if (provider.genresState is LoadingState ||
            provider.categoryImages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return StateHandler(
          state: provider.genresState,
          onSuccess:
              (genres) => Container(
                color: CupertinoColors.systemGroupedBackground,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  padding: const EdgeInsets.all(14),
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genreEntry = genres.entries.elementAt(index);
                    final imageUrl = provider.categoryImages[genreEntry.key];
                    return CategoryCard(
                      category: genreEntry.value,
                      imageUrl:
                          imageUrl != null
                              ? 'https://image.tmdb.org/t/p/w500$imageUrl'
                              : null,
                    );
                  },
                ),
              ),
        );
      },
    );
  }
}
