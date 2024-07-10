import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';

class NftNetworkInfoWidget extends StatelessWidget {
  const NftNetworkInfoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NftCubit, NftState>(
      bloc: getIt<NftCubit>(),
      listenWhen: (previous, current) =>
          previous.nftNetworkEntity != current.nftNetworkEntity,
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              NftDetailValueTile(
                title: "네트워크", //chian
                value: state.nftNetworkEntity.network,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: NftDetailValueTile(
                  title: "홀더 수", //"Holders",
                  value: state.nftNetworkEntity.holderCount,
                ),
              ),
              NftDetailValueTile(
                title: "바닥가", //"Floor Price",
                value: "${state.nftNetworkEntity.floorPrice}",
              ),
            ],
          ),
        );
      },
    );
  }
}

class NftDetailValueTile extends StatelessWidget {
  const NftDetailValueTile({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: fontCompactMd(color: fore3),
        ),
        Text(
          value,
          style: fontCompactMd(color: fore1),
        ),
      ],
    );
  }
}
