import 'package:drift/drift.dart';

extension TableUtils on GeneratedDatabase {
  Future<int> deleteRow(
    Table table,
    Insertable val,
  ) async {
    return await delete(table as TableInfo).delete(val);
  }

  Future<int> insertRow(
    Table table,
    Insertable val,
  ) async {
    return await into(table as TableInfo).insert(val);
  }

  Future<bool> updateRow(
    Table table,
    Insertable val,
  ) async {
    return await this.update(table as TableInfo).replace(val);
  }
}

Value<T> addField<T>(T? val, {T? fallback}) {
  Value<T>? _fallback;

  if (fallback != null) {
    _fallback = Value<T>(fallback);
  }

  if (val == null) {
    return _fallback ?? Value.absent();
  }

  if (val is String && (val == 'null' || val == 'Null')) {
    return _fallback ?? Value.absent();
  }

  return Value(val);
}
