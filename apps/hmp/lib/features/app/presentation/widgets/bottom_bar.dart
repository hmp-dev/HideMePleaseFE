import 'package:flutter/material.dart';
import 'package:mobile/app/core/enum/menu_type.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class BottomBar extends StatefulWidget {
  final MenuType selectedType;
  final Function(MenuType) onTap;
  final double opacity;

  const BottomBar({
    super.key,
    required this.selectedType,
    required this.onTap,
    required this.opacity,
  });

  @override
  State<StatefulWidget> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final double TOP_PADDING = 14.0;
  final double BOTTOM_MIN_PADDING = 24.0;
  final double HORIZONTAL_PADDING = 20.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: TOP_PADDING,
        bottom: MediaQuery.of(context).padding.bottom > 20
            ? MediaQuery.of(context).padding.bottom
            : 20,
        left: HORIZONTAL_PADDING,
        right: HORIZONTAL_PADDING,
      ),
      decoration: const BoxDecoration(
        color: Colors.black,
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(12),
        //   topRight: Radius.circular(12),
        // ),
        // border: Border(
        //   top: BorderSide(color: Color.fromRGBO(89, 89, 89, 0.5)),
        // ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...MenuType.values.map(
            (e) {
              return _item(type: e);
            },
          ),
        ],
      ),
    );
  }

  Widget _item({required MenuType type}) {
    bool isActiveType = widget.selectedType == type;
    //Color textColor = isActiveType ? gray100 : stroke_02;
    return GestureDetector(
      onTap: () {
        widget.onTap(type);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (type == MenuType.events && false)
                ? DefaultImage(
                    path: isActiveType
                        ? type.activeIconPath
                        : type.deactivateIconPath,
                    height: 20,
                    width: 20,
                  )
                : DefaultImage(
                    path: isActiveType
                        ? type.activeIconPath
                        : type.deactivateIconPath,
                    height: 28,
                    width: 28,
                  ),
          ],
        ),
      ),
    );
  }
}
