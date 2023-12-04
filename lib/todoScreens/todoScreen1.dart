import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:octa_todo_app/authentications/profilePage.dart';
import 'package:octa_todo_app/controller/task_controller.dart';
import 'package:octa_todo_app/homePage.dart';
import 'package:octa_todo_app/json/getAllCategory.dart';
import 'package:octa_todo_app/json/getfilteredTodo.dart';
import 'package:octa_todo_app/services/client.dart';
import 'package:octa_todo_app/todoScreens/reminderDateDropDown.dart';
import 'package:octa_todo_app/todoScreens/reminderTime.dart';
import 'package:octa_todo_app/todoScreens/singleTaskReader.dart';
import 'package:octa_todo_app/todoScreens/taskHistory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:octa_todo_app/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class TodoScreen1 extends StatefulWidget {
  const TodoScreen1({super.key});

  @override
  State<TodoScreen1> createState() => _TodoScreen1State();
}
late OverlayEntry floatingPriorityDropdown;
TaskController taskController = Get.find();

List<String> tagsList = [];

class RemainderData {
  String dateTime = '';
  String frequency = '';


  RemainderData({required this.dateTime, required this.frequency});

  Map<String, dynamic> toJson() {
      return {
        'dateTime': dateTime,
        'frequency': frequency,
      };
  }
}
final List<RemainderData> remainderDataList = [
  RemainderData(
    dateTime: "",
    frequency: ""
  )
];
List<GetTodoFiltered> todoList = [];

late Future<List<GetTodoFiltered>> _getAllFilteredTodo;

bool _isUploading = false;

var _id, value;
Future<List<GetTodoFiltered>> getAllFilteredTodo() async {
  final Uri uri = Uri.parse(
      "https://notesapp-i6yf.onrender.com/user/todoTask/getFilteredToDo");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  final Map<String, String> headers = {'x-auth-token': '$token'};
  final response = await http.get(uri, headers: headers);
  print("getAllFilteredTodo");

  print(response.body);
  value = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final List<dynamic> data = responseData['data'];
    todoList = data.map((json) => GetTodoFiltered.fromJson(json)).toList();

    return todoList;
  } else {
    print("no worked");

    // throw Exception('Failed to load data');
    return todoList;
  }
}
Future<List<GetTodoFiltered>> getPriorityTask(String priority) async {
  final Uri uri = Uri.parse(
      "https://notesapp-i6yf.onrender.com/user/todoTask/getFilteredToDo");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  final Map<String, String> headers = {'x-auth-token': '$token'};
  final response = await http.get(uri, headers: headers);

  value = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final List<dynamic> data = responseData['data'];
    List<GetTodoFiltered> todoListOld =
    data.map((json) => GetTodoFiltered.fromJson(json)).toList();

      todoList = todoListOld.where((todo) => todo.priority == priority).toList();


    return todoList;
  } else {

    return todoList;
  }
}
Future<List<GetTodoFiltered>> getCompletedTask(bool completed) async {
  final Uri uri = Uri.parse(
      "https://notesapp-i6yf.onrender.com/user/todoTask/getFilteredToDo");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  final Map<String, String> headers = {'x-auth-token': '$token'};
  final response = await http.get(uri, headers: headers);

  value = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final List<dynamic> data = responseData['data'];
    List<GetTodoFiltered> todoListOld =
    data.map((json) => GetTodoFiltered.fromJson(json)).toList();

    todoList = todoListOld.where((todo) => todo.completed == completed).toList();


    return todoList;
  } else {

    return todoList;
  }
}
Future<List<GetTodoFiltered>> getCategoryTask(String category) async {
  final Uri uri = Uri.parse(
      "https://notesapp-i6yf.onrender.com/user/todoTask/getFilteredToDo");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  final Map<String, String> headers = {'x-auth-token': '$token'};
  final response = await http.get(uri, headers: headers);

  value = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final List<dynamic> data = responseData['data'];
    List<GetTodoFiltered> todoListOld =
    data.map((json) => GetTodoFiltered.fromJson(json)).toList();

    todoList = todoListOld.where((todo) => todo.category == category).toList();


    return todoList;
  } else {

    return todoList;
  }
}
 String code = "Default";
late OverlayEntry floatingReminderDropdown;
class _TodoScreen1State extends State<TodoScreen1> {
  String? selectedValue;
  // bool isKeyboardOpen = false;

  var status;
  var profilepic;
  String? profilepicUrl;
  String? name;
  var email;

  void getProfileDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      // the response we are getting is a response.body
      var response = await context
          .read<AuthClient>()
          .getProfile('/user/auth/getProfile', token!);
      setState(() {
        var value = jsonDecode(response);
        var dataResponse = value;
        print("picvalues");
        print(dataResponse);
        status = dataResponse["message"];
        profilepic = dataResponse["data"]["profilePic"]["filename"];
        profilepicUrl = dataResponse["data"]["profilePic"]["url"];
        name = dataResponse["data"]["name"];
        email = dataResponse["data"]["email"];
      });
      print(status);
      print(profilepic);
      print(profilepicUrl);
      print(name);
    } catch (e) {
      print(e.toString());
    }
  }

  void findDropdownData() {
    RenderBox? renderBox =
        actionCategoryKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      cheight = renderBox.size.height;
      cwidth = renderBox.size.width;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      cxPosition = offset.dx;
      cyPosition = offset.dy;
    } else {
      // Handle the case where renderBox is not a RenderBox
    }
  }

  late double dheight, dwidth, dxPosition, dyPosition;
  void findDateDropdownData() {
    RenderBox? renderBox =
        actionDateKey.currentContext?.findRenderObject() as RenderBox?;
    // RenderObject? renderBox =actionKey.currentContext?.findRenderObject();
    if (renderBox != null) {
      dheight = renderBox.size.height;
      dwidth = renderBox.size.width;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      dxPosition = offset.dx;
      dyPosition = offset.dy;
    } else {
      // Handle the case where renderBox is not a RenderBox
    }
  }

  OverlayEntry _createFloatingCategoryDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: cxPosition,
        width: cwidth * 2,
        top: 479,
        height: 7 * cheight,
        child: DropDowncategory(
          itemHeight: cheight,
          isDropdownCategoryOpened: isDropdownCategoryOpened,
          floatingCategoryDropdown: floatingCategoryDropdown,
        ),
      );
    });
  }

  bool isDropDateOpened = false;
  late OverlayEntry floatingdateDropdown;
  OverlayEntry _createFloatingDateDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: 28,
        width: dwidth * 4,
        top: 172,
        height: 510,
        child: DropDownDate(
          itemHeight: dheight,
          isDropdownOpened: isDropDateOpened,
          floatingdateDropdown: floatingdateDropdown,
        ),
      );
    });
  }

  TextEditingController dateController = TextEditingController();
  late GlobalKey actionPriorityKey;
  late double pheight, pwidth, pxPosition, pyPosition;
  bool isDropdownPriorityOpened = false;


  void findPriorityDropdownData() {
    RenderBox? renderBox =
        actionPriorityKey.currentContext?.findRenderObject() as RenderBox?;
    // RenderObject? renderBox =actionKey.currentContext?.findRenderObject();
    if (renderBox != null) {
      pheight = renderBox.size.height;
      pwidth = renderBox.size.width;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      pxPosition = offset.dx;
      pyPosition = offset.dy;
    } else {
      // Handle the case where renderBox is not a RenderBox
    }
  }

  OverlayEntry _createFloatingPriorityDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        right: 27,
        width: pwidth * 1.3,
        top: 550,
        height: 130,
        child: DropDownPriority(
          itemHeight: pheight,
        ),
      );
    });
  }

  late GlobalKey actionReminderKey;

  bool isDropdownReminderOpened = false;
  late double rheight, rwidth, rxPosition, ryPosition;
  void findDropdownReminderData() {
    RenderBox? renderBox =
        actionReminderKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      rheight = renderBox.size.height;
      rwidth = renderBox.size.width;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      rxPosition = offset.dx;
      ryPosition = offset.dy;
    } else {}
  }

  OverlayEntry _createFloatingReminderDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: rxPosition,
        width: rwidth * 2.8,
        top: 420,
        height: 10.5 * rheight,
        child: DropDownReminder(
          itemHeight: rheight,
          isDropdownReminderOpened: isDropdownReminderOpened,
          floatingReminderDropdown: floatingReminderDropdown,
        ),
      );
    });
  }




  @override
  void initState() {
    getProfileDetails();
    _getAllFilteredTodo = getAllFilteredTodo();
    setState(() {
      actionCategoryKey = LabeledGlobalKey("Category");
      actionDateKey = LabeledGlobalKey("Date");
      actionPriorityKey = LabeledGlobalKey("Priority");
      actionReminderKey = LabeledGlobalKey("Reminder");
      actionMenuKey = LabeledGlobalKey('Default');
      isDropdownCategoryOpened = false;
      isDropdownPriorityOpened = false;
      isDropdownReminderOpened = false;
      isDropdownMenuOpened = false;
      //  dateController.text = "";
    });
    // CategoryDropDown.categoryCheck = false;
    floatingCategoryDropdown = _createFloatingCategoryDropdown();
    floatingdateDropdown = _createFloatingDateDropdown();
    floatingPriorityDropdown = _createFloatingPriorityDropdown();
    floatingReminderDropdown = _createFloatingReminderDropdown();
    floatingMenuDropdown = _createfloatingMenuDropdown();

  }



