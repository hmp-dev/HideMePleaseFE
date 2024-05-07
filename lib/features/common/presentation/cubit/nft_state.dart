part of 'nft_cubit.dart';

class NftState extends BaseState {
  final NftCollectionsGroupEntity nftCollectionsGroupEntity;
  final List<SelectedNFTEntity> selectedNftTokensList;
  final List<SelectedNFTEntity> nftsListHome;
  final DateTime collectionFetchTime;
  final String errorMessage;
  final String selectedChain;
  final WelcomeNftEntity welcomeNftEntity;
  final String consumeWelcomeNftUrl;
  final List<NftBenefitEntity>? nftBenefitList;

  @override
  final RequestStatus submitStatus;

  const NftState({
    required this.nftCollectionsGroupEntity,
    required this.selectedNftTokensList,
    required this.nftsListHome,
    required this.collectionFetchTime,
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
    required this.selectedChain,
    required this.welcomeNftEntity,
    required this.consumeWelcomeNftUrl,
    required this.nftBenefitList,
  });

  factory NftState.initial() => NftState(
        nftCollectionsGroupEntity: NftCollectionsGroupEntity.empty(),
        selectedNftTokensList: const [],
        nftsListHome: const [],
        collectionFetchTime: DateTime.now(),
        submitStatus: RequestStatus.initial,
        errorMessage: "",
        selectedChain: ChainType.ALL.name,
        welcomeNftEntity: const WelcomeNftEntity.empty(),
        consumeWelcomeNftUrl: "",
        nftBenefitList: const [],
      );

  @override
  List<Object?> get props => [
        nftCollectionsGroupEntity,
        selectedNftTokensList,
        nftsListHome,
        collectionFetchTime,
        submitStatus,
        errorMessage,
        selectedChain,
        welcomeNftEntity,
        consumeWelcomeNftUrl,
        nftBenefitList,
      ];

  @override
  NftState copyWith({
    NftCollectionsGroupEntity? nftCollectionsGroupEntity,
    List<SelectedNFTEntity>? selectedNftTokensList,
    List<SelectedNFTEntity>? nftsListHome,
    DateTime? collectionFetchTime,
    RequestStatus? submitStatus,
    bool? isProfileIncomplete,
    String? errorMessage,
    String? selectedChain,
    WelcomeNftEntity? welcomeNftEntity,
    String? consumeWelcomeNftUrl,
    List<NftBenefitEntity>? nftBenefitList,
  }) {
    return NftState(
      nftCollectionsGroupEntity:
          nftCollectionsGroupEntity ?? this.nftCollectionsGroupEntity,
      selectedNftTokensList:
          selectedNftTokensList ?? this.selectedNftTokensList,
      nftsListHome: nftsListHome ?? this.nftsListHome,
      collectionFetchTime: collectionFetchTime ?? this.collectionFetchTime,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedChain: selectedChain ?? this.selectedChain,
      welcomeNftEntity: welcomeNftEntity ?? this.welcomeNftEntity,
      consumeWelcomeNftUrl: consumeWelcomeNftUrl ?? this.consumeWelcomeNftUrl,
      nftBenefitList: nftBenefitList ?? this.nftBenefitList,
    );
  }
}
