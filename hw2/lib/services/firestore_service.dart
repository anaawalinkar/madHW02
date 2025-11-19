import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users collection
  final String _usersCollection = 'users';
  
  // Messages collection
  final String _messagesCollection = 'messages';

  // Create or update user document
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create/update user: ${e.toString()}');
    }
  }

  // Get user by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  // Send message to a board
  Future<void> sendMessage(Message message) async {
    try {
      await _firestore
          .collection(_messagesCollection)
          .add(message.toMap());
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  // Get messages stream for a board (real-time)
  Stream<List<Message>> getMessagesStream(String boardId) {
    return _firestore
        .collection(_messagesCollection)
        .where('boardId', isEqualTo: boardId)
        .snapshots()
        .map((snapshot) {
      // Sort in memory to avoid requiring a composite index
      final messages = snapshot.docs.map((doc) {
        return Message.fromMap(doc.id, doc.data());
      }).toList();
      
      // Sort by createdAt in ascending order
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      return messages;
    });
  }

  // Get all message boards (hardcoded for now, but stored in Firestore)
  Future<List<Map<String, dynamic>>> getMessageBoards() async {
    try {
      // For now, return hardcoded boards
      // In a real app, you'd fetch from Firestore
      return [
        {
          'id': 'general',
          'name': 'General Discussion',
          'icon': '💬',
        },
        {
          'id': 'tech',
          'name': 'Technology',
          'icon': '💻',
        },
        {
          'id': 'sports',
          'name': 'Sports',
          'icon': '⚽',
        },
        {
          'id': 'music',
          'name': 'Music',
          'icon': '🎵',
        },
        {
          'id': 'movies',
          'name': 'Movies & TV',
          'icon': '🎬',
        },
      ];
    } catch (e) {
      throw Exception('Failed to get message boards: ${e.toString()}');
    }
  }
}
