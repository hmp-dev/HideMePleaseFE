part of 'nft_cubit.dart';

class NftState extends BaseState {
  final NftCollectionsGroupEntity nftCollectionsGroupEntity;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const NftState({
    required this.nftCollectionsGroupEntity,
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
  });

  factory NftState.initial() => NftState(
        nftCollectionsGroupEntity: NftCollectionsGroupEntity.empty(),
        submitStatus: RequestStatus.initial,
        errorMessage: "",
      );

  @override
  List<Object?> get props => [
        nftCollectionsGroupEntity,
        submitStatus,
        errorMessage,
      ];

  @override
  NftState copyWith({
    NftCollectionsGroupEntity? nftCollectionsGroupEntity,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
  }) {
    return NftState(
      nftCollectionsGroupEntity:
          nftCollectionsGroupEntity ?? this.nftCollectionsGroupEntity,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
