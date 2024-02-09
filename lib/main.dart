import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white), // Set icon color to white
        ),
      ),
      home: const PhotoList(),
    );
  }
}

class PhotoList extends StatefulWidget {
  const PhotoList({Key? key});

  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  List<Photo> photos = [];
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

      if (response.statusCode == 200) {
        final photosJson = jsonDecode(response.body) as List<dynamic>;
        photos = photosJson.map((photoJson) => Photo.fromJson(photoJson)).toList();
      } else {
        throw Exception('Failed to load photos');
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Photo Gallery App', style: TextStyle(color: Colors.white),),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != ''
          ? Center(child: Text(error))
          : ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return ListTile(
            title: Text(photo.title),
            leading: Image.network(photo.thumbnailUrl),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoDetail(photo: photo),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Photo {
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo({required this.id, required this.title, required this.url, required this.thumbnailUrl});

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    id: json['id'],
    title: json['title'],
    url: json['url'],
    thumbnailUrl: json['thumbnailUrl'],
  );
}

class PhotoDetail extends StatelessWidget {
  final Photo photo;

  const PhotoDetail({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Photo Details', style: TextStyle(color: Colors.white),),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Image.network(photo.url),
              const SizedBox(height: 20),
              Text(photo.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,),
              const SizedBox(height: 20),
              Text('ID: ${photo.id}'),
            ],
          ),
        ),
      ),
    );
  }
}

