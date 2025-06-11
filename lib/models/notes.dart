import 'package:isar/isar.dart';
import 'package:todo_app/models/enums.dart';
part 'notes.g.dart';

@Collection()
class Notes {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? title;

  String? content;

  @enumerated
  Status status = Status.pending;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  Notes copyWith({String? title, String? content, Status? status}) {
    return Notes()..id = id
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..title = title ?? this.title
      ..content = content ?? this.content
      ..status = status ?? this.status;
  }

  Notes changeStatus(Id id){
    final finalStatus = status == Status.pending ? Status.completed : Status.pending;

    return Notes()..id = id
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..title = title ?? this.title
      ..content = content ?? this.content
      ..status = finalStatus;
  }

}