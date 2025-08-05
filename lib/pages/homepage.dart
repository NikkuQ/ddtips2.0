import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: DDTips(),
      ),
    );
  }
}

class DDTips extends StatefulWidget {
  const DDTips({super.key});

  @override
  State<DDTips> createState() => _DDTipsState();
}

class _DDTipsState extends State<DDTips> {
  String tip = 'Qui è dove vanno le curiosità?';
  bool _showOptionsHover = false;
  bool timerState = true;
  List<String> tips = [];
  int tipsIndex = 0;
  double timerSeconds = 7;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    loadTips().then((loadedTips) {
      tips = loadedTips;
      tips.shuffle();
      tip = tips[tipsIndex];
      startTimer();
    });
  }

  void nextTip({bool isClicked = false}) {
    if (tips.isEmpty) return;
    if (tipsIndex < tips.length - 1) {
      tipsIndex++;
    } else {
      tipsIndex = 0;
    }
    changeTip();
    if (isClicked) {
      timer.cancel();
      startTimer();
    }
  }

  void prevTip() {
    if (tips.isEmpty) return;
    if (tipsIndex > 0) {
      tipsIndex--;
    } else {
      tipsIndex = tips.length - 1;
    }
    changeTip();
  }

  void changeTip() {
    return setState(() {
      tip = tips[tipsIndex];
    });
  }

  void startTimer() {
    timer = Timer.periodic(
      Duration(seconds: timerSeconds.toInt()),
      (_) => nextTip(),
    );
  }

  void timerControl() {
    if (timerState) {
      startTimer();
    } else {
      timer.cancel();
    }
  }

  void setTimer(double value) {
    setState(() {
      timer.cancel();
      timerSeconds = value;
      startTimer();
    });
  }

  void selectBGImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpeg', 'jpg', 'png'],
    );

    if (result != null) {}
  }

  void selectTipsFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      timer.cancel();
      File file = File(result.files.single.path!);
      final raw = await file.readAsString();
      var newTips = raw.split('|').map((e) => e.trim()).toList();
      tips = newTips;
      tips.shuffle();
      tip = tips[0];
      startTimer();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            optionsMenu(context),
            Spacer(flex: 10),
            tipsBox(),
            Spacer(flex: 10),
            navigationButtons(),
            Spacer(flex: 15),
          ],
        ),
      ),
    );
  }

  Row optionsMenu(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: MouseRegion(
            onEnter: (_) => setState(() => _showOptionsHover = true),
            onExit: (_) => setState(() => _showOptionsHover = false),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: _showOptionsHover ? 1.0 : 0.3,
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return StatefulBuilder(
                        builder: (context, setStateDialog) {
                          return AlertDialog(
                            title: Text('Opzioni'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Attiva/Disattiva timer',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    Switch(
                                      value: timerState,
                                      onChanged: (value) {
                                        setState(() {
                                          timerState = value;
                                          timerControl();
                                        });
                                        setStateDialog(() {});
                                      },
                                    ),
                                  ],
                                ),
                                Slider.adaptive(
                                  value: timerSeconds,
                                  onChanged: timerState
                                      ? (double value) {
                                          setState(() {
                                            setTimer(value);
                                            setStateDialog(() {});
                                          });
                                        }
                                      : null,
                                  min: 1,
                                  max: 30,
                                  divisions: 29,
                                  label: '$timerSeconds',
                                ),
                                Text(
                                  'Tempo tra i tips: ${timerSeconds.toInt()} secondi',
                                  style: TextStyle(fontSize: 15),
                                ),
                                SizedBox(height: 30),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: selectBGImage,
                                      child: Text('Seleziona sfondo'),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: selectTipsFile,
                                      child: Text('Seleziona file dei tips'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Center navigationButtons() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: prevTip,
            child: Text(
              '←',
              style: TextStyle(fontSize: 30, fontFamily: 'MorrisRoman'),
            ),
          ),
          SizedBox(width: 30),
          ElevatedButton(
            onPressed: () => nextTip(isClicked: true),
            child: Text(
              '→',
              style: TextStyle(fontSize: 30, fontFamily: 'MorrisRoman'),
            ),
          ),
        ],
      ),
    );
  }

  Padding tipsBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lo sapevi che:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                fontFamily: 'MorrisRoman',
              ),
            ),
            SizedBox(height: 12),
            Text(
              tip,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 24,
                fontFamily: 'MorrisRoman',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<String>> loadTips() async {
  final raw = await rootBundle.loadString('assets/D&D.txt');
  return raw.split('|').map((e) => e.trim()).toList();
}
