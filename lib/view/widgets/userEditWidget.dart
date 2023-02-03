import 'package:dtr360_version3_2/utils/alertbox.dart';
import 'package:dtr360_version3_2/utils/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../model/users.dart';
import '../../utils/firebase_functions.dart';

class UserEditWidget extends StatefulWidget {
  const UserEditWidget({super.key});

  @override
  State<UserEditWidget> createState() => _MyWidgetState();
}
List<String>? list = <String>['Admin', 'Employee', 'IT', 'Approver', 'IT/Admin', 'Former Employee'];
class _MyWidgetState extends State<UserEditWidget> {
  
  TextEditingController employeeId = TextEditingController();
  TextEditingController employeeName= TextEditingController();
  TextEditingController department= TextEditingController();
  List<Employees>? employeeList;
  Employees selectedEmployee = new Employees();
  String? dropdownValue; 
  String? userTypeDropdown;
  bool loaded = false;
  bool _isWfh = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeList = await fetchAllEmployees();
      sortListAlphabetical(employeeList!);
      setState(() {
        loaded = true;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title:  Text("User Edit"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
          child: SafeArea(
              child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5.h),
            child: Container(
                width: 40.w,
                height: 40.w,
                child: Lottie.asset('assets/json_files/user_edit.json')),
          ),
          Padding(
              padding:
                  EdgeInsets.only(left: 28.0, right: 28.0, top: 20, bottom: 0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Color.fromARGB(255, 57, 57, 231)),
                underline: Container(
                  height: 2,
                  color: Color.fromARGB(255, 57, 57, 231),
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                    selectedEmployee = employeeList!.where((element) => element.guid == dropdownValue).first;
                    employeeName = TextEditingController(text: selectedEmployee.empName);
                    employeeId = TextEditingController(text: selectedEmployee.empId);
                    department = TextEditingController(text: selectedEmployee.dept);
                    _isWfh = selectedEmployee.wfh == 'null' || selectedEmployee.wfh == '' ? false : true;
                    userTypeDropdown = selectedEmployee.usrType;
                    print(selectedEmployee.key);
                  });
                },
                items: employeeList != null ? employeeList!.map((e) {
                  return DropdownMenuItem<String>(
                    value: e.guid!,
                    child: Text(e.empName!),
                  );
                }).toList() : [],
              )),
          Padding(
              padding:
                  EdgeInsets.only(left: 28.0, right: 28.0, top: 20, bottom: 0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: userTypeDropdown,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Color.fromARGB(255, 57, 57, 231)),
                underline: Container(
                  height: 2,
                  color: Color.fromARGB(255, 57, 57, 231),
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    userTypeDropdown = value!;
                    print(userTypeDropdown);
                  });
                },
                items: list!.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )),
          Padding(
            padding:
                EdgeInsets.only(left: 28.0, right: 28.0, top: 20, bottom: 0),
            child: TextField(
              controller: employeeName,
              decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                prefixIcon: Icon(Icons.drive_file_rename_outline),
                  border: OutlineInputBorder(), labelText: 'Employee Name'),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: 28.0, right: 28.0, top: 20, bottom: 0),
            child: TextField(
              controller: employeeId,
              decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(), labelText: 'Employee ID'),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: 28.0, right: 28.0, top: 20, bottom: 0),
            child: TextField(
              controller: department,
              decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                prefixIcon: Icon(Icons.corporate_fare),
                  border: OutlineInputBorder(), labelText: 'Department'),
            ),
          ),
          Padding(
              padding:
                  EdgeInsets.only(left: 18.0, right: 28.0, top: 20, bottom: 0),
              child: Row(
                children: [
                  Checkbox(
                    value: _isWfh,
                    onChanged: (value) {
                      setState(() {
                        _isWfh = value!;
                        print(_isWfh);
                      });
                    },
                  ),
                  Text('Work from Home', style: TextStyle(fontSize: 20)),
                ],
              )),
          Container(
            height: 6.h,
            width: 80.w,
            decoration: BoxDecoration(
                color: Colors.orange, borderRadius: BorderRadius.circular(20)), 
            child: TextButton.icon(
              icon: Icon(Icons.person_add, color: Colors.white,),
              onPressed: () async {
                if(employeeName.text != '' && employeeId.text != '' && department.text != ''){
                  updateEmployeeDetails(selectedEmployee.key, department.text, employeeId.text,employeeName.text, _isWfh, userTypeDropdown);
                  success_box(context, "Employee profile updated.");
                  employeeList = await fetchAllEmployees();
                  sortListAlphabetical(employeeList!);
                  department.text = '';
                  employeeId.text = '';
                  employeeName.text = '';
                  FocusScope.of(context).unfocus();
                }
                else{
                  warning_box(context, "Please complete all the fields");
                }
                
                
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (_) => const HomePage()));
              },
              label: Text('UPDATE USER', style: TextStyle(fontSize: 20, color: Colors.white))
            ),
          ),
        ],
      ))),
    );
  } 
}