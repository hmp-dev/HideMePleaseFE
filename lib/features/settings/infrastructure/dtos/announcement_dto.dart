class Announcement {
  final String date;
  final String title;

  Announcement({required this.date, required this.title});
}

final List<Announcement> announcements = [
  Announcement(date: '2024/04/15', title: '제목 없음'),
  Announcement(date: '2024/04/15', title: 'Hide others'),
  Announcement(date: '2024/04/15', title: 'W3W (Web3 Wednesday)'),
  Announcement(date: '2024/04/15', title: 'W3W (Web3 Wednesday)'),
  Announcement(date: '2024/04/15', title: '안녕하세요! 오늘은 유치원소식'),
  Announcement(date: '2024/04/15', title: '오늘의 식단 - 점심 메뉴입니다'),
];
