import 'package:flutter/material.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key, required this.listOfTips});
  final List<String> listOfTips;

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  late List<String> modifiedList;
  final ScrollController _scrollController = ScrollController();
  final Map<int, FocusNode> _focusNodes = {};
  final Map<int, TextEditingController> _textController = {};

  @override
  void initState() {
    super.initState();
    modifiedList = List<String>.from(widget.listOfTips);
    _initializeControllers();
  }

  void _initializeControllers() {
    for (int i = 0; i < modifiedList.length; i++) {
      _focusNodes[i] = FocusNode();
      _textController[i] = TextEditingController(text: modifiedList[i]);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNodes.values.forEach(disposeNodes);
    _textController.values.forEach(disposeControllers);
    super.dispose();
  }

  void disposeNodes(node) => node.dispose();
  void disposeControllers(controller) => controller.dispose();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista dei TIP'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: modifiedList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.only(left: 10, right: 5),
                    title: TextField(
                      controller: _textController[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) {
                        modifiedList[index] = value;
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.redAccent,
                      onPressed: () {
                        setState(() {
                          _focusNodes[index]?.dispose();
                          _textController[index]?.dispose();
                          _focusNodes.remove(index);
                          _textController.remove(index);
                          modifiedList.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                right: 20,
                bottom: 10,
                top: 10,
                left: 20,
              ),
              width: double.infinity,
              color: Theme.of(context).colorScheme.inversePrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      addAndScroll();
                    },
                    icon: Icon(Icons.post_add),
                    label: Text("Aggiungi tip"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, modifiedList); // Torna indietro
                    },
                    icon: Icon(Icons.save),
                    label: Text('Salva e indietro'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addAndScroll() {
    int newIndex = modifiedList.length;

    setState(() {
      modifiedList.add("");
      _focusNodes[newIndex] = FocusNode();
      _textController[newIndex] = TextEditingController(text: "");
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      _focusNodes[newIndex]?.requestFocus();
    });
  }
}
