class Message {
  final String id;
  final String text;
  final DateTime createdAt;
  final String userId;
  final String userEmail;
  final String userName;
  final String boardId;

  Message({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.boardId,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'boardId': boardId,
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      text: map['text'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      userId: map['userId'],
      userEmail: map['userEmail'],
      userName: map['userName'],
      boardId: map['boardId'],
    );
  }
}