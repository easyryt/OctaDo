import 'package:get/get.dart';

import '../todoScreens/todoScreen1.dart';

class TaskController extends GetxController {
  //UserPersonalInfo
  RxString priority = ''.obs;
  RxString category = ''.obs;
  RxString dueDate = ''.obs;
  RxString dueTime = ''.obs;
  RxString remainderDate = ''.obs;
  RxString remainderTime = ''.obs;
  RxString frequency = ''.obs;

  RxList<RemainderData> remainderDataList = <RemainderData>[].obs;

  void addRemainderData(RemainderData data) {
    remainderDataList.add(data);
  }

  void removeRemainderData(RemainderData data) {
    remainderDataList.remove(data);
  }
}
