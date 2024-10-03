// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/titleW.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectableCalendar extends StatefulWidget {
  const SelectableCalendar({super.key});

  @override
  _SelectableCalendarState createState() => _SelectableCalendarState();
}

enum SelectionMode { range, multiple }

class _SelectableCalendarState extends State<SelectableCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedStartDay;
  DateTime? _selectedEndDay;
  List<DateTime> _selectedDays = [];
  SelectionMode _selectionMode = SelectionMode.range;

  bool type() {
    if (_selectionMode == SelectionMode.range) {
      _selectedDays = [];
      return true;
    }
    _selectedStartDay = null;
    _selectedEndDay = null;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(250, 244, 229, 1),
      ),
      home: Scaffold(
        body: lang == null
            ? const Center(
                child: SpinKitSpinningLines(
                    color: Color.fromRGBO(169, 200, 149, 1), size: 50.0))
            : Column(
                children: [
                  Stack(children: [
                    titleW(
                      title: lang! ? 'Fecha/s' : 'Date/s',
                    ),
                    Positioned(
                        left: 30,
                        top: 70,
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios,
                                  size: 30, color: Colors.black),
                            ),
                            Text(
                              lang! ? 'Regresar' : 'Back',
                              style: const TextStyle(fontSize: 10),
                            )
                          ],
                        )),
                    Positioned(
                        left: 330,
                        top: 70,
                        child: Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.switch_left),
                              onPressed: () {
                                setState(() {
                                  _selectionMode =
                                      _selectionMode == SelectionMode.range
                                          ? SelectionMode.multiple
                                          : SelectionMode.range;
                                  _selectedStartDay = null;
                                  _selectedEndDay = null;
                                  _selectedDays.clear();
                                  type();
                                  setState(() {});
                                });
                              },
                            ),
                            Text(
                              type()
                                  ? (lang! ? 'Intervalo' : 'Interval')
                                  : (lang! ? 'Libre' : 'Free'),
                              style: const TextStyle(fontSize: 10),
                            )
                          ],
                        ))
                  ]),
                  TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2026, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      if (_selectionMode == SelectionMode.range) {
                        if (_selectedStartDay != null &&
                            _selectedEndDay != null) {
                          return day.isAfter(_selectedStartDay!
                                  .subtract(const Duration(days: 1))) &&
                              day.isBefore(_selectedEndDay!
                                  .add(const Duration(days: 1)));
                        }
                        return _selectedStartDay == day ||
                            _selectedEndDay == day;
                      } else {
                        return _selectedDays.contains(day);
                      }
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                        if (_selectionMode == SelectionMode.range) {
                          if (_selectedStartDay == null ||
                              _selectedEndDay != null) {
                            _selectedStartDay = selectedDay;
                            _selectedEndDay = null;
                          } else if (selectedDay.isBefore(_selectedStartDay!)) {
                            _selectedStartDay = selectedDay;
                          } else {
                            _selectedEndDay = selectedDay;
                          }
                        } else {
                          if (_selectedDays.contains(selectedDay)) {
                            _selectedDays.remove(selectedDay);
                          } else {
                            _selectedDays.add(selectedDay);
                          }
                        }
                      });
                    },
                    calendarStyle: CalendarStyle(
                      rangeHighlightColor: Colors.blue.withOpacity(0.3),
                      rangeStartDecoration: const BoxDecoration(
                        color: Color.fromARGB(255, 154, 209, 255),
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: const BoxDecoration(
                        color: Color.fromARGB(255, 154, 209, 255),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color.fromARGB(255, 154, 209, 255),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: const BoxDecoration(
                        color: Color.fromARGB(255, 200, 92, 184),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                          context,
                          !type()
                              ? {'dates': _selectedDays}
                              : {
                                  'start': _selectedStartDay,
                                  'end': _selectedEndDay
                                });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.dataset,
                          size: 25,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          lang! ? 'Aceptar fechas' : 'Accept dates',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 22.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.schedule,
                          size: 25,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
