class SaveSelectedTokensReorderRequestDto {
  List<String> order;

  SaveSelectedTokensReorderRequestDto({
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'order': order,
    };
  }
}
