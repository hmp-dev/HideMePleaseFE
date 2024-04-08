import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';

class CarouselDots extends StatelessWidget {
  const CarouselDots(
      {super.key,
      required this.images,
      this.selectedImage = 0,
      required this.onTap});
  final List<dynamic> images;
  final int selectedImage;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
        children: List.generate(
            images.length,
            (index) => Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onTap(index);
                    },
                    child: Container(
                      height: 5,
                      margin: EdgeInsets.only(
                          left: index == 0 ? 10 : 0,
                          right: index == images.length - 1 ? 10 : 10),
                      decoration: BoxDecoration(
                          color: selectedImage == index ? pink : Colors.black,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )));
  }
}
