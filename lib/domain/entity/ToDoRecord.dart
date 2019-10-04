
import 'package:todo_app/domain/entity/Category.dart';
import 'package:todo_app/domain/entity/ToDo.dart';

class ToDoRecord {
  static ToDoRecord createDraft(DateTime date, int index) {
    final toDo = ToDo(
      year: date.year,
      month: date.month,
      day: date.day,
      index: index,
    );
    final category = Category();
    return ToDoRecord(
      toDo: toDo,
      category: category,
      isDraft: true,
    );
  }

  final ToDo toDo;
  final Category category;
  final bool isDraft;

  const ToDoRecord({
    this.toDo = const ToDo(),
    this.category = const Category(),
    this.isDraft = false,
  });

  ToDoRecord buildNew({
    ToDo toDo,
    Category category,
  }) {
    return ToDoRecord(
      toDo: toDo ?? this.toDo,
      category: category ?? this.category,
      isDraft: this.isDraft,
    );
  }
}