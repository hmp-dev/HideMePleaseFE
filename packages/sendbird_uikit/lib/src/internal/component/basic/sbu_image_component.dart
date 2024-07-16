// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';

class SBUImageComponent extends SBUStatelessComponent {
  final String imageUrl;
  final String? cacheKey;
  final Widget? errorWidget;

  const SBUImageComponent({
    required this.imageUrl,
    this.cacheKey,
    this.errorWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? Container();
    }

    return CachedNetworkImage(
      cacheKey: cacheKey,
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? Container(),
    );
  }
}
