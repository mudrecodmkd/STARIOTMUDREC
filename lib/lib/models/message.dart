class Message {
  final bool fromUser; // true=user, false=mudrec
  final String text;
  final DateTime time;

  Message({required this.fromUser, required this.text, required this.time});

  Map<String, dynamic> toJson() => {
        'fromUser': fromUser,
        'text': text,
        'time': time.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        fromUser: j['fromUser'] as bool,
        text: j['text'] as String,
        time: DateTime.parse(j['time'] as String),
      );
}
