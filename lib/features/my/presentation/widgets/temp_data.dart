class NFTItem {
  final String title;
  final String imagePath;

  NFTItem({
    required this.title,
    required this.imagePath,
  });
}

final List<NFTItem> nftItemsBasedGod = [
  NFTItem(
    title: "Vasuki : Tha Naga King",
    imagePath: "assets/images/nft_card_image_2.png",
  ),
  NFTItem(
    title: "Agni Dev: God Of Fire",
    imagePath: "assets/images/nft_card_image_1.png",
  ),
];

final List<NFTItem> nftItemsReadyToHide = [
  NFTItem(
    title: "Ready to hide\n#298",
    imagePath: "assets/images/nft_card_image_medium.png",
  ),
];

final List<NFTItem> nftItemsOutCast = [
  NFTItem(
    title: "outcast #116",
    imagePath: "assets/images/nft_card_image_3.png",
  ),
  NFTItem(
    title: "outcast #122",
    imagePath: "assets/images/nft_card_image_6.png",
  ),
  NFTItem(
    title: "outcast #23",
    imagePath: "assets/images/nft_card_image_5.png",
  ),
];
