import 'dart:ui';

import 'package:dtr360_version3_2/view/widgets/loaderView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sizer/sizer.dart';

import '../../../model/filingdocument.dart';
import '../../../utils/alertbox.dart';
import '../../../utils/fileDocuments_functions.dart';
import '../../../utils/firebase_functions.dart';
import '../../../utils/utilities.dart';

class OvertimeWidget extends StatefulWidget {
  const OvertimeWidget({super.key});

  @override
  State<OvertimeWidget> createState() => _OvertimeWidgetState();
}

class _OvertimeWidgetState extends State<OvertimeWidget> {
  final FilingDocument dataModel = FilingDocument();
  DateTime startDate = DateTime.now();
  DateTime otDate = DateTime.now();
  var employeeProfile;
  String? selectedOtType;
  TimeOfDay initialTimeFrom = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay initialTimeTo = const TimeOfDay(hour: 0, minute: 0);
  TextEditingController reason = TextEditingController();
  TextEditingController totalHours = TextEditingController();
  List<String> otType = [
    'Regular',
    'Rest Day',
    'Regular Holiday',
    'Special Non-working Holiday',
    'Rest Day Regular Holiday',
    'Rest Day Special Non Working Holiday'
  ];
  bool isOvernightOt = false;
  bool isFlexi = false;
  bool _loaded = true;
  bool isProcessing = false;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      employeeProfile = await read_employeeProfile();
      dataModel.guid = employeeProfile[4] ?? '';
      dataModel.dept = employeeProfile[1] ?? '';
      dataModel.empKey = employeeProfile[7] ?? '';
      dataModel.employeeName = employeeProfile[0] ?? '';
      setState(() {
        dataModel.date = startDate.toString();
        dataModel.otDate = otDate.toString();
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        dataModel.date = startDate.toString();
      });
    }
  }

  Future<void> _otDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: otDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != otDate) {
      setState(() {
        otDate = picked;
        dataModel.otDate = otDate.toString();
      });
    }
  }

  Future<void> _selectTimeFrom(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTimeFrom);
    if (picked != null && picked != initialTimeFrom) {
      setState(() {
        initialTimeFrom = picked;
        dataModel.otfrom = convertStringDateToUnix(dataModel.otDate, formatTime(initialTimeFrom), 'Overtime', false, dataModel.otfrom);
        if (dataModel.otfrom != null && dataModel.otTo != null) {
          String totalNoHours = computeTotalHours(dataModel.otfrom, dataModel.otTo);
          totalHours.text = totalNoHours;
          dataModel.hoursNo = totalNoHours;
        }
      });
    }
  }

  Future<void> _selectTimeTo(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTimeTo);
    if (picked != null && picked != initialTimeTo) {
      setState(() {
        initialTimeTo = picked;
        dataModel.otTo = convertStringDateToUnix(dataModel.otDate, formatTime(initialTimeTo), 'Overtime', true, dataModel.otfrom);
        if (dataModel.otfrom != '' && dataModel.otTo != '') {
          String totalNoHours = computeTotalHours(dataModel.otfrom, dataModel.otTo);
          totalHours.text = totalNoHours;
          dataModel.hoursNo = totalNoHours;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderView(showLoader: _loaded == false, child: SingleChildScrollView(
      child: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Overtime',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(labelText: 'Date of Filing'),
                readOnly: true,
                controller: TextEditingController(text: formatDate(startDate)),
              ),
              // DropdownButtonFormField<String>(
              //   value: selectedOtType,
              //   decoration: const InputDecoration(
              //     labelText: 'OT Type',
              //   ),
              //   onChanged: (newValue) {
              //     setState(() {
              //       selectedOtType = newValue;
              //       dataModel.otType = newValue!;
              //     });
              //   },
              //   items: otType.map((dropdownValue) {
              //     return DropdownMenuItem<String>(
              //       value: dropdownValue,
              //       child: Text(dropdownValue),
              //     );
              //   }).toList(),
              // ),
              TextField(
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(labelText: 'Date of Overtime'),
                onTap: () {
                  _otDate(context);
                },
                controller: TextEditingController(text: formatDate(otDate)),
              ),
              TextField(
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(labelText: 'From'),
                onTap: () {
                  _selectTimeFrom(context);
                },
                controller: TextEditingController(text: formatTime(initialTimeFrom)),
              ),
              TextField(
                keyboardType: TextInputType.none,
                decoration: const InputDecoration(labelText: 'To'),
                onTap: () {
                  _selectTimeTo(context);
                },
                controller: TextEditingController(text: formatTime(initialTimeTo)),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Total Hours'),
                onChanged: (value) {
                  setState(() {
                    dataModel.reason = value;
                  });
                },
                controller: totalHours,
              ),
              Row(
                children: [
                  Checkbox(
                      value: isOvernightOt,
                      onChanged: (bool? value) {
                        setState(() {
                          isOvernightOt = value!;
                          dataModel.isOvernightOt = value!;
                        });
                      }),
                  const Text(
                    'Overnight OT',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              Row(
                children: [
                  Checkbox(
                      value: isFlexi,
                      onChanged: (bool? value) {
                        setState(() {
                          isFlexi = value!;
                          dataModel.isFlexi = value!;
                        });
                      }),
                  const Text(
                    'Flexi Hours',
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Reason'),
                onChanged: (value) {
                  setState(() {
                    dataModel.reason = value;
                  });
                },
                controller: reason,
              ),
              const SizedBox(height: 40),
              Container(
                height: 6.h,
                width: 80.w,
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.file_copy,
                    color: Color.fromARGB(255, 141, 105, 105),
                  ),
                  onPressed: () async {
                    if(isProcessing == false){
                      
                      dataModel.docType = 'Overtime';
                      var isDupe = await checkIfDuplicate(dataModel.dateFrom, dataModel.dateTo, dataModel.correctDate, dataModel.otDate, dataModel.docType,
                          dataModel.guid, dataModel.isOut, dataModel.otfrom);
                      var isValid = await checkIfValidDate(
                          dataModel.otDate, employeeProfile[4], true, dataModel.otfrom, dataModel.otTo, dataModel.isOvernightOt, dataModel.isOut, true, dataModel.isFlexi);
                      if (reason.text != '' && totalHours.text != '' && totalHours.text != '0') {
                        if (isValid && (double.parse(totalHours.text) > 0 || isOvernightOt)) {
                          if (!isDupe) {
                            var otType = await checkIfValidDate(
                                dataModel.otDate, employeeProfile[4], true, dataModel.otfrom, dataModel.otTo, dataModel.isOvernightOt, dataModel.isOut, false, dataModel.isFlexi);
                            dataModel.otType = otType;
                            setState(() {
                              isProcessing = true;
                              _loaded = false;
                            });
                            await fileDocument(dataModel, context);
                            setState(() {
                              dataModel.resetProperties();
                              reason.text = '';
                              startDate = DateTime.now();
                              otDate = DateTime.now();
                              dataModel.date = startDate.toString();
                              dataModel.otDate = otDate.toString();
                              initialTimeFrom = const TimeOfDay(hour: 0, minute: 0);
                              initialTimeTo = const TimeOfDay(hour: 0, minute: 0);
                              totalHours.text = '';
                              isProcessing = false;
                              _loaded = true;
                            });
                          } else {
                            warning_box(context, 'There is already an application on this date');
                          }
                        } else {
                          warning_box(context, 'Invalid Overtime');
                        }
                      } else {
                        warning_box(context, 'Please complete the fields.');
                      }
                    }
                    else{
                      warning_box(context, 'Request is already in process');
                    }
                  },
                  label: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              )
            ],
          )),
    ));
  }
}
