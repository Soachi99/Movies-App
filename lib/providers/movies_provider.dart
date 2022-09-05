import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/models/popular_response.dart';
import 'package:movies_app/models/search_movie_response.dart';

import '../models/models.dart';

class MoviesProvider extends ChangeNotifier {
  final String _baseUrl = 'api.themoviedb.org';
  final String _apiKey = '939d798fe447f98651751e8ffa5ab86a';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData({required String endPoint, int page = 1}) async {
    final url = Uri.https(_baseUrl, endPoint,
        {'api_key': _apiKey, 'language': _language, 'page': '$page'});
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final response = await _getJsonData(endPoint: '3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(response);

    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    final response =
        await _getJsonData(endPoint: '3/movie/popular', page: _popularPage);
    final popularResponse = PopularResponse.fromJson(response);

    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final response = await _getJsonData(endPoint: '3/movie/$movieId/credits');

    final credits = Credits.fromJson(response);

    moviesCast[movieId] = credits.cast;

    return credits.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
        {'api_key': _apiKey, 'language': _language, 'query': query});
    final response = await http.get(url);
    final searchMovie = SearchMovie.fromJson(response.body);

    return searchMovie.results;
  }
}
