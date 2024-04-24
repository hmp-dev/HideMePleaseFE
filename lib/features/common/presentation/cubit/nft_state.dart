part of 'nft_cubit.dart';

class NftState extends BaseState {
  final NftCollectionsGroupEntity nftCollectionsGroupEntity;
  final List<SelectedNFTDto> selectedNftTokensList;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const NftState({
    required this.nftCollectionsGroupEntity,
    required this.selectedNftTokensList,
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
  });

  factory NftState.initial() => NftState(
        nftCollectionsGroupEntity: NftCollectionsGroupEntity.empty(),
        selectedNftTokensList: const [],
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
    List<SelectedNFTDto>? selectedNftTokensList,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
  }) {
    return NftState(
      nftCollectionsGroupEntity:
          nftCollectionsGroupEntity ?? this.nftCollectionsGroupEntity,
      selectedNftTokensList:
          selectedNftTokensList ?? this.selectedNftTokensList,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
