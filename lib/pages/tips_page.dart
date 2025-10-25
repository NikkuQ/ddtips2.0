import 'package:ddtips2/widget/tip_item.dart';
import 'package:flutter/material.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key, required this.listOfTips});
  final List<String> listOfTips;

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  late List<TipItem> _tipList;
  late List<String> _originalList;
  final ScrollController _scrollController = ScrollController();
  bool _listIsChanged = false;

  @override
  void initState() {
    super.initState();
    _originalList = List<String>.from(widget.listOfTips);
    _tipList = widget.listOfTips.map((text) => TipItem(text: text)).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    disposeList();
    super.dispose();
  }

  void disposeList() {
    for (var item in _tipList) {
      item.dispose();
    }
  }

  void cancelChanges() {
    _listIsChanged = false;
    setState(() {
      disposeList();
      _tipList = _originalList.map((text) => TipItem(text: text)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista dei TIP'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _tipList.length,
                itemBuilder: (context, index) {
                  final tip = _tipList[index];
                  return ListTile(
                    key: tip.key,
                    contentPadding: EdgeInsets.only(left: 10, right: 5),
                    title: TextField(
                      controller: tip.controller,
                      focusNode: tip.focusNode,
                      onChanged: (value) {
                        _listIsChanged = true;
                        setState(() {
                          tip.text = value;
                        });
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.redAccent,
                      onPressed: () {
                        _listIsChanged = true;
                        setState(() {
                          tip.dispose();
                          _tipList.removeAt(index);
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
              color: theme.colorScheme.inversePrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: addAndScroll,
                    icon: Icon(Icons.post_add),
                    label: Text("Aggiungi tip"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _listIsChanged ? cancelChanges : null,
                    icon: Icon(Icons.cancel_outlined),
                    label: Text("Annulla modifiche"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        _tipList.map((tip) => tip.text).toList(),
                      );
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
    _listIsChanged = true;
    setState(() {
      _tipList.add(TipItem(text: ""));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      _tipList.last.focusNode.requestFocus();
    });
  }
}
