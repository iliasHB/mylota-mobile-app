// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../utils/math_util.dart';
// import '../utils/styles.dart';
// class AlertDialog {
//   static showAlertDialog(BuildContext context, String? token) {
//     // final dashVehicleReqEntity = DashVehicleReqEntity(
//     //     token: token ?? "", contentType: 'application/json');
//
//     // final TextEditingController searchController = TextEditingController();
//     // ValueNotifier<String> searchQuery = ValueNotifier('');
//
//     return showGeneralDialog(
//       context: context,
//       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//       barrierDismissible: true,
//       pageBuilder: (_, __, ___) {
//         return Align(
//           alignment: Alignment.center,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.6),
//               width: size.width - 30,
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'Alert',
//                             style: AppStyle.cardSubtitle,
//                           ),
//                           const Spacer(),
//                           IconButton(
//                               onPressed: () => Navigator.pop(context),
//                               icon: const Icon(Icons.cancel_outlined))
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
