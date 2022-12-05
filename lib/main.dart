import 'dart:convert';
import 'package:flutter/material.dart';

//import 'package:http/http.dart' as http;
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(
          // primarySwatch: Colors.blue,
          ),
      home: const MyHomePage(title: 'ScrollView'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController scrollController = ScrollController();
  bool isLoading = true;
  List<Movie> movies = <Movie>[];
  int page = 1;

  @override
  void initState() {
    super.initState();
    getMovies();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  Future<void> getMovies() async {
    final Response response = await get(
      Uri.parse('https://yts.mx/api/v2/list_movies.json?limit=20&page = $page'),
    );

    final Map<String, dynamic> firstLevelAnswer = jsonDecode(response.body) as Map<String, dynamic>;
    final Map<String, dynamic> data = firstLevelAnswer['data'] as Map<String, dynamic>;
    final List<Map<dynamic, dynamic>> listOfMovies = List<Map<dynamic, dynamic>>.from(data['movies'] as List<dynamic>);

    for (final Map<dynamic, dynamic> currentItem in listOfMovies) {
      final List<String> genreList = List<String>.from(currentItem['genres'] as List<dynamic>);

      final Movie currentMovie =
          Movie(currentItem['title'] as String, currentItem['medium_cover_image'] as String, genreList);

      movies.add(currentMovie);
    }

    page += 1;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Builder(
          builder: (BuildContext context) {
            if (isLoading && page == 1) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              controller: scrollController,
              itemCount: movies.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (movies.length == index) {
                  // && isLoading) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }

                final String currentTitle = movies[index].title;
                final String currentImage = movies[index].imageAddress;
                final List<String> currentGenre = movies[index].genre;
                final StringBuffer allGenres = StringBuffer();
                for (int i = 0; i < currentGenre.length; i++) {
                  allGenres
                    ..write(currentGenre[i])
                    ..write(' ');
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(image: NetworkImage(currentImage), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: 100,
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      currentTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(allGenres.toString()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void onScroll() {
    final double offsetPos = scrollController.offset;
    final double maxScrollExtent = scrollController.position.maxScrollExtent;

    if (offsetPos > maxScrollExtent - MediaQuery.of(context).size.height && !isLoading) {
      getMovies();
    }
  }
}

class Movie {
  Movie(this.title, this.imageAddress, this.genre);

  final String title;
  final String imageAddress;
  final List<String> genre;
}
