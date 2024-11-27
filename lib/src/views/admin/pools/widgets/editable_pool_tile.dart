import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lhs_fencing/src/models/bout.dart';

class _EditableBoutTileWidget extends StatefulWidget {
  final Bout bout;
  final int index;

  const _EditableBoutTileWidget({
    required this.bout,
    required this.index,
  });

  @override
  State<_EditableBoutTileWidget> createState() =>
      _EditableBoutTileWidgetState();
}

class _EditableBoutTileWidgetState extends State<_EditableBoutTileWidget> {
  late TextEditingController fencerController;
  late TextEditingController opponentController;

  @override
  void initState() {
    super.initState();
    fencerController =
        TextEditingController(text: widget.bout.fencerScore.toString());
    opponentController =
        TextEditingController(text: widget.bout.opponentScore.toString());
  }

  @override
  void dispose() {
    fencerController.dispose();
    opponentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isScoreTied = int.tryParse(fencerController.text) ==
        int.tryParse(opponentController.text);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  "${widget.index + 1}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bout.fencer.fullShortenedName,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Rating: ${widget.bout.fencer.rating.isEmpty ? "U" : widget.bout.fencer.rating}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: fencerController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(":"),
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: opponentController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.bout.opponent.fullShortenedName,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Rating: ${widget.bout.opponent.rating.isEmpty ? "U" : widget.bout.opponent.rating}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isScoreTied)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ToggleButtons(
                isSelected: const [false, false],
                onPressed: (int index) {
                  int fencerScore = int.tryParse(fencerController.text) ?? 0;
                  int opponentScore =
                      int.tryParse(opponentController.text) ?? 0;
                  // _updateBout(
                  //   widget.bout,
                  //   fencerScore,
                  //   opponentScore,
                  //   fencerWins: index == 0,
                  // );
                },
                color: Colors.grey,
                selectedColor: Colors.white,
                fillColor: Colors.green,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(widget.bout.fencer.fullShortenedName),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(widget.bout.opponent.fullShortenedName),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  int fencerScore = int.tryParse(fencerController.text) ?? 0;
                  int opponentScore =
                      int.tryParse(opponentController.text) ?? 0;

                  // If scores are different, update normally
                  if (fencerScore != opponentScore) {
                    // _updateBout(widget.bout, fencerScore, opponentScore);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    // _editingBouts.remove(widget.bout.id);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
