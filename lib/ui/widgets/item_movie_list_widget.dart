import 'package:flutter/material.dart';

import '../../models/movie.dart';

class ItemMovieListWidget extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const ItemMovieListWidget({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF13201C),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'poster_${movie.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: movie.posterUrl.isEmpty
                      ? Container(
                    width: 82,
                    height: 120,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.movie, size: 34),
                  )
                      : Image.network(
                    movie.posterUrl,
                    width: 82,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: Colors.tealAccent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            movie.releaseDate,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 26,
                  ),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}