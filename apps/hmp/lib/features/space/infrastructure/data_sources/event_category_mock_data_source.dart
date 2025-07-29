import 'package:mobile/features/space/infrastructure/dtos/event_category_dto.dart';

class EventCategoryMockDataSource {
  static List<EventCategoryDto> getMockEventCategories() {
    return [
      EventCategoryDto(
        id: '1',
        name: '크리스마스 이벤트',
        nameEn: 'Christmas Event',
        description: '크리스마스 특별 할인 이벤트',
        descriptionEn: 'Christmas special discount event',
        displayOrder: 1,
        isActive: true,
        colorCode: '#FF0000',
        iconUrl: 'https://example.com/christmas-icon.png',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      EventCategoryDto(
        id: '2',
        name: '신년 이벤트',
        nameEn: 'New Year Event',
        description: '새해 맞이 특별 이벤트',
        descriptionEn: 'New Year special event',
        displayOrder: 2,
        isActive: true,
        colorCode: '#00FF00',
        iconUrl: 'https://example.com/newyear-icon.png',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      EventCategoryDto(
        id: '3',
        name: '할로윈 파티',
        nameEn: 'Halloween Party',
        description: '할로윈 특별 파티 이벤트',
        descriptionEn: 'Halloween special party event',
        displayOrder: 3,
        isActive: true,
        colorCode: '#FF8C00',
        iconUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}