class SelectTokenToggleRequestDto {
  String nftId;
  bool selected;
  int order;

  SelectTokenToggleRequestDto({
    required this.nftId,
    required this.selected,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      "nftId": nftId,
      "selected": selected,
      "order": order,
    };
  }
}
