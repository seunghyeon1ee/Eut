import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


  
  class Screentime extends StatefulWidget {
  @override
  State<Screentime> createState() => _ScreentimeState();
}

class _ScreentimeState extends State<Screentime> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<int, bool> _expandedStates = {};  // 확장 상태를 관리하는 맵

  void _toggleExpanded(int index) {
    setState(() {
      _expandedStates[index] = !_expandedStates.containsKey(index) || !_expandedStates[index]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20),
          child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 350, height: 500,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4.50,
                    offset: Offset(3, 3),
                    spreadRadius: 0,
                  )
                ],
          ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _expandedStates.clear();  // 새로운 날짜를 선택할 때 확장 상태 초기화
                  });
                },
                calendarFormat: CalendarFormat.week,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false, // TableCalendar 위젯의 헤더에 있는 포맷 변경 버튼의 가시성을 제어
                  titleCentered: true,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(50)),// 달력에서의 오늘을 날짜에 대한 데이터
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(20), right: Radius.circular(100)),// 달력에서의 내가 선택한 날짜 데이터
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      String topEmotion = '행복';
                      topEmotion = events
                          .map((event) => (event as Map<String, dynamic>)['details'] as String)
                          .reduce((value, element) => value.length > element.length ? value : element);
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 0.3),
                        decoration: BoxDecoration(
                          color: (topEmotion == '행복' || topEmotion =='중립' || topEmotion == '당황')? Color(0x60FF7672) : Color(0xFFEC295D),
                          shape: BoxShape.circle,
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
    ),
        ],
      ),
      ),
      ),
    );
  }
}