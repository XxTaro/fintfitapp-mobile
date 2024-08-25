// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoryTable extends Category
    with TableInfo<$CategoryTable, CategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $CategoryTable createAlias(String alias) {
    return $CategoryTable(attachedDatabase, alias);
  }
}

class CategoryData extends DataClass implements Insertable<CategoryData> {
  final int id;
  final String name;
  const CategoryData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CategoryCompanion toCompanion(bool nullToAbsent) {
    return CategoryCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory CategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CategoryData copyWith({int? id, String? name}) => CategoryData(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('CategoryData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryData && other.id == this.id && other.name == this.name);
}

class CategoryCompanion extends UpdateCompanion<CategoryData> {
  final Value<int> id;
  final Value<String> name;
  const CategoryCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CategoryCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<CategoryData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CategoryCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return CategoryCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $GoalTable extends Goal with TableInfo<$GoalTable, GoalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
      'value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateStartMeta =
      const VerificationMeta('dateStart');
  @override
  late final GeneratedColumn<DateTime> dateStart = GeneratedColumn<DateTime>(
      'date_start', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dateEndMeta =
      const VerificationMeta('dateEnd');
  @override
  late final GeneratedColumn<DateTime> dateEnd = GeneratedColumn<DateTime>(
      'date_end', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, description, value, categoryId, dateStart, dateEnd];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal';
  @override
  VerificationContext validateIntegrity(Insertable<GoalData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('date_start')) {
      context.handle(_dateStartMeta,
          dateStart.isAcceptableOrUnknown(data['date_start']!, _dateStartMeta));
    } else if (isInserting) {
      context.missing(_dateStartMeta);
    }
    if (data.containsKey('date_end')) {
      context.handle(_dateEndMeta,
          dateEnd.isAcceptableOrUnknown(data['date_end']!, _dateEndMeta));
    } else if (isInserting) {
      context.missing(_dateEndMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}value'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      dateStart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_start'])!,
      dateEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_end'])!,
    );
  }

  @override
  $GoalTable createAlias(String alias) {
    return $GoalTable(attachedDatabase, alias);
  }
}

class GoalData extends DataClass implements Insertable<GoalData> {
  final int id;
  final String description;
  final int value;
  final int categoryId;
  final DateTime dateStart;
  final DateTime dateEnd;
  const GoalData(
      {required this.id,
      required this.description,
      required this.value,
      required this.categoryId,
      required this.dateStart,
      required this.dateEnd});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['description'] = Variable<String>(description);
    map['value'] = Variable<int>(value);
    map['category_id'] = Variable<int>(categoryId);
    map['date_start'] = Variable<DateTime>(dateStart);
    map['date_end'] = Variable<DateTime>(dateEnd);
    return map;
  }

  GoalCompanion toCompanion(bool nullToAbsent) {
    return GoalCompanion(
      id: Value(id),
      description: Value(description),
      value: Value(value),
      categoryId: Value(categoryId),
      dateStart: Value(dateStart),
      dateEnd: Value(dateEnd),
    );
  }

  factory GoalData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalData(
      id: serializer.fromJson<int>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      value: serializer.fromJson<int>(json['value']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      dateStart: serializer.fromJson<DateTime>(json['dateStart']),
      dateEnd: serializer.fromJson<DateTime>(json['dateEnd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'description': serializer.toJson<String>(description),
      'value': serializer.toJson<int>(value),
      'categoryId': serializer.toJson<int>(categoryId),
      'dateStart': serializer.toJson<DateTime>(dateStart),
      'dateEnd': serializer.toJson<DateTime>(dateEnd),
    };
  }

  GoalData copyWith(
          {int? id,
          String? description,
          int? value,
          int? categoryId,
          DateTime? dateStart,
          DateTime? dateEnd}) =>
      GoalData(
        id: id ?? this.id,
        description: description ?? this.description,
        value: value ?? this.value,
        categoryId: categoryId ?? this.categoryId,
        dateStart: dateStart ?? this.dateStart,
        dateEnd: dateEnd ?? this.dateEnd,
      );
  @override
  String toString() {
    return (StringBuffer('GoalData(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('value: $value, ')
          ..write('categoryId: $categoryId, ')
          ..write('dateStart: $dateStart, ')
          ..write('dateEnd: $dateEnd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, description, value, categoryId, dateStart, dateEnd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalData &&
          other.id == this.id &&
          other.description == this.description &&
          other.value == this.value &&
          other.categoryId == this.categoryId &&
          other.dateStart == this.dateStart &&
          other.dateEnd == this.dateEnd);
}

class GoalCompanion extends UpdateCompanion<GoalData> {
  final Value<int> id;
  final Value<String> description;
  final Value<int> value;
  final Value<int> categoryId;
  final Value<DateTime> dateStart;
  final Value<DateTime> dateEnd;
  const GoalCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.value = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.dateStart = const Value.absent(),
    this.dateEnd = const Value.absent(),
  });
  GoalCompanion.insert({
    this.id = const Value.absent(),
    required String description,
    required int value,
    required int categoryId,
    required DateTime dateStart,
    required DateTime dateEnd,
  })  : description = Value(description),
        value = Value(value),
        categoryId = Value(categoryId),
        dateStart = Value(dateStart),
        dateEnd = Value(dateEnd);
  static Insertable<GoalData> custom({
    Expression<int>? id,
    Expression<String>? description,
    Expression<int>? value,
    Expression<int>? categoryId,
    Expression<DateTime>? dateStart,
    Expression<DateTime>? dateEnd,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (value != null) 'value': value,
      if (categoryId != null) 'category_id': categoryId,
      if (dateStart != null) 'date_start': dateStart,
      if (dateEnd != null) 'date_end': dateEnd,
    });
  }

  GoalCompanion copyWith(
      {Value<int>? id,
      Value<String>? description,
      Value<int>? value,
      Value<int>? categoryId,
      Value<DateTime>? dateStart,
      Value<DateTime>? dateEnd}) {
    return GoalCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      categoryId: categoryId ?? this.categoryId,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (dateStart.present) {
      map['date_start'] = Variable<DateTime>(dateStart.value);
    }
    if (dateEnd.present) {
      map['date_end'] = Variable<DateTime>(dateEnd.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('value: $value, ')
          ..write('categoryId: $categoryId, ')
          ..write('dateStart: $dateStart, ')
          ..write('dateEnd: $dateEnd')
          ..write(')'))
        .toString();
  }
}

class $MovementTable extends Movement
    with TableInfo<$MovementTable, MovementData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
      'value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, description, value, categoryId, timestamp, goalId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movement';
  @override
  VerificationContext validateIntegrity(Insertable<MovementData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovementData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}value'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goal_id'])!,
    );
  }

  @override
  $MovementTable createAlias(String alias) {
    return $MovementTable(attachedDatabase, alias);
  }
}

