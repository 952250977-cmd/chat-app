import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String avatarUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl = '',
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });
}

class Moment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final List<String> imagePaths;
  final DateTime createdAt;
  final List<String> likes;
  final List<MomentComment> comments;

  Moment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.imagePaths = const [],
    required this.createdAt,
    this.likes = const [],
    this.comments = const [],
  });
}

class MomentComment {
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  MomentComment({
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });
}

class ContactInfo {
  final String id;
  final String type;
  final String value;
  final String? imagePath;

  ContactInfo({
    required this.id,
    required this.type,
    required this.value,
    this.imagePath,
  });
}

class AppData extends ChangeNotifier {
  UserModel? _currentUser;
  final List<UserModel> _users = [];
  final Map<String, List<ChatMessage>> _messages = {};
  final List<Moment> _moments = [];
  final List<ContactInfo> _contacts = [];

  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  List<Moment> get moments => _moments;
  List<ContactInfo> get contacts => _contacts;

  AppData() {
    _initMockData();
  }

  void _initMockData() {
    _users.addAll([
      UserModel(uid: 'u1', email: 'alice@test.com', displayName: 'Alice'),
      UserModel(uid: 'u2', email: 'bob@test.com', displayName: 'Bob'),
      UserModel(uid: 'u3', email: 'charlie@test.com', displayName: 'Charlie'),
    ]);

    final now = DateTime.now();
    _moments.addAll([
      Moment(
        id: 'm1',
        userId: 'u1',
        userName: 'Alice',
        content: '今天天气真好，出去散步了~',
        createdAt: now.subtract(const Duration(hours: 2)),
        likes: ['u2'],
        comments: [
          MomentComment(userId: 'u2', userName: 'Bob', content: '看起来不错！', createdAt: now.subtract(const Duration(hours: 1))),
        ],
      ),
      Moment(
        id: 'm2',
        userId: 'u2',
        userName: 'Bob',
        content: '刚吃完一顿超好吃的火锅',
        createdAt: now.subtract(const Duration(hours: 5)),
        likes: [],
        comments: [],
      ),
    ]);

    _messages['u1_u2'] = [
      ChatMessage(id: '1', senderId: 'u1', receiverId: 'u2', content: '嗨，在吗？', timestamp: now.subtract(const Duration(minutes: 30))),
      ChatMessage(id: '2', senderId: 'u2', receiverId: 'u1', content: '在的，什么事？', timestamp: now.subtract(const Duration(minutes: 28))),
      ChatMessage(id: '3', senderId: 'u1', receiverId: 'u2', content: '周末一起出去玩？', timestamp: now.subtract(const Duration(minutes: 25))),
    ];
  }

  String _getChatKey(String uid1, String uid2) {
    final ids = [uid1, uid2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  bool login(String email, String password) {
    if (email.isEmpty || password.length < 3) return false;
    _currentUser = UserModel(uid: 'me', email: email, displayName: email.split('@').first);
    notifyListeners();
    return true;
  }

  bool register(String email, String password, String displayName) {
    if (email.isEmpty || password.length < 3 || displayName.isEmpty) return false;
    _currentUser = UserModel(uid: 'me', email: email, displayName: displayName);
    _users.add(_currentUser!);
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  List<ChatMessage> getMessages(String otherUid) {
    if (_currentUser == null) return [];
    final key = _getChatKey(_currentUser!.uid, otherUid);
    return _messages[key] ?? [];
  }

  void sendMessage(String otherUid, String content) {
    if (_currentUser == null) return;
    final key = _getChatKey(_currentUser!.uid, otherUid);
    _messages.putIfAbsent(key, () => []);
    _messages[key]!.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUser!.uid,
      receiverId: otherUid,
      content: content,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void createMoment(String content, List<String> imagePaths) {
    if (_currentUser == null) return;
    _moments.insert(0, Moment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUser!.uid,
      userName: _currentUser!.displayName,
      content: content,
      imagePaths: imagePaths,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void toggleLike(String momentId) {
    if (_currentUser == null) return;
    final moment = _moments.firstWhere((m) => m.id == momentId);
    final likes = List<String>.from(moment.likes);
    if (likes.contains(_currentUser!.uid)) {
      likes.remove(_currentUser!.uid);
    } else {
      likes.add(_currentUser!.uid);
    }
    final idx = _moments.indexWhere((m) => m.id == momentId);
    _moments[idx] = Moment(
      id: moment.id,
      userId: moment.userId,
      userName: moment.userName,
      content: moment.content,
      imagePaths: moment.imagePaths,
      createdAt: moment.createdAt,
      likes: likes,
      comments: moment.comments,
    );
    notifyListeners();
  }

  void addComment(String momentId, String content) {
    if (_currentUser == null) return;
    final moment = _moments.firstWhere((m) => m.id == momentId);
    final comments = List<MomentComment>.from(moment.comments);
    comments.add(MomentComment(
      userId: _currentUser!.uid,
      userName: _currentUser!.displayName,
      content: content,
      createdAt: DateTime.now(),
    ));
    final idx = _moments.indexWhere((m) => m.id == momentId);
    _moments[idx] = Moment(
      id: moment.id,
      userId: moment.userId,
      userName: moment.userName,
      content: moment.content,
      imagePaths: moment.imagePaths,
      createdAt: moment.createdAt,
      likes: moment.likes,
      comments: comments,
    );
    notifyListeners();
  }

  void addContact(String type, String value, String? imagePath) {
    _contacts.insert(0, ContactInfo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      value: value,
      imagePath: imagePath,
    ));
    notifyListeners();
  }

  void deleteContact(String contactId) {
    _contacts.removeWhere((c) => c.id == contactId);
    notifyListeners();
  }
}
