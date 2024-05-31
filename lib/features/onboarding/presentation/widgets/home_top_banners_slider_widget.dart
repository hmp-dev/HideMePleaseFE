// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mobile/app/core/logger/logger.dart';
// import 'package:mobile/features/common/presentation/cubit/network_cubit.dart';

// class OnBoardingSliderWidget extends StatefulWidget {
//   const OnBoardingSliderWidget({
//     super.key,
//   });

//   @override
//   State<OnBoardingSliderWidget> createState() => _OnBoardingSliderWidgetState();
// }

// class _OnBoardingSliderWidgetState extends State<OnBoardingSliderWidget> {
//   int _currentIndex = 0;
//   final CarouselController _carouselController = CarouselController();

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<NetworkInfoCubit, ConnectivityResult>(
//       builder: (context, connectivityState) {
//         return Stack(
//           children: [
//             CarouselSlider(
//               carouselController: _carouselController,
//               options: CarouselOptions(
//                   viewportFraction: 1,
//                   height: 280,
//                   enableInfiniteScroll: false,
//                   enlargeCenterPage: false,
//                   autoPlayInterval: const Duration(seconds: 3),
//                   onPageChanged: (int index, CarouselPageChangedReason reason) {
//                    ('the current Carasoul Index: $index').log();
//                     setState(() {
//                       _currentIndex = index;
//                     });
//                   }),
//               items: [
//                 for (var i = 1;
//                     i <= num.parse('${widget.appBannersList.length}');
//                     i++)
//                   i
//               ].map((int item) {
//                 return AppBannerWidget(
//                   storeId: widget.storeId,
//                   banner: "${widget.appBannersList[item - 1].mobile}",
//                   bannerLink: "${widget.appBannersList[item - 1].link}",
//                   connectivityState: connectivityState,
//                 );
//               }).toList(),
//             ),
//             if (_currentIndex + 1 < widget.appBannersList.length)
//               Positioned(
//                 top: 0,
//                 bottom: 0,
//                 right: 0,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.arrow_forward,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     _carouselController.nextPage();
//                   },
//                 ),
//               ),
//             if (_currentIndex != 0)
//               Positioned(
//                 top: 0,
//                 bottom: 0,
//                 left: 0,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.arrow_back,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     _carouselController.previousPage();
//                   },
//                 ),
//               ),
//             Positioned(
//               bottom: 16,
//               left: 0,
//               right: 0,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: widget.appBannersList.map((banner) {
//                   final index = widget.appBannersList.indexOf(banner);
//                   return Container(
//                     width: 8,
//                     height: 8,
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color:
//                           _currentIndex == index ? Colors.white : Colors.grey,
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
