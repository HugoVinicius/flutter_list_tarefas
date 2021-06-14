import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/item.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>.filled(0, Item(title: "", done: false), growable: false);

  HomePage() {
    items = [];
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Item 2", done: true));
    // items.add(Item(title: "Item 3", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void add(){
    setState(() {
      if (newTaskCtrl.text.isEmpty) return;

      widget.items.add(
          Item(title: newTaskCtrl.text,
              done: false,
          )
      );
      newTaskCtrl.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
       Iterable decoded = jsonDecode(data);
       List<Item> result = decoded.map((e) => Item.fromJson(e)).toList();

       setState(() {
         widget.items = result;
       });
    }
  }

  Future save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState(){
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration (
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            )
          ),
        )
      ),
      body: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (BuildContext ctxt, int index) {
            final item = widget.items[index];

            return Dismissible(
              key: Key(item.title),
              background: Container(
                color: Colors.red.withOpacity(0.2),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Remover",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              onDismissed: (direction){
                  remove(index);
              },
              child: CheckboxListTile(
                title: Text(item.title, style: item.done ? TextStyle(decoration: TextDecoration.lineThrough) : TextStyle(),),
                value: item.done,
                onChanged: (value){
                   setState(() {
                      item.done = value!;
                      save();
                  });
                },
              ),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ) ,
    );
  }


}