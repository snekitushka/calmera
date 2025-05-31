import 'package:calmera/text_styles.dart';
import 'package:calmera/presentation/widgets/navbar.dart';
import 'package:calmera/presentation/widgets/diary/new_mood.dart';
import 'package:calmera/presentation/widgets/diary/week_calendar.dart';
import 'package:calmera/services/chat_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../services/exercise_service.dart';
import '../services/dairy_service.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  List<Diary> _entries = [];
  List<Diary> _dayEntries = [];
  String _userId = '1'; // Пример UserId
  final DiaryService _diaryService = DiaryService();
  var selectedDate = DateTime.now();
  List<FlSpot> moodData = [
    FlSpot(0, 3),
    FlSpot(1, 0),
    FlSpot(2, 2),
    FlSpot(3, 1),
    FlSpot(4, 4),
    FlSpot(5, 3),
    FlSpot(6, 4),
  ];

  Future<void> _fetchDiaryEntries() async {
    try {
      final entries = await DiaryService.fetchDiaryEntries();

      DateTime weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      DateTime weekEnd = weekStart.add(const Duration(days: 6));

      List<Diary> weekEntries = entries.where((entry) {
        return entry.eventDatetime.isAfter(weekStart.subtract(Duration(seconds: 1))) &&
            entry.eventDatetime.isBefore(weekEnd.add(Duration(days: 1)));
      }).toList();

      Map<int, List<int>> moodPerWeekday = {};

      for (var entry in weekEntries) {
        int weekdayIndex = entry.eventDatetime.weekday - 1;
        int moodLevel = _getMoodLevel(entry.emotionalState);
        moodPerWeekday.putIfAbsent(weekdayIndex, () => []).add(moodLevel);
      }

      List<FlSpot> updatedMoodData = List.generate(7, (index) {
        if (moodPerWeekday.containsKey(index)) {
          final moods = moodPerWeekday[index]!;
          double avgMood = moods.reduce((a, b) => a + b) / moods.length;
          return FlSpot(index.toDouble(), avgMood);
        } else {
          return FlSpot(index.toDouble(), 0);
        }
      });

      setState(() {
        _dayEntries = entries
            .where((entry) => entry.eventDatetime.year == selectedDate.year &&
            entry.eventDatetime.month == selectedDate.month &&
            entry.eventDatetime.day == selectedDate.day)
            .toList()
            .reversed
            .toList();

        moodData = updatedMoodData;
      });
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
    }
  }



  @override
  void initState() {
    super.initState();
    _fetchDiaryEntries();
    initializeDateFormatting('ru_RU', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2C8955),
        title: Text('Дневник эмоций', style: TextStyles.title,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            HorizontalWeekCalendar(
              minDate: DateTime(2024, 12, 31),
              maxDate: DateTime(2026, 1, 31),
              initialDate: DateTime.now(),
              onDateChange: (date) {
                setState(() {
                  selectedDate = date;
                  _fetchDiaryEntries();
                });
              },
              monthFormat: "MMMM yyyy",
              showNavigationButtons: true,
              weekStartFrom: WeekStartFrom.Monday,
              borderRadius: BorderRadius.circular(20),
              activeBackgroundColor: Color(0xFF2C8955),
              activeTextColor: Colors.white,
              inactiveBackgroundColor: Color(0xFF2C8955).withOpacity(.3),
              inactiveTextColor: Colors.white,
              disabledTextColor: Colors.grey,
              disabledBackgroundColor: Colors.grey.withOpacity(.3),
              activeNavigatorColor: Color(0xFF2C8955),
              inactiveNavigatorColor: Colors.grey,
              monthColor: Color(0xFF2C8955),
              onWeekChange: (List<DateTime> dates) {},
              scrollPhysics: const BouncingScrollPhysics(),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Text('${DateFormat('d MMMM', 'ru').format(selectedDate)}', style: TextStyles.subtitle,),
            if (_dayEntries.isNotEmpty)
               ListView.builder(
                 padding: EdgeInsets.only(bottom: 8),
                  shrinkWrap: true,
                  itemCount: _dayEntries.length,
                  itemBuilder: (ctx, index) {
                    final entry = _dayEntries[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.only(bottom: 8)),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFFDDDD),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Card(
                            margin: EdgeInsets.all(2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.black,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(
                                                entry.emotionalState == 'Отлично'
                                                    ? Icons.sentiment_very_satisfied
                                                    : entry.emotionalState == 'Грустно'
                                                    ? Icons.sentiment_dissatisfied
                                                    : entry.emotionalState == 'Ужасно'
                                                    ? Icons.sentiment_very_dissatisfied
                                                    : entry.emotionalState == 'Нормально'
                                                    ? Icons.sentiment_neutral
                                                    : Icons.sentiment_satisfied,
                                                color: entry.emotionalState == 'Отлично'
                                                    ? Colors.green
                                                    : entry.emotionalState == 'Грустно'
                                                    ? Colors.orange
                                                    : entry.emotionalState == 'Ужасно'
                                                    ? Colors.red
                                                    : entry.emotionalState == 'Нормально'
                                                    ? Colors.yellow[600]
                                                    : Colors.lightGreen,
                                                size: 40,
                                              ),
                                              SizedBox(width: 10,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    entry.emotionalState,
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                  ),
                                                  Text(
                                                    DateFormat('HH:mm').format(entry.eventDatetime),
                                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            showAddMoodRecordForm(
                                              context,
                                                  (Diary updatedEntry) async {
                                                setState(() {
                                                  _dayEntries[index] = updatedEntry;

                                                });
                                                await _fetchDiaryEntries();
                                              },
                                              entry,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_forever, color: Colors.red),
                                          onPressed: () {
                                            print('${entry.id}',);
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoAlertDialog(
                                                  title: Text('Удаление записи'),
                                                  content: Text('Вы уверены, что хотите удалить запись?'),
                                                  actions: <Widget>[
                                                    CupertinoDialogAction(
                                                      child: Text('Отмена'),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    CupertinoDialogAction(
                                                      isDestructiveAction: true,
                                                      child: Text('Удалить'),
                                                      onPressed: () async {
                                                        Navigator.of(context).pop();
                                                        await DiaryService.deleteDiaryEntry(entry.id!);
                                                        await _fetchDiaryEntries();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Запись удалена')),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyles.body,
                                        children: [
                                          TextSpan(
                                            text: 'Эмоции: ',
                                            style: TextStyles.body!.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: entry.mood,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 3,),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyles.body,
                                        children: [
                                          TextSpan(
                                            text: 'Ситуация: ',
                                            style: TextStyles.body!.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: entry.situation,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 3,),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyles.body,
                                        children: [
                                          TextSpan(
                                            text: 'Мысли: ',
                                            style: TextStyles.body!.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: entry.thoughts,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ]
                            ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('График настроения', style: TextStyles.subtitle,)),
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFFDDDD),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                        Icon(Icons.sentiment_very_satisfied, color: Colors.green),
                        Icon(Icons.sentiment_satisfied, color: Colors.lightGreen),
                        Icon(Icons.sentiment_neutral, color: Colors.yellow[600]),
                        Icon(Icons.sentiment_dissatisfied, color: Colors.orange),
                        Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
                        Padding(padding: EdgeInsets.only(bottom: 7))
                      ]
                  ),
                  Padding(padding: EdgeInsets.only(left: 16)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: SideTitles(showTitles: false),
                            bottomTitles: SideTitles(showTitles: true, getTitles: (value) {
                              switch (value.toInt()) {
                                case 0:
                                  return 'Пн';
                                case 1:
                                  return 'Вт';
                                case 2:
                                  return 'Ср';
                                case 3:
                                  return 'Чт';
                                case 4:
                                  return 'Пт';
                                case 5:
                                  return 'Сб';
                                case 6:
                                  return 'Вс';
                                default:
                                  return '';
                              }
                            }),
                          ),
                          borderData: FlBorderData(show: true),
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          maxY: 4,
                          lineBarsData: [
                            LineChartBarData(
                              spots: moodData,
                              isCurved: false,
                              colors: [Color(0xFF2C8955)],
                              barWidth: 5,
                              belowBarData: BarAreaData(show: true, colors: [Color(0xFF2C8955).withOpacity(0.3)]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddMoodRecordForm(context, (Diary newEntry) async {
          setState(() {
            _entries.add(newEntry);
          }
          );
          await _fetchDiaryEntries();
        }, null,), //context.pushNamed(AppRoute.addRecord.name),
        child: const Icon(Icons.add_outlined, color: Colors.white, size: 50,),
        backgroundColor: Color(0xFF2C8955),
        shape: CircleBorder(),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

int _getMoodLevel(String emotionalState) {
  switch (emotionalState) {
    case 'Отлично':
      return 4;
    case 'Хорошо':
      return 3;
    case 'Нормально':
      return 2;
    case 'Грустно':
      return 1;
    default:
      return 0;
  }
}