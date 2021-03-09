import 'package:drawing_notes_app/drawing_screen.dart';
import 'package:flutter/material.dart';


class Drawing {
  String name = "";

  Drawing(String name) {
    this.name = name;
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  List<Drawing> drawings = [];
  List<ListTile> drawingWidgets = [];
  List<ListTile> newDrawingList = [];
  TextEditingController search = TextEditingController();
  TextEditingController newDrawing = TextEditingController();
  List<List<Offset>> _points = [<Offset>[]];
  final _formKey = GlobalKey<FormState>();

  void addNewDrawing(String name) {
    setState(() {
      drawings.add(Drawing(name));
      drawingWidgets.add(ListTile(title: Text(name)));
    });
  }

  // ignore: non_constant_identifier_names
  ListTile return_list_tile (String title, List<Offset> result){
    return ListTile(
      title: Text(
          title,
        style: TextStyle(
          fontSize: 40.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DrawingScreen(points: result)));
      },
    );
  }
  _showDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget> [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget> [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: newDrawing,
                          decoration: InputDecoration(
                            hintText: 'Enter name for drawing',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)
                            ),
                            labelText: 'Title'
                            )
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget> [
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
                                List<Offset> save =[];
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (drawingContext) => DrawingScreen(points: save),
                                    ));
                                setState(() {
                                  _points.add(result);
                                  drawingWidgets.add(return_list_tile(newDrawing.text, result));
                                  newDrawingList = List.from(drawingWidgets);
                                  newDrawing.text = "";
                                  Navigator.of(dialogContext).pop();
                                });
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )
                )
              ],
            )
          );
        }
    );
  }

  onItemChanged(String value) {
    setState(() {
      newDrawingList = drawingWidgets.where((string) => string.title.toString().toLowerCase().contains(value.toLowerCase())).toList();
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
          children: <Widget> [
            Padding(
                padding: EdgeInsets.all((4.0)),
                child: TextField(
                  scrollPadding: EdgeInsets.all(8.0),
                  controller: search,
                  decoration: InputDecoration(
                    hintText: 'Search filter',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)
                    ),
                  ),
                  onChanged: onItemChanged,
                ),
            ) ] + newDrawingList,
          )
        ),
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



