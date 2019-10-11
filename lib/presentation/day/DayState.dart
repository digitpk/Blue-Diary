
import 'package:todo_app/AppColors.dart';
import 'package:todo_app/domain/entity/Category.dart';
import 'package:todo_app/domain/entity/CategoryPicker.dart';
import 'package:todo_app/domain/entity/DayRecord.dart';
import 'package:todo_app/domain/entity/ToDo.dart';
import 'package:todo_app/domain/entity/ToDoRecord.dart';
import 'package:todo_app/presentation/day/DayScreen.dart';

enum DayViewState {
  WHOLE_LOADING,
  NORMAL,
}

class DayState {
  static const CATEGORY_PICKERS = [
    CategoryPicker(true, AppColors.CATEGORY_COLOR_01),
    CategoryPicker(true, AppColors.CATEGORY_COLOR_02),
    CategoryPicker(true, AppColors.CATEGORY_COLOR_03),
    CategoryPicker(true, AppColors.CATEGORY_COLOR_04),
    CategoryPicker(false, AppColors.CATEGORY_COLOR_01),
    CategoryPicker(false, AppColors.CATEGORY_COLOR_02),
    CategoryPicker(false, AppColors.CATEGORY_COLOR_03),
    CategoryPicker(false, AppColors.CATEGORY_COLOR_04),
  ];

  final DayViewState viewState;
  final Map<int, DayRecord> pageIndexDayRecordMap;
  final EditorState editorState;
  final ToDoRecord editingToDoRecord;
  final Category editingCategory;
  final List<Category> allCategories;
  final List<CategoryPicker> categoryPickers;
  final int selectedPickerIndex;
  final DateTime initialDate;
  final int initialDayRecordPageIndex;
  final DateTime currentDate;
  final int currentDayRecordPageIndex;

  final bool scrollToBottomEvent;
  final bool scrollToToDoListEvent;

  int get year => currentDate?.year ?? 0;
  int get month => currentDate?.month ?? 0;
  int get day => currentDate?.day ?? 0;
  int get weekday => currentDate?.weekday ?? 0;
  bool get isFabVisible => editorState == EditorState.HIDDEN;
  DayRecord get currentDayRecord => pageIndexDayRecordMap[currentDayRecordPageIndex];

  const DayState({
    this.viewState = DayViewState.WHOLE_LOADING,
    this.pageIndexDayRecordMap = const {},
    this.editorState = EditorState.HIDDEN,
    this.editingToDoRecord = const ToDoRecord(),
    this.editingCategory = const Category(),
    this.allCategories = const [],
    this.categoryPickers = CATEGORY_PICKERS,
    this.selectedPickerIndex = -1,
    this.initialDate,
    this.initialDayRecordPageIndex = DayScreen.INITIAL_DAY_PAGE,
    this.currentDate,
    this.currentDayRecordPageIndex = DayScreen.INITIAL_DAY_PAGE,

    this.scrollToBottomEvent = false,
    this.scrollToToDoListEvent = false,
  });

  DayRecord getDayRecordForPageIndex(int index) {
    return pageIndexDayRecordMap[index];
  }

  DayState buildNew({
    DayViewState viewState,
    DayRecord currentDayRecord,
    DayRecord prevDayRecord,
    DayRecord nextDayRecord,
    EditorState editorState,
    ToDoRecord editingToDoRecord,
    Category editingCategory,
    List<Category> allCategories,
    int selectedPickerIndex,
    DateTime initialDate,
    int currentDayRecordPageIndex,
    DateTime currentDate,

    bool scrollToBottomEvent,
    bool scrollToToDoListEvent,
  }) {
    final prevMap = this.pageIndexDayRecordMap;
    final currentPageIndex = currentDayRecordPageIndex ?? this.currentDayRecordPageIndex;
    final Map<int, DayRecord> pageIndexDayRecordMap = {
      currentPageIndex - 1: prevDayRecord ?? prevMap[currentPageIndex - 1],
      currentPageIndex: currentDayRecord ?? prevMap[currentPageIndex],
      currentPageIndex + 1: nextDayRecord ?? prevMap[currentPageIndex + 1],
    };
    return DayState(
      viewState: viewState ?? this.viewState,
      pageIndexDayRecordMap: pageIndexDayRecordMap,
      editorState: editorState ?? this.editorState,
      editingToDoRecord: editingToDoRecord ?? this.editingToDoRecord,
      editingCategory: editingCategory ?? this.editingCategory,
      allCategories: allCategories ?? this.allCategories,
      selectedPickerIndex: selectedPickerIndex ?? this.selectedPickerIndex,
      initialDate: initialDate ?? this.initialDate,
      currentDayRecordPageIndex: currentDayRecordPageIndex ?? this.currentDayRecordPageIndex,
      currentDate: currentDate ?? this.currentDate,

      // these are one-time events, so default to false if not given to "true" as parameter
      scrollToBottomEvent: scrollToBottomEvent ?? false,
      scrollToToDoListEvent: scrollToToDoListEvent ?? false,
    );
  }

  DayState buildNewToDoUpdated(ToDo updated) {
    final newRecords = List.of(currentDayRecord.toDoRecords);
    final updatedIndex = newRecords.indexWhere((it) => it.toDo.key == updated.key);
    if (updatedIndex >= 0) {
      newRecords[updatedIndex] = newRecords[updatedIndex].buildNew(toDo: updated);
      final updatedDayRecord = currentDayRecord.buildNew(toDoRecords: newRecords);
      return buildNew(currentDayRecord: updatedDayRecord);
    } else {
      return this;
    }
  }
}

enum EditorState {
  HIDDEN,
  SHOWN_TODO,
  SHOWN_CATEGORY,
}