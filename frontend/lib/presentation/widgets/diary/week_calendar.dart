import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:intl/intl.dart';

import '../../../text_styles.dart';

enum WeekStartFrom {
  Sunday,
  Monday,
}

class HorizontalWeekCalendar extends StatefulWidget {
  /// week start from Monday or Sunday
  ///
  /// default value is
  /// ```dart
  /// [WeekStartFrom.Monday]
  /// ```
  final WeekStartFrom? weekStartFrom;

  ///get DateTime on date select
  ///
  /// ```dart
  /// onDateChange: (DateTime date){
  ///    print(date);
  /// }
  /// ```
  final Function(DateTime)? onDateChange;

  ///get the list of DateTime on week change
  ///
  /// ```dart
  /// onWeekChange: (List<DateTime> list){
  ///    print("First date: ${list.first}");
  ///    print("Last date: ${list.last}");
  /// }
  /// ```
  final Function(List<DateTime>)? onWeekChange;

  /// Active background color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor
  /// ```
  final Color? activeBackgroundColor;

  /// In-Active background color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor.withOpacity(.2)
  /// ```
  final Color? inactiveBackgroundColor;

  /// Disable background color
  ///
  /// Default value is
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? disabledBackgroundColor;

  /// Active text color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor
  /// ```
  final Color? activeTextColor;

  /// In-Active text color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor.withOpacity(.2)
  /// ```
  final Color? inactiveTextColor;

  /// Disable text color
  ///
  /// Default value is
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? disabledTextColor;

  /// Active Navigator color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor
  /// ```
  final Color? activeNavigatorColor;

  /// In-Active Navigator color
  ///
  /// Default value is
  /// ```dart
  /// Colors.grey
  /// ```
  final Color? inactiveNavigatorColor;

  /// Month Color
  ///
  /// Default value is
  /// ```dart
  /// Theme.of(context).primaryColor.withOpacity(.2)
  /// ```
  final Color? monthColor;

  /// border radius of date card
  ///
  /// Default value is `null`
  final BorderRadiusGeometry? borderRadius;

  /// scroll physics
  ///
  /// Default value is
  /// ```
  /// scrollPhysics: const ClampingScrollPhysics(),
  /// ```
  final ScrollPhysics? scrollPhysics;

  /// showNavigationButtons
  ///
  /// Default value is `true`
  final bool? showNavigationButtons;

  /// monthFormat
  ///
  /// If it's current year then
  /// Default value will be ```MMMM```
  ///
  /// Otherwise
  /// Default value will be `MMMM yyyy`
  final String? monthFormat;

  final DateTime minDate;

  final DateTime maxDate;

  final DateTime initialDate;

  final bool showTopNavbar;

  final HorizontalWeekCalenderController? controller;

  ///controll the date jump
  ///
  /// ```dart
  /// jumpPre()
  /// Jump scoll calender to left
  ///
  /// jumpNext()
  /// Jump calender to right date
  /// ```

  HorizontalWeekCalendar({
    super.key,
    this.onDateChange,
    this.onWeekChange,
    this.activeBackgroundColor,
    this.controller,
    this.inactiveBackgroundColor,
    this.disabledBackgroundColor = Colors.grey,
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = Colors.white,
    this.disabledTextColor = Colors.white,
    this.activeNavigatorColor,
    this.inactiveNavigatorColor,
    this.monthColor,
    this.weekStartFrom = WeekStartFrom.Monday,
    this.borderRadius,
    this.scrollPhysics = const ClampingScrollPhysics(),
    this.showNavigationButtons = true,
    this.monthFormat,
    required this.minDate,
    required this.maxDate,
    required this.initialDate,
    this.showTopNavbar = true,
  })  :
  // assert(minDate != null && maxDate != null),
        assert(minDate.isBefore(maxDate)),
        assert(
        minDate.isBefore(initialDate) && (initialDate).isBefore(maxDate)),
        super();

  @override
  State<HorizontalWeekCalendar> createState() => _HorizontalWeekCalendarState();
}

