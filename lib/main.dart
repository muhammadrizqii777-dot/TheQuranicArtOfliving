// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'habit_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox<Habit>('habits');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Qur\'anic Art of Living',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F4F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF0F4F7),
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF4C5B9C),
          secondary: const Color(0xFF8FBC8F),
        ),
      ),
      home: const HabitsTrackerPage(),
    );
  }
}

class HabitsTrackerPage extends StatefulWidget {
  const HabitsTrackerPage({super.key});

  @override
  _HabitsTrackerPageState createState() => _HabitsTrackerPageState();
}

class _HabitsTrackerPageState extends State<HabitsTrackerPage> {
  final _habitBox = Hive.box<Habit>('habits');
  final TextEditingController _textController = TextEditingController();

  void _addHabit(String name) {
    final newHabit = Habit()
      ..name = name
      ..isDone = List.generate(66, (index) => false)
      ..duration = 66
      ..startDate = DateTime.now();
    _habitBox.add(newHabit);
    _textController.clear();
  }

  void _toggleHabit(int habitIndex, int dayIndex) {
    final habit = _habitBox.getAt(habitIndex)!;
    setState(() {
      habit.isDone[dayIndex] = !habit.isDone[dayIndex];
    });
    _habitBox.putAt(habitIndex, habit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habits Tracker',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _habitBox.listenable(),
        builder: (context, Box<Habit> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Tidak ada kebiasaan. Tambahkan yang baru!'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, habitIndex) {
              final habit = box.getAt(habitIndex)!;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 11,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: habit.duration,
                        itemBuilder: (context, dayIndex) {
                          return GestureDetector(
                            onTap: () => _toggleHabit(habitIndex, dayIndex),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: habit.isDone[dayIndex] ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Tambah Kebiasaan Baru'),
                content: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: 'Nama Kebiasaan'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        _addHabit(_textController.text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Tambah'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}