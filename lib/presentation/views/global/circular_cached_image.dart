import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:igshark/presentation/views/global/loading_indicator.dart';

class CircularCachedImage extends StatelessWidget {
  const CircularCachedImage({Key? key, required this.picture, required this.username, this.itemRadius})
      : super(key: key);

  final String picture;
  final String username;
  final double? itemRadius;

  @override
  CachedNetworkImage build(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: picture,
        imageBuilder: (context, imageProvider) => Container(
              height: (itemRadius != null) ? itemRadius : 50,
              width: (itemRadius != null) ? itemRadius : 50,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        placeholder: (context, url) => LoadingIndicator(
              width: (itemRadius != null) ? itemRadius! : 50,
              height: (itemRadius != null) ? itemRadius! : 50,
            ),
        errorWidget: (context, url, error) => Container(
              height: (itemRadius != null) ? itemRadius : 50,
              width: (itemRadius != null) ? itemRadius : 50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                image: DecorationImage(
                  image: AssetImage("assets/images/default_avatar.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
        cacheManager: CacheManager(
          Config(
            username,
            stalePeriod: const Duration(days: 30),
          ),
        ));
  }
}
