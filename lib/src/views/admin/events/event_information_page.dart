import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/practice.dart';

class EventInformationScreen extends StatelessWidget {
  final Practice practice;

  const EventInformationScreen({super.key, required this.practice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Information'),
      ),
      body: ListView(
        children: [
          const BusStatusSection(),
          CoachesSection(),
          ScoreSummarySection(),
          const ScoringSection(),
          // Add more sections as needed
        ],
      ),
    );
  }
}

class BusStatusSection extends StatefulWidget {
  const BusStatusSection({super.key});

  @override
  BusStatusSectionState createState() => BusStatusSectionState();
}

class BusStatusSectionState extends State<BusStatusSection> {
  bool isOnBus = false; // Replace with actual bus status

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Bus Status'),
      trailing: Switch(
        value: isOnBus,
        onChanged: (value) {
          setState(() {
            isOnBus = value;
          });
          // Add code for updating bus status
        },
      ),
    );
  }
}

class CoachesSection extends StatelessWidget {
  final List<String> coaches = ['Coach 1', 'Coach 2', 'Coach 3'];

  CoachesSection({super.key}); // Replace with actual coach data

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Coaches Taking the Bus'),
      subtitle: Text(coaches.join(', ')),
    );
  }
}

class ScoreSummarySection extends StatelessWidget {
  final List<String> rounds = ['Round 1', 'Round 2', 'Round 3'];
  final List<String> weapons = ['Sabre', 'Foil', 'Epee'];
  final List<String> fencerNames = ['Fencer 1', 'Fencer 2', 'Fencer 3'];

  final Map<String,
          Map<String, Map<String, Map<String, TextEditingController>>>>
      scoreControllers = {
    'Sabre': {
      'Fencer 1': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 2': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 3': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
    },
    'Foil': {
      'Fencer 1': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 2': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 3': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
    },
    'Epee': {
      'Fencer 1': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 2': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 3': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
    },
  };

  ScoreSummarySection({super.key}); // Text editing controllers for each score

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var round in rounds)
            Column(
              children: [
                Text(round),
                for (var weapon in weapons)
                  Column(
                    children: [
                      Text(weapon),
                      for (var fencer in fencerNames)
                        Row(
                          children: [
                            Text('$fencer:'),
                            Text(scoreControllers[weapon]![fencer]![round]![
                                    'Your Team']!
                                .text),
                            const Text('-'),
                            Text(scoreControllers[weapon]![fencer]![round]![
                                    'Opponent']!
                                .text),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          Column(
            children: [
              const Text('Total'),
              for (var weapon in weapons)
                Column(
                  children: [
                    Text(weapon),
                    for (var fencer in fencerNames)
                      Row(
                        children: [
                          Text('$fencer:'),
                          Text(calculateTotalScore(weapon, fencer)),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String calculateTotalScore(String weapon, String fencer) {
    int total = 0;
    for (var round in rounds) {
      int yourTeamScore = int.tryParse(
              scoreControllers[weapon]![fencer]![round]!['Your Team']!.text) ??
          0;
      int opponentScore = int.tryParse(
              scoreControllers[weapon]![fencer]![round]!['Opponent']!.text) ??
          0;
      total += yourTeamScore + opponentScore;
    }
    return total.toString();
  }
}

class ScoringSection extends StatefulWidget {
  const ScoringSection({super.key});

  @override
  ScoringSectionState createState() => ScoringSectionState();
}

class ScoringSectionState extends State<ScoringSection> {
  final List<String> rounds = ['Round 1', 'Round 2', 'Round 3'];
  final List<String> weapons = ['Sabre', 'Foil', 'Epee'];
  final List<String> fencerNames = ['Fencer 1', 'Fencer 2', 'Fencer 3'];
  final List<int> boutNumbers = [1, 2, 3]; // Adjust as needed

  Map<String, Map<String, Map<String, Map<String, TextEditingController>>>>
      scoreControllers = {
    'Sabre': {
      'Fencer 1': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 2': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 3': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
    },
    'Foil': {
      'Fencer 1': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 2': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 3': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
    },
    'Epee': {
      'Fencer 1': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 2': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
      'Fencer 3': {
        'Round 1': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 2': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        },
        'Round 3': {
          'Your Team': TextEditingController(),
          'Opponent': TextEditingController()
        }
      },
    },
  }; // Text editing controllers for each score

  Map<String, Map<String, String>> selectedFencer = {
    'Sabre': {
      'Round 1': 'Fencer 1',
      'Round 2': 'Fencer 1',
      'Round 3': 'Fencer 1'
    },
    'Foil': {
      'Round 1': 'Fencer 1',
      'Round 2': 'Fencer 1',
      'Round 3': 'Fencer 1'
    },
    'Epee': {
      'Round 1': 'Fencer 1',
      'Round 2': 'Fencer 1',
      'Round 3': 'Fencer 1'
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scoring'),
        for (var round in rounds)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$round:'),
              for (var weapon in weapons)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$weapon:'),
                    for (var fencer in fencerNames)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(
                                boutNumbers[fencerNames.indexOf(fencer)]
                                    .toString(),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            DropdownButton<String>(
                              value: selectedFencer[weapon]![round],
                              onChanged: (value) {
                                setState(() {
                                  selectedFencer[weapon]![round] = value!;
                                });
                              },
                              items: fencerNames.map((String fencer) {
                                return DropdownMenuItem<String>(
                                  value: fencer,
                                  child: Text(fencer),
                                );
                              }).toList(),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextField(
                                  controller: scoreControllers[weapon]![
                                      fencer]![round]!['Your Team'],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                      labelText: 'Your Team'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextField(
                                  controller: scoreControllers[weapon]![
                                      fencer]![round]!['Opponent'],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                      labelText: 'Opponent'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ElevatedButton(
          onPressed: () {
            // Add code to save the edited scores
            saveScores();
          },
          child: const Text('Save Scores'),
        ),
      ],
    );
  }

  void saveScores() {
    // Add code to process and save the edited scores
    // You can access the scores using scoreControllers map
    // For example, scoreControllers['Sabre']['Fencer 1']['Round 1']['Your Team'].text contains the edited score
  }
}
