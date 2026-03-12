// aplicativo de introdução ao uso de Widgets de Layout (Columns, Rows, Stacks, Containers)

//void main
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Widgets de Layout")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      color: Colors.lightBlue,
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                    ),
                    Icon(Icons.star),
                  ],
                ),
                //fechei a stack mas estou dentro da linha
                Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      color: Colors.amberAccent,
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                    ),
                    Icon(Icons.circle_outlined),
                  ],
                ),
                //ainda dentro da linha outro stack
                Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      color: Colors.green,
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                    ),
                    Icon(Icons.star),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      color: Colors.lightBlue,
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                    ),
                    Icon(Icons.star),
                  ],
                ),
                //fechei a stack mas estou dentro da linha
                Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      color: Colors.amberAccent,
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                    ),
                    Icon(Icons.circle_outlined),
                  ],
                ),
                //ainda dentro da linha outro stack
                Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      color: Colors.green,
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                    ),
                    Icon(Icons.star),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      color: Colors.lightBlue,
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                    ),
                    Icon(Icons.star),
                  ],
                ),
                //fechei a stack mas estou dentro da linha
                Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      color: Colors.amberAccent,
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                    ),
                    Icon(Icons.circle_outlined),
                  ],
                ),
                //ainda dentro da linha outro stack
                Stack(
                  alignment: AlignmentGeometry.center,
                  children: [
                    Container(
                      color: Colors.green,
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                    ),
                    Icon(Icons.star),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
