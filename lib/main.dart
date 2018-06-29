import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// utils
List<Photo> parsePhotos( String responseBody ){
  final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

Future<List<Photo>> fetchPhotos( http.Client client ) async {
  //return client.get('https://thor.net.nait.ca/~herbv/images/web.php');
  final response = await client.get('https://thor.net.nait.ca/~herbv/images/web.php');
  return compute( parsePhotos, response.body);
}

class Photo {
  final int id;
  final String title;
  final String thumbnailUrl;

  Photo( {this.id, this.title, this.thumbnailUrl });
  bool operator == ( other ) => other is Photo && this.id == other.id;
  int get hashcode => id.hashCode;
  factory Photo.fromJson( Map<String, dynamic> json ) {
    return Photo( 
      id: json['id'] as int,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final title = 'Web-o-tron';
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: this.title,
      theme: new ThemeData( primaryColor: Colors.lightGreen, fontFamily: 'Raleway'),
      home: new PhotoList(this.title),
    );
  }
}
class PhotoList extends StatefulWidget {
  final title;
  PhotoList( this.title );
  @override
  State<StatefulWidget> createState() => new PhotoListState(this.title);
}
class PhotoListState extends State<PhotoList> {
  String title;
  final _suggestions = List<Photo>();
  final _saved = Set<Photo>();
  final _bigFont = const TextStyle( fontSize: 24.0 );
  PhotoListState( this.title );
  @override Widget build( BuildContext context ) {
    return new Scaffold( 
      appBar: new AppBar( 
        title: new Text(this.title), 
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.visibility), onPressed: _pushSaved ,)
        ],
      ), 
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context,snapshot) {
          if( snapshot.hasError) print( snapshot.error );
          return snapshot.hasData ? _buildPhotoList( snapshot.data ) : Center(child: CircularProgressIndicator());
        },
      ),
      );
  }
  Widget _buildPhotoList( List<Photo> photos ){
    return new ListView.builder(
      itemCount: photos.length * 2,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if( i.isOdd) return new Divider();
        final index = i ~/ 2;
        return _buildRow(photos[index]);
      },
    );
  }
  Widget _buildRow( Photo photo){
    final alreadySaved = _saved.contains(photo);
    print('Building row with ' + photo.id.toString() + ' State : ' + alreadySaved.toString());
    return new ListTile( 
      title: new Text(photo.title, style: _bigFont,),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.blue : null,
      ),
      onTap: () {
        setState(() {
          if( alreadySaved ) {
            _saved.remove(photo);
          } else {
            _saved.add(photo);
          }
        });
      },
    );
  }
  void _pushSaved(){
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          final tiles = _saved.map(
            (photo) {
              return new Image.network(photo.thumbnailUrl);
            }
          );
          return new Scaffold(
            appBar: new AppBar( title: new Text('Saved Suggestions'),),
            body: new GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2,),
              children: tiles.toList(),),
          );
        }
      ),
    );
  }
}