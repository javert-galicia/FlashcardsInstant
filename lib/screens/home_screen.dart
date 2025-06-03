import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../models/flashcard.dart';
import '../models/topic.dart';
import '../services/storage_service.dart';
import '../widgets/flashcard_view.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Topic> _topics = [];
  Topic? _selectedTopic;
  int _currentIndex = 0;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final topics = await widget.storageService.loadTopics();
    setState(() {
      _topics.clear();
      _topics.addAll(topics);
      if (topics.isNotEmpty) {
        _selectedTopic = topics.first;
      }
    });
  }

  Future<void> _saveTopics() async {
    await widget.storageService.saveTopics(_topics);
  }

  Future<void> _addTopic() async {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        Color selectedColor = Colors.blue;
        IconData selectedIcon = Icons.book;

        return StatefulBuilder(
          builder: (context, setState) {
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
                ElevatedButton(                  onPressed: () async {
                    if (name.isNotEmpty) {
                      final newTopic = Topic(
                        id: _uuid.v4(),
                        name: name,
                        color: selectedColor,
                        icon: selectedIcon,
                      );
                      setState(() {
                        _topics.add(newTopic);
                        _selectedTopic = newTopic;
                      });
                      await _saveTopics();
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addFlashcard() async {
    if (_selectedTopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a topic first'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        String question = '';
        String answer = '';

        return AlertDialog(
          title: const Text('Add New Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'Enter the question',
                ),
                onChanged: (value) => question = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  hintText: 'Enter the answer',
                ),
                onChanged: (value) => answer = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (question.isNotEmpty && answer.isNotEmpty) {
                  setState(() {
                    _selectedTopic!.cards.add(
                      Flashcard(
                        id: _uuid.v4(),
                        question: question,
                        answer: answer,
                        createdAt: DateTime.now(),
                      ),
                    );
                  });
                  await _saveTopics();
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

  Future<void> _editTopic(Topic topic) async {
    showDialog(
      context: context,
      builder: (context) {
        String name = topic.name;
        Color selectedColor = topic.color;
        IconData selectedIcon = topic.icon;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Topic'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Topic Name',
                      hintText: 'Enter topic name',
                    ),
                    controller: TextEditingController(text: name),
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
                  onPressed: () async {
                    if (name.isNotEmpty) {
                      topic.name = name;
                      topic.color = selectedColor;
                      topic.icon = selectedIcon;
                      await widget.storageService.updateTopic(topic);
                      setState(() {});
                      await _saveTopics();
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteFlashcard(Flashcard card) async {
    if (_selectedTopic == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flashcard'),
        content: const Text('Are you sure you want to delete this flashcard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.storageService.deleteFlashcard(_selectedTopic!.id, card.id);
              setState(() {
                _selectedTopic!.cards.remove(card);
                if (_currentIndex >= _selectedTopic!.cards.length) {
                  _currentIndex = max(0, _selectedTopic!.cards.length - 1);
                }
              });
              await _saveTopics();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTopic(Topic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Topic'),
        content: Text('Are you sure you want to delete "${topic.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.storageService.deleteTopic(topic.id);
              setState(() {
                _topics.remove(topic);
                if (_selectedTopic == topic) {
                  _selectedTopic = _topics.isNotEmpty ? _topics.first : null;
                }
              });
              await _saveTopics(); // Save after deleting
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      appBar: AppBar(        title: Text(_selectedTopic?.name ?? 'Flashcards Instant'),
        backgroundColor: _selectedTopic?.color ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () {              showAboutDialog(
                context: context,
                applicationName: 'Flashcards Instant',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 64),
                children: [
                  const Text(
                    '© 2025 Javert Galicia\n'
                    'MIT License\n\n'
                    'Developed by Javert Galicia with assistance from GitHub Copilot\n\n'
                    'A simple and elegant flashcards app for effective learning.'
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  'Topics',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _topics.isEmpty
                  ? Center(
                      child: Text(
                        'No topics yet!\nTap + to add one.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _topics.length,
                      itemBuilder: (context, index) {
                        final topic = _topics[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: topic.color,
                            child: Icon(topic.icon, color: Colors.white),
                          ),
                          title: Text(topic.name),
                          subtitle: Text('${topic.cards.length} cards'),
                          selected: topic == _selectedTopic,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _editTopic(topic);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteTopic(topic);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() => _selectedTopic = topic);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _addTopic();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Topic'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _selectedTopic == null
          ? Center(
              child: Text(
                'Select a topic from the menu\nor create a new one.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            )
          : _selectedTopic!.cards.isEmpty
              ? Center(
                  child: Text(
                    'No flashcards yet!\nTap + to add one.',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        itemCount: _selectedTopic!.cards.length,
                        controller: PageController(
                          viewportFraction: 0.9,
                          initialPage: _currentIndex,
                        ),
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final card = _selectedTopic!.cards[index];
                          return FlashcardView(
                            flashcard: card,
                            onDelete: () => _deleteFlashcard(card),
                          );
                        },
                      ),
                    ),
                    if (_selectedTopic!.cards.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Card ${_currentIndex + 1} of ${_selectedTopic!.cards.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                  ],
                ),
      floatingActionButton: _selectedTopic == null
          ? null
          : FloatingActionButton(
              onPressed: _addFlashcard,
              child: const Icon(Icons.add),
            ),
    );
  }
}
