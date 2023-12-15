import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

Future<UserData?> getFencingData(UserData userData, BuildContext context,
    {bool settingUp = false}) async {
  UserData newUserData = UserData.fromJson(userData.toJson());
  try {
    Uri url;
    if (newUserData.usaFencingID.isEmpty && settingUp) {
      url = Uri.https('proxy-7jwpj4qcgq-uc.a.run.app',
          'https://member.usafencing.org/search/members', {
        'first': newUserData.firstName,
        'last': newUserData.lastName,
        'division': '',
        'inactive': 'true',
        'country': '',
        'id': '',
      });
    } else if (newUserData.usaFencingID.isNotEmpty) {
      url = Uri.https('proxy-7jwpj4qcgq-uc.a.run.app',
          'https://member.usafencing.org/search/members', {
        'first': '',
        'last': '',
        'division': '',
        'inactive': 'true',
        'country': '',
        'id': newUserData.usaFencingID,
      });
    } else {
      return null;
    }
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
      if (newUserData.club != titles[3]) {
        newUserData.club = titles[3];
      }
      if (newUserData.usaFencingID != titles[1]) {
        newUserData.usaFencingID = titles[1];
      }
      switch (newUserData.weapon) {
        case Weapon.foil:
          if (newUserData.rating != titles[7]) {
            newUserData.rating = titles[7];
          }
          break;
        case Weapon.epee:
          if (newUserData.rating != titles[8]) {
            newUserData.rating = titles[8];
          }
          break;
        case Weapon.saber:
          if (newUserData.rating != titles[9]) {
            newUserData.rating = titles[9];
          }
          break;

        case Weapon.unsure:
          if (newUserData.rating != "U") {
            newUserData.rating = "U";
          }
          break;
      }
      return newUserData;
    }
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
    debugPrint("Uncaught error: $e");
  }
  return null;
}
