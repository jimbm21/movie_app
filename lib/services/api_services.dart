import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../ui/utils/constants.dart';

class ApiServices {
  Future<List<Movie>> getPopularMovies() async {
    if (Constants.token.isEmpty) {
      throw Exception(
        'No se encontró el token de TMDB. Ejecuta la app usando --dart-define=TMDB_TOKEN=TU_TOKEN',
      );
    }

    final uri = Uri.parse('${Constants.baseUrl}/movie/popular').replace(
      queryParameters: {
        'language': Constants.language,
        'page': '1',
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

      return results
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList();
    }

    throw Exception(
      'Error al consumir la API. Código: ${response.statusCode}. Respuesta: ${response.body}',
    );
  }
}