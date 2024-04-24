import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';

class CollectionTitleWidget extends StatelessWidget {
  final String title;
  final String chainSymbol;

  const CollectionTitleWidget({
    super.key,
    required this.title,
    required this.chainSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          DefaultImage(
            path: "assets/icons/ethereum_chain_icon.svg",
            width: 40,
            height: 40,
          ),
          const HorizontalSpace(15),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              title,
              //"London Underground Station(LUS) 264 Genesis",
              overflow: TextOverflow.ellipsis,
              style: fontSB(18),
            ),
          )
        ],
      ),
    );
  }
}
