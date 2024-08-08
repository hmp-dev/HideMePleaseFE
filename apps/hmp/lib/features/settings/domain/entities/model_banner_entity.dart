import 'package:equatable/equatable.dart';

class ModelBannerEntity extends Equatable {
  final String image;
  final String startDate;
  final String endDate;

  const ModelBannerEntity({
    required this.image,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        image,
        startDate,
        endDate,
      ];

  const ModelBannerEntity.empty()
      : image = '',
        startDate = '',
        endDate = '';

  ModelBannerEntity copyWith({
    String? image,
    String? startDate,
    String? endDate,
  }) {
    return ModelBannerEntity(
      image: image ?? this.image,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
