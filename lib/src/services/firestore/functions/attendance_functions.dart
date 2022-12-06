import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';

final FirestoreService firestore = FirestoreService.instance;

Future addAttendance(
    String userID, List<AttendanceMonth> months, Attendance attendance) async {
  DateTime month =
      DateTime(attendance.practiceStart.year, attendance.practiceStart.month);
  int index = months.indexWhere((m) => m.month.isAtSameMomentAs(month));
  if (index == -1) {
    months
        .add(AttendanceMonth(id: "", attendances: [attendance], month: month));
  } else {
    months[index].attendances.add(attendance);
  }
  for (var month in months) {
    if (month.id.isEmpty) {
      await FirestoreService.instance.addData(
          path: FirestorePath.attendances(userID), data: month.toMap());
    } else {
      await FirestoreService.instance.updateData(
          path: FirestorePath.attendance(userID, month.id),
          data: month.toMap());
    }
  }
}

Future updateAttendance(
    String userID, List<AttendanceMonth> months, Attendance attendance) async {
  DateTime month =
      DateTime(attendance.practiceStart.year, attendance.practiceStart.month);
  int index = months.indexWhere((m) => m.month.isAtSameMomentAs(month));
  if (index == -1) {
    months
        .add(AttendanceMonth(id: "", attendances: [attendance], month: month));
  } else {
    int attendanceIndex =
        months[index].attendances.indexWhere((att) => att.id == attendance.id);

    months[index]
        .attendances
        .replaceRange(attendanceIndex, attendanceIndex + 1, [attendance]);
  }
  for (var month in months) {
    if (month.id.isEmpty) {
      await FirestoreService.instance.addData(
          path: FirestorePath.attendances(userID), data: month.toMap());
    } else {
      await FirestoreService.instance.updateData(
          path: FirestorePath.attendance(userID, month.id),
          data: month.toMap());
    }
  }
}
