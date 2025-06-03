import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/topic.dart';
import '../widgets/topic_card.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final List<Topic> _topics = [];
  final _uuid = const Uuid();

  void _addTopic() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        Color selectedColor = Colors.blue;
        IconData selectedIcon = Icons.book;

        return AlertDialog(
          title: const Text('Add New Topic'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Topic Name',
                  hintText: 'Enter topic name',
                ),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.teal,
                ].map((color) => InkWell(
                  onTap: () => setState(() => selectedColor = color),
                  child: CircleAvatar(
                    backgroundColor: color,
                    child: selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  Icons.book,
                  Icons.science,
                  Icons.language,
                  Icons.history,
                  Icons.calculate,
                  Icons.music_note,
                ].map((icon) => InkWell(
                  onTap: () => setState(() => selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedIcon == icon
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    _topics.add(
                      Topic(
                        id: _uuid.v4(),
                        name: name,
                        color: selectedColor,
                        icon: selectedIcon,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _topics.isEmpty
          ? Center(
              child: Text(
                'No topics yet!\nTap + to add one.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                return TopicCard(topic: _topics[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTopic,
        child: const Icon(Icons.add),
      ),
    );
  }
}
