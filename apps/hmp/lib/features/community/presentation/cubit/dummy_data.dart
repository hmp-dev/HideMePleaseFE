class ChatMessage {
  final String senderName;
  final String message;

  const ChatMessage({
    required this.senderName,
    required this.message,
  });
}

final List<ChatMessage> recentDummyMsgs = [
  const ChatMessage(
    senderName: '펑크족',
    message: '오늘 블루밍에서 재즈 한 잔합니까?',
  ),
  const ChatMessage(
    senderName: '노땡큐씨',
    message: '전 하미플 을지에서 은신할 예정이요',
  ),
  const ChatMessage(
    senderName: '퓨철이',
    message: '아하, 말걸리가 더 땡기는데.... 막걸리는 별로세요?',
  ),
];