// here only get todoList



  static String? categoryText;
  static bool categoryCheck = false;
  late GlobalKey actionCategoryKey;
  late GlobalKey actionDateKey;
  late double cheight, cwidth, cxPosition, cyPosition;
  bool isDropdownCategoryOpened = false;
  // bool isDropDateOpened = false;
  late OverlayEntry floatingCategoryDropdown;
  late OverlayEntry floatingDropdown;
  void _showBottomSheet() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    var dataModel = Provider.of<AuthClient>(context, listen: false);

    TimeOfDay _selectedTime = TimeOfDay.now();

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (picked != null && picked != _selectedTime) {
        setState(() {
          _selectedTime = picked;
        });

        // Convert TimeOfDay to DateTime
        DateTime dateTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        // Add milliseconds manually (since TimeOfDay doesn't include milliseconds)
        dateTime = dateTime.add(Duration(milliseconds: 460));

        // Format the DateTime using the desired pattern
        String formattedTime = DateFormat("THH:mm:ss.SSS'Z'").format(dateTime.toUtc());

        taskController.dueTime.value = formattedTime;
        print("Anurag${taskController.dueTime.value}");
        showSnackBar("Anurag${taskController.dueTime.value}", context);
      }
    }

    DateTime today = DateTime.now();
    void _ondaySelected(DateTime dueDate,) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);
      taskController.dueDate.value = formattedDate;
      _selectTime(context);
    }

    // print("object hii ${dataModel.category}");
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final MediaQueryData mediaQueryData = MediaQuery.of(context);
        return Padding(
          padding: mediaQueryData.viewInsets,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Consumer<AuthClient>(builder: (context, authClient, child) {
              return Container(
                margin: EdgeInsets.all(8.0),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: 323,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 228, 225, 225),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 5.0, left: 9),
                          child: TextField(
                            controller: titleController,
                            // focusNode: textfieldFocusNode,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "What Would You Like To Do?",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                                color: Color.fromARGB(255, 101, 99, 99),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 70,
                        width: 323,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 228, 225, 225),
                          borderRadius: BorderRadius.circular(5),
                          // color: Color.fromARGB(255, 236, 233, 233),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 4.0, left: 9),
                          child: TextField(
                            controller: descriptionController,
                            // focusNode: textfieldFocusNode,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Description",
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                                color: Color.fromARGB(255, 101, 99, 99),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 173, 180, 179),
                              borderRadius: BorderRadius.circular(13.0),
                            ),
                            child: GestureDetector(
                              key: actionCategoryKey,
                              onTap: () {
                                setState(() {
                                  //reminder
                                  if (isDropdownReminderOpened) {
                                    if (floatingReminderDropdown?.mounted ??
                                        false) {
                                      floatingReminderDropdown?.remove();
                                    }
                                  }
                                  // priority
                                  if (isDropdownPriorityOpened) {
                                    if (floatingPriorityDropdown?.mounted ??
                                        false) {
                                      floatingPriorityDropdown?.remove();
                                    }
                                  }
                                  //date
                                  if (isDropDateOpened) {
                                    // Close the date dropdown if it's open
                                    if (floatingdateDropdown?.mounted ??
                                        false) {
                                      floatingdateDropdown.remove();
                                    }
                                  }
                                  //category
                                  if (isDropdownCategoryOpened) {
                                    if (floatingCategoryDropdown?.mounted ??
                                        false) {
                                      floatingCategoryDropdown?.remove();
                                    }
                                  } else {
                                    findDropdownData();
                                    floatingCategoryDropdown =
                                        _createFloatingCategoryDropdown();
                                    Overlay.of(context)
                                        .insert(floatingCategoryDropdown);
                                  }
                                  //category
                                  isDropdownCategoryOpened =
                                      !isDropdownCategoryOpened;

                                  authClient.dropDownCategoryCheck(
                                      isDropdownCategoryOpened);
                                  //date
                                  isDropDateOpened = false;
                                  authClient
                                      .dropDownDateCheck(isDropDateOpened);
                                  // priority
                                  isDropdownPriorityOpened = false;
                                  authClient.dropDownPriorityCheck(
                                      isDropdownPriorityOpened);
                                  //reminder
                                  isDropdownReminderOpened = false;
                                  authClient.dropDownReminderCheck(
                                      isDropdownReminderOpened);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 200, 197, 197),
                                  // color: Color.fromARGB(255, 233, 10, 10),
                                ),
                                // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0, right: 10),
                                      child: taskController.category.value == ''? Text(
                                        'Category',
                                        maxLines: 1,// category
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.w600),
                                      ):Text(
                                        "${taskController.category.value}", // category
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(0xFF6C6C6C),
                              borderRadius: BorderRadius.circular(13.0),
                            ),
                            // child: DateDropDown(
                            //   text: "Date",
                            // ),
                            child: GestureDetector(
                              key: actionDateKey,
                              onTap: () async{
                                setState(() async{
                                  //category
                                  if (isDropdownCategoryOpened) {
                                    // Close the category dropdown if it's open
                                    if (floatingCategoryDropdown?.mounted ??
                                        false) {
                                      floatingCategoryDropdown.remove();
                                    }
                                  }
                                  //priority
                                  if (isDropdownPriorityOpened) {
                                    if (floatingPriorityDropdown?.mounted ??
                                        false) {
                                      floatingPriorityDropdown?.remove();
                                    }
                                  }
                                  //reminder
                                  if (isDropdownReminderOpened) {
                                    if (floatingReminderDropdown?.mounted ??
                                        false) {
                                      floatingReminderDropdown?.remove();
                                    }
                                  }
                                  //date
                                  if (isDropDateOpened) {
                                    floatingdateDropdown.remove();
                                  } else {
                                    // findDateDropdownData();
                                    // floatingdateDropdown =
                                    //     _createFloatingDateDropdown();
                                    // Overlay.of(context)
                                    //     .insert(floatingdateDropdown);
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: today,
                                      firstDate: DateTime.utc(2023, 10, 16),
                                      lastDate: DateTime.utc(2030, 3, 14),
                                    );

                                    if (pickedDate != null) {
                                      _ondaySelected(pickedDate);
                                    }
                                  }
                                  //date
                                  // isDropDateOpened = !isDropDateOpened;
                                  // authClient
                                  //     .dropDownDateCheck(isDropDateOpened);
                                  // category

                                  isDropdownCategoryOpened = false;
                                  authClient.dropDownCategoryCheck(
                                      isDropdownCategoryOpened);
                                  // priority
                                  isDropdownPriorityOpened = false;
                                  authClient.dropDownPriorityCheck(
                                      isDropdownPriorityOpened);
                                  // reminder
                                  isDropdownReminderOpened = false;
                                  authClient.dropDownReminderCheck(
                                      isDropdownReminderOpened);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 200, 197, 197),
                                  // color: Color.fromARGB(255, 233, 10, 10),
                                ),
                                // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        "Date",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Container(
                            height: 30,
                            width: 88,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 200, 197, 197),
                              borderRadius: BorderRadius.circular(13.0),
                            ),
                            // child: PriorityDropDown(
                            //   text: "priority",
                            // ),
                            child: GestureDetector(
                              key: actionPriorityKey,
                              onTap: () {
                                setState(() {
                                  //category
                                  if (isDropdownCategoryOpened) {
                                    // Close the category dropdown if it's open
                                    if (floatingCategoryDropdown?.mounted ??
                                        false) {
                                      floatingCategoryDropdown.remove();
                                    }
                                  }
                                  //date
                                  if (isDropDateOpened) {
                                    // Close the date dropdown if it's open
                                    if (floatingdateDropdown.mounted ??
                                        false) {
                                      floatingdateDropdown.remove();
                                    }
                                  }
                                  //reminder
                                  if (isDropdownReminderOpened) {
                                    if (floatingReminderDropdown.mounted ??
                                        false) {
                                      floatingReminderDropdown.remove();
                                    }
                                  }
                                  //priority
                                  if (isDropdownPriorityOpened) {
                                    if (floatingPriorityDropdown.mounted ??
                                        false) {
                                      floatingPriorityDropdown.remove();
                                    }
                                  } else {
                                    findPriorityDropdownData();
                                    floatingPriorityDropdown =
                                        _createFloatingPriorityDropdown();
                                    Overlay.of(context)
                                        .insert(floatingPriorityDropdown);
                                  }
                                  //priority
                                  isDropdownPriorityOpened =
                                      !isDropdownPriorityOpened;
                                  authClient.dropDownPriorityCheck(
                                      isDropdownPriorityOpened);
                                  //date
                                  isDropDateOpened = false;
                                  authClient
                                      .dropDownDateCheck(isDropDateOpened);
                                  // category
                                  isDropdownCategoryOpened = false;
                                  authClient.dropDownDateCheck(
                                      isDropdownCategoryOpened);
                                  //reminder
                                  isDropdownReminderOpened = false;
                                  authClient.dropDownReminderCheck(
                                      isDropdownReminderOpened);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 200, 197, 197),
                                  // color: Color.fromARGB(255, 233, 10, 10),
                                ),
                                // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0, right: 10),
                                      child: taskController.priority.value == ''?Text(
                                        "Priority",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ):Text(
                                        "${taskController.priority.value}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 12,
                          ),
                          Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 200, 197, 197),
                              borderRadius: BorderRadius.circular(13.0),
                            ),
                            // child: ReminderDropDown(
                            //   text: "Remainder",
                            // ),
                            child: GestureDetector(
                              key: actionReminderKey,
                              onTap: () {
                                setState(() {
                                  //category
                                  if (isDropdownCategoryOpened) {
                                    // Close the category dropdown if it's open
                                    if (floatingCategoryDropdown?.mounted ??
                                        false) {
                                      floatingCategoryDropdown.remove();
                                    }
                                  }
                                  //date
                                  if (isDropDateOpened) {
                                    // Close the date dropdown if it's open
                                    if (floatingdateDropdown?.mounted ??
                                        false) {
                                      floatingdateDropdown.remove();
                                    }
                                  }
                                  // priority
                                  if (isDropdownPriorityOpened) {
                                    if (floatingPriorityDropdown?.mounted ??
                                        false) {
                                      floatingPriorityDropdown?.remove();
                                    }
                                  }
                                  //reminder
                                  if (isDropdownReminderOpened) {
                                    if (floatingReminderDropdown?.mounted ??
                                        false) {
                                      floatingReminderDropdown?.remove();
                                    }
                                  } else {
                                    findDropdownReminderData();
                                    floatingReminderDropdown =
                                        _createFloatingReminderDropdown();
                                    Overlay.of(context)
                                        .insert(floatingReminderDropdown);
                                  }
                                  //reminder
                                  isDropdownReminderOpened =
                                      !isDropdownReminderOpened;
                                  authClient.dropDownReminderCheck(
                                      isDropdownReminderOpened);
                                  //priority
                                  isDropdownPriorityOpened = false;
                                  authClient.dropDownPriorityCheck(
                                      isDropdownPriorityOpened);
                                  //date
                                  isDropDateOpened = false;
                                  authClient
                                      .dropDownDateCheck(isDropDateOpened);
                                  // category
                                  isDropdownCategoryOpened = false;
                                  authClient.dropDownDateCheck(
                                      isDropdownCategoryOpened);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 200, 197, 197),
                                  // color: Color.fromARGB(255, 233, 10, 10),
                                ),
                                // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Text(
                                        "Reminder",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Container(
                            height: 30,
                            width: 88,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 200, 197, 197),
                              borderRadius: BorderRadius.circular(13.0),
                            ),
                            // child: PriorityDropDown(
                            //   text: "priority",
                            // ),
                            child: GestureDetector(
                              onTap: () async{
                                setState(() async{
                                  //category
                                  if (isDropdownCategoryOpened) {
                                    // Close the category dropdown if it's open
                                    if (floatingCategoryDropdown?.mounted ??
                                        false) {
                                      floatingCategoryDropdown.remove();
                                    }
                                  }
                                  //priority
                                  if (isDropdownPriorityOpened) {
                                    if (floatingPriorityDropdown?.mounted ??
                                        false) {
                                      floatingPriorityDropdown?.remove();
                                    }
                                  }
                                  //reminder
                                  if (isDropdownReminderOpened) {
                                    if (floatingReminderDropdown?.mounted ??
                                        false) {
                                      floatingReminderDropdown?.remove();
                                    }
                                  }
                                  //date
                                  if (isDropDateOpened) {
                                    floatingdateDropdown.remove();
                                  } else {
                                    // findDateDropdownData();
                                    // floatingdateDropdown =
                                    //     _createFloatingDateDropdown();
                                    // Overlay.of(context)
                                    //     .insert(floatingdateDropdown);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.zero,
                                          shape: StadiumBorder(),
                                          content: CustomDialog(setState: set),
                                        );
                                      },
                                    );
                                  }
                                  //date
                                  // isDropDateOpened = !isDropDateOpened;
                                  // authClient
                                  //     .dropDownDateCheck(isDropDateOpened);
                                  // category

                                  isDropdownCategoryOpened = false;
                                  authClient.dropDownCategoryCheck(
                                      isDropdownCategoryOpened);
                                  // priority
                                  isDropdownPriorityOpened = false;
                                  authClient.dropDownPriorityCheck(
                                      isDropdownPriorityOpened);
                                  // reminder
                                  isDropdownReminderOpened = false;
                                  authClient.dropDownReminderCheck(
                                      isDropdownReminderOpened);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromARGB(255, 200, 197, 197),
                                  // color: Color.fromARGB(255, 233, 10, 10),
                                ),
                                // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(left: 10.0, right: 10),
                                      child:Text(
                                        "Tags",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            // print(CategoryDropDown.categoryCheck);
                            if (authClient.dropDowncategoryOpened == false &&
                                authClient.dropDownDateOpened == false &&
                                authClient.dropDownPriorityOpened == false &&
                                authClient.dropDownReminderOpened == false) {
                              print("done all false");
                              createTodoTask(
                                titleController,
                                descriptionController,
                                authClient.categoryTextSelected,
                                dataModel.selectedDate,
                              );
                            }
                          },
                          child: _isUploading?CircularProgressIndicator(strokeWidth: 2, color: Colors.red,):Container(
                            height: 63,
                            width: 63,
                            // color: Colors.red,
                            child: Image.asset(
                              'assets/TodoScreen1/Group 237.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Future<String> createTodoTask(
      TextEditingController title,
      TextEditingController description,
      String category,
      String today) async {
    try {
      setState(() {
        _isUploading = true;
      });
      final apiUrl = Uri.parse(
          'https://notesapp-i6yf.onrender.com/user/todoTask/createTask');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final headers = {
        'Content-Type': 'application/json',
        'x-auth-token': '$token',
      };

      final userData = {
        'title': title.text.toString(),
        'description': description.text.toString(),
        'category': category.toString(),
        "priority": taskController.priority.value,
        "tags": tagsList,
        "dueDate": "${taskController.dueDate.value}${taskController.dueTime.value}",
        'reminders': taskController.remainderDataList.map((remainder) => remainder.toJson()).toList(),
      };

      final response = await http.post(
        apiUrl,
        headers: headers,
        body: jsonEncode(userData),
      );
      if (response.statusCode == 201) {
        // Navigator.pushAndRemoveUntil(
        //     context,
        //     PageTransition(
        //       child: HomePage(),
        //       type: PageTransitionType.fade,
        //       isIos: true,
        //       duration: Duration(milliseconds: 900),
        //     ),
        //     (route) => false);
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${response.statusCode} ${response.body}'),
          ),
        );

        return "${response.statusCode} ${response.body}"; // Data posted successfully
      } else {
        setState(() {
          _isUploading = false;
        });
        print('HTTP Error: ${response.body}');
        var value = jsonDecode(response.body);
        var message = value['message'];

        showDialog(
          context: context,
          builder: (context) => Center(
            child: AlertDialog(
              backgroundColor: Color.fromARGB(255, 15, 1, 84),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message != null)
                    Text(
                      "$message",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 232, 229, 229),
                          fontFamily: "Google Sans"),
                    ),
                ],
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    child: Text("Ok"))
              ],
            ),
          ),
        );

        print('HTTP Error: ${response.body}');
        return "${response.statusCode} ${response.body}"; // Data posting failed
      }
    } catch (error) {
      print('Error: $error');
      return "Error Occurred-$error"; // Data posting failed
    }
  }

  late GlobalKey actionMenuKey;
  late double mheight, mwidth, mxPosition, myPosition;
  bool isDropdownMenuOpened = false;
  late OverlayEntry floatingMenuDropdown;
  void findDropdownMenuData() {
    RenderBox? renderBox =
        actionMenuKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      mheight = renderBox.size.height;
      mwidth = renderBox.size.width;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      mxPosition = offset.dx;
      myPosition = offset.dy;
    } else {
      // Handle the case where renderBox is not a RenderBox
    }
  }

  OverlayEntry _createfloatingMenuDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: mxPosition,
        width: mwidth,
        top: myPosition + mheight,
        height: 9 * mheight,
        child: DropDownMenu(
          itemHeight: mheight,
          isDropdownMenuOpened: isDropdownMenuOpened,
          floatingMenuDropdown: floatingMenuDropdown,
        ),
      );
    });
  }

  Future<void> _showCustomDialog(
      BuildContext context,
      VoidCallback setState,
      ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: StadiumBorder(),
          content: CoverDialog(setState: setState),
        );
      },
    );
  }



  void set(){
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Consumer<AuthClient>(
        builder: (context, authClient, child) {
          return Scaffold(
            drawer: CustomDrawer(context, profilepic, profilepicUrl, name, email),
            body: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 82,
                      width: double.infinity,
                      color: Color(0xFF6C6C6C),
                      child: Container(
                        padding: EdgeInsets.only(
                            right: 25, left: 25, top: 35, bottom: 13),
                        height: 38,
                        // color: Colors.red,
                        // width: 375,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (BuildContext builderContext) {
                                return InkWell(
                                  onTap: () {
                                    Scaffold.of(builderContext).openDrawer();
                                  },
                                  child: Container(
                                    height: 19,
                                    width: 23,
                                    child: Image.asset(
                                      'assets/todo/Group 388.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              width: 43,
                            ),
                            Container(
                              height: 30,
                              width: 200,

                              child: GestureDetector(
                                key: actionMenuKey,
                                onTap: () {
                                  // setState(() {
                                  //   if (floatingMenuDropdown?.mounted ??
                                  //       false) {
                                  //     floatingMenuDropdown?.remove();
                                  //   } else {
                                  //     findDropdownMenuData();
                                  //     floatingMenuDropdown =
                                  //         _createfloatingMenuDropdown();
                                  //     Overlay.of(context)
                                  //         .insert(floatingMenuDropdown);
                                  //   }
                                  //
                                  //   isDropdownMenuOpened =
                                  //       !isDropdownMenuOpened;
                                  //   authClient
                                  //       .dropDownCheck(isDropdownMenuOpened);
                                  // });
                                  _showCustomDialog(context, set);
                                },
                                child: Container(
                                  // width: 700,
                                  // height: 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color.fromARGB(255, 151, 150, 150),
                                    // color: Color.fromARGB(255, 233, 10, 10),
                                  ),
                                  // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 6.0,
                                        ),
                                        child: Container(
                                          width: 140,
                                          // color: Colors.green,
                                          child: Text(
                                            code,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 1.0),
                                        child: Icon(
                                          (isDropdownMenuOpened)
                                              ? Icons.arrow_drop_down
                                              : Icons.arrow_drop_up,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 400,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                // color: Color.fromARGB(255, 187, 184, 184),
                                // color: Colors.blue,
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 12, bottom: 12),
                              child: FutureBuilder<List<GetTodoFiltered>>(
                                future: _getAllFilteredTodo,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2));
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text("Error: ${snapshot.error}"));
                                  } else {
                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        final cover = snapshot.data![index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 5,
                                            left: 4,
                                          ),
                                          child: (cover != null)
                                              ? InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                SingleTaskReader(
                                                                  id: value['data']
                                                                          [
                                                                          index]
                                                                      ['_id'],
                                                                )));
                                                  },
                                                  child: Container(
                                                    // color: Colors.green,
                                                    height: 40,
                                                    child: ListTile(
                                                      leading: Container(
                                                        // color: Colors.red,
                                                        height: 15,
                                                        width: 15,
                                                        child:
                                                            (cover.completed ==
                                                                    false)
                                                                ? Image.asset(
                                                                    'assets/TodoScreen1/Group 214.png',
                                                                  )
                                                                : Image.asset(
                                                                    'assets/TodoScreen1/Ellipse 77.png',
                                                                  ),
                                                      ),

                                                      // compare the lit comming with the selectedtext in menu
                                                      // (cover.category ==
                                                      //         AuthClient()
                                                      //             .categoryTextSelected)

                                                      title: Text(
                                                        "${cover.title}",
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  child: Text("NO Task Found"),
                                                ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 700,
                  left: 29,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskHistory(),
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 20,
                      child: Text(
                        "Task History",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  // menu method to close menu drop down
                  if (isDropdownMenuOpened) {
                    if (floatingMenuDropdown?.mounted ?? false) {
                      floatingMenuDropdown?.remove();
                    }
                  }

                  _showBottomSheet();
                });
              },
              backgroundColor: Colors.white,
              // backgroundColor: Colors.black,
              elevation: 0,
              child: Image.asset(
                'assets/TodoScreen1/Group 208.png',
              ),
            ),

          );
        },
      ),

    );
  }
}


