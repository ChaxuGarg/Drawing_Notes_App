// ignore: avoid_web_libraries_in_flutter
// import 'dart:html';

import 'package:drawing_notes_app/drawing_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController search = TextEditingController();
  TextEditingController newDrawing = TextEditingController();
  TextEditingController rename = TextEditingController();
  List<List<Offset>> _points = [<Offset>[]];
  List<int> displayIndex = [];
  List<String> titles = [];
  int counter = 0;
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _renameKey = GlobalKey<FormState>();

  List<Dismissible> get_drawing_list(List<int> displayIndex) {
    List<Dismissible> display = [];
    for (int i = 0; i < displayIndex.length; ++i) {
      display.add(return_dismissible(displayIndex[i]));
    }
    return display;
  }

  Dismissible return_dismissible(int index) {
    return Dismissible(
        key: UniqueKey(),
        background: Container(color: Colors.red),
        onDismissed: (direction) {
          setState(() {
            displayIndex.removeAt(displayIndex.length - 1);
            counter--;
            _points.removeAt(index);
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(titles[index] + " deleted")));

          setState(() {
            titles.removeAt(index);
          });
        },
        child: GestureDetector(
          onLongPress: () {
            _renameDialog(context, index);
          },
            child: Container(
          child: ListTile(
            title: Text(
              titles[index],
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DrawingScreen(
                            points: _points[index],
                        title: titles[index],
                          )));
              setState(() {
                _points[index] = result;
                _saveDrawing(_points);
              });
            },
          ),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        )));
  }

  _saveDrawing(List<List<Offset>> points) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _pointsString = _points.toString();
    prefs.setString("pointsList", _pointsString);
    prefs.setStringList("titles", titles);
    prefs.setInt("counter", counter);
    return true;
  }

  List<List<Offset>> parseOffset(String pointsList) {
    String x = pointsList.substring(1, pointsList.length - 1);
    List<String> first = x.split("]");
    List<List<Offset>> drawings = List<List<Offset>>();
    for (var offset in first) {
      if (offset == " " || offset == "") break;
      List<String> listOffset = offset.substring(1, offset.length).split("), ");
      List<Offset> drawing = List<Offset>();
      for (int k = 0; k < listOffset.length; k++) {
        if (listOffset[k] != 'null') {
          if (listOffset[k].contains('null')) {
            String s = listOffset[k].split('null, ')[1];
            listOffset[k] = 'null';
            drawing.add(null);
            listOffset.insert(k + 1, s);
            continue;
          }
          drawing.add(Offset(
              double.parse(listOffset[k].split("(")[1].split(",")[0]),
              double.parse(listOffset[k].split(", ")[1])));
        } else {
          drawing.add(null);
        }
      }
      drawings.add(drawing);
    }
    return drawings;
  }

  _getSavedDrawing() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getInt("counter") != null) counter = prefs.getInt("counter");
      if (prefs.getString("pointsList") != null)
        _points = parseOffset(prefs.getString("pointsList"));
      if (prefs.getStringList("titles") != null)
        titles = prefs.getStringList("titles");
      for (int i = 0; i < _points.length; ++i) {
        displayIndex.add(i);
      }
      if (prefs.getStringList("titles") == null) {
        displayIndex = [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });

    _getSavedDrawing();

    setState(() {
      _isLoading = false;
    });
  }

  _renameDialog(context, int index) {
    rename.text = "";
    showDialog(
        context: context,
        builder: (BuildContext renameContext) {
          return AlertDialog(
            content: Stack(
              overflow:  Overflow.visible,
              children: <Widget>[
                Form(
                  key: _renameKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: rename,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)
                            )
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: RaisedButton(
                          color: Colors.red,
                          child: Text("Rename"),
                          onPressed: () {
                            setState(() {
                              titles[index] = rename.text;
                              _saveDrawing(_points);
                            });
                            Navigator.of(renameContext).pop();
                          },
                        ),
                      )
                    ],
                  )
                )
              ],
            ),
          );
        }
    );
  }

  _showDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
              content: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                            controller: newDrawing,
                            decoration: InputDecoration(
                                hintText: 'Enter name for drawing',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue)),
                                labelText: 'Title')),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: Colors.red,
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: Colors.green,
                              child: Text("Add"),
                              onPressed: () async {
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (drawingContext) =>
                                          DrawingScreen(points: List<Offset>(), title: newDrawing.text),
                                    ));
                                setState(() {
                                  _points.add(result);
                                  titles.add(newDrawing.text);
                                  displayIndex.add(counter);
                                  counter++;
                                  newDrawing.text = "";
                                  if (counter == 1) {
                                    _points.removeAt(0);
                                  }
                                  _saveDrawing(_points);
                                  Navigator.of(dialogContext).pop();
                                });
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ))
            ],
          ));
        });
  }

  onItemChanged(String value) {
    displayIndex = [];
    setState(() {
      for (int i = 0; i < titles.length; i++) {
        if (titles[i].toLowerCase().contains(value.toLowerCase()))
          displayIndex.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drawing Notes"),
      ),
      body: Card(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : <Widget>[
                        Padding(
                          padding: EdgeInsets.all((4.0)),
                          child: TextField(
                            scrollPadding: EdgeInsets.all(8.0),
                            controller: search,
                            decoration: InputDecoration(
                              hintText: 'Search filter',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)),
                            ),
                            onChanged: onItemChanged,
                          ),
                        )
                      ] +
                      get_drawing_list(displayIndex))),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add",
        child: Icon(Icons.add),
        onPressed: () {
          _showDialog(context);
        },
      ),
    );
  }
}
