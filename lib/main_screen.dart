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
  TextEditingController search = TextEditingController();
  TextEditingController newDrawing = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void addNewDrawing(String name) {
    setState(() {
      drawings.add(Drawing(name));
      drawingWidgets.add(ListTile(title: Text(name)));
    });
  }

  _showDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
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
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: Colors.green,
                              child: Text("Add"),
                              onPressed: () {
                                setState(() {
                                  drawingWidgets.add(ListTile(title: Text(newDrawing.text)));
                                });
                                newDrawing.text = "";
                                Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drawing Notes"),
      ),
      body: ListView(
        children: <Widget> [
          TextField(
            controller: search,
          )
        ] + drawingWidgets,
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
