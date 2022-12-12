import 'package:flutter/cupertino.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key, this.width = 15, this.height = 15, this.radius = 7.5}) : super(key: key);
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: CupertinoActivityIndicator(
            radius: radius,
          ),
          // CircularProgressIndicator(
          //   valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.appBack),
          //   backgroundColor: ColorsManager.cardBack,
          //   strokeWidth: 2,
          // ),
        )
      ],
    );
  }
}
