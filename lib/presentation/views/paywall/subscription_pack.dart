import 'package:flutter/material.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:shimmer/shimmer.dart';

class SubscriptionPack extends StatelessWidget {
  const SubscriptionPack({
    Key? key,
    required this.title,
    required this.saveText,
    required this.monthlyPrice,
    required this.productId,
    required this.selected,
    required this.mostPopular,
  }) : super(key: key);

  final String title;
  final String saveText;
  final String monthlyPrice;
  final String productId;
  final String selected;
  final bool mostPopular;

  @override
  Widget build(BuildContext context) {
    late bool isSelected;
    if (selected == productId) {
      isSelected = true;
    } else {
      isSelected = false;
    }
    return Center(
      child: Column(
        children: [
          Stack(children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: (isSelected) ? ColorsManager.primaryColor : ColorsManager.primaryColor.withOpacity(0.3),
                    width: 2.0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            color: ColorsManager.textColor,
                            fontSize: 24.0,
                            fontFamily: 'Abel',
                            fontStyle: FontStyle.normal,
                          ),
                          textAlign: TextAlign.left),
                      Text(saveText,
                          style: const TextStyle(
                            color: ColorsManager.secondarytextColor,
                            fontSize: 16.0,
                            fontFamily: 'Abel',
                            fontStyle: FontStyle.normal,
                          ),
                          textAlign: TextAlign.left),
                    ],
                  ),
                  Text(monthlyPrice,
                      style: const TextStyle(
                        color: ColorsManager.primaryColor,
                        fontSize: 18.0,
                        fontFamily: 'Abel',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right),
                ],
              ),
            ),
            (mostPopular == true)
                ? const Positioned(
                    right: 20,
                    top: 15,
                    child: Text("Most popular",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 206, 28),
                          fontSize: 12.0,
                          fontFamily: 'Abel',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right),
                  )
                : const SizedBox.shrink(),
          ]),
        ],
      ),
    );
  }
}

subscriptionPackPlaceholder(context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.9,
    padding: const EdgeInsets.all(8.0),
    margin: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      border: Border.all(color: ColorsManager.primaryColor.withOpacity(0.3), width: 2.0),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: ColorsManager.appBack,
              highlightColor: Color.fromARGB(255, 64, 64, 82).withOpacity(0.3),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 30,
                color: ColorsManager.appBack,
              ),
            ),
            const SizedBox(height: 10),
            Shimmer.fromColors(
              baseColor: ColorsManager.appBack,
              highlightColor: Color.fromARGB(255, 64, 64, 82).withOpacity(0.3),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: 10,
                color: ColorsManager.appBack,
              ),
            ),
          ],
        )
      ],
    ),
  );
}
