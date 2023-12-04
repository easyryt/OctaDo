import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:octa_todo_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import '../json/getAllCategory.dart';
import '../services/client.dart';

class TodoDetailsScreen extends StatefulWidget {
  final String id;
  const TodoDetailsScreen({super.key, required this.id});

  @override
  State<TodoDetailsScreen> createState() => _TodoDetailsScreenState();
}
String selectedCategory = "";
String selectedPriority = "";
class _TodoDetailsScreenState extends State<TodoDetailsScreen> {

  var dataResponse;

  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _priorityController = TextEditingController();
  TextEditingController _dueDateController = TextEditingController();
  TextEditingController _completedController = TextEditingController();
  TextEditingController _remainderController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _frequencyController = TextEditingController();

  bool _isLoading = false;
  bool _isUploading = false;

  void getSingleTaskDetails(String _id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      // the response we are getting is a response.body
      var response = await AuthClient()
          .getSingleTask('/user/todoTask/getSingleTask/$_id', token!);
      setState(() {
        var value = jsonDecode(response);
        _isLoading = false;
         dataResponse = value['task'];
        // title = dataResponse['title'];
        _descriptionController.text =  dataResponse['description'];
        _categoryController.text =  dataResponse['category'];
        _priorityController.text =  dataResponse['priority'];
        _completedController.text =  dataResponse['completed'].toString();
        _dueDateController.text =  dataResponse['dueDate'];
        _idController.text =  dataResponse['_id'];
        selectedCategory = dataResponse['category'];
        selectedPriority = dataResponse['priority'];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e.toString());
    }
  }

  Future<String> updateTodoTask() async {
    try {
      setState(() {
        _isUploading = true;
      });
      final apiUrl = Uri.parse(
          'https://notesapp-i6yf.onrender.com/user/todoTask/updateTask/${widget.id}');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final headers = {
        'Content-Type': 'application/json',
        'x-auth-token': '$token',
      };

      final userData = {
        'description': _descriptionController.text.toString(),
        'category': selectedCategory,
        "priority": selectedPriority,
        // "dueDate": "${taskController.dueDate.value}${taskController.dueTime.value}",
        // 'reminders': taskController.remainderDataList.map((remainder) => remainder.toJson()).toList(),
      };

      final response = await http.put(
        apiUrl,
        headers: headers,
        body: jsonEncode(userData),
      );
      if (response.statusCode == 200) {
        setState(() {
          _isUploading = false;
        });

        return "${response.statusCode} ${response.body}"; // Data posted successfully
      } else {
        setState(() {
          _isUploading = false;
        });
        return "${response.statusCode} ${response.body}"; // Data posting failed
      }
    } catch (error) {
      setState(() {
        _isUploading = false;
      });
      return "Error Occurred-$error"; // Data posting failed
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var _id = widget.id;
    getSingleTaskDetails(_id);

  }
  void set(){
    print("Ho bya");
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body:_isLoading?Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue,)): SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 82,
                color: Color(0xff6C6C6C),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(18, 0, 0, 0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          child: Container(
                              width: 23,
                              height: 12,
                              child: Icon(Icons.arrow_back_ios,
                                  color: Colors.white)),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "All List",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.filter_alt_rounded,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0)
                    .copyWith(top: 12),
                child: Container(
                  height: 34,
                  width: double.infinity,
                  // color: Colors.red,
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    dataResponse['title'],
                    // 'title here',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              TextFieldDesign(maxLine: 4,title: "Description", controller: _descriptionController,),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(child:  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            "Category",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        GestureDetector(
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  shape: StadiumBorder(),
                                  content: Category(setState: set),
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 48,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey, // Border color
                                width: 0.5, // Border width
                              ),
                              borderRadius:
                              BorderRadius.circular(8.0), // Optional: Border radius
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                   selectedCategory
                                  ),
                                ),
                              ],
                            )

                          ),
                        )
                      ],
                    ),
                  )),
                  Expanded(child:  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            "Priority",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        GestureDetector(
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  shape: StadiumBorder(),
                                  content: PriorityDialog(setState: set),
                                );
                              },
                            );
                          },
                          child: Container(
                              height: 48,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey, // Border color
                                  width: 0.5, // Border width
                                ),
                                borderRadius:
                                BorderRadius.circular(8.0), // Optional: Border radius
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                        selectedPriority
                                    ),
                                  ),
                                ],
                              )

                          ),
                        )
                      ],
                    ),
                  )),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              TextFieldDesign(maxLine: 1,title: "Due Date", controller: _dueDateController,),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(child: TextFieldDesign(maxLine: 1, title: "completed", controller: _completedController,)),
                  Expanded(child : TextFieldDesign(maxLine: 1, title: "remainders", controller: _remainderController,)),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              TextFieldDesign(maxLine: 1,title: "ID", controller: _idController,),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(child: TextFieldDesign(maxLine: 1, title: "frequency", controller: _frequencyController,)),
                  Expanded(child : SizedBox()),
                ],
              ),
              SizedBox(
                height: 32,
              ),
              GestureDetector(
                onTap: ()async{
                  String message = await updateTodoTask();
                  showSnackBar(message, context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Color(0xff6C6C6C),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Center(
                      child: _isUploading?CircularProgressIndicator(strokeWidth: 2, color: Colors.white,):Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldDesign extends StatelessWidget {
  final int maxLine;
  final String title;
  final TextEditingController controller;
  const TextFieldDesign({super.key, required this.maxLine, required this.title, required this.controller});

  @override
  Widget build(BuildContext context) {
    return
      Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey, // Border color
                width: 0.5, // Border width
              ),
              borderRadius:
                  BorderRadius.circular(8.0), // Optional: Border radius
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLine,
              decoration: InputDecoration(
                hintText: 'Enter text',
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                border: InputBorder.none, // Remove the default border
              ),
            ),
          )
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
                                    widget.setState();
                                    setState(() {
                                      selectedCategory = "${cover.category}";
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


class PriorityDialog extends StatefulWidget {
  final VoidCallback setState;
  const PriorityDialog({super.key, required this.setState});

  @override
  State<PriorityDialog> createState() => _PriorityDialogState();
}

class _PriorityDialogState extends State<PriorityDialog> {
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
                        "Priority",
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: GestureDetector(
                        onTap: (){

                          selectedPriority = "low";
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
                              "Low",
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
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: GestureDetector(
                        onTap: (){

                          setState(() {
                            selectedPriority = "medium";
                          });
                          Navigator.pop(context);
                          widget.setState();
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: Text(
                              "Medium",
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
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedPriority = "high";
                          });
                          Navigator.pop(context);
                          widget.setState();
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: Text(
                              "High",
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
                    )
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
