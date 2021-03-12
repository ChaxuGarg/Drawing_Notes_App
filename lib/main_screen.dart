import 'package:drawing_notes_app/drawing_screen.dart';
import 'package:flutter/material.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  TextEditingController search = TextEditingController();
  TextEditingController newDrawing = TextEditingController();
  List<List<Offset>> _points = [<Offset>[]];
  List<Dismissible> drawingDismissible = [];
  List<int> displayIndex = [];
  List<String> titles = [];
  int counter = 0;

  final _formKey = GlobalKey<FormState>();

  List<Dismissible> get_drawing_list(List<Dismissible> drawingDismissible, List<int> displayIndex) {
    List<Dismissible> display = [];
    for(int i = 0; i < displayIndex.length; ++i){
      display.add(drawingDismissible[displayIndex[i]]);
    }
    return display;
  }

  Dismissible return_dismissible(String title, List<Offset> result) {
    return Dismissible(
        key: UniqueKey(),
        background: Container(color: Colors.red),
        onDismissed: (direction) {
          int index = titles.indexOf(title);
          setState(() {
            displayIndex.removeAt(displayIndex.length - 1);
            counter--;
            _points.removeAt(index);
            drawingDismissible.removeAt(index);
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(titles[index] + " deleted")));

          setState(() {
            titles.removeAt(index);
          });
        },
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DrawingScreen(points: result,))
            );
          },
        ),
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
                                List<Offset> save = [];
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (drawingContext) =>
                                          DrawingScreen(points: save),
                                    ));
                                setState(() {
                                  _points.add(result);
                                  titles.add(newDrawing.text);
                                  displayIndex.add(counter);
                                  counter++;
                                  drawingDismissible.add(return_dismissible(newDrawing.text, result));
                                  newDrawing.text = "";
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
      for(int i = 0; i < titles.length; i++) {
        if(titles[i].toLowerCase().contains(value.toLowerCase())) displayIndex.add(i);
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
        children: <Widget>[
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
              get_drawing_list(drawingDismissible, displayIndex)
      )),
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
