import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DropDownWidget extends StatefulWidget {
  final Function(String) setQueryData;
  final String bookButtonTriggered;
  final String testTypeButtonTriggered;

  const DropDownWidget({
    required this.bookButtonTriggered,
    required this.testTypeButtonTriggered,
    required this.setQueryData,
    super.key,
  });

  @override
  State<DropDownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropDownWidget> {
  String? _dropdownValue;
  Map<String, dynamic>? listOfUnitsData;

  void dropdownCallBack(String? selectedValue) {
    setState(() {
      _dropdownValue = selectedValue;
    });
    widget.setQueryData(selectedValue!);
  }

  Future<void> readJsonUnitData() async {
    final String response = await rootBundle.loadString('data.json');
    final Map<String, dynamic> data = await json.decode(response);
    setState(() {
      listOfUnitsData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    readJsonUnitData();
  }

  @override
  Widget build(BuildContext context) {
    if (listOfUnitsData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    List<DropdownMenuItem<String>> dropdownItems = [];
    if (widget.bookButtonTriggered != "" &&
        widget.testTypeButtonTriggered != "") {
      final units = listOfUnitsData![widget.bookButtonTriggered]
          [widget.testTypeButtonTriggered];
      final unitList = List<String>.from(units);
      dropdownItems = unitList
          .map((unit) => DropdownMenuItem(
                value: unit,
                child: Text(unit),
              ))
          .toList();
    }

    if (!dropdownItems.map((item) => item.value).contains(_dropdownValue)) {
      _dropdownValue = null;
    }

    return DropdownButton<String>(
      underline: const SizedBox(),
      elevation: 16,
      focusColor: Colors.white,
      padding: const EdgeInsets.all(6),
      hint: const Text('Select an unit'),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      isExpanded: true,
      items: dropdownItems,
      onChanged: dropdownCallBack,
      value: _dropdownValue,
    );
  }
}
