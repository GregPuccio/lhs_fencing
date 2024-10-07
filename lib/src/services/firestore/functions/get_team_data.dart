// import 'package:flutter/material.dart';
// import 'package:lhs_fencing/src/constants/enums.dart';
// import 'package:lhs_fencing/src/models/user_data.dart';
// import 'package:html/dom.dart' as dom;
// import 'package:http/http.dart' as http;

// Future<UserData?> getCurrentBoysStats(BuildContext context) async {
//   try {
//     Uri url;
//     // if (newUserData.usaFencingID.isEmpty && settingUp) {
//     //   url = Uri.https('proxy-7jwpj4qcgq-uc.a.run.app',
//     //       'https://member.usafencing.org/search/members', {
//     //     'first': newUserData.firstName,
//     //     'last': newUserData.lastName,
//     //     'division': '',
//     //     'inactive': 'true',
//     //     'country': '',
//     //     'id': '',
//     //   });
//     // } else if (newUserData.usaFencingID.isNotEmpty) {
//     //   url = Uri.https('proxy-7jwpj4qcgq-uc.a.run.app',
//     //       'https://member.usafencing.org/search/members', {
//     //     'first': '',
//     //     'last': '',
//     //     'division': '',
//     //     'inactive': 'true',
//     //     'country': '',
//     //     'id': newUserData.usaFencingID,
//     //   });
//     // } else {
//     //   return null;
//     // }
//     url = Uri.https(
//         'proxy-7jwpj4qcgq-uc.a.run.app',
//         "highschoolsports.nj.com"
//             "/school/livingston-livingston/boysfencing/season/2022-2023/");
//     final response = await http.get(
//       url,
//       headers: {
//         'X-Requested-With': 'XMLHTTPREQUEST',
//       },
//     );
//     dom.Document html = dom.Document.html(response.body);

//     List titles = [];
//     print(html
//         .querySelectorAll('table[class]="table table-striped table-borderless"')
//         .length);
//     html
//         .querySelectorAll('team-schedule')
//         .forEach((e) => titles.addAll(e.children.map((e) {
//               if (e.innerHtml.startsWith("<")) {
//                 return e.children.first.innerHtml;
//               } else {
//                 return e.innerHtml.trim();
//               }
//             })));
//     print(titles);
//     if (titles.isNotEmpty) {
//       print("SOMETHING IS HERE");
//     }
//   } catch (e) {
//     // ignore: use_build_context_synchronously
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(e.toString())));
//     debugPrint("Uncaught error: $e");
//   }
//   return null;
// }
