import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';

Future<UserData?> getFencingData(
  UserData userData,
  BuildContext context, {
  bool upload = true,
}) async {
  try {
    final url = Uri.https('proxy-7jwpj4qcgq-uc.a.run.app',
        'https://member.usafencing.org/search/members', {
      'first': userData.firstName,
      'last': userData.lastName,
      'division': '',
      'inactive': 'true',
      'country': '',
      'id': '',
    });
    // final url = Uri.https("highschoolsports.nj.com",
    //     "/school/livingston-livingston/boysfencing/season/2022-2023/");
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    List titles = [];
    html
        .querySelectorAll('tr[itemprop]="member"')
        .forEach((e) => titles.addAll(e.children.map((e) {
              if (e.innerHtml.startsWith("<")) {
                return e.children.first.innerHtml;
              } else {
                return e.innerHtml.trim();
              }
            })));
    if (titles.isNotEmpty) {
      if (userData.club != titles[3]) {
        userData.club = titles[3];
      }
      switch (userData.weapon) {
        case Weapon.foil:
          if (userData.rating != titles[7]) {
            userData.rating = titles[7];
          }
          break;
        case Weapon.epee:
          if (userData.rating != titles[8]) {
            userData.rating = titles[8];
          }
          break;
        case Weapon.saber:
          if (userData.rating != titles[9]) {
            userData.rating = titles[9];
          }
          break;

        case Weapon.unsure:
          if (userData.rating != "U") {
            userData.rating = "U";
          }
          break;
      }
      if (upload) {
        FirestoreService.instance.setData(
          path: FirestorePath.user(userData.id),
          data: userData.toMap(),
        );
      }
      return userData;
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
    debugPrint("Uncaught error: $e");
  }
  return null;
}
