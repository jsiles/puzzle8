import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MaterialApp(home: Home()));

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<_BoxItem?> current; // Estado actual
  final List<_BoxItem?> goal = [
    _BoxItem('A', Colors.red),
    _BoxItem('B', Colors.blue),
    _BoxItem('C', Colors.orange),
    _BoxItem('D', Colors.brown),
    _BoxItem('E', Colors.lightBlue),
    _BoxItem('F', Colors.yellow),
    _BoxItem('G', Colors.indigo),
    _BoxItem('H', Colors.black),
    null,
  ];

  _HomeState() : current = [];

  @override
  void initState() {
    super.initState();
    _shuffleTiles();
  }

  void _shuffleTiles() {
    final random = Random();
    List<_BoxItem?> shuffled = List<_BoxItem?>.from(goal);
    do {
      shuffled.shuffle(random);
    } while (!_isSolvable(shuffled));
    setState(() {
      current = shuffled;
    });
  }

  bool _isSolvable(List<_BoxItem?> tiles) {
    List<_BoxItem> withoutNull =
        tiles.whereType<_BoxItem>().toList(); // remove null
    int inversions = 0;
    for (int i = 0; i < withoutNull.length - 1; i++) {
      for (int j = i + 1; j < withoutNull.length; j++) {
        if (withoutNull[i].label.compareTo(withoutNull[j].label) > 0) {
          inversions++;
        }
      }
    }
    return inversions % 2 == 0;
  }

  void _moveTile(int index) {
    int emptyIndex = current.indexOf(null);
    if (_isAdjacent(index, emptyIndex)) {
      setState(() {
        final temp = current[index];
        current[index] = null;
        current[emptyIndex] = temp;

        if (_isVictory()) {
          Future.delayed(Duration(milliseconds: 300), () {
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text('¡Felicidades!'),
                    content: const Text('Has resuelto el puzzle.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _shuffleTiles();
                        },
                        child: const Text('Jugar otra vez'),
                      ),
                    ],
                  ),
            );
          });
        }
      });
    }
  }

  bool _isAdjacent(int index1, int index2) {
    int row1 = index1 ~/ 3, col1 = index1 % 3;
    int row2 = index2 ~/ 3, col2 = index2 % 3;
    return (row1 == row2 && (col1 - col2).abs() == 1) ||
        (col1 == col2 && (row1 - row2).abs() == 1);
  }

  bool _isVictory() {
    for (int i = 0; i < goal.length; i++) {
      if (goal[i]?.label != current[i]?.label) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('8 Puzzle'),
        actions: [
          IconButton(onPressed: _shuffleTiles, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Stack(
        children: [
          // Grilla principal
          Align(
            alignment: const Alignment(0, 0.6),
            child: _buildGrid(current, size: 80, clickable: true),
          ),
          // Miniatura
          Align(
            alignment: const Alignment(1, -1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildGrid(goal, size: 25, clickable: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<_BoxItem?> items, {
    required double size,
    required bool clickable,
  }) {
    return Table(
      defaultColumnWidth: FixedColumnWidth(size + 4),
      children: List.generate(3, (row) {
        return TableRow(
          children: List.generate(3, (col) {
            int index = row * 3 + col;
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: GestureDetector(
                onTap:
                    clickable && item != null ? () => _moveTile(index) : null,
                child:
                    item != null
                        ? Container(
                          width: size,
                          height: size,
                          color: item.color,
                          alignment: Alignment.center,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: size * 0.4,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        ),
              ),
            );
          }),
        );
      }),
    );
  }
}

class _BoxItem {
  final String label;
  final Color color;

  _BoxItem(this.label, this.color);
}