class _HorizontalWeekCalendarState extends State<HorizontalWeekCalendar> {
  CarouselSliderController carouselController = CarouselSliderController();

  final int _initialPage = 1;

  DateTime today = DateTime.now();
  DateTime selectedDate = DateTime.now();
  List<DateTime> currentWeek = [];
  int currentWeekIndex = 0;

  List<List<DateTime>> listOfWeeks = [];

  @override
  void initState() {
    initCalender();
    super.initState();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  initCalender() {
    final date = widget.initialDate;
    selectedDate = widget.initialDate;

    DateTime startOfCurrentWeek = widget.weekStartFrom == WeekStartFrom.Monday
        ? getDate(date.subtract(Duration(days: date.weekday - 1)))
        : getDate(date.subtract(Duration(days: date.weekday % 7)));

    currentWeek.add(startOfCurrentWeek);
    for (int index = 0; index < 6; index++) {
      DateTime addDate = startOfCurrentWeek.add(Duration(days: (index + 1)));
      currentWeek.add(addDate);
    }

    listOfWeeks.add(currentWeek);

    _getMorePreviousWeeks();

    _getMoreNextWeeks();

    if (widget.controller != null) {
      widget.controller!._stateChangerPre.addListener(() {
        print("previous");
        _onBackClick();
      });

      widget.controller!._stateChangerNex.addListener(() {
        print("next");
        _onNextClick();
      });
    }
  }

  String getMonthInNominative(DateTime date) {
    final List<String> months = [
      "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
      "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"
    ];
    return months[date.month - 1]; // date.month вернет число от 1 до 12, поэтому уменьшаем на 1
  }

  _getMorePreviousWeeks() {
    List<DateTime> minus7Days = [];
    DateTime startFrom = listOfWeeks[currentWeekIndex].first;

    bool canAdd = false;
    for (int index = 0; index < 7; index++) {
      DateTime minusDate = startFrom.add(Duration(days: -(index + 1)));
      minus7Days.add(minusDate);
      // if (widget.minDate != null) {
      if (minusDate.add(const Duration(days: 1)).isAfter(widget.minDate)) {
        canAdd = true;
      }
      // } else {
      //   canAdd = true;
      // }
    }
    if (canAdd == true) {
      listOfWeeks.add(minus7Days.reversed.toList());
    }
    setState(() {});
  }

  _getMoreNextWeeks() {
    List<DateTime> plus7Days = [];
    // DateTime startFrom = currentWeek.last;
    DateTime startFrom = listOfWeeks[currentWeekIndex].last;

    // bool canAdd = false;
    // int newCurrentWeekIndex = 1;
    for (int index = 0; index < 7; index++) {
      DateTime addDate = startFrom.add(Duration(days: (index + 1)));
      plus7Days.add(addDate);
      // if (widget.maxDate != null) {
      //   if (addDate.isBefore(widget.maxDate!)) {
      //     canAdd = true;
      //     newCurrentWeekIndex = 1;
      //   } else {
      //     newCurrentWeekIndex = 0;
      //   }
      // } else {
      //   canAdd = true;
      //   newCurrentWeekIndex = 1;
      // }
    }
    // print("canAdd: $canAdd");
    // print("newCurrentWeekIndex: $newCurrentWeekIndex");

    // if (canAdd == true) {
    listOfWeeks.insert(0, plus7Days);
    // }
    currentWeekIndex = 1;
    setState(() {});
  }

  _onDateSelect(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    widget.onDateChange?.call(selectedDate);
  }

  _onBackClick() {
    carouselController.nextPage();
  }

  _onNextClick() {
    carouselController.previousPage();
  }

  onWeekChange(index) {
    if (currentWeekIndex < index) {
      // on back
    }
    if (currentWeekIndex > index) {
      // on next
    }

    currentWeekIndex = index;
    currentWeek = listOfWeeks[currentWeekIndex];

    if (currentWeekIndex + 1 == listOfWeeks.length) {
      _getMorePreviousWeeks();
    }

    if (index == 0) {
      _getMoreNextWeeks();
      carouselController.nextPage();
    }

    widget.onWeekChange?.call(currentWeek);
    setState(() {});
  }

  // =================

  bool _isReachMinimum(DateTime dateTime) {
    return widget.minDate.add(const Duration(days: -1)).isBefore(dateTime);
  }

  bool _isReachMaximum(DateTime dateTime) {
    return widget.maxDate.add(const Duration(days: 1)).isAfter(dateTime);
  }

  bool _isNextDisabled() {
    DateTime lastDate = listOfWeeks[currentWeekIndex].last;
    // if (widget.maxDate != null) {
    String lastDateFormatted = DateFormat('yyyy/MM/dd').format(lastDate);
    String maxDateFormatted = DateFormat('yyyy/MM/dd').format(widget.maxDate);
    if (lastDateFormatted == maxDateFormatted) return true;
    // }

    bool isAfter =
    // widget.maxDate == null ? false :
    lastDate.isAfter(widget.maxDate);

    return isAfter;
    // return listOfWeeks[currentWeekIndex].last.isBefore(DateTime.now());
  }

  bool isBackDisabled() {
    DateTime firstDate = listOfWeeks[currentWeekIndex].first;
    // if (widget.minDate != null) {
    String firstDateFormatted = DateFormat('yyyy/MM/dd').format(firstDate);
    String minDateFormatted = DateFormat('yyyy/MM/dd').format(widget.minDate);
    if (firstDateFormatted == minDateFormatted) return true;
    // }

    bool isBefore =
    // widget.minDate == null ? false :
    firstDate.isBefore(widget.minDate);

    return isBefore;
    // return listOfWeeks[currentWeekIndex].last.isBefore(DateTime.now());
  }

  isCurrentYear() {
    return DateFormat('yyyy', 'ru').format(currentWeek.first) ==
        DateFormat('yyyy', 'ru').format(today);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // var withOfScreen = MediaQuery.of(context).size.width;

    // double boxHeight = withOfScreen / 7;

    return currentWeek.isEmpty
        ? const SizedBox()
        : Column(
      children: [
        if (widget.showTopNavbar)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.showNavigationButtons == true
                  ? GestureDetector(
                onTap: isBackDisabled()
                    ? null
                    : () {
                  _onBackClick();
                },
                child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Colors.grey
                ),
              )
                  : const SizedBox(),
              Padding(padding: EdgeInsets.only(right: 8, left: 8),
              child: Container(
                width: 130,
                alignment: Alignment.center,
                child: Text(
                    '${getMonthInNominative(currentWeek.first)} ${DateFormat('yyyy').format(currentWeek.first)}',
                    style: TextStyles.body
                ),
              ),),
              widget.showNavigationButtons == true
                  ? GestureDetector(
                onTap: _isNextDisabled()
                    ? null
                    : () {
                  _onNextClick();
                },
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey
                ),
              )
                  : const SizedBox(),
            ],
          ),
        if (widget.showTopNavbar) const SizedBox(height: 8),
        CarouselSlider(
          // carouselController: carouselController,
          controller: carouselController,
          items: [
            if (listOfWeeks.isNotEmpty)
              for (int ind = 0; ind < listOfWeeks.length; ind++)
                SizedBox(
                  // height: boxHeight,
                  width: double.infinity,
                  // color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int weekIndex = 0;
                      weekIndex < listOfWeeks[ind].length;
                      weekIndex++)
                        Builder(builder: (_) {
                          DateTime currentDate =
                          listOfWeeks[ind][weekIndex];
                          return Expanded(
                            child: GestureDetector(
                              // onTap: () {
                              //   _onDateSelect(currentDate);
                              // },
                              // TODO: disabled
                              onTap: _isReachMaximum(currentDate) &&
                                  _isReachMinimum(currentDate)
                                  ? () {
                                _onDateSelect(
                                  listOfWeeks[ind][weekIndex],
                                );
                              }
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: widget.borderRadius,
                                    // color: DateFormat('dd-MM-yyyy').format(
                                    //             listOfWeeks[ind]
                                    //                 [weekIndex]) ==
                                    //         DateFormat('dd-MM-yyyy')
                                    //             .format(selectedDate)
                                    //     ? widget.activeBackgroundColor ??
                                    //         theme.primaryColor
                                    //     : widget.inactiveBackgroundColor ??
                                    //         theme.primaryColor
                                    //             .withOpacity(.2),
                                    // TODO: disabled
                                    color: DateFormat('dd-MM-yyyy')
                                        .format(currentDate) ==
                                        DateFormat('dd-MM-yyyy')
                                            .format(selectedDate)
                                        ? widget.activeBackgroundColor ??
                                        theme.primaryColor
                                        : _isReachMaximum(currentDate) &&
                                        _isReachMinimum(currentDate)
                                        ? widget.inactiveBackgroundColor ??
                                        theme.primaryColor
                                            .withOpacity(.2)
                                        : widget.disabledBackgroundColor ??
                                        Colors.grey,
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat(
                                            'EEE', 'ru_RU'
                                        ).format(
                                          listOfWeeks[ind][weekIndex],
                                        ),
                                        textAlign: TextAlign.center,
                                        style: TextStyles.body!
                                            .copyWith(
                                          // color: DateFormat('dd-MM-yyyy')
                                          //             .format(listOfWeeks[
                                          //                     ind]
                                          //                 [weekIndex]) ==
                                          //         DateFormat('dd-MM-yyyy')
                                          //             .format(selectedDate)
                                          //     ? widget.activeTextColor ??
                                          //         Colors.white
                                          //     : widget.inactiveTextColor ??
                                          //         Colors.white
                                          //             .withOpacity(.2),
                                          // TODO: disabled
                                          color: DateFormat('dd-MM-yyyy')
                                              .format(
                                              currentDate) ==
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate)
                                              ? widget.activeTextColor ??
                                              Colors.white
                                              : _isReachMaximum(
                                              currentDate) &&
                                              _isReachMinimum(
                                                  currentDate)
                                              ? widget.inactiveTextColor ??
                                              Colors.white
                                                  .withOpacity(.2)
                                              : widget.disabledTextColor ??
                                              Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        // "$weekIndex: ${listOfWeeks[ind][weekIndex] == DateTime.now()}",
                                        "${currentDate.day}",
                                        textAlign: TextAlign.center,
                                        style: TextStyles.body!
                                            .copyWith(
                                          // color: DateFormat('dd-MM-yyyy')
                                          //             .format(listOfWeeks[
                                          //                     ind]
                                          //                 [weekIndex]) ==
                                          //         DateFormat('dd-MM-yyyy')
                                          //             .format(selectedDate)
                                          //     ? widget.activeTextColor ??
                                          //         Colors.white
                                          //     : widget.inactiveTextColor ??
                                          //         Colors.white
                                          //             .withOpacity(.2),
                                          // TODO: disabled
                                          color: DateFormat('dd-MM-yyyy')
                                              .format(
                                              currentDate) ==
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate)
                                              ? widget.activeTextColor ??
                                              Colors.white
                                              : _isReachMaximum(
                                              currentDate) &&
                                              _isReachMinimum(
                                                  currentDate)
                                              ? widget.inactiveTextColor ??
                                              Colors.white
                                                  .withOpacity(.2)
                                              : widget.disabledTextColor ??
                                              Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
          ],
          options: CarouselOptions(
            initialPage: _initialPage,
            scrollPhysics:
            widget.scrollPhysics ?? const ClampingScrollPhysics(),
            height: 60,
            viewportFraction: 1,
            enableInfiniteScroll: false,
            reverse: true,
            onPageChanged: (index, reason) {
              onWeekChange(index);
            },
          ),
        ),
      ],
    );
  }
}

class HorizontalWeekCalenderController {
  final ValueNotifier<int> _stateChangerPre = ValueNotifier<int>(0);
  final ValueNotifier<int> _stateChangerNex = ValueNotifier<int>(0);

  void jumpPre() {
    _stateChangerPre.value = _stateChangerPre.value + 1;
  }

  void jumpNext() {
    _stateChangerNex.value = _stateChangerNex.value + 1;
  }
}
