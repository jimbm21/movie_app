import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/api_services.dart';
import '../ui/widgets/item_movie_list_widget.dart';
import 'movie_detail_page.dart';

enum MovieCategory {
  popular,
  topRated,
  upcoming,
  search,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiServices apiServices = ApiServices();
  final TextEditingController searchController = TextEditingController();

  late Future<List<Movie>> moviesFuture;
  MovieCategory selectedCategory = MovieCategory.popular;

  Timer? searchTimer;

  @override
  void initState() {
    super.initState();
    moviesFuture = apiServices.getPopularMovies();
  }

  @override
  void dispose() {
    searchTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void loadPopular() {
    searchController.clear();
    setState(() {
      selectedCategory = MovieCategory.popular;
      moviesFuture = apiServices.getPopularMovies();
    });
  }

  void loadTopRated() {
    searchController.clear();
    setState(() {
      selectedCategory = MovieCategory.topRated;
      moviesFuture = apiServices.getTopRatedMovies();
    });
  }

  void loadUpcoming() {
    searchController.clear();
    setState(() {
      selectedCategory = MovieCategory.upcoming;
      moviesFuture = apiServices.getUpcomingMovies();
    });
  }

  void searchMovies(String value) {
    searchTimer?.cancel();

    searchTimer = Timer(const Duration(milliseconds: 500), () {
      final query = value.trim();

      if (query.isEmpty) {
        loadPopular();
        return;
      }

      setState(() {
        selectedCategory = MovieCategory.search;
        moviesFuture = apiServices.searchMovies(query);
      });
    });
  }

  Future<void> refreshMovies() async {
    setState(() {
      switch (selectedCategory) {
        case MovieCategory.popular:
          moviesFuture = apiServices.getPopularMovies();
          break;
        case MovieCategory.topRated:
          moviesFuture = apiServices.getTopRatedMovies();
          break;
        case MovieCategory.upcoming:
          moviesFuture = apiServices.getUpcomingMovies();
          break;
        case MovieCategory.search:
          moviesFuture = apiServices.searchMovies(searchController.text);
          break;
      }
    });
  }

  void openMovieDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailPage(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07110E),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Movie App',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Explora películas desde The Movie DB',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: searchController,
                        onChanged: searchMovies,
                        decoration: InputDecoration(
                          hintText: 'Buscar película...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isEmpty
                              ? null
                              : IconButton(
                            onPressed: loadPopular,
                            icon: const Icon(Icons.close),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF13201C),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _CategoryButton(
                              label: 'Populares',
                              selected:
                              selectedCategory == MovieCategory.popular,
                              onTap: loadPopular,
                            ),
                            _CategoryButton(
                              label: 'Mejor valoradas',
                              selected:
                              selectedCategory == MovieCategory.topRated,
                              onTap: loadTopRated,
                            ),
                            _CategoryButton(
                              label: 'Próximamente',
                              selected:
                              selectedCategory == MovieCategory.upcoming,
                              onTap: loadUpcoming,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Movie>>(
                    future: moviesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Ocurrió un error:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      final movies = snapshot.data ?? [];

                      if (movies.isEmpty) {
                        return const Center(
                          child: Text('No se encontraron películas.'),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: refreshMovies,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];

                            return ItemMovieListWidget(
                              movie: movie,
                              onTap: () => openMovieDetail(movie),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.teal,
        backgroundColor: const Color(0xFF13201C),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.grey.shade300,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}