import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Web-o=tron',
      theme: new ThemeData( primaryColor: Colors.lightGreen, fontFamily: 'Raleway'),
      home: new RandomWords(),
    );
  }
}
class RandomWords extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new RandomWordsState();
}
class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _bigFont = const TextStyle( fontSize: 18.0 );
  @override Widget build( BuildContext context ) {
    return new Scaffold( 
      appBar: new AppBar( 
        title: new Text('Web-o=tron'), 
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved ,)
        ],
      ), 
      body: _buildSuggestions(),
      );
  }
  Widget _buildSuggestions(){
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if( i.isOdd) return new Divider();
        final index = i ~/ 2;
        if( index >= _suggestions.length ){
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }
  Widget _buildRow( WordPair pair){
    final alreadySaved = _saved.contains(pair);
    return new ListTile( 
      title: new Text(pair.asPascalCase, style: _bigFont,),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.blue : null,
      ),
      onTap: () {
        setState(() {
          if( alreadySaved ) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
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
            (pair) {
              return new ListTile(
                title: new Text(pair.asPascalCase, style: _bigFont,),
              );
            }
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return new Scaffold(
            appBar: new AppBar( title: new Text('Saved Suggestions'),),
            body: new ListView(children: divided,),
          );
        }
      ),
    );
  }
}