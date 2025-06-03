import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/topic.dart';

class StorageService {
  static const String _topicsKey = 'flashcards_topics';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<void> saveTopics(List<Topic> topics) async {
    final topicsJson = topics.map((topic) => topic.toJson()).toList();
    await _prefs.setString(_topicsKey, jsonEncode(topicsJson));
  }

  Future<List<Topic>> loadTopics() async {
    final topicsString = _prefs.getString(_topicsKey);
    if (topicsString == null) return [];

    try {
      final topicsJson = jsonDecode(topicsString) as List;
      return topicsJson
          .map((json) => Topic.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading topics: $e');
      return [];
    }
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  Future<void> deleteTopic(String topicId) async {
    final topics = await loadTopics();
    topics.removeWhere((topic) => topic.id == topicId);
    await saveTopics(topics);
  }

  Future<void> deleteFlashcard(String topicId, String cardId) async {
    final topics = await loadTopics();
    final topicIndex = topics.indexWhere((topic) => topic.id == topicId);
    if (topicIndex != -1) {
      topics[topicIndex].cards.removeWhere((card) => card.id == cardId);
      await saveTopics(topics);
    }
  }

  Future<void> updateTopic(Topic topic) async {
    final topics = await loadTopics();
    final index = topics.indexWhere((t) => t.id == topic.id);
    if (index != -1) {
      topics[index] = topic;
      await saveTopics(topics);
    }
  }
}