class MovementData extends DataClass implements Insertable<MovementData> {
  final int id;
  final String description;
  final int value;
  final int categoryId;
  final DateTime timestamp;
  final int goalId;
  const MovementData(
      {required this.id,
      required this.description,
      required this.value,
      required this.categoryId,
      required this.timestamp,
      required this.goalId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['description'] = Variable<String>(description);
    map['value'] = Variable<int>(value);
    map['category_id'] = Variable<int>(categoryId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['goal_id'] = Variable<int>(goalId);
    return map;
  }

  MovementCompanion toCompanion(bool nullToAbsent) {
    return MovementCompanion(
      id: Value(id),
      description: Value(description),
      value: Value(value),
      categoryId: Value(categoryId),
      timestamp: Value(timestamp),
      goalId: Value(goalId),
    );
  }

  factory MovementData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementData(
      id: serializer.fromJson<int>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      value: serializer.fromJson<int>(json['value']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      goalId: serializer.fromJson<int>(json['goalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'description': serializer.toJson<String>(description),
      'value': serializer.toJson<int>(value),
      'categoryId': serializer.toJson<int>(categoryId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'goalId': serializer.toJson<int>(goalId),
    };
  }

  MovementData copyWith(
          {int? id,
          String? description,
          int? value,
          int? categoryId,
          DateTime? timestamp,
          int? goalId}) =>
      MovementData(
        id: id ?? this.id,
        description: description ?? this.description,
        value: value ?? this.value,
        categoryId: categoryId ?? this.categoryId,
        timestamp: timestamp ?? this.timestamp,
        goalId: goalId ?? this.goalId,
      );
  @override
  String toString() {
    return (StringBuffer('MovementData(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('value: $value, ')
          ..write('categoryId: $categoryId, ')
          ..write('timestamp: $timestamp, ')
          ..write('goalId: $goalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, description, value, categoryId, timestamp, goalId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementData &&
          other.id == this.id &&
          other.description == this.description &&
          other.value == this.value &&
          other.categoryId == this.categoryId &&
          other.timestamp == this.timestamp &&
          other.goalId == this.goalId);
}

class MovementCompanion extends UpdateCompanion<MovementData> {
  final Value<int> id;
  final Value<String> description;
  final Value<int> value;
  final Value<int> categoryId;
  final Value<DateTime> timestamp;
  final Value<int> goalId;
  const MovementCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.value = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.goalId = const Value.absent(),
  });
  MovementCompanion.insert({
    this.id = const Value.absent(),
    required String description,
    required int value,
    required int categoryId,
    required DateTime timestamp,
    required int goalId,
  })  : description = Value(description),
        value = Value(value),
        categoryId = Value(categoryId),
        timestamp = Value(timestamp),
        goalId = Value(goalId);
  static Insertable<MovementData> custom({
    Expression<int>? id,
    Expression<String>? description,
    Expression<int>? value,
    Expression<int>? categoryId,
    Expression<DateTime>? timestamp,
    Expression<int>? goalId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (value != null) 'value': value,
      if (categoryId != null) 'category_id': categoryId,
      if (timestamp != null) 'timestamp': timestamp,
      if (goalId != null) 'goal_id': goalId,
    });
  }

  MovementCompanion copyWith(
      {Value<int>? id,
      Value<String>? description,
      Value<int>? value,
      Value<int>? categoryId,
      Value<DateTime>? timestamp,
      Value<int>? goalId}) {
    return MovementCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      categoryId: categoryId ?? this.categoryId,
      timestamp: timestamp ?? this.timestamp,
      goalId: goalId ?? this.goalId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('value: $value, ')
          ..write('categoryId: $categoryId, ')
          ..write('timestamp: $timestamp, ')
          ..write('goalId: $goalId')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  late final $CategoryTable category = $CategoryTable(this);
  late final $GoalTable goal = $GoalTable(this);
  late final $MovementTable movement = $MovementTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [category, goal, movement];
}
