import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../res/app_colors.dart';

class TabBarShimmer extends StatelessWidget {
  const TabBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
           5,
                (index) =>       Shimmer.fromColors(
                  baseColor: gray.withOpacity(0.5),
                  highlightColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                    child: Container(
                      height: 10,
                      width: MediaQuery.of(context).size.width/5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
