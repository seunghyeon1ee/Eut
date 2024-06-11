import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Statistics extends StatelessWidget {
  @override
    Widget build(BuildContext context) {
    return StatisticsScreen();
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 화면을 터치하면 키보드를 닫음
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(140.0),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: Padding(
                padding: EdgeInsets.only(top: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      SvgPicture.asset('assets/icon_eut.svg', height: 80),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                labelColor: Colors.black,
                indicatorColor: Color(0xFF8F8F8F),
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                tabs: [
                  Tab(text: "오늘"),
                  Tab(text: "이번 주"),
                  Tab(text: "이번 달"),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              DayView(),
              WeekView(),
              MonthView(),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------


class DayView extends StatefulWidget {
  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  final DateTime today = DateTime.now();
  bool isLoading = true;
  Map<String, dynamic> apiData = {};

  Future<void> fetchData() async {
    // DateTime 객체를 yyyy-MM-dd 형식의 문자열로 변환
    String date = today.toIso8601String().split('T')[0];
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? accessToken = prefs.getString('access_token');  // 액세스 토큰은 안전하게 관리하고 있어야 합니다.
    print('today: $date');
    final response = await http.get(
      Uri.parse('http://54.180.229.143:8080/api/v1/stat/daily?date=$date'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',  // Authorization 헤더 추가
      },
    );

    print(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      if (responseData['code'] == "0000" && responseData['message'] == "SUCCESS") {
        setState(() {
          apiData = responseData['result'];
          isLoading = false;
        });
      } else {
        throw Exception('Data fetch was successful but returned an unexpected code or message');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    List<String> morningConversations = List<String>.from(apiData['summaryDay']);


    List<String> afternoonConversations = List<String>.from(apiData['summaryEvening']);

    int _currentPage = 0;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "정우정 님의",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "\n하루를 요약 해드릴게요!",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            ExpandablePageView.builder(
              itemCount: 2,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                List<String> conversations = index == 0 ? morningConversations : afternoonConversations;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: conversations.length,
                    itemBuilder: (context, i) {
                      return ConversationSummaryWidget(
                        title: index == 0 ? '오전에 나눈 대화' : '오후에 나눈 대화',
                        details: conversations
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.0),
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.pinkAccent : Colors.grey,
                  ),
                );
              }),
            ),
            SizedBox(height: 10),
            ScreenTimeSummary(today: today),
            SizedBox(height: 3),
            MoodRanking(),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------------

class ScreenTimeSummary extends StatefulWidget {
  final DateTime today;

  ScreenTimeSummary({required this.today});

  @override
  _ScreenTimeSummaryState createState() => _ScreenTimeSummaryState();
}

class _ScreenTimeSummaryState extends State<ScreenTimeSummary> {
  bool isLoading = true;
  Map<String, int> dailyScreenTime = {};
  int totalScreenTimeSecond = 0;
  String? selectedTime;

  Future<void> fetchData() async {
    // DateTime 객체를 yyyy-MM-dd 형식의 문자열로 변환
    String date = widget.today.toIso8601String().split('T')[0];
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? accessToken = prefs.getString('access_token');  // 액세스 토큰은 안전하게 관리하고 있어야 합니다.

    final response = await http.get(
      Uri.parse('http://54.180.229.143:8080/api/v1/stat/daily?date=$date'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',  // Authorization 헤더 추가
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['code'] == "0000" && responseBody['message'] == "SUCCESS") {
        // 데이터 처리
        setState(() {
          dailyScreenTime = Map<String, int>.from(responseBody['result']['dailyScreenTime']);
          totalScreenTimeSecond = responseBody['result']['totalScreenTimeSecond'];
          isLoading = false;
        });
      } else {
        throw Exception('Data fetch was successful but returned an unexpected code or message: ${responseBody['message']}');
      }
    } else {
      throw Exception('Failed to load data, status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showTooltip(String message) {
    setState(() {
      selectedTime = message;
    });
  }

  void _clearTooltip() {
    setState(() {
      selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    double totalHours = totalScreenTimeSecond / 3600;  // 총 스크린 타임을 시간 단위로 변환
    List<double> screenTimes = dailyScreenTime.values.map((e) => e / 60).toList();  // 초를 분으로 변환

    return GestureDetector(
      onTap: () {
        _clearTooltip();
        FocusScope.of(context).unfocus(); // 키보드를 숨김
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "총 스크린 타임",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${totalHours.floor()}시간 ${((totalHours - totalHours.floor()) * 60).round()}분",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: ShapeDecoration(
                      color: Colors.transparent, // 배경색을 투명으로 설정
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Colors.pinkAccent),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "오늘, ${widget.today.month}월 ${widget.today.day}일",
                      style: TextStyle(fontSize: 14, color: Colors.pinkAccent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (selectedTime != null)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // 배경색을 투명으로 설정
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey, // 테두리 색상
                      width: 1, // 테두리 두께
                    ),
                  ),
                  child: Text(
                    selectedTime!,
                    style: TextStyle(fontSize: 14, color: Colors.grey), // 텍스트 색상을 회색으로 설정
                  ),
                ),
              SizedBox(height: 16),
              Container(
                height: 150,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 120,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback: (barTouchResponse) {
                        if (barTouchResponse != null && barTouchResponse.spot != null) {
                          final spot = barTouchResponse.spot!;
                          final index = spot.touchedBarGroupIndex;
                          final timeLabel = _getTimeLabel(index);
                          final minutes = screenTimes[index];
                          final message = "$timeLabel: ${minutes.round()}분 사용";
                          _showTooltip(message);
                        } else {
                          _clearTooltip(); // 터치된 막대가 없으면 시간 박스를 사라지게 함
                        }
                      },
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return null;
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: SideTitles( // 왼쪽 타이틀 비활성화
                        showTitles: false,
                      ),
                      rightTitles: SideTitles( // 오른쪽 타이틀
                        showTitles: true,
                        getTextStyles: (value) => const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        margin: 8,
                        interval: 30,
                        getTitles: (double value) {
                          if (value == 0) return '0분';
                          if (value == 30) return '30분';
                          if (value == 60) return '60분';
                          if (value == 90) return '90분';
                          if (value == 120) return '120분';
                          return '';
                        },
                      ),
                      bottomTitles: SideTitles( // 아래쪽 타이틀
                        showTitles: true,
                        getTextStyles: (value) => const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        margin: 8,
                        getTitles: (double value) {
                          switch (value.toInt()) {
                            case 0:
                              return '오전 12시';
                            case 3:
                              return '오전 6시';
                            case 6:
                              return '오후 12시';
                            case 9:
                              return '오후 6시';
                            default:
                              return '';
                          }
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true, // 세로선 그리기
                      horizontalInterval: 30,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        if (value.toInt() == 0 || value.toInt() == 3 || value.toInt() == 6 || value.toInt() == 9) {
                          return FlLine(
                            color: Colors.grey,
                            strokeWidth: 1,
                            dashArray: [5, 5], // 세로선 점선
                          );
                        }
                        return FlLine(
                          color: Colors.transparent,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: screenTimes
                        .asMap()
                        .entries
                        .map(
                          (entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            y: entry.value,
                            colors: [Colors.redAccent],
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // index를 받아서 해당 시간대를 반환하는 함수
  String _getTimeLabel(int index) {
    switch (index) {
      case 0:
        return "오전 12시 ~ 오전 2시";
      case 1:
        return "오전 2시 ~ 오전 4시";
      case 2:
        return "오전 4시 ~ 오전 6시";
      case 3:
        return "오전 6시 ~ 오전 8시";
      case 4:
        return "오전 8시 ~ 오전 10시";
      case 5:
        return "오전 10시 ~ 오전 12시";
      case 6:
        return "오후 12시 ~ 오후 2시";
      case 7:
        return "오후 2시 ~ 오후 4시";
      case 8:
        return "오후 4시 ~ 오후 6시";
      case 9:
        return "오후 6시 ~ 오후 8시";
      case 10:
        return "오후 8시 ~ 오후 10시";
      case 11:
        return "오후 10시 ~ 오전 12시";
      default:
        return "";
    }
  }
}

// ------------------------------------------------------------------------------------


class WeekView extends StatefulWidget {
  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  final DateTime today = DateTime.now();
  bool isLoading = true;
  Map<String, dynamic>? weeklyData;

  @override
  void initState() {
    super.initState();
    fetchWeeklyData();
  }

  Future<void> fetchWeeklyData() async {
    String date = today.toIso8601String().split('T')[0]; // 'yyyy-mm-dd' 형식으로 날짜를 얻음
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');  // 액세스 토큰은 안전하게 관리하고 있어야 합니다.

    final response = await http.get(
        Uri.parse('http://54.180.229.143:8080/api/v1/stat/weekly?date=$date'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json; charset=UTF-8', // 추가된 헤더
        }
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['code'] == "0000" && responseBody['message'] == "SUCCESS") {
        // 데이터 처리
        setState(() {
          weeklyData = responseBody['result'];
          isLoading = false;
        });
      } else {
        throw Exception('Data fetch was successful but returned an unexpected code or message: ${responseBody['message']}');
      }
    } else {
      throw Exception('Failed to load weekly data, status code: ${response.statusCode}');
    }
  }

  List<String> _generateWeekDays() {
    List<String> weekDays = [];
    for (int i = 6; i >= 0; i--) {
      DateTime day = today.subtract(Duration(days: i));
      if (day.weekday == today.weekday) {
        weekDays.add('오늘');
      } else {
        weekDays.add(_getWeekdayLabel(day.weekday));
      }
    }
    return weekDays;
  }

  String _getWeekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '월';
      case DateTime.tuesday:
        return '화';
      case DateTime.wednesday:
        return '수';
      case DateTime.thursday:
        return '목';
      case DateTime.friday:
        return '금';
      case DateTime.saturday:
        return '토';
      case DateTime.sunday:
        return '일';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    List<String> xLabels = _generateWeekDays();
    List<double> screenTimeWeekly = weeklyData!['screenTimeWeekly'].map((e) => e as Map<String, dynamic>).map((key, value) => value).toList();
    List<double> negativeExpRate = weeklyData!['negativeExpRate'].map((e) => e as Map<String, dynamic>).map((key, value) => value).toList();


    double avgHours = weeklyData!['avgUsageTimeSecond'] / 3600.0;
    String topEmotion = weeklyData!['avgEmotion']['maxScore'].keys.first;
    double topEmotionScore = weeklyData!['avgEmotion']['maxScore'][topEmotion];

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('assets/${topEmotion}.png'),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "부모 님은",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "$topEmotion한 한 주를 보내셨습니다!",
                                  style: TextStyle(fontSize: 12, color: Colors.pinkAccent),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to detailed view
                                  },
                                  child: Text(
                                    "대화내용을 확인해보세요.",
                                    style: TextStyle(fontSize: 12, color: Colors.blueAccent, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '최근 7일 동안 하루 평균 ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        TextSpan(
                          text: '${avgHours.toStringAsFixed(1)}시간',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        TextSpan(
                          text: '을 대화하셨습니다.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    '이번주는 지난주보다 ${weeklyData!['changeUsageTimeSecond']}초 더 대화하셨어요.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: LineChartWidget(
                title: Text(' '),
                data: screenTimeWeekly,
                xLabels: xLabels,
                yInterval: 2,
                yMax: 12,
                showGradient: true,
                gradientColors: [Colors.pink.withOpacity(0.5), Colors.pink.withOpacity(0.0)],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: LineChartWidget(
                title: Text('이번주 부정 표현 사용 비율입니다.'),
                data: negativeExpRate,
                xLabels: xLabels,
                yInterval: 30,
                yMax: 100,
                showGradient: true,
                gradientColors: [Colors.pink.withOpacity(0.5), Colors.pink.withOpacity(0.0)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
class MonthView extends StatefulWidget {
  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  DateTime now = DateTime.now();
  DateTime startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endOfMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  Map<String, dynamic>? monthlyData;

  @override
  void initState() {
    super.initState();
    fetchMonthlyData();
  }


  Future<void> fetchMonthlyData() async {
    String date = startOfMonth.toIso8601String().split('T')[0]; // 'yyyy-mm-dd' 형식으로 날짜를 얻음
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');  // 액세스 토큰은 안전하게 관리하고 있어야 합니다.

    final response = await http.get(
      Uri.parse('http://54.180.229.143:8080/api/v1/stat/monthly?date=$date'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',  // Authorization 헤더 추가
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['code'] == "0000" && responseBody['message'] == "SUCCESS") {
        // 데이터 처리
        setState(() {
          monthlyData = responseBody['result'];
        });
      } else {
        throw Exception('Data fetch was successful but returned an unexpected code or message: ${responseBody['message']}');
      }
    } else {
      throw Exception('Failed to load monthly data, status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (monthlyData == null) {
      return Center(child: CircularProgressIndicator());
    }

    int avgUsageTimeSecond = monthlyData!['avgUsageTimeSecond'];
    int changeUsageTimeSecond = monthlyData!['changeUsageTimeSecond'];

    double avgHours = avgUsageTimeSecond / 3600;
    double prevMonthAvgHours = (avgUsageTimeSecond - changeUsageTimeSecond) / 3600;
    double difference = avgHours - prevMonthAvgHours;
    String differenceText = difference > 0 ? '더 대화했어요.' : '덜 대화했어요.';

    List<double> screenTimeMonthlyInHours = monthlyData!['screenTimeMonthly'].map((e) => e as Map<String, dynamic>).map((key, value) => value as double).toList();
    List<double> negativeExpRate = monthlyData!['negativeExpRate'].values.map<double>((rate) => rate.toDouble()).toList();
    Map<String, dynamic> avgEmotion = monthlyData!['avgEmotion'];
    String topEmotion = avgEmotion.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final Map<String, String> emotionImages = {
      '걱정': 'assets/worried.png',
      '불안': 'assets/anxious.png',
      '행복': 'assets/happy.png',
      '분노': 'assets/angry.png',
      '당황': 'assets/confused.png',
      '슬픔': 'assets/sad.png',
      '혐오': 'assets/disgusted.png',
      '중립': 'assets/neutral.png',
    };

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(emotionImages[topEmotion]!),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "부모 님은",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "$topEmotion 한 한달을 보내셨습니다!",
                                  style: TextStyle(fontSize: 14, color: Colors.pinkAccent),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailedMonthlyConversationView(emotionData: avgEmotion, emotionImages: emotionImages)),
                                    );
                                  },
                                  child: Text(
                                    "대화내용을 확인해보세요.",
                                    style: TextStyle(fontSize: 14, color: Colors.blueAccent, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: LineChartWidget(
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '이번달 동안 하루 평균 ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                        text: '${avgHours.toStringAsFixed(1)}시간',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      TextSpan(
                        text: '을 대화하셨습니다.\n이번달은 지난달 보다 ${difference.abs().toStringAsFixed(1)}시간 ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      TextSpan(
                        text: differenceText,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: difference > 0 ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                ),
                data: screenTimeMonthlyInHours,
                xLabels: ['1주', '2주', '3주', '4주', '5주'],
                yInterval: 2,
                yMax: 12,
                showGradient: true,
                gradientColors: [Colors.pink, Color(0x00FFFFFF)],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: LineChartWidget(
                title: Text('부정표현 사용 비율', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                data: negativeExpRate,
                xLabels: ['1주', '2주', '3주', '4주', '5주'],
                yInterval: 30,
                yMax: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------

class ConversationSummaryWidget extends StatefulWidget {
  final String title;
  final List<String> details;

  ConversationSummaryWidget({
    required this.title,
    required this.details,
  });

  @override
  _ConversationSummaryWidgetState createState() => _ConversationSummaryWidgetState();
}

class _ConversationSummaryWidgetState extends State<ConversationSummaryWidget> {
  bool _isExpanded = false;
  final Color defaultTextColor = Colors.black; // 기본 텍스트 색상

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (bool expanding) => setState(() => _isExpanded = expanding),
        title: ListTile(
          title: Text(
            widget.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('widget.date'),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14),
                  SizedBox(width: 4),
                  Text('widget.time'),
                ],
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "상세 대화내용",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: defaultTextColor, // 기본 색상 사용
                    ),
                  ),
                  SizedBox(height: 10),
                  ...widget.details.map((detail) => Text("• $detail", style: TextStyle(color: defaultTextColor))).toList(),
                  SizedBox(height: 10), // 간격 추가
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('widget.date', style: TextStyle(color: defaultTextColor)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14),
                          SizedBox(width: 4),
                          Text('widget.time', style: TextStyle(color: defaultTextColor)),
                        ],
                      ),
                    ],
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

// --------------------------------------------------------------


class MoodRanking extends StatelessWidget {
  // 감정에 따른 이미지 경로 맵핑
  final Map<String, String> emotionImages = {
    '걱정': 'assets/worried.png',
    '불안': 'assets/anxious.png',
    '행복': 'assets/happy.png',
    '분노': 'assets/angry.png',
    '당황': 'assets/confused.png',
    '슬픔': 'assets/sad.png',
    '혐오': 'assets/disgusted.png',
    '중립': 'assets/neutral.png', // 중립 추가
  };

  Future<List<Map<String, dynamic>>> fetchEmotionData() async {
    String date = '2024-06-12';
    // String date = DateTime.now().toIso8601String().split('T')[0]; // 오늘 날짜를 yyyy-mm-dd 형식으로 변환
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');  // 저장된 액세스 토큰을 가져옵니다.

    final response = await http.get(
        Uri.parse('http://54.180.229.143:8080/api/v1/stat/daily?date=$date'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken', // 액세스 토큰을 사용하여 Authorization 헤더를 설정합니다.
          'Content-Type': 'application/json; charset=UTF-8', // 추가된 헤더
        }
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      if (responseBody['code'] == "0000" && responseBody['message'] == "SUCCESS") {
        // 데이터 처리
        final data = responseBody['result']['sentimentAnalysis'];
        return List<Map<String, dynamic>>.from(data.map((item) => {
          'percentage': item['score'],
          'emotion': item['label'],
        }));
      } else {
        throw Exception('Data fetch was successful but returned an unexpected code or message: ${responseBody['message']}');
      }
    } else {
      throw Exception('Failed to load emotion data, status code: ${response.statusCode}');
    }
  }

  Color getMarkerColor(String emotion) {
    return (emotion == '행복' || emotion == '중립' || emotion == '당황') ? Color(0x60FF7672) : Color(0xFFEC295D);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchEmotionData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        List<Map<String, dynamic>> emotionData = snapshot.data!;
        emotionData.sort((a, b) => b['percentage'].compareTo(a['percentage']));
        List<Map<String, dynamic>> topThreeEmotions = emotionData.take(3).toList();

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '기분을 확인해보세요!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedEmotionStatisticsView(
                            emotionData: emotionData,
                            emotionImages: emotionImages,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      '더 알아보기 >',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: topThreeEmotions.map((data) {
                    Color boxColor = getMarkerColor(data['emotion']);
                    Color textColor = Colors.white;
                    return EmotionWidget(
                      percentage: data['percentage'].toInt(),
                      emotion: data['emotion'],
                      imagePath: emotionImages[data['emotion']]!,
                      textColor: textColor,
                      boxColor: boxColor,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EmotionWidget extends StatelessWidget {
  final int percentage;
  final String emotion;
  final String imagePath;
  final Color textColor;
  final Color boxColor;

  const EmotionWidget({
    Key? key,
    required this.percentage,
    required this.emotion,
    required this.imagePath,
    required this.textColor,
    required this.boxColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Column(
        children: [
          Text(
            '$percentage%',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
          ),
          SizedBox(height: 5),
          Image.asset(imagePath, height: 50), // PNG 이미지 로드
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              emotion,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailedEmotionStatisticsView extends StatelessWidget {
  final List<Map<String, dynamic>> emotionData;
  final Map<String, String> emotionImages;

  DetailedEmotionStatisticsView({required this.emotionData, required this.emotionImages});

  Color getMarkerColor(String emotion) {
    return (emotion == '행복' || emotion == '중립' || emotion == '당황') ? Color(0x60FF7672) : Color(0xFFEC295D);
  }

  @override
  Widget build(BuildContext context) {
    emotionData.sort((a, b) => b['percentage'].compareTo(a['percentage']));
    String topEmotion = emotionData[0]['emotion'];

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('상세 감정통계')), // 제목 가운데 정렬
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32), // 제목과 텍스트 사이 간격 조정
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '오늘 하루 ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: '$topEmotion',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                    ),
                    TextSpan(
                      text: '이 많으셨네요.\n전화통화를 추천드려요!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 32), // 텍스트와 순위 사이 간격 조정
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: emotionData.take(3).map((data) {
                  Color boxColor = getMarkerColor(data['emotion']);
                  Color textColor = Colors.white;
                  return EmotionWidget(
                    percentage: data['percentage'].toInt(),
                    emotion: data['emotion'],
                    imagePath: emotionImages[data['emotion']]!,
                    textColor: textColor,
                    boxColor: boxColor,
                  );
                }).toList(),
              ),
              SizedBox(height: 32), // 순위와 EmotionBar 사이 간격 조정
              ..._buildEmotionBars(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEmotionBars() {
    return emotionData.map((data) {
      Color boxColor = getMarkerColor(data['emotion']);
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: boxColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data['emotion'],
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Text(
              '${data['percentage']}%',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      );
    }).toList();
  }
}


//----------------------------------------------------------------------------

class EmotionBar extends StatelessWidget {
  final String emotion;
  final int percentage;

  const EmotionBar({Key? key, required this.emotion, required this.percentage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0), // EmotionBar들 간 간격 조정
      child: Row(
        children: [
          Text(emotion, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(width: 19),
          Expanded(
            child: SizedBox(
              height: 19, // 두께 조정
              child: LinearProgressIndicator(
                value: percentage / 100.0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
              ),
            ),
          ),
          SizedBox(width: 10),
          Text('$percentage%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
        ],
      ),
    );
  }
}

class DetailedWeeklyConversationView extends StatefulWidget {
  final List<Map<String, dynamic>> emotionData;

  DetailedWeeklyConversationView({required this.emotionData});

  @override
  _DetailedWeeklyConversationViewState createState() => _DetailedWeeklyConversationViewState();
}

class _DetailedWeeklyConversationViewState extends State<DetailedWeeklyConversationView> {
  int selectedDayIndex = DateTime.now().weekday - 1;
  DateTime selectedDay = DateTime.now();

  List<List<Map<String, dynamic>>> weeklyConversations = [];

  @override
  void initState() {
    super.initState();
    fetchWeeklyData();
  }

  Future<void> fetchWeeklyData() async {
    String date = selectedDay.toIso8601String().split('T')[0]; // 'yyyy-mm-dd' 형식으로 날짜를 얻음
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');  // 액세스 토큰은 안전하게 관리하고 있어야 합니다.

    final response = await http.get(
        Uri.parse('http://54.180.229.143:8080/api/v1/stat/weekly?date=$date'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',  // Authorization 헤더 추가
          'Content-Type': 'application/json; charset=UTF-8', // 추가된 헤더
        }
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['code'] == "0000" && responseBody['message'] == "SUCCESS") {
        // 데이터 처리
        setState(() {
          weeklyConversations = parseWeeklyConversations(responseBody['result']['weeklyConversations']);
        });
      } else {
        throw Exception('Data fetch was successful but returned an unexpected code or message: ${responseBody['message']}');
      }
    } else {
      throw Exception('Failed to load weekly data, status code: ${response.statusCode}');
    }
  }

  List<List<Map<String, dynamic>>> parseWeeklyConversations(Map<String, dynamic> data) {
    // 예시: 주간 대화 데이터를 파싱하여 리스트로 변환
    return [
      data['mon'],
      data['tue'],
      data['wed'],
      data['thu'],
      data['fri'],
      data['sat'],
      data['sun'],
    ].map((conversations) {
      return List<Map<String, dynamic>>.from(conversations.map((conversation) => {
        'title': conversation['title'],
        'date': conversation['date'],
        'duration': conversation['duration'],
        'details': List<String>.from(conversation['details']),
      }));
    }).toList();
  }

  List<Map<String, dynamic>> getConversationsForSelectedDay() {
    if (selectedDayIndex < weeklyConversations.length) {
      return weeklyConversations[selectedDayIndex];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    DateTime startOfWeek = selectedDay.subtract(Duration(days: selectedDay.weekday - 1));
    List<DateTime> weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Scaffold(
      appBar: AppBar(
        title: Text('주간 요약 정보'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDayIndex = index;
                        selectedDay = weekDays[index];
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          ['월', '화', '수', '목', '금', '토', '일'][index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selectedDayIndex == index
                                ? Colors.pinkAccent
                                : weekDays[index].day == DateTime.now().day &&
                                weekDays[index].month == DateTime.now().month &&
                                weekDays[index].year == DateTime.now().year
                                ? Colors.green
                                : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${weekDays[index].day}',
                              style: TextStyle(
                                color: selectedDayIndex == index ? Colors.white : Colors.black,
                                fontWeight: selectedDayIndex == index ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        if (index < weeklyConversations.length && weeklyConversations[index].isNotEmpty)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: ['행복', '중립', '당황'].any(
                                      (emotion) => weeklyConversations[index]
                                      .map((conversation) => (conversation['details'] as List<String>).join(' '))
                                      .reduce((value, element) => value.length > element.length ? value : element)
                                      .contains(emotion)
                              ) ? Color(0x60FF7672) : Color(0xFFEC295D),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일 (${['월', '화', '수', '목', '금', '토', '일'][selectedDayIndex]})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: getConversationsForSelectedDay().map((conversation) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ConversationSummaryWidget(
                          title: conversation['title'],
                          details: List<String>.from(conversation['details']),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getMarkerColor(String emotion) {
    return (emotion == '행복' || emotion == '중립' || emotion == '당황') ? Color(0x60FF7672) : Color(0xFFEC295D);
  }
}

class StatCard extends StatelessWidget {
  final String label; // 카드의 레이블 텍스트
  final int percentage; // 백분율 값
  final Color color; // 색상

  const StatCard({Key? key, required this.label, required this.percentage, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 카드의 외부 여백 설정
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color, // 원형 아바타의 배경색 설정
          child: Text('$percentage%', style: TextStyle(color: Colors.white)), // 백분율 텍스트 표시
        ),
        title: Text(label), // 카드의 제목 텍스트 설정
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0), // 상단 여백 설정
          child: LinearProgressIndicator(
            value: percentage / 100, // 진행률 값 설정
            backgroundColor: Colors.grey[200], // 진행 바의 배경색 설정
            valueColor: AlwaysStoppedAnimation<Color>(color), // 진행 바의 색상 설정
          ),
        ),
      ),
    );
  }
}

//-------------------------------------------------------------------------------

class LineChartWidget extends StatelessWidget {
  final Text title;
  final List<double> data;
  final List<String> xLabels;
  final double yInterval;
  final double yMax;
  final bool showGradient;
  final List<Color> gradientColors;

  const LineChartWidget({
    Key? key,
    required this.title,
    required this.data,
    required this.xLabels,
    required this.yInterval,
    required this.yMax,
    this.showGradient = true,
    this.gradientColors = const [Colors.pink, Color(0x00FFFFFF)],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: yInterval,
              ),
              titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: true,
                  interval: yInterval,
                  getTitles: (value) {
                    return value.toInt().toString();
                  },
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) {
                    if (value.toInt() < xLabels.length) {
                      return xLabels[value.toInt()];
                    } else {
                      return '';
                    }
                  },
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xCCCCCC)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: data
                      .map((e) => FlSpot(e, e ))
                      .toList(),
                  isCurved: false,
                  colors: [Colors.pink],
                  barWidth: 3,
                  isStrokeCapRound: false,
                  dotData: FlDotData(show: true),
                  belowBarData: showGradient
                      ? BarAreaData(
                    show: true,
                    gradientColorStops: [0.2, 1],
                    gradientFrom: Offset(0, 0),
                    gradientTo: Offset(0, 1),
                    colors: gradientColors,
                  )
                      : BarAreaData(show: false),
                ),
              ],
              minY: 0,
              maxY: yMax,
            ),
          ),
        ),
      ],
    );
  }
}

//--------------------------------------------------------------------------

class DetailedMonthlyConversationView extends StatefulWidget {
  final Map<String, dynamic> emotionData;
  final Map<String, dynamic> emotionImages;

  DetailedMonthlyConversationView({required this.emotionData, required this.emotionImages});

  @override
  _DetailedMonthlyConversationViewState createState() => _DetailedMonthlyConversationViewState();
}

class _DetailedMonthlyConversationViewState extends State<DetailedMonthlyConversationView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<int, bool> _expandedStates = {};  // 확장 상태를 관리하는 맵

  List<Map<String, dynamic>> dailyNegativityRatioList=[];

  @override
  void initState() {
    super.initState();
    fetchMonthlyData();
  }

  void fetchMonthlyData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');  // 액세스 토큰은 안전하게 관리하고 있어야 합니다.

    final response = await http.get(
        Uri.parse('http://54.180.229.143:8080/api/v1/stat/calendar?month=${_focusedDay.month}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',  // Authorization 헤더 추가
          'Content-Type': 'application/json; charset=UTF-8', // 추가된 헤더
        }
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['code'] == "0000" && responseBody['message'] == "SUCCESS") {
        // 데이터 처리
        setState(() {
          dailyNegativityRatioList = responseBody['result']['dailyNegativityRatioList'];
        });
      } else {
        throw Exception('Data fetch was successful but returned an unexpected code or message: ${responseBody['message']}');
      }
    } else {
      throw Exception('Failed to load monthly data, status code: ${response.statusCode}');
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // 대화 데이터를 이 함수에서 처리
    return dailyNegativityRatioList
        .where((event) => DateTime.parse(event['date']).day == day.day)
        .toList();
  }

  void _toggleExpanded(int index) {
    setState(() {
      _expandedStates[index] = !_expandedStates.containsKey(index) || !_expandedStates[index]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // widget.emotionData.sort((a, b) => b['percentage'].compareTo(a['percentage']));
    String topEmotion = widget.emotionData[0]['emotion'];

    return Scaffold(
      appBar: AppBar(
        title: Text('월간 요약 정보'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
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
              calendarFormat: CalendarFormat.month,
              eventLoader: _getEventsForDay,
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // TableCalendar 위젯의 헤더에 있는 포맷 변경 버튼의 가시성을 제어
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,  // 달력에서의 오늘을 날짜에 대한 데이터
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  shape: BoxShape.circle,  // 달력에서의 내가 선택한 날짜 데이터
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
            const SizedBox(height: 8.0),
            if (_selectedDay != null) ...[ // _selectedDay가 null이 아니면 실행
              Padding(
                padding: const EdgeInsets.all(16.0), // 모든 방향에 16.0의 패딩 추가
                child: Align(
                  alignment: Alignment.centerLeft, // 왼쪽 정렬
                  child: Text(
                    '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일', // 선택된 날짜를 표시
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // 텍스트 스타일 설정
                  ),
                ),
              ),
              ..._getEventsForDay(_selectedDay!).asMap().entries.map((entry) { // 선택된 날짜의 이벤트를 가져와서 맵핑
                int index = entry.key; // 현재 이벤트의 인덱스
                var event = entry.value; // 현재 이벤트 데이터
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // 수직 8.0, 수평 16.0 패딩 추가
                  child: ConversationCard(
                    title: event['title']!, // 이벤트 제목
                    date: event['date']!, // 이벤트 날짜
                    duration: event['duration']!, // 이벤트 지속 시간
                    details: event['details'] ?? '', // 이벤트 세부 내용 (없으면 빈 문자열)
                    isExpanded: _expandedStates[index] ?? false, // 확장 상태
                    onTap: () => _toggleExpanded(index), // 카드 탭 시 확장/축소 상태 변경 함수 호출
                  ),
                );
              }).toList(), // 맵핑된 이벤트 리스트를 반환
            ],
          ],
        ),
      ),
    );
  }
}

class ConversationCard extends StatelessWidget {
  final String title;
  final String date;
  final String duration;
  final List<String> details; // 수정된 부분
  final bool isExpanded;
  final VoidCallback onTap;

  const ConversationCard({
    Key? key,
    required this.title,
    required this.date,
    required this.duration,
    required this.details,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14),
                    SizedBox(width: 4),
                    Text(duration),
                  ],
                ),
              ],
            ),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: onTap,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: details.map((detail) => Text(detail)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}