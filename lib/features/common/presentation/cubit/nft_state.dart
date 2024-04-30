part of 'nft_cubit.dart';

class NftState extends BaseState {
  final NftCollectionsGroupEntity nftCollectionsGroupEntity;
  final List<SelectedNFTDto> selectedNftTokensList;
  final DateTime collectionFetchTime;
  final String errorMessage;
  final String selectedChain;
  final WelcomeNftEntity welcomeNftEntity;
  final List<UserSelectedNftEntity> userSelectedNfts;
  final String consumeWelcomeNftUrl;

  @override
  final RequestStatus submitStatus;

  const NftState({
    required this.nftCollectionsGroupEntity,
    required this.selectedNftTokensList,
    required this.collectionFetchTime,
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
    required this.selectedChain,
    required this.welcomeNftEntity,
    required this.userSelectedNfts,
    required this.consumeWelcomeNftUrl,
  });

  factory NftState.initial() => NftState(
        nftCollectionsGroupEntity: NftCollectionsGroupEntity.empty(),
        selectedNftTokensList: const [],
        collectionFetchTime: DateTime.now(),
        submitStatus: RequestStatus.initial,
        errorMessage: "",
        selectedChain: ChainType.ALL.name,
        welcomeNftEntity: const WelcomeNftEntity.empty(),
        userSelectedNfts: const [],
        consumeWelcomeNftUrl: "",
      );

  @override
  List<Object?> get props => [
        nftCollectionsGroupEntity,
        selectedNftTokensList,
        collectionFetchTime,
        submitStatus,
        errorMessage,
        selectedChain,
        welcomeNftEntity,
        userSelectedNfts,
        consumeWelcomeNftUrl,
      ];

  @override
  NftState copyWith({
    NftCollectionsGroupEntity? nftCollectionsGroupEntity,
    List<SelectedNFTDto>? selectedNftTokensList,
    DateTime? collectionFetchTime,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
    String? selectedChain,
    WelcomeNftEntity? welcomeNftEntity,
    List<UserSelectedNftEntity>? userSelectedNfts,
    String? consumeWelcomeNftUrl,
  }) {
    return NftState(
      nftCollectionsGroupEntity:
          nftCollectionsGroupEntity ?? this.nftCollectionsGroupEntity,
      selectedNftTokensList:
          selectedNftTokensList ?? this.selectedNftTokensList,
      collectionFetchTime: collectionFetchTime ?? this.collectionFetchTime,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedChain: selectedChain ?? this.selectedChain,
      welcomeNftEntity: welcomeNftEntity ?? this.welcomeNftEntity,
      userSelectedNfts: userSelectedNfts ?? this.userSelectedNfts,
      consumeWelcomeNftUrl: consumeWelcomeNftUrl ?? this.consumeWelcomeNftUrl,
    );
  }
}
