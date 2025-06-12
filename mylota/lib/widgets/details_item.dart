import 'package:flutter/material.dart';

import '../utils/styles.dart';


class DetailItem extends StatelessWidget {
  final String title;
  final String desc;
  final String period;

  const DetailItem({
    super.key,
    required this.title,
    required this.desc,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppStyle.cardSubtitle.copyWith(fontSize: 14)),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(period,
                      style: AppStyle.cardfooter
                          .copyWith(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ),
          Text(desc, style: AppStyle.cardfooter.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}