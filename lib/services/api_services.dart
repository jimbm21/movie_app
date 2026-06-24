import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../ui/utils/constants.dart';

class ApiServices {
  Future<List<Movie>> getPopularMovies() {
    return _getMovies('/movie/popular');
  }

  Future<List<Movie>> getTopRatedMovies() {
    return _getMovies('/movie/top_rated');
  }

  Future<List<Movie>> getUpcomingMovies() {
    return _getMovies('/movie/upcoming');
  }

  Future<List<Movie>> searchMovies(String query) {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return getPopularMovies();
    }

    return _getMovies(
      '/search/movie',
      extraParams: {
        'query': cleanQuery,
        'include_adult': 'false',
      },
    );
  }

  Future<List<Movie>> _getMovies(
      String path, {
        Map<String, String> extraParams = const {},
      }) async {
    if (Constants.token.isEmpty) {
      throw Exception(
        'No se encontró el token de TMDB. Ejecuta la app usando --dart-define=TMDB_TOKEN=TU_TOKEN',
      );
    }

    final uri = Uri.parse('${Constants.baseUrl}$path').replace(
      queryParameters: {
        'language': Constants.language,
        'page': '1',
        ...extraParams,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${Constants.token}',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final List results = data['results'] ?? [];

      return results.map((movieJson) => Movie.fromJson(movieJson)).toList();
    }

    throw Exception(
      'Error al consumir la API. Código: ${response.statusCode}',
    );
  }
}