class CoverDialog extends StatefulWidget {
  final VoidCallback  setState;
  const CoverDialog({
    super.key, required this.setState,
  });

  @override
  State<CoverDialog> createState() => _CoverDialogState();
}

class _CoverDialogState extends State<CoverDialog> {
  bool isYear = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: Colors.white),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Filter",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontFamily: "MontserratBold",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        _getAllFilteredTodo = getPriorityTask("low");
                        widget.setState();
                        setState(() {
                          code = "Priority Low";
                        });
                        Navigator.pop(context);


                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            "Priority = Low",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                              fontFamily: "MontserratRegular",
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        _getAllFilteredTodo = getPriorityTask("high");
                        setState(() {
                          code = "Priority High";
                        });
                        widget.setState();
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            "Priority = high",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                              fontFamily: "MontserratRegular",
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        _getAllFilteredTodo = getAllFilteredTodo();
                        widget.setState();
                        setState(() {
                          code = "Default";
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            "Priority = Default",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                              fontFamily: "MontserratRegular",
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              contentPadding: EdgeInsets.zero,
                              shape: StadiumBorder(),
                              content: Category(setState: widget.setState),
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            "Category",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                              fontFamily: "MontserratRegular",
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        _getAllFilteredTodo = getCompletedTask(true);
                        widget.setState();
                        setState(() {
                          code = "Completed";
                        });
                        Navigator.pop(context);

                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            "Completed",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                              fontFamily: "MontserratRegular",
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        _getAllFilteredTodo = getCompletedTask(false);
                        widget.setState();
                        setState(() {
                          code = "Uncompleted";
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            "Uncompleted",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.normal,
                              fontFamily: "MontserratRegular",
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Category extends StatefulWidget {
  final VoidCallback setState;
  const Category({
    super.key, required this.setState,
  });

  @override
  State<Category> createState() => _CategoryState();
}
List<GetAllTodoCategory> categoriesList = [];
var dataCategoryReceived;
Future<List<GetAllTodoCategory>> getAllCover() async {
  final Uri uri = Uri.parse(
      "https://notesapp-i6yf.onrender.com/user/todoTaskCategory/getAllTodoCategory");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  final Map<String, String> headers = {'x-auth-token': '$token'};
  final response = await http.get(uri, headers: headers);

  dataCategoryReceived = jsonDecode(response.body);
  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final List<dynamic> data =
    responseData['data']; // Assuming 'data' contains the list
    categoriesList =
        data.map((json) => GetAllTodoCategory.fromJson(json)).toList();
    return categoriesList;
  } else {

    throw Exception('Failed to load data');
  }
}
class _CategoryState extends State<Category> {
  bool isYear = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Container(
              height: 450,
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: Colors.white),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Category",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontFamily: "MontserratBold",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    FutureBuilder<List<GetAllTodoCategory>>(
                      future: getAllCover(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2));
                        } else if (snapshot.hasError) {
                          return Center(
                              child:
                              Text("Error: ${snapshot.error}"));
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final cover = snapshot.data![index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                child: GestureDetector(
                                  onTap: (){
                                    _getAllFilteredTodo = getCategoryTask(cover.category);
                                    widget.setState();
                                    setState(() {
                                      code = "${cover.category}";
                                    });
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                      child: Text(
                                        cover.category,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: "MontserratRegular",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


CustomDrawer(context, var profilepic, var profilepicUrl, var name, var email) {
  return Drawer(
    backgroundColor: Color.fromARGB(255, 54, 53, 53),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topRight: Radius.circular(100)),
      ),
      child: Stack(
        children: <Widget>[
          Container(
            height: 176,
            width: 331,
            decoration: BoxDecoration(
              color: Color(0xFF6C6C6C),
              borderRadius: BorderRadius.only(topRight: Radius.circular(100)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(0, 1),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Positioned(
            top: 90,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 80,
              child: (profilepicUrl != null)
                  ? ClipOval(
                      child: Image.network(
                        profilepicUrl,
                        fit: BoxFit.cover,
                        height: 158,
                        width: 160,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                    ),
            ),
          ),
          SizedBox(height: 16.0),
          Positioned(
            top: 260,
            left: 10,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              imageUrl: profilepicUrl,
                              name: name,
                            )));
              },
              child: Container(
                width: 250,
                // color: Colors.blue,
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text("My Profile"),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Positioned(
            top: 340,
            left: 50,
            child: Text(
              "Name : $name",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 380,
            left: 50,
            child: Text(
              "Email : $email",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          Positioned(
            top: 600,
            left: 10,
            child: Container(
              width: 250,
              // color: Colors.red,
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                onTap: () {
                  // Handle "Settings" tap
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class DropDowncategory extends StatefulWidget {
  double itemHeight;
  OverlayEntry floatingCategoryDropdown;
  bool isDropdownCategoryOpened;

  DropDowncategory({
    Key? key,
    required this.itemHeight,
    required this.floatingCategoryDropdown,
    required this.isDropdownCategoryOpened,
  }) : super(key: key);

  @override
  State<DropDowncategory> createState() => _DropDowncategoryState();
}

class _DropDowncategoryState extends State<DropDowncategory> {
  @override
  var dataCategoryReceived;

  List<GetAllTodoCategory> categoriesList = [];
  Future<List<GetAllTodoCategory>> getAllCategoryList() async {
    final Uri uri = Uri.parse(
        "https://notesapp-i6yf.onrender.com/user/todoTaskCategory/getAllTodoCategory");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final Map<String, String> headers = {'x-auth-token': '$token'};
    final response = await http.get(uri, headers: headers);
    // print("all cate");
    // print(" hiiiiiiii ${response.body}");

    dataCategoryReceived = jsonDecode(response.body);
    // var id = value['data'][0]['_id'];
    // print(id);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data =
          responseData['data']; // Assuming 'data' contains the list
      categoriesList =
          data.map((json) => GetAllTodoCategory.fromJson(json)).toList();

      return categoriesList;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed"),
        ),
      );
      // throw Exception('Failed to load data');
      return categoriesList;
    }
  }

  var data;
  var value;
  var messageResponse;

  Future<String> createCategoryList(String textController) async {
    try {
      final apiUrl = Uri.parse(
          'https://notesapp-i6yf.onrender.com/user/todoTaskCategory/createTodoCategory');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final headers = {
        'Content-Type': 'application/json',
        'x-auth-token': '$token',
      };

      final userData = {
        'category': textController,
      };

      final response = await http.post(
        apiUrl,
        headers: headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return "${response.statusCode} ${response.body}"; // Data posted successfully
      } else {
        print('HTTP Error: ${response.statusCode}');
        return "${response.statusCode} ${response.body}"; // Data posting failed
      }
    } catch (error) {
      print('Error: $error');
      return "Error Occurred-$error"; // Data posting failed
    }
  }

  TextEditingController? newCategoryController;
  void _showCreateNewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        newCategoryController = TextEditingController();
        return Stack(
          children: [
            Positioned(
              top: 150,
              child: AlertDialog(
                title: Text("New Category"),
                content: TextField(
                  controller: newCategoryController,
                  decoration: InputDecoration(labelText: "Category Name"),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        String newCategoryinput =
                            newCategoryController!.text.trim();
                        if (newCategoryinput.isNotEmpty) {
                          createCategoryList(newCategoryinput);
                        }
                      }

                      Navigator.of(context).pop();
                    },
                    child: Text("Create"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void DeleteSingleTaskDetails(String _id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      // the response we are getting is a response.body
      var response = await AuthClient().DeletesingleCategory(
          '/user/todoTaskCategory/deleteToDoCategory/$_id', token!);
      setState(() {
        var value = jsonDecode(response);
        var dataResponse = value;
        print("delete task values");
        print(dataResponse);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    OverlayEntry floatingCategoryDropdown = widget.floatingCategoryDropdown;
    String selectedCategoryfromButton;
    var isSelected = false;
    AuthClient authClient = Provider.of<AuthClient>(context, listen: false);

    return Consumer<AuthClient>(builder: (context, authClient, child) {
      return Container(
        // color: Colors.pink,
        // color: Color(0xFF6C6C6C).withOpacity(0.7),
        height: widget.itemHeight * 5,
        width: double.maxFinite,
        child: Column(
          children: <Widget>[
            Material(
              elevation: 23,
              color: Color(0xFF6C6C6C).withOpacity(0.7),
              // shape: ArrowShape(),
              child: SingleChildScrollView(
                child: Container(
                  height: 6 * widget.itemHeight,
                  decoration: BoxDecoration(
                    // color: Colors.transparent,
                    // color: Colors.blue,
                    // color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: <Widget>[
                      Material(
                        elevation: 2,
                        // color: Colors.blue,
                        color: Color(0xFF6C6C6C).withOpacity(0.7),
                        // shape: ArrowShape(),
                        child: InkWell(
                          onTap: () {
                            print("hii tapped");
                            setState(() {
                              // updatedropDownopened();
                              _showCreateNewDialog();
                              // if (widget.isDropdownOpened == true) {
                              //   floatingDropdown.remove();
                              //   authClient.dropDownOpened = false;
                              // }
                            });
                          },
                          child: Container(
                            // height: widget.itemHeight,
                            decoration: BoxDecoration(
                              // color: Colors.blue,
                              color: Color(0xFF6C6C6C).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Create New",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 13,
                      ),
                      Container(
                        // height: double.maxFinite,
                        // color: Colors.blue,
                        width: double.maxFinite,
                        child: Column(
                          children: [
                            Material(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  // color: Colors.purple,
                                  color: Color(0xFF6C6C6C).withOpacity(0.7),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 6),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 120,
                                      // color: Colors.green,
                                      child: FutureBuilder<
                                          List<GetAllTodoCategory>>(
                                        future: getAllCategoryList(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2));
                                          } else if (snapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    "Error: ${snapshot.error}"));
                                          } else {
                                            return ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (context, index) {
                                                final cover =
                                                    snapshot.data![index];

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 3.0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        taskController.category.value =
                                                        selectedCategoryfromButton = cover.category;
                                                            cover.category;
                                                        print("printing ");
                                                        print(
                                                            selectedCategoryfromButton);

                                                        // here gone to authclient the value selected
                                                        authClient.updateCategory(
                                                            selectedCategoryfromButton);
                                                        if (widget
                                                                .isDropdownCategoryOpened ==
                                                            true) {
                                                          floatingCategoryDropdown
                                                              .remove();
                                                          authClient
                                                                  .dropDownOpened =
                                                              false;
                                                        }
                                                      });
                                                    },
                                                    onLongPress: () {
                                                      if (widget
                                                              .isDropdownCategoryOpened ==
                                                          true) {
                                                        floatingCategoryDropdown
                                                            .remove();
                                                        authClient
                                                                .dropDownOpened =
                                                            false;
                                                      }

                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                "Delete Category"),
                                                            content: Text(
                                                                "Are you sure you want to delete ${cover.category}?"),
                                                            actions: [
                                                              TextButton(
                                                                child: Text(
                                                                    "Cancel"),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: Text(
                                                                    "Delete"),
                                                                onPressed: () {
                                                                  var _id = dataCategoryReceived[
                                                                          'data']
                                                                      [
                                                                      index]['_id'];
                                                                  print(
                                                                      "the id to be deleted category is ${_id}");

                                                                  DeleteSingleTaskDetails(
                                                                      _id);

                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text(
                                                      "${cover.category}",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Align(
              alignment: Alignment(-0.6, 0),
              child: ClipPath(
                clipper: ArrowCategoryClipper(),
                child: Container(
                  height: 13,
                  width: 13,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 60, 59, 59),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 3,
            ),
          ],
        ),
      );
    });
  }
}

class DropDownDate extends StatefulWidget {
  final double itemHeight;
  OverlayEntry floatingdateDropdown;
  bool isDropdownOpened;
  DropDownDate({
    Key? key,
    required this.itemHeight,
    required this.floatingdateDropdown,
    required this.isDropdownOpened,
  }) : super(key: key);

  @override
  State<DropDownDate> createState() => _DropDownDateState();
}

class _DropDownDateState extends State<DropDownDate> {
  TextEditingController dateController = TextEditingController();
  @override
  void initState() {
    dateController.text = "";
  }

  DateTime today = DateTime.now();

  String? formattedSelectedDate;
  String? formattedtoday;
  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    void _ondaySelected(DateTime dueDate,) {
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dueDate);
      setState(() {
        taskController.dueDate.value = formattedDate;


        AuthClient().updateDate(formattedSelectedDate!, formattedDate);
      });
    }

    return Container(
      height: 30,
      width: double.maxFinite,
      child: Column(
        children: <Widget>[
          Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(15),
            // shape: ArrowShape(),
            color: Color.fromARGB(255, 216, 216, 216).withOpacity(0.7),
            child: Container(
              height: 16.3 * widget.itemHeight,
              decoration: BoxDecoration(
                color: Color(0xFF6C6C6C).withOpacity(0.7),
                // color: Color.fromARGB(255, 196, 17, 17).withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: ()async{
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: today,
                        firstDate: DateTime.utc(2023, 10, 16),
                        lastDate: DateTime.utc(2030, 3, 14),
                      );
                      if (pickedDate != null) {
                        _ondaySelected(pickedDate);
                      }
                    },
                    child: TableCalendar(
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, date, events) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                      locale: "en_Us",
                      focusedDay: today,
                      rowHeight: 30,
                      headerVisible: false,
                      weekNumbersVisible: false,
                      daysOfWeekVisible: false,
                      firstDay: DateTime.utc(2023, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      headerStyle: HeaderStyle(
                          formatButtonVisible: false, titleCentered: true),
                      availableGestures: AvailableGestures.all,
                      selectedDayPredicate: (day) => isSameDay(day, today),
                      // onDaySelected: _ondaySelected,
                    ),
                  ),
                  SizedBox(
                    height: 150,
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        // taskController.dueDate.value = "Today";
                      });
                    },
                    child: DropDownItem(
                      text: "Today",
                      iconData: Icons.add_circle_outline,
                      isSelected: false,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        // taskController.dueDate.value = "Tomorrow";
                      });
                    },
                    child: DropDownItem(
                      text: "Tomorrow",
                      iconData: Icons.add_circle_outline,
                      isSelected: false,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        // taskController.dueDate.value = "This Weekend";
                      });
                    },
                    child: DropDownItem(
                      text: "This Weekend",
                      iconData: Icons.add_circle_outline,
                      isSelected: false,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        // taskController.dueDate.value = "Next Date";
                      });
                    },
                    child: DropDownItem(
                      text: "Next Date",
                      iconData: Icons.add_circle_outline,
                      isSelected: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Align(
            alignment: Alignment(0.003, 0),
            child: ClipPath(
              clipper: ArrowDateClipper(),
              child: Container(
                height: 13,
                width: 13,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 60, 59, 59),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
        ],
      ),
    );
  }
}

class ArrowCategoryClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, 0); // Start from the top-left corner
    path.lineTo(size.width, 0); // Draw a line to the top-right corner
    path.lineTo(
        size.width / 2, size.height); // Draw a line to the bottom-center
    path.close(); // Close the path to form a triangular shape

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class ArrowDateClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // path.moveTo(0, size.height);
    // path.lineTo(size.width / 2, 0);
    // path.lineTo(size.width, size.height);
    path.moveTo(0, 0); // Start from the top-left corner
    path.lineTo(size.width, 0); // Draw a line to the top-right corner
    path.lineTo(
        size.width / 2, size.height); // Draw a line to the bottom-center
    path.close(); // Close the path to form a triangular shape

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class DropDownItem extends StatelessWidget {
  final String text;
  final IconData? iconData;
  final bool isSelected;
  final bool isFirstItem;
  final bool isLastItem;

  const DropDownItem(
      {Key? key,
      required this.text,
      this.iconData,
      this.isSelected = false,
      this.isFirstItem = false,
      this.isLastItem = false})
      : super(key: key);

  factory DropDownItem.first(
      {required String text,
      required IconData iconData,
      required bool isSelected}) {
    return DropDownItem(
      text: text,
      iconData: iconData,
      isSelected: isSelected,
      isFirstItem: true,
    );
  }

  factory DropDownItem.last(
      {required String text,
      required IconData iconData,
      required bool isSelected}) {
    return DropDownItem(
      text: text,
      iconData: iconData,
      isSelected: isSelected,
      isLastItem: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        // width: 150,

        decoration: BoxDecoration(
          // color: Colors.purple,
          borderRadius: BorderRadius.vertical(
            top: isFirstItem ? Radius.circular(8) : Radius.zero,
            bottom: isLastItem ? Radius.circular(8) : Radius.zero,
          ),
          color: isSelected
              ? Colors.red.shade900
              : Color(0xFF6C6C6C).withOpacity(0.7),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        child: Row(
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Spacer(),
            // Icon(
            //   iconData,
            //   color: Colors.white,
            // ),
          ],
        ),
      ),
    );
  }
}

class DropDownPriority extends StatefulWidget {
  final double itemHeight;

  DropDownPriority({super.key, required this.itemHeight});

  @override
  State<DropDownPriority> createState() => _DropDownPriorityState();
}

class _DropDownPriorityState extends State<DropDownPriority> {
  @override
  Widget build(BuildContext context) {
    print(widget.itemHeight * 4.6);
    return Container(
      // color: Colors.pink,
      height: 105,
      width: double.maxFinite,
      child: Column(
        children: <Widget>[
          Material(
            elevation: 23,
            // shape: ArrowShape(),
            child: Container(
              height: 3.7 * widget.itemHeight,
              decoration: BoxDecoration(
                  // color: Colors.green,
                  // borderRadius: BorderRadius.circular(15),
                  ),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        taskController.priority.value = "high";
                      });
                      if (floatingPriorityDropdown.mounted ??
                          false) {
                        floatingPriorityDropdown.remove();
                      }
                    },
                    child: DropDownPriorityItem(
                      text: "Default",
                      iconData: Icons.bookmark,
                      isSelected: false,
                      color: Colors.red,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        taskController.priority.value = "high";
                      });
                      if (floatingPriorityDropdown.mounted ??
                          false) {
                        floatingPriorityDropdown.remove();
                      }
                    },
                    child: DropDownPriorityItem(
                      text: "High",
                      iconData: Icons.bookmark,
                      isSelected: false,
                      color: Colors.yellow,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        taskController.priority.value = "low";
                      });
                      if (floatingPriorityDropdown.mounted ??
                          false) {
                        floatingPriorityDropdown.remove();
                      }
                    },
                    child: DropDownPriorityItem(
                      text: "Low",
                      iconData: Icons.bookmark,
                      isSelected: false,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Align(
            alignment: Alignment(0.2, 0),
            child: ClipPath(
              clipper: ArrowPriorityClipper(),
              child: Container(
                height: 13,
                width: 13,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 60, 59, 59),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DropDownPriorityItem extends StatelessWidget {
  final String text;
  final IconData? iconData;
  final bool isSelected;
  final bool isFirstItem;
  final bool isLastItem;
  final Color? color;

  const DropDownPriorityItem(
      {Key? key,
      required this.text,
      this.iconData,
      this.color,
      this.isSelected = false,
      this.isFirstItem = false,
      this.isLastItem = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        // width: 150,
        decoration: BoxDecoration(
          // color: Colors.purple,
          borderRadius: BorderRadius.vertical(
            top: isFirstItem ? Radius.circular(8) : Radius.zero,
            bottom: isLastItem ? Radius.circular(8) : Radius.zero,
          ),
          color: isSelected
              ? Colors.red.shade900
              : Color(0xFF6C6C6C).withOpacity(0.7),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        child: Row(
          children: <Widget>[
            Icon(
              iconData,
              color: color,
            ),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Spacer(),
          ],
        ),
      ),
    );
  }
}

class ArrowPriorityClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, 0); // Start from the top-left corner
    path.lineTo(size.width, 0); // Draw a line to the top-right corner
    path.lineTo(
        size.width / 2, size.height); // Draw a line to the bottom-center
    path.close(); // Close the path to form a triangular shape

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

// work here
class DropDownReminder extends StatefulWidget {
  double itemHeight;
  OverlayEntry floatingReminderDropdown;
  bool isDropdownReminderOpened;

  DropDownReminder({
    Key? key,
    required this.itemHeight,
    required this.floatingReminderDropdown,
    required this.isDropdownReminderOpened,
  }) : super(key: key);

  @override
  State<DropDownReminder> createState() => _DropDownReminderState();
}

class _DropDownReminderState extends State<DropDownReminder> {
  bool reminderdrop = false;
  bool dailydrop = false;
  bool weeklydrop = false;
  bool monthlydrop = false;
  late GlobalKey actionReminderDateKey;
  late double rdheight, rdwidth, rdxPosition, rdyPosition;
  bool isDropdownReminderDateOpened = false;
  late OverlayEntry floatingReminderdateDropdown;
  TextEditingController dateController = TextEditingController();

  // // time
  late GlobalKey actionReminderTimeKey;
  late double rtheight, rtwidth, rtxPosition, rtyPosition;
  bool isDropdownReminderTimeOpened = false;
  late OverlayEntry floatingReminderTimeDropdown;
  TextEditingController TimeController = TextEditingController();



  @override
  void initState() {
    setState(() {
      actionReminderDateKey = LabeledGlobalKey("RemDate");
      actionReminderTimeKey = LabeledGlobalKey("RemTime");
      dateController.text = "";
      TimeController.text = "";
    });

    floatingReminderdateDropdown = _createFloatingReminderDateDropdown();
    floatingReminderTimeDropdown = _createFloatingReminderTimeDropdown();
  }

  void findDropdownReminderDate() {
    RenderBox? renderBox =
        actionReminderDateKey.currentContext?.findRenderObject() as RenderBox?;
    // RenderObject? renderBox =actionKey.currentContext?.findRenderObject();
    if (renderBox != null) {
      rdheight = renderBox.size.height;
      rdwidth = renderBox.size.width;
      // rdwidth = 50;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      rdxPosition = offset.dx;
      rdyPosition = offset.dy;
    } else {
      // Handle the case where renderBox is not a RenderBox
    }
  }

  OverlayEntry _createFloatingReminderDateDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: 40,
        width: rdwidth * 7,
        top: 252,
        height: 260,
        child: DropDownReminderDate(
          itemHeight: rdheight,
          isDropdownReminderDateOpened: isDropdownReminderDateOpened,
          floatingReminderdateDropdown: floatingReminderdateDropdown,
        ),
      );
    });
  }
// timee

  void findDropdownReminderTime() {
    RenderBox? renderBox =
        actionReminderTimeKey.currentContext?.findRenderObject() as RenderBox?;
    // RenderObject? renderBox =actionKey.currentContext?.findRenderObject();
    if (renderBox != null) {
      rtheight = renderBox.size.height;
      rtwidth = renderBox.size.width;
      Offset offset = renderBox.localToGlobal(Offset.zero);
      rtxPosition = offset.dx;
      rtyPosition = offset.dy;
    } else {
      // Handle the case where renderBox is not a RenderBox
    }
  }

  OverlayEntry _createFloatingReminderTimeDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: 40,
        width: rtwidth * 7,
        top: 445,
        height: 100,
        child: Material(
          color: Color(0xFF6C6C6C),
          child: Container(
            // color: Colors.pink,
            height: 30,
            width: double.maxFinite,
            child: Column(
              children: <Widget>[
                Material(
                  elevation: 23,
                  // shape: ArrowShape(),
                  child: Container(
                    height: 2.5 * widget.itemHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF6C6C6C).withOpacity(0.7),
                      // color: Color.fromARGB(255, 229, 10, 10).withOpacity(0.7),
                      // borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          // onTap: () => _selectTime(),
                          child: InkWell(
                            onTap: () async{
                              if (isDropdownReminderTimeOpened) {
                                // Close the category dropdown if it's open
                                if (floatingReminderTimeDropdown?.mounted ??
                                    false) {
                                  floatingReminderTimeDropdown.remove();
                                }
                              }
                              //date
                              if (isDropdownReminderDateOpened) {
                                // Close the date dropdown if it's open
                                if (floatingReminderdateDropdown.mounted ??
                                    false) {
                                  floatingReminderdateDropdown.remove();
                                }
                              }
                              isDropdownReminderDateOpened =
                                  !isDropdownReminderDateOpened;
                              isDropdownReminderTimeOpened =
                                  !isDropdownReminderTimeOpened;
                              if (widget.isDropdownReminderOpened) {
                                if (widget.floatingReminderDropdown.mounted ??
                                    false) {
                                  widget.floatingReminderDropdown.remove();
                                }
                              }

                              // DateTime? pickedDate = await showDatePicker(
                              //   context: context,
                              //   initialDate: today,
                              //   firstDate: DateTime.utc(2023, 10, 16),
                              //   lastDate: DateTime.utc(2030, 3, 14),
                              // );
                              //
                              // if (pickedDate != null) {
                              //   _onRemainderdaySelected(pickedDate, "");
                              // }
                            },

                            // also close reminder
                            child: Container(
                              child: Center(
                                child: Text(
                                  "12",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Align(
                  alignment: Alignment(-0.8, 0),
                  child: ClipPath(
                    clipper: ArrowReminderTimeClipper(),
                    child: Container(
                      height: 13,
                      width: 13,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 60, 59, 59),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }



  Future<void> _selectRemainderTime(BuildContext context, String frequency) async {
    TimeOfDay _selectedTime = TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });

      // Convert TimeOfDay to DateTime
      DateTime dateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Add milliseconds manually (since TimeOfDay doesn't include milliseconds)
      dateTime = dateTime.add(Duration(milliseconds: 460));

      // Format the DateTime using the desired pattern
      String formattedTime = DateFormat("THH:mm:ss.SSS'Z'").format(dateTime.toUtc());
      taskController.remainderTime.value = formattedTime;
      taskController.frequency.value = "Hourly";

      Get.find<TaskController>()
          .addRemainderData(RemainderData(dateTime: "${taskController.remainderDate.value}${taskController.remainderTime.value}", frequency: taskController.frequency.value)
      );
    }
  }


  void _onRemainderdaySelected(BuildContext context, DateTime dueDate, String frequency) async{

    String formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);
    taskController.remainderDate.value = formattedDate;
    print("ho gya!!!!!!!!!!!!!!!!!");
    await _selectRemainderTime(context, frequency);

  }


  @override
  Widget build(BuildContext context) {
    AuthClient authClient = Provider.of<AuthClient>(context, listen: false);
    DateTime today = DateTime.now();
    return Container(
      // color: Colors.pink,
      height: 50,
      width: double.maxFinite,
      child: Column(
        children: <Widget>[
          Material(
            elevation: 0,
            color: Color.fromARGB(255, 171, 170, 170).withOpacity(0.7),
            // color: Colors.transparent.withOpacity(0),
            child: Container(
              height: 9.299 * widget.itemHeight,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 103, 102, 102).withOpacity(0.7),
                // color: Colors.blue,
                // borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    onTap:()async{
                      floatingReminderDropdown.remove();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: today,
                        firstDate: DateTime.utc(2023, 10, 16),
                        lastDate: DateTime.utc(2030, 3, 14),
                      );

                      if (pickedDate != null) {
                        _onRemainderdaySelected(context, pickedDate, "hourly");
                      }
                      ///next step
                    },
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                      decoration: BoxDecoration(
                        // color: Colors.purple,
                        // borderRadius: BorderRadius.circular(13),
                        color: Color(0xFF6C6C6C),
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Hourly",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                reminderdrop = !reminderdrop;
                              });
                            },
                            child: (reminderdrop == false)
                                ? Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (reminderdrop)
                    Container(
                      color:
                          Color.fromARGB(255, 156, 154, 154).withOpacity(0.7),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 2),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                height: 30,
                                child: GestureDetector(
                                  key: actionReminderDateKey,
                                  onTap: () {
                                    setState(() {
                                      //time
                                      if (isDropdownReminderTimeOpened) {
                                        if (floatingReminderTimeDropdown
                                                ?.mounted ??
                                            false) {
                                          floatingReminderTimeDropdown
                                              ?.remove();
                                        }
                                      }
                                      if (isDropdownReminderDateOpened) {
                                        if (floatingReminderdateDropdown
                                                ?.mounted ??
                                            false) {
                                          floatingReminderdateDropdown
                                              ?.remove();
                                        }
                                      } else {
                                        findDropdownReminderDate();
                                        floatingReminderdateDropdown =
                                            _createFloatingReminderDateDropdown();
                                        Overlay.of(context).insert(
                                            floatingReminderdateDropdown);
                                      }
                                      isDropdownReminderDateOpened =
                                          !isDropdownReminderDateOpened;
                                      isDropdownReminderTimeOpened =
                                          !isDropdownReminderTimeOpened;
                                    });
                                  },
                                  child: Text(
                                    "Date ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  GestureDetector(
                    onTap:()async{
                      floatingReminderDropdown.remove();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: today,
                        firstDate: DateTime.utc(2023, 10, 16),
                        lastDate: DateTime.utc(2030, 3, 14),
                      );

                      if (pickedDate != null) {
                        _onRemainderdaySelected(context, pickedDate, "Daily");
                      }
                    },
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                      decoration: BoxDecoration(
                        // color: Colors.purple,

                        // borderRadius: BorderRadius.circular(13),
                        color: Color(0xFF6C6C6C),
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Daily",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                dailydrop = !dailydrop;
                              });
                            },
                            child: (dailydrop == false)
                                ? Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap:()async{
                      floatingReminderDropdown.remove();
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: today,
                        firstDate: DateTime.utc(2023, 10, 16),
                        lastDate: DateTime.utc(2030, 3, 14),
                      );

                      if (pickedDate != null) {
                        _onRemainderdaySelected(context, pickedDate, "Weekly");
                      }
                    },
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                      decoration: BoxDecoration(
                        // color: Colors.purple,

                        // borderRadius: BorderRadius.circular(13),
                        color: Color(0xFF6C6C6C),
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Weekly",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                weeklydrop = !weeklydrop;
                              });
                            },
                            child: (weeklydrop == false)
                                ? Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap:()async{
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: today,
                        firstDate: DateTime.utc(2023, 10, 16),
                        lastDate: DateTime.utc(2030, 3, 14),
                      );

                      if (pickedDate != null) {
                        _onRemainderdaySelected(context, pickedDate, "Monthly");
                      }
                    },
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                      decoration: BoxDecoration(
                        // color: Colors.purple,

                        // borderRadius: BorderRadius.circular(13),
                        color: Color(0xFF6C6C6C),
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Monthly",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                monthlydrop = !monthlydrop;
                              });
                            },
                            child: (monthlydrop == false)
                                ? Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ClipPath(
                clipper: ArrowReminderClipper(),
                child: Container(
                  height: 13,
                  width: 13,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 60, 59, 59),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
        ],
      ),
    );
  }
}

class ArrowReminderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, 0); // Start from the top-left corner
    path.lineTo(size.width, 0); // Draw a line to the top-right corner
    path.lineTo(
        size.width / 2, size.height); // Draw a line to the bottom-center
    path.close(); // Close the path to form a triangular shape

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class DropDownMenu extends StatefulWidget {
  final double itemHeight;
  OverlayEntry floatingMenuDropdown;
  bool isDropdownMenuOpened;
  DropDownMenu({
    Key? key,
    required this.itemHeight,
    required this.floatingMenuDropdown,
    required this.isDropdownMenuOpened,
  }) : super(key: key);

  @override
  State<DropDownMenu> createState() => _DropDownMenuState();
}

class _DropDownMenuState extends State<DropDownMenu> {
  static String selectedText = 'hello';

  Future<String> createCategoryList(String textController) async {
    try {
      final apiUrl = Uri.parse(
          'https://notesapp-i6yf.onrender.com/user/todoTaskCategory/createTodoCategory');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final headers = {
        'Content-Type': 'application/json',
        'x-auth-token': '$token',
      };

      final userData = {
        'category': textController,
      };

      final response = await http.post(
        apiUrl,
        headers: headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return "${response.statusCode} ${response.body}"; // Data posted successfully
      } else {
        print('HTTP Error: ${response.statusCode}');
        return "${response.statusCode} ${response.body}"; // Data posting failed
      }
    } catch (error) {
      print('Error: $error');
      return "Error Occurred-$error"; // Data posting failed
    }
  }

  List<GetAllTodoCategory> categoriesList = [];
  var dataCategoryReceived;
  Future<List<GetAllTodoCategory>> getAllCover() async {
    final Uri uri = Uri.parse(
        "https://notesapp-i6yf.onrender.com/user/todoTaskCategory/getAllTodoCategory");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final Map<String, String> headers = {'x-auth-token': '$token'};
    final response = await http.get(uri, headers: headers);

    print("all cate");
    print(" hiii this is menu drop down ${response.body}");

    dataCategoryReceived = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data =
          responseData['data']; // Assuming 'data' contains the list
      categoriesList =
          data.map((json) => GetAllTodoCategory.fromJson(json)).toList();

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Success"),
      //   ),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("${token}"),
      //   ),
      // );
      return categoriesList;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed"),
        ),
      );
      throw Exception('Failed to load data');
    }
  }

  void DeleteSingleTaskDetails(String _id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      // the response we are getting is a response.body
      var response = await AuthClient().DeletesingleCategory(
          '/user/todoTaskCategory/deleteToDoCategory/$_id', token!);
      setState(() {
        var value = jsonDecode(response);
        var dataResponse = value;
        print("delete task values");
        print(dataResponse);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  TextEditingController? newCategoryController;
  void _showCreateNewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        newCategoryController = TextEditingController();

        return Align(
          alignment: Alignment.bottomCenter,
          child: AlertDialog(
            title: Text("New Category"),
            content: TextField(
              controller: newCategoryController,
              decoration: InputDecoration(labelText: "Category Name"),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    String newCategoryinput =
                        newCategoryController!.text.trim();

                    if (newCategoryinput.isNotEmpty) {
                      createCategoryList(newCategoryinput);
                    }
                  });

                  Navigator.of(context).pop();
                },
                child: Text("Create"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    OverlayEntry floatingMenuDropdown = widget.floatingMenuDropdown;
    // String selectedCategoryfromButton;
    AuthClient authClient = Provider.of<AuthClient>(context, listen: false);
    return Consumer<AuthClient>(
      builder: (context, authClient, child) {
        return Container(
          // color: Colors.pink,
          height: widget.itemHeight * 8,
          width: double.maxFinite,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 3,
              ),
              Align(
                alignment: Alignment(0.7, 0),
                child: ClipPath(
                  clipper: ArrowMenuClipper(),
                  child: Container(
                    height: 13,
                    width: 13,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 60, 59, 59),
                    ),
                  ),
                ),
              ),
              Material(
                elevation: 23,
                color: Colors.transparent,
                // shape: ArrowShape(),
                child: SingleChildScrollView(
                  child: Container(
                    height: 6 * widget.itemHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 13,
                        ),
                        Container(
                          // height: double.maxFinite,
                          // color: Colors.blue,
                          width: double.maxFinite,
                          child: Column(
                            children: [
                              Material(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    // color: Colors.purple,
                                    color: Color(0xFF6C6C6C).withOpacity(0.7),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 6),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 120,
                                        // color: Colors.green,
                                        child: FutureBuilder<
                                            List<GetAllTodoCategory>>(
                                          future: getAllCover(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2));
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      "Error: ${snapshot.error}"));
                                            } else {
                                              return ListView.builder(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                itemCount:
                                                    snapshot.data!.length,
                                                itemBuilder: (context, index) {
                                                  final cover =
                                                      snapshot.data![index];

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 3.0),
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedText =
                                                              cover.category;
                                                          print(selectedText);
                                                          AuthClient()
                                                              .updateCategory(
                                                                  selectedText);
                                                          // print(
                                                          //     "selected text from menu is ${AuthClient().categoryTextSelected}");
                                                          if (widget
                                                                  .isDropdownMenuOpened ==
                                                              true) {
                                                            floatingMenuDropdown
                                                                .remove();
                                                            authClient
                                                                    .dropDownOpened =
                                                                false;
                                                          }
                                                        });

                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            backgroundColor:
                                                                Colors.green,
                                                            content: Text(
                                                                " Category $selectedText Selected"),
                                                          ),
                                                        );
                                                      },
                                                      onLongPress: () {
                                                        if (widget
                                                                .isDropdownMenuOpened ==
                                                            true) {
                                                          floatingMenuDropdown
                                                              .remove();
                                                          authClient
                                                                  .dropDownOpened =
                                                              false;
                                                        }
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  "Delete Category"),
                                                              content: Text(
                                                                  "Are you sure you want to delete ${cover.category}?"),
                                                              actions: [
                                                                TextButton(
                                                                  child: Text(
                                                                      "Cancel"),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child: Text(
                                                                      "Delete"),
                                                                  onPressed:
                                                                      () {
                                                                    var _id = dataCategoryReceived['data']
                                                                            [
                                                                            index]
                                                                        ['_id'];
                                                                    print(
                                                                        "the id to be deleted category is ${_id}");

                                                                    DeleteSingleTaskDetails(
                                                                        _id);

                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Text(
                                                        "${cover.category}", // work , personal ....
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Material(
                                elevation: 2,
                                // color: Colors.transparent,
                                color: Color.fromARGB(255, 156, 154, 154)
                                    .withOpacity(0.7),
                                // shape: ArrowShape(),
                                child: InkWell(
                                  onTap: () {
                                    print("hii tapped");
                                    setState(() {
                                      // updatedropDownopened();
                                      _showCreateNewDialog();
                                    });
                                  },
                                  child: Container(
                                    // height: widget.itemHeight,
                                    decoration: BoxDecoration(
                                      // color: Colors.blue,
                                      // color: Color(0xFF6C6C6C).withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Create New",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 3,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ArrowMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CustomDialog extends StatefulWidget {
  final VoidCallback setState;

  const CustomDialog({
    super.key, required this.setState,

  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  TextEditingController tagController = TextEditingController();

  bool _isUploading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Container(
              height: 280,
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: "Enter Tag",
                    enabled: false,
                    decoration: InputDecoration(
                      border: InputBorder.none, // Removes the border,
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontFamily: "MontserratBold",
                        color: Colors.black,
                      ),
                      hintText: 'Enter Tag',
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "MontserratBold",
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "MontserratRegular",
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                      keyboardType: TextInputType.text,
                      controller: tagController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Enter Tag",
                        hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: "MontserratRegular",
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                            BorderSide(color: Colors.blue, width: 1)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                            BorderSide(color: Colors.blue, width: 1)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (tagController.text.isNotEmpty) {
                        // Add the entered text to the list
                        setState(() {
                          tagsList.add(tagController.text);
                        });

                        // Clear the text field
                        tagController.clear();
                        print(tagsList);
                      }
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text(
                            "Add",
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: "MontserratBold",
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}