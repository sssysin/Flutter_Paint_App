import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(PaintApp());

class PaintApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Paint App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PaintPage(),
    );
  }
}

class DrawingArea {
  Offset point;
  Paint areaPaint;
  DrawingArea({this.areaPaint, this.point});
}

class PaintPage extends StatefulWidget {
  @override
  _PaintPageState createState() => _PaintPageState();
}

class _PaintPageState extends State<PaintPage> {
  List<DrawingArea> points = [];
  Color selectedColor;
  double strokeWidth;

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  void selectColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          content: SingleChildScrollView(
            child: SlidePicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                this.setState(() {
                  selectedColor = color;
                });
              },
              paletteType: PaletteType.rgb,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: false,
              showIndicator: true,
              indicatorBorderRadius: const BorderRadius.vertical(
                top: const Radius.circular(25.0),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(138, 35, 135, 1.0),
                    Color.fromRGBO(233, 64, 87, 1.0),
                    Color.fromRGBO(242, 113, 33, 1.0),
                  ]),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24.0,
                ),
                Container(
                  width: width * 0.92,
                  height: height * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: new GestureDetector(
                    onPanDown: (details) {
                      this.setState(() {
                        points.add(DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                      });
                    },
                    onPanUpdate: (details) {
                      this.setState(() {
                        points.add(DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                      });
                    },
                    onPanEnd: (details) {
                      this.setState(() {
                        points.add(null);
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CustomPaint(
                        painter: MyCustomPainter(points: points),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  width: width * 0.92,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.color_lens,
                            color: selectedColor,
                          ),
                          onPressed: () {
                            selectColor();
                          }),
                      Expanded(
                        child: Slider(
                          min: 1.0,
                          max: 10.0,
                          activeColor: selectedColor,
                          value: strokeWidth,
                          onChanged: (value) {
                            this.setState(() {
                              strokeWidth = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.layers_clear,
                            color: selectedColor,
                          ),
                          onPressed: () {
                            this.setState(() {
                              points.clear();
                            });
                          }),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> points;
  MyCustomPainter({@required this.points});
  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    for (int x = 0; x < points.length - 1; x++) {
      if (points[x] != null && points[x + 1] != null) {
        Paint paint = points[x].areaPaint;
        canvas.drawLine(points[x].point, points[x + 1].point, paint);
      } else if (points[x] != null && points[x + 1] == null) {
        Paint paint = points[x].areaPaint;
        canvas.drawPoints(PointMode.points, [points[x].point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
