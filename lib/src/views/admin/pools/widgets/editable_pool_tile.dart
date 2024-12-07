import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/user_data.dart';

class BoutTile extends StatefulWidget {
  final Bout bout;
  final int index;
  final bool isEditing;
  final Function(Bout) onBoutUpdated;
  final Function(String) onEditToggle;
  final UserData? fencer;

  const BoutTile({
    super.key,
    required this.bout,
    required this.index,
    this.isEditing = false,
    required this.onBoutUpdated,
    required this.onEditToggle,
    this.fencer,
  });

  @override
  BoutTileState createState() => BoutTileState();
}

class BoutTileState extends State<BoutTile> {
  late TextEditingController _fencerScoreController;
  late TextEditingController _opponentScoreController;
  bool? _fencerWin;
  bool _boutUpdated = false;

  @override
  void initState() {
    super.initState();
    _fencerScoreController = TextEditingController(
      text: widget.bout.fencerScore.toString(),
    );
    _opponentScoreController = TextEditingController(
      text: widget.bout.opponentScore.toString(),
    );
    _fencerScoreController.addListener(() {
      setState(() {
        if (_fencerScoreController.text.isEmpty) {
          _fencerScoreController.text = "0";
        }
      });
    });
    _opponentScoreController.addListener(() {
      setState(() {
        if (_opponentScoreController.text.isEmpty) {
          _opponentScoreController.text = "0";
        }
      });
    });
    _fencerWin = widget.bout.fencerWin;
    if (!_fencerWin! && !widget.bout.opponentWin) {
      _fencerWin = null;
    }
  }

  @override
  void dispose() {
    _fencerScoreController.dispose();
    _opponentScoreController.dispose();
    super.dispose();
  }

  Color? _getScoreColor(bool isFencerScore) {
    if (!widget.isEditing && _fencerWin != null) {
      return isFencerScore
          ? (_fencerWin == true ? Colors.green : Colors.red)
          : (_fencerWin == false ? Colors.green : Colors.red);
    }

    // Default case when no manual winner is selected
    return null;
  }

  bool _saveChanges() {
    final updatedBout = widget.bout.copyWith(
      fencerScore: int.tryParse(_fencerScoreController.text),
      opponentScore: int.tryParse(_opponentScoreController.text),
      fencerWin: _fencerWin,
      opponentWin: _fencerWin != null ? !_fencerWin! : null,
    );
    if (updatedBout.fencerScore == updatedBout.opponentScore &&
        _fencerWin == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "There is a tie! Select a winner before saving.",
      )));
      return false;
    }

    widget.onBoutUpdated(updatedBout);
    return true;
  }

  void _updateBout() {
    setState(() {
      if (int.parse(_fencerScoreController.text) >
          int.parse(_opponentScoreController.text)) {
        _fencerWin = true;
      } else if (int.parse(_fencerScoreController.text) <
          int.parse(_opponentScoreController.text)) {
        _fencerWin = false;
      }
      _boutUpdated = true;
    });
  }

  Widget _buildStaticContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            child: Text(
              "${widget.index + 1}",
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.bout.fencer.fullShortenedName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.fencer == widget.bout.fencer
                        ? Colors.orange
                        : null),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Rating: ${widget.bout.fencer.rating.isEmpty ? "U" : widget.bout.fencer.rating}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "${widget.bout.fencerScore}",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _getScoreColor(true),
                ),
          ),
        ),
        Text(
          ":",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "${widget.bout.opponentScore}",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _getScoreColor(false),
                ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.bout.opponent.fullShortenedName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.fencer == widget.bout.opponent
                        ? Colors.orange
                        : null),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.edit),
        ),
      ],
    );
  }

  Widget _buildEditableContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            child: Text(
              "${widget.index + 1}",
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.bout.fencer.fullShortenedName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.fencer == widget.bout.fencer
                        ? Colors.orange
                        : null),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Rating: ${widget.bout.fencer.rating.isEmpty ? "U" : widget.bout.fencer.rating}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 0,
          child: SizedBox(
            width: 50,
            child: TextField(
              controller: _fencerScoreController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getScoreColor(true),
                  ),
              onChanged: (_) => _updateBout(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        Text(
          ":",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Expanded(
          flex: 0,
          child: SizedBox(
            width: 50,
            child: TextField(
              controller: _opponentScoreController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getScoreColor(false),
                  ),
              onChanged: (_) => _updateBout(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.bout.opponent.fullShortenedName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.fencer == widget.bout.opponent
                        ? Colors.orange
                        : null),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.save),
        ),
      ],
    );
  }

  Widget _buildTieBreaker() {
    return int.tryParse(_fencerScoreController.text) ==
            int.parse(_opponentScoreController.text)
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Select Winner:'),
                ),
                ToggleButtons(
                  isSelected: [_fencerWin == true, _fencerWin == false],
                  onPressed: (int index) {
                    setState(() {
                      if ((index == 0 && _fencerWin == true) ||
                          (index == 1 && _fencerWin == false)) {
                        _fencerWin = null;
                      } else {
                        _fencerWin = index == 0;
                      }
                      _updateBout();
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.bout.fencer.fullShortenedName),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.bout.opponent.fullShortenedName),
                    ),
                  ],
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.isEditing
          ? Theme.of(context).colorScheme.secondaryContainer
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Column(
          children: [
            widget.isEditing ? _buildEditableContent() : _buildStaticContent(),
            if (widget.isEditing) _buildTieBreaker(),
          ],
        ),
        onTap: () async {
          if (widget.isEditing && _boutUpdated) {
            bool retVal = _saveChanges();
            if (retVal) {
              widget.onEditToggle(widget.bout.id);
            }
          } else {
            widget.onEditToggle(widget.bout.id);
          }
        },
      ),
    );
  }
}
