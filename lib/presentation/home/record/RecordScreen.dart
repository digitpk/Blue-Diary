
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinity_page_view/infinity_page_view.dart';
import 'package:todo_app/domain/home/record/entity/DayMemo.dart';
import 'package:todo_app/domain/home/record/entity/DayRecord.dart';
import 'package:todo_app/domain/home/record/entity/ToDo.dart';
import 'package:todo_app/domain/home/record/entity/WeekMemo.dart';
import 'package:todo_app/presentation/home/record/RecordActions.dart';
import 'package:todo_app/presentation/home/record/RecordBloc.dart';
import 'package:todo_app/presentation/home/record/RecordState.dart';
import 'package:todo_app/presentation/widgets/DayMemoTextField.dart';
import 'package:todo_app/presentation/widgets/ToDoTextField.dart';
import 'package:todo_app/presentation/widgets/WeekMemoTextField.dart';

class RecordScreen extends StatefulWidget {
  @override
  State createState() {
    return _RecordScreenState();
  }
}

class _RecordScreenState extends State<RecordScreen> {
  RecordBloc _bloc;
  final _daysPageController = InfinityPageController(initialPage: 0, viewportFraction: 0.75);
  final Map<String, FocusNode> _focusNodes = {};

  @override
  initState() {
    super.initState();
    _bloc = RecordBloc();
  }

  @override
  dispose() {
    super.dispose();
    _bloc.dispose();

    _focusNodes.forEach((key, focusNode) => focusNode.dispose());
    _focusNodes.clear();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: _bloc.initialState,
      stream: _bloc.state,
      builder: (context, snapshot) {
        return _buildUI(snapshot.data);
      }
    );
  }

  Widget _buildUI(RecordState state) {
    return WillPopScope(
      onWillPop: () async {
        return !_unfocusTextFieldIfAny();
      },
      child: GestureDetector(
        onTapDown: (_) => _unfocusTextFieldIfAny(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildYearAndMonthNthWeek(state),
            _buildWeekMemos(state),
            _buildDayRecordsPager(state),
          ],
        ),
      ),
    );
  }

  bool _unfocusTextFieldIfAny() {
    for (FocusNode focusNode in _focusNodes.values) {
      if (focusNode.hasPrimaryFocus) {
        focusNode.unfocus();
        return true;
      }
    }
    return false;
  }

  Widget _buildYearAndMonthNthWeek(RecordState state) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              state.yearText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4,),
            Text(
              state.monthAndNthWeekText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      onTap: _onYearAndMonthNthWeekClicked,
    );
  }

  _onYearAndMonthNthWeekClicked() {
    _bloc.actions.add(NavigateToCalendarPage());
  }

  Widget _buildWeekMemos(RecordState state) {
    final weekMemos = state.weekMemos;
    return Padding(
      padding: EdgeInsets.only(left: 12, top: 12, right: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: List.generate(weekMemos.length, (index) {
              final weekMemo = weekMemos[index];
              final textField = WeekMemoTextField(
                focusNode: _getOrCreateFocusNode(weekMemo.key),
                text: weekMemo.content,
                onChanged: (changed) => _onWeekMemoTextChanged(weekMemo, changed),
              );

              if (index == 0) {
                return textField;
              } else {
                return Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: textField,
                );
              }
            }),
          );
        },
      ),
    );
  }

  _onWeekMemoTextChanged(WeekMemo weekMemo, String changed) {
    _bloc.actions.add(UpdateSingleWeekMemo(weekMemo, changed));
  }

  Widget _buildDayRecordsPager(RecordState state) {
    final dayRecords = state.dayRecords;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: InfinityPageView(
          controller: _daysPageController,
          itemCount: dayRecords.length,
          itemBuilder: (context, index) {
            // 에에~? 왜 dayRecords.length가 0인데도 itemBuilder가 한번 불리징 훔..
            if (dayRecords.isEmpty) {
              return null;
            }
            return _buildDayRecord(dayRecords[index]);
          },
          onPageChanged: _onDayRecordsPageChanged,
        ),
      ),
    );
  }

  _onDayRecordsPageChanged(int index) {
    _bloc.actions.add(UpdateDayRecordPageIndex(index));
  }

  Widget _buildDayRecord(DayRecord record) {
    return Center(
      child: ClipRect(
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 8,),
                Center(
                  child: Text(record.title),
                ),
                SizedBox(
                  height: 228,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6,),
                    child: ListView.builder(
                      itemCount: record.toDos.length + 1,
                      itemBuilder: (context, index) {
                        if (index == record.toDos.length) {
                          return Center(
                            child: IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () => _onAddToDoClicked(record),
                            ),
                          );
                        } else {
                          final toDo = record.toDos[index];
                          return ToDoTextField(
                            focusNode: _getOrCreateFocusNode(toDo.key),
                            toDo: toDo,
                            onChanged: (s) => _onToDoTextChanged(record, toDo, s),
                            onCheckBoxClicked: () => _onToDoCheckBoxClicked(record, toDo),
                            onDismissed: () => _onToDoDismissed(record, toDo),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.black,),
                Padding(
                  padding: EdgeInsets.only(left: 4, top: 4,),
                  child: Text(
                    'MEMO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DayMemoTextField(
                  focusNode: _getOrCreateFocusNode(record.memo.key),
                  text: record.memo.content,
                  onChanged: (s) => _onDayMemoTextChanged(record.memo, s),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  FocusNode _getOrCreateFocusNode(String key) {
    if (_focusNodes.containsKey(key)) {
      return _focusNodes[key];
    } else {
      final newFocusNode = FocusNode();
      _focusNodes[key] = newFocusNode;
      return newFocusNode;
    }
  }

  _onAddToDoClicked(DayRecord dayRecord) {
    _bloc.actions.add(AddToDo(dayRecord));
  }

  _onToDoTextChanged(DayRecord dayRecord, ToDo toDo, String changed) {
    _bloc.actions.add(UpdateToDoContent(dayRecord, toDo, changed));
  }

  _onToDoCheckBoxClicked(DayRecord dayRecord, ToDo toDo) {
    if (!toDo.isDone) {
      _bloc.actions.add(UpdateToDoDone(dayRecord, toDo));
    }
  }

  _onToDoDismissed(DayRecord dayRecord, ToDo toDo) {
    _bloc.actions.add(RemoveToDo(dayRecord, toDo));
  }

  _onDayMemoTextChanged(DayMemo dayMemo, String changed) {
    _bloc.actions.add(UpdateDayMemo(dayMemo, changed));
  }
}
