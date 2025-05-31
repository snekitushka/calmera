import 'package:calmera/presentation/widgets/green_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/dairy_service.dart';
import '../../../text_styles.dart';
import '../input_field.dart';

class AddMoodRecordForm extends StatefulWidget {
  final void Function(Diary) onSubmit;
  final Diary? initialEntry;

  const AddMoodRecordForm({super.key, required this.onSubmit, this.initialEntry,});

  @override
  _AddMoodRecordFormState createState() => _AddMoodRecordFormState();
}

class _AddMoodRecordFormState extends State<AddMoodRecordForm> {
  final _formKey = GlobalKey<FormState>();
  int selected = 0;
  String _selectedEmotion = 'Нормально';
  String _description = '';
  String _situation = '';
  String _thoughts = '';
  DateTime _time = DateTime.now() ;

  @override
  void initState() {
    super.initState();
    if (widget.initialEntry != null) {
      final entry = widget.initialEntry!;
      _time = entry.eventDatetime;
      _selectedEmotion = entry.emotionalState;
      _description = entry.mood;
      _situation = entry.situation;
      _thoughts = entry.thoughts;

      switch (_selectedEmotion) {
        case 'Отлично': selected = 5; break;
        case 'Хорошо': selected = 4; break;
        case 'Нормально': selected = 3; break;
        case 'Грустно': selected = 2; break;
        case 'Ужасно': selected = 1; break;
      }
    }
  }

  Future<void> updateTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );

    if (selectedTime != null) {
      setState(() {
        _time = DateTime(
          _time.year,
          _time.month,
          _time.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  Future<void> updateDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime.fromMillisecondsSinceEpoch(1),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _time = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          _time.hour,
          _time.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 60,
            child: CupertinoDatePicker(
              initialDateTime: _time,
              use24hFormat: true,
              onDateTimeChanged: (value) {
                _time = value;
              },
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selected = 5;
                    _selectedEmotion = 'Отлично';
                  });
                },
                  child: Icon(Icons.sentiment_very_satisfied, color: selected == 5 ? Colors.green : Colors.black, size: 70,)),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selected = 4;
                    _selectedEmotion = 'Хорошо';
                  });
                },
                child: Icon(Icons.sentiment_satisfied, color: selected == 4 ? Colors.lightGreen : Colors.black, size: 70,),),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selected = 3;
                    _selectedEmotion = 'Нормально';
                  });
                },child: Icon(Icons.sentiment_neutral, color: selected == 3 ? Colors.yellow[700] : Colors.black, size: 70,),),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selected = 2;
                    _selectedEmotion = 'Грустно';
                  });
                },child: Icon(Icons.sentiment_dissatisfied, color: selected == 2 ? Colors.orange : Colors.black, size: 70,),),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selected = 1;
                    _selectedEmotion = 'Ужасно';
                  });
                },child: Icon(Icons.sentiment_very_dissatisfied, color: selected == 1 ? Colors.red : Colors.black, size: 70),),
            ],
          ),
          SizedBox(height: 15),

          // Описание
          InputField(
            label: 'Описание эмоций',
            initialValue: _description,
            onChanged: (value) => setState(() => _description = value),
            validator: (value) =>
            value == null || value.isEmpty ? 'Пожалуйста, введите описание' : null,
          ),

          SizedBox(height: 8),

          InputField(
            label: 'Ситуация',
            initialValue: _situation,
            onChanged: (value) => setState(() => _situation = value),
          ),


          SizedBox(height: 8),

          InputField(
            label: 'Мысли',
            initialValue: _thoughts,
            onChanged: (value) => setState(() => _thoughts = value),
          ),
          SizedBox(height: 15),
          GreenButton(text: 'Сохранить', onPressed: () async { if (_formKey.currentState!.validate()) {
            final diaryEntry = Diary(
              eventDatetime: _time,
              emotionalState: _selectedEmotion,
              situation: _situation,
              mood: _description,
              thoughts: _thoughts,
              bodySensations: '',
            );
            widget.onSubmit(diaryEntry);
          }; },),
          SizedBox(height: 20,),
        ],
      ),
    );
  }
}

void showAddMoodRecordForm(BuildContext context, void Function(Diary) onCreated, Diary? initialEntry) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (BuildContext context) {
      return Container(
        height: 520,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Как вы себя чувствуете?', style: TextStyles.title.copyWith(color: Colors.black)),
            AddMoodRecordForm(
              initialEntry: initialEntry,
              onSubmit: (diaryEntry) async {
                try {
                  Diary result;
                  if (initialEntry != null) {
                    result = await DiaryService.updateDiaryEntry(initialEntry.id!, diaryEntry);
                  } else {
                    result = await DiaryService.createDiaryEntry(diaryEntry);
                  }

                  onCreated(result);
                  Navigator.of(context).pop();

                } catch (e) {
                  print('Ошибка при сохранении: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка при сохранении')),
                  );
                }
              },
            ),
          ],
        ),
      );
    },
    clipBehavior: Clip.antiAliasWithSaveLayer,
  );
}
