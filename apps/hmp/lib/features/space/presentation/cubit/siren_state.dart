import 'package:equatable/equatable.dart';
import 'package:mobile/features/space/domain/entities/siren_entity.dart';
import 'package:mobile/features/space/domain/entities/siren_list_response_entity.dart';
import 'package:mobile/features/space/domain/entities/siren_create_response_entity.dart';
import 'package:mobile/features/space/domain/entities/siren_stats_entity.dart';

class SirenState extends Equatable {
  final bool isLoading;
  final bool isCreating;
  final bool isDeleting;
  final String errorMessage;
  final List<SirenEntity> sirenList;
  final SirenListResponseEntity sirenListResponse;
  final SirenCreateResponseEntity? createResponse;
  final SirenStatsEntity? stats;
  final String sortBy; // 'distance' or 'time'
  final int currentPage;
  final Set<String> reportedSirenIds;
  final Set<String> blockedUserIds;

  const SirenState({
    this.isLoading = false,
    this.isCreating = false,
    this.isDeleting = false,
    this.errorMessage = '',
    this.sirenList = const [],
    this.sirenListResponse = const SirenListResponseEntity.empty(),
    this.createResponse,
    this.stats,
    this.sortBy = 'time',
    this.currentPage = 1,
    this.reportedSirenIds = const {},
    this.blockedUserIds = const {},
  });

  SirenState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isDeleting,
    String? errorMessage,
    List<SirenEntity>? sirenList,
    SirenListResponseEntity? sirenListResponse,
    SirenCreateResponseEntity? createResponse,
    SirenStatsEntity? stats,
    String? sortBy,
    int? currentPage,
    Set<String>? reportedSirenIds,
    Set<String>? blockedUserIds,
  }) {
    return SirenState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage ?? this.errorMessage,
      sirenList: sirenList ?? this.sirenList,
      sirenListResponse: sirenListResponse ?? this.sirenListResponse,
      createResponse: createResponse ?? this.createResponse,
      stats: stats ?? this.stats,
      sortBy: sortBy ?? this.sortBy,
      currentPage: currentPage ?? this.currentPage,
      reportedSirenIds: reportedSirenIds ?? this.reportedSirenIds,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isCreating,
        isDeleting,
        errorMessage,
        sirenList,
        sirenListResponse,
        createResponse,
        stats,
        sortBy,
        currentPage,
        reportedSirenIds,
        blockedUserIds,
      ];
}
