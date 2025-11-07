// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _routeNameMeta =
      const VerificationMeta('routeName');
  @override
  late final GeneratedColumn<String> routeName = GeneratedColumn<String>(
      'route_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _driverIdMeta =
      const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
      'driver_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
      'vehicle_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, routeName, driverId, vehicleId, direction, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(Insertable<Trip> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('route_name')) {
      context.handle(_routeNameMeta,
          routeName.isAcceptableOrUnknown(data['route_name']!, _routeNameMeta));
    }
    if (data.containsKey('driver_id')) {
      context.handle(_driverIdMeta,
          driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta));
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      routeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}route_name']),
      driverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_id'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_id']),
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final String id;
  final DateTime date;
  final String? routeName;
  final String driverId;
  final String? vehicleId;
  final String direction;
  final String? status;
  final DateTime? createdAt;
  const Trip(
      {required this.id,
      required this.date,
      this.routeName,
      required this.driverId,
      this.vehicleId,
      required this.direction,
      this.status,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || routeName != null) {
      map['route_name'] = Variable<String>(routeName);
    }
    map['driver_id'] = Variable<String>(driverId);
    if (!nullToAbsent || vehicleId != null) {
      map['vehicle_id'] = Variable<String>(vehicleId);
    }
    map['direction'] = Variable<String>(direction);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      date: Value(date),
      routeName: routeName == null && nullToAbsent
          ? const Value.absent()
          : Value(routeName),
      driverId: Value(driverId),
      vehicleId: vehicleId == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleId),
      direction: Value(direction),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      routeName: serializer.fromJson<String?>(json['routeName']),
      driverId: serializer.fromJson<String>(json['driverId']),
      vehicleId: serializer.fromJson<String?>(json['vehicleId']),
      direction: serializer.fromJson<String>(json['direction']),
      status: serializer.fromJson<String?>(json['status']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'routeName': serializer.toJson<String?>(routeName),
      'driverId': serializer.toJson<String>(driverId),
      'vehicleId': serializer.toJson<String?>(vehicleId),
      'direction': serializer.toJson<String>(direction),
      'status': serializer.toJson<String?>(status),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Trip copyWith(
          {String? id,
          DateTime? date,
          Value<String?> routeName = const Value.absent(),
          String? driverId,
          Value<String?> vehicleId = const Value.absent(),
          String? direction,
          Value<String?> status = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      Trip(
        id: id ?? this.id,
        date: date ?? this.date,
        routeName: routeName.present ? routeName.value : this.routeName,
        driverId: driverId ?? this.driverId,
        vehicleId: vehicleId.present ? vehicleId.value : this.vehicleId,
        direction: direction ?? this.direction,
        status: status.present ? status.value : this.status,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      routeName: data.routeName.present ? data.routeName.value : this.routeName,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      direction: data.direction.present ? data.direction.value : this.direction,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('routeName: $routeName, ')
          ..write('driverId: $driverId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, date, routeName, driverId, vehicleId, direction, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.date == this.date &&
          other.routeName == this.routeName &&
          other.driverId == this.driverId &&
          other.vehicleId == this.vehicleId &&
          other.direction == this.direction &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String?> routeName;
  final Value<String> driverId;
  final Value<String?> vehicleId;
  final Value<String> direction;
  final Value<String?> status;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.routeName = const Value.absent(),
    this.driverId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.direction = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required DateTime date,
    this.routeName = const Value.absent(),
    required String driverId,
    this.vehicleId = const Value.absent(),
    required String direction,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        driverId = Value(driverId),
        direction = Value(direction);
  static Insertable<Trip> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? routeName,
    Expression<String>? driverId,
    Expression<String>? vehicleId,
    Expression<String>? direction,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (routeName != null) 'route_name': routeName,
      if (driverId != null) 'driver_id': driverId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (direction != null) 'direction': direction,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<String?>? routeName,
      Value<String>? driverId,
      Value<String?>? vehicleId,
      Value<String>? direction,
      Value<String?>? status,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return TripsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      routeName: routeName ?? this.routeName,
      driverId: driverId ?? this.driverId,
      vehicleId: vehicleId ?? this.vehicleId,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (routeName.present) {
      map['route_name'] = Variable<String>(routeName.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('routeName: $routeName, ')
          ..write('driverId: $driverId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StopsTable extends Stops with TableInfo<$StopsTable, Stop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
      'trip_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plannedLatLngMeta =
      const VerificationMeta('plannedLatLng');
  @override
  late final GeneratedColumn<String> plannedLatLng = GeneratedColumn<String>(
      'planned_lat_lng', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actualLatLngMeta =
      const VerificationMeta('actualLatLng');
  @override
  late final GeneratedColumn<String> actualLatLng = GeneratedColumn<String>(
      'actual_lat_lng', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actualAddressMeta =
      const VerificationMeta('actualAddress');
  @override
  late final GeneratedColumn<String> actualAddress = GeneratedColumn<String>(
      'actual_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _signaturePathMeta =
      const VerificationMeta('signaturePath');
  @override
  late final GeneratedColumn<String> signaturePath = GeneratedColumn<String>(
      'signature_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tripId,
        clientId,
        kind,
        plannedLatLng,
        actualLatLng,
        actualAddress,
        timestamp,
        status,
        note,
        photoPath,
        signaturePath,
        accuracy,
        speed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stops';
  @override
  VerificationContext validateIntegrity(Insertable<Stop> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta,
          tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('planned_lat_lng')) {
      context.handle(
          _plannedLatLngMeta,
          plannedLatLng.isAcceptableOrUnknown(
              data['planned_lat_lng']!, _plannedLatLngMeta));
    }
    if (data.containsKey('actual_lat_lng')) {
      context.handle(
          _actualLatLngMeta,
          actualLatLng.isAcceptableOrUnknown(
              data['actual_lat_lng']!, _actualLatLngMeta));
    }
    if (data.containsKey('actual_address')) {
      context.handle(
          _actualAddressMeta,
          actualAddress.isAcceptableOrUnknown(
              data['actual_address']!, _actualAddressMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('signature_path')) {
      context.handle(
          _signaturePathMeta,
          signaturePath.isAcceptableOrUnknown(
              data['signature_path']!, _signaturePathMeta));
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Stop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stop(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      plannedLatLng: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}planned_lat_lng']),
      actualLatLng: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actual_lat_lng']),
      actualAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actual_address']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      signaturePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signature_path']),
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy']),
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed']),
    );
  }

  @override
  $StopsTable createAlias(String alias) {
    return $StopsTable(attachedDatabase, alias);
  }
}

class Stop extends DataClass implements Insertable<Stop> {
  final String id;
  final String tripId;
  final String clientId;
  final String kind;
  final String? plannedLatLng;
  final String? actualLatLng;
  final String? actualAddress;
  final DateTime? timestamp;
  final String status;
  final String? note;
  final String? photoPath;
  final String? signaturePath;
  final double? accuracy;
  final double? speed;
  const Stop(
      {required this.id,
      required this.tripId,
      required this.clientId,
      required this.kind,
      this.plannedLatLng,
      this.actualLatLng,
      this.actualAddress,
      this.timestamp,
      required this.status,
      this.note,
      this.photoPath,
      this.signaturePath,
      this.accuracy,
      this.speed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['client_id'] = Variable<String>(clientId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || plannedLatLng != null) {
      map['planned_lat_lng'] = Variable<String>(plannedLatLng);
    }
    if (!nullToAbsent || actualLatLng != null) {
      map['actual_lat_lng'] = Variable<String>(actualLatLng);
    }
    if (!nullToAbsent || actualAddress != null) {
      map['actual_address'] = Variable<String>(actualAddress);
    }
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<DateTime>(timestamp);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || signaturePath != null) {
      map['signature_path'] = Variable<String>(signaturePath);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    return map;
  }

  StopsCompanion toCompanion(bool nullToAbsent) {
    return StopsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      clientId: Value(clientId),
      kind: Value(kind),
      plannedLatLng: plannedLatLng == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedLatLng),
      actualLatLng: actualLatLng == null && nullToAbsent
          ? const Value.absent()
          : Value(actualLatLng),
      actualAddress: actualAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(actualAddress),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      signaturePath: signaturePath == null && nullToAbsent
          ? const Value.absent()
          : Value(signaturePath),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      speed:
          speed == null && nullToAbsent ? const Value.absent() : Value(speed),
    );
  }

  factory Stop.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stop(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      kind: serializer.fromJson<String>(json['kind']),
      plannedLatLng: serializer.fromJson<String?>(json['plannedLatLng']),
      actualLatLng: serializer.fromJson<String?>(json['actualLatLng']),
      actualAddress: serializer.fromJson<String?>(json['actualAddress']),
      timestamp: serializer.fromJson<DateTime?>(json['timestamp']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      signaturePath: serializer.fromJson<String?>(json['signaturePath']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      speed: serializer.fromJson<double?>(json['speed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'clientId': serializer.toJson<String>(clientId),
      'kind': serializer.toJson<String>(kind),
      'plannedLatLng': serializer.toJson<String?>(plannedLatLng),
      'actualLatLng': serializer.toJson<String?>(actualLatLng),
      'actualAddress': serializer.toJson<String?>(actualAddress),
      'timestamp': serializer.toJson<DateTime?>(timestamp),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'photoPath': serializer.toJson<String?>(photoPath),
      'signaturePath': serializer.toJson<String?>(signaturePath),
      'accuracy': serializer.toJson<double?>(accuracy),
      'speed': serializer.toJson<double?>(speed),
    };
  }

  Stop copyWith(
          {String? id,
          String? tripId,
          String? clientId,
          String? kind,
          Value<String?> plannedLatLng = const Value.absent(),
          Value<String?> actualLatLng = const Value.absent(),
          Value<String?> actualAddress = const Value.absent(),
          Value<DateTime?> timestamp = const Value.absent(),
          String? status,
          Value<String?> note = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          Value<String?> signaturePath = const Value.absent(),
          Value<double?> accuracy = const Value.absent(),
          Value<double?> speed = const Value.absent()}) =>
      Stop(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        clientId: clientId ?? this.clientId,
        kind: kind ?? this.kind,
        plannedLatLng:
            plannedLatLng.present ? plannedLatLng.value : this.plannedLatLng,
        actualLatLng:
            actualLatLng.present ? actualLatLng.value : this.actualLatLng,
        actualAddress:
            actualAddress.present ? actualAddress.value : this.actualAddress,
        timestamp: timestamp.present ? timestamp.value : this.timestamp,
        status: status ?? this.status,
        note: note.present ? note.value : this.note,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        signaturePath:
            signaturePath.present ? signaturePath.value : this.signaturePath,
        accuracy: accuracy.present ? accuracy.value : this.accuracy,
        speed: speed.present ? speed.value : this.speed,
      );
  Stop copyWithCompanion(StopsCompanion data) {
    return Stop(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      kind: data.kind.present ? data.kind.value : this.kind,
      plannedLatLng: data.plannedLatLng.present
          ? data.plannedLatLng.value
          : this.plannedLatLng,
      actualLatLng: data.actualLatLng.present
          ? data.actualLatLng.value
          : this.actualLatLng,
      actualAddress: data.actualAddress.present
          ? data.actualAddress.value
          : this.actualAddress,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      signaturePath: data.signaturePath.present
          ? data.signaturePath.value
          : this.signaturePath,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      speed: data.speed.present ? data.speed.value : this.speed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stop(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('clientId: $clientId, ')
          ..write('kind: $kind, ')
          ..write('plannedLatLng: $plannedLatLng, ')
          ..write('actualLatLng: $actualLatLng, ')
          ..write('actualAddress: $actualAddress, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('photoPath: $photoPath, ')
          ..write('signaturePath: $signaturePath, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tripId,
      clientId,
      kind,
      plannedLatLng,
      actualLatLng,
      actualAddress,
      timestamp,
      status,
      note,
      photoPath,
      signaturePath,
      accuracy,
      speed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stop &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.clientId == this.clientId &&
          other.kind == this.kind &&
          other.plannedLatLng == this.plannedLatLng &&
          other.actualLatLng == this.actualLatLng &&
          other.actualAddress == this.actualAddress &&
          other.timestamp == this.timestamp &&
          other.status == this.status &&
          other.note == this.note &&
          other.photoPath == this.photoPath &&
          other.signaturePath == this.signaturePath &&
          other.accuracy == this.accuracy &&
          other.speed == this.speed);
}

class StopsCompanion extends UpdateCompanion<Stop> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> clientId;
  final Value<String> kind;
  final Value<String?> plannedLatLng;
  final Value<String?> actualLatLng;
  final Value<String?> actualAddress;
  final Value<DateTime?> timestamp;
  final Value<String> status;
  final Value<String?> note;
  final Value<String?> photoPath;
  final Value<String?> signaturePath;
  final Value<double?> accuracy;
  final Value<double?> speed;
  final Value<int> rowid;
  const StopsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.kind = const Value.absent(),
    this.plannedLatLng = const Value.absent(),
    this.actualLatLng = const Value.absent(),
    this.actualAddress = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.signaturePath = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StopsCompanion.insert({
    required String id,
    required String tripId,
    required String clientId,
    required String kind,
    this.plannedLatLng = const Value.absent(),
    this.actualLatLng = const Value.absent(),
    this.actualAddress = const Value.absent(),
    this.timestamp = const Value.absent(),
    required String status,
    this.note = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.signaturePath = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tripId = Value(tripId),
        clientId = Value(clientId),
        kind = Value(kind),
        status = Value(status);
  static Insertable<Stop> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? clientId,
    Expression<String>? kind,
    Expression<String>? plannedLatLng,
    Expression<String>? actualLatLng,
    Expression<String>? actualAddress,
    Expression<DateTime>? timestamp,
    Expression<String>? status,
    Expression<String>? note,
    Expression<String>? photoPath,
    Expression<String>? signaturePath,
    Expression<double>? accuracy,
    Expression<double>? speed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (clientId != null) 'client_id': clientId,
      if (kind != null) 'kind': kind,
      if (plannedLatLng != null) 'planned_lat_lng': plannedLatLng,
      if (actualLatLng != null) 'actual_lat_lng': actualLatLng,
      if (actualAddress != null) 'actual_address': actualAddress,
      if (timestamp != null) 'timestamp': timestamp,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (photoPath != null) 'photo_path': photoPath,
      if (signaturePath != null) 'signature_path': signaturePath,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StopsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tripId,
      Value<String>? clientId,
      Value<String>? kind,
      Value<String?>? plannedLatLng,
      Value<String?>? actualLatLng,
      Value<String?>? actualAddress,
      Value<DateTime?>? timestamp,
      Value<String>? status,
      Value<String?>? note,
      Value<String?>? photoPath,
      Value<String?>? signaturePath,
      Value<double?>? accuracy,
      Value<double?>? speed,
      Value<int>? rowid}) {
    return StopsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      clientId: clientId ?? this.clientId,
      kind: kind ?? this.kind,
      plannedLatLng: plannedLatLng ?? this.plannedLatLng,
      actualLatLng: actualLatLng ?? this.actualLatLng,
      actualAddress: actualAddress ?? this.actualAddress,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
      signaturePath: signaturePath ?? this.signaturePath,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (plannedLatLng.present) {
      map['planned_lat_lng'] = Variable<String>(plannedLatLng.value);
    }
    if (actualLatLng.present) {
      map['actual_lat_lng'] = Variable<String>(actualLatLng.value);
    }
    if (actualAddress.present) {
      map['actual_address'] = Variable<String>(actualAddress.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (signaturePath.present) {
      map['signature_path'] = Variable<String>(signaturePath.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StopsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('clientId: $clientId, ')
          ..write('kind: $kind, ')
          ..write('plannedLatLng: $plannedLatLng, ')
          ..write('actualLatLng: $actualLatLng, ')
          ..write('actualAddress: $actualAddress, ')
          ..write('timestamp: $timestamp, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('photoPath: $photoPath, ')
          ..write('signaturePath: $signaturePath, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendancesTable extends Attendances
    with TableInfo<$AttendancesTable, Attendance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _timeInMeta = const VerificationMeta('timeIn');
  @override
  late final GeneratedColumn<DateTime> timeIn = GeneratedColumn<DateTime>(
      'time_in', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _timeOutMeta =
      const VerificationMeta('timeOut');
  @override
  late final GeneratedColumn<DateTime> timeOut = GeneratedColumn<DateTime>(
      'time_out', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _capturedByMeta =
      const VerificationMeta('capturedBy');
  @override
  late final GeneratedColumn<String> capturedBy = GeneratedColumn<String>(
      'captured_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, clientId, date, timeIn, timeOut, capturedBy, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendances';
  @override
  VerificationContext validateIntegrity(Insertable<Attendance> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time_in')) {
      context.handle(_timeInMeta,
          timeIn.isAcceptableOrUnknown(data['time_in']!, _timeInMeta));
    }
    if (data.containsKey('time_out')) {
      context.handle(_timeOutMeta,
          timeOut.isAcceptableOrUnknown(data['time_out']!, _timeOutMeta));
    }
    if (data.containsKey('captured_by')) {
      context.handle(
          _capturedByMeta,
          capturedBy.isAcceptableOrUnknown(
              data['captured_by']!, _capturedByMeta));
    } else if (isInserting) {
      context.missing(_capturedByMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attendance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attendance(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      timeIn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time_in']),
      timeOut: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time_out']),
      capturedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}captured_by'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $AttendancesTable createAlias(String alias) {
    return $AttendancesTable(attachedDatabase, alias);
  }
}

class Attendance extends DataClass implements Insertable<Attendance> {
  final String id;
  final String clientId;
  final DateTime date;
  final DateTime? timeIn;
  final DateTime? timeOut;
  final String capturedBy;
  final String? note;
  const Attendance(
      {required this.id,
      required this.clientId,
      required this.date,
      this.timeIn,
      this.timeOut,
      required this.capturedBy,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || timeIn != null) {
      map['time_in'] = Variable<DateTime>(timeIn);
    }
    if (!nullToAbsent || timeOut != null) {
      map['time_out'] = Variable<DateTime>(timeOut);
    }
    map['captured_by'] = Variable<String>(capturedBy);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  AttendancesCompanion toCompanion(bool nullToAbsent) {
    return AttendancesCompanion(
      id: Value(id),
      clientId: Value(clientId),
      date: Value(date),
      timeIn:
          timeIn == null && nullToAbsent ? const Value.absent() : Value(timeIn),
      timeOut: timeOut == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOut),
      capturedBy: Value(capturedBy),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Attendance.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attendance(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      date: serializer.fromJson<DateTime>(json['date']),
      timeIn: serializer.fromJson<DateTime?>(json['timeIn']),
      timeOut: serializer.fromJson<DateTime?>(json['timeOut']),
      capturedBy: serializer.fromJson<String>(json['capturedBy']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'date': serializer.toJson<DateTime>(date),
      'timeIn': serializer.toJson<DateTime?>(timeIn),
      'timeOut': serializer.toJson<DateTime?>(timeOut),
      'capturedBy': serializer.toJson<String>(capturedBy),
      'note': serializer.toJson<String?>(note),
    };
  }

  Attendance copyWith(
          {String? id,
          String? clientId,
          DateTime? date,
          Value<DateTime?> timeIn = const Value.absent(),
          Value<DateTime?> timeOut = const Value.absent(),
          String? capturedBy,
          Value<String?> note = const Value.absent()}) =>
      Attendance(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        date: date ?? this.date,
        timeIn: timeIn.present ? timeIn.value : this.timeIn,
        timeOut: timeOut.present ? timeOut.value : this.timeOut,
        capturedBy: capturedBy ?? this.capturedBy,
        note: note.present ? note.value : this.note,
      );
  Attendance copyWithCompanion(AttendancesCompanion data) {
    return Attendance(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      date: data.date.present ? data.date.value : this.date,
      timeIn: data.timeIn.present ? data.timeIn.value : this.timeIn,
      timeOut: data.timeOut.present ? data.timeOut.value : this.timeOut,
      capturedBy:
          data.capturedBy.present ? data.capturedBy.value : this.capturedBy,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attendance(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('date: $date, ')
          ..write('timeIn: $timeIn, ')
          ..write('timeOut: $timeOut, ')
          ..write('capturedBy: $capturedBy, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, clientId, date, timeIn, timeOut, capturedBy, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attendance &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.date == this.date &&
          other.timeIn == this.timeIn &&
          other.timeOut == this.timeOut &&
          other.capturedBy == this.capturedBy &&
          other.note == this.note);
}

class AttendancesCompanion extends UpdateCompanion<Attendance> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<DateTime> date;
  final Value<DateTime?> timeIn;
  final Value<DateTime?> timeOut;
  final Value<String> capturedBy;
  final Value<String?> note;
  final Value<int> rowid;
  const AttendancesCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.date = const Value.absent(),
    this.timeIn = const Value.absent(),
    this.timeOut = const Value.absent(),
    this.capturedBy = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendancesCompanion.insert({
    required String id,
    required String clientId,
    required DateTime date,
    this.timeIn = const Value.absent(),
    this.timeOut = const Value.absent(),
    required String capturedBy,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        clientId = Value(clientId),
        date = Value(date),
        capturedBy = Value(capturedBy);
  static Insertable<Attendance> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<DateTime>? date,
    Expression<DateTime>? timeIn,
    Expression<DateTime>? timeOut,
    Expression<String>? capturedBy,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (date != null) 'date': date,
      if (timeIn != null) 'time_in': timeIn,
      if (timeOut != null) 'time_out': timeOut,
      if (capturedBy != null) 'captured_by': capturedBy,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendancesCompanion copyWith(
      {Value<String>? id,
      Value<String>? clientId,
      Value<DateTime>? date,
      Value<DateTime?>? timeIn,
      Value<DateTime?>? timeOut,
      Value<String>? capturedBy,
      Value<String?>? note,
      Value<int>? rowid}) {
    return AttendancesCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      capturedBy: capturedBy ?? this.capturedBy,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (timeIn.present) {
      map['time_in'] = Variable<DateTime>(timeIn.value);
    }
    if (timeOut.present) {
      map['time_out'] = Variable<DateTime>(timeOut.value);
    }
    if (capturedBy.present) {
      map['captured_by'] = Variable<String>(capturedBy.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendancesCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('date: $date, ')
          ..write('timeIn: $timeIn, ')
          ..write('timeOut: $timeOut, ')
          ..write('capturedBy: $capturedBy, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxesTable extends Outboxes with TableInfo<$OutboxesTable, Outboxe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
      'op', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retriesMeta =
      const VerificationMeta('retries');
  @override
  late final GeneratedColumn<int> retries = GeneratedColumn<int>(
      'retries', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entity, payloadJson, op, createdAt, retries, synced, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outboxes';
  @override
  VerificationContext validateIntegrity(Insertable<Outboxe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retries')) {
      context.handle(_retriesMeta,
          retries.isAcceptableOrUnknown(data['retries']!, _retriesMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Outboxe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Outboxe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      op: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}op'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retries: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retries'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  $OutboxesTable createAlias(String alias) {
    return $OutboxesTable(attachedDatabase, alias);
  }
}

class Outboxe extends DataClass implements Insertable<Outboxe> {
  final int id;
  final String entity;
  final String payloadJson;
  final String op;
  final DateTime createdAt;
  final int retries;
  final bool synced;
  final DateTime? syncedAt;
  const Outboxe(
      {required this.id,
      required this.entity,
      required this.payloadJson,
      required this.op,
      required this.createdAt,
      required this.retries,
      required this.synced,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity'] = Variable<String>(entity);
    map['payload_json'] = Variable<String>(payloadJson);
    map['op'] = Variable<String>(op);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retries'] = Variable<int>(retries);
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  OutboxesCompanion toCompanion(bool nullToAbsent) {
    return OutboxesCompanion(
      id: Value(id),
      entity: Value(entity),
      payloadJson: Value(payloadJson),
      op: Value(op),
      createdAt: Value(createdAt),
      retries: Value(retries),
      synced: Value(synced),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory Outboxe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Outboxe(
      id: serializer.fromJson<int>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      op: serializer.fromJson<String>(json['op']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retries: serializer.fromJson<int>(json['retries']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(entity),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'op': serializer.toJson<String>(op),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retries': serializer.toJson<int>(retries),
      'synced': serializer.toJson<bool>(synced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  Outboxe copyWith(
          {int? id,
          String? entity,
          String? payloadJson,
          String? op,
          DateTime? createdAt,
          int? retries,
          bool? synced,
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      Outboxe(
        id: id ?? this.id,
        entity: entity ?? this.entity,
        payloadJson: payloadJson ?? this.payloadJson,
        op: op ?? this.op,
        createdAt: createdAt ?? this.createdAt,
        retries: retries ?? this.retries,
        synced: synced ?? this.synced,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  Outboxe copyWithCompanion(OutboxesCompanion data) {
    return Outboxe(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      op: data.op.present ? data.op.value : this.op,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retries: data.retries.present ? data.retries.value : this.retries,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Outboxe(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('op: $op, ')
          ..write('createdAt: $createdAt, ')
          ..write('retries: $retries, ')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entity, payloadJson, op, createdAt, retries, synced, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Outboxe &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.payloadJson == this.payloadJson &&
          other.op == this.op &&
          other.createdAt == this.createdAt &&
          other.retries == this.retries &&
          other.synced == this.synced &&
          other.syncedAt == this.syncedAt);
}

class OutboxesCompanion extends UpdateCompanion<Outboxe> {
  final Value<int> id;
  final Value<String> entity;
  final Value<String> payloadJson;
  final Value<String> op;
  final Value<DateTime> createdAt;
  final Value<int> retries;
  final Value<bool> synced;
  final Value<DateTime?> syncedAt;
  const OutboxesCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.op = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retries = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  OutboxesCompanion.insert({
    this.id = const Value.absent(),
    required String entity,
    required String payloadJson,
    required String op,
    required DateTime createdAt,
    this.retries = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncedAt = const Value.absent(),
  })  : entity = Value(entity),
        payloadJson = Value(payloadJson),
        op = Value(op),
        createdAt = Value(createdAt);
  static Insertable<Outboxe> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<String>? payloadJson,
    Expression<String>? op,
    Expression<DateTime>? createdAt,
    Expression<int>? retries,
    Expression<bool>? synced,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (op != null) 'op': op,
      if (createdAt != null) 'created_at': createdAt,
      if (retries != null) 'retries': retries,
      if (synced != null) 'synced': synced,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  OutboxesCompanion copyWith(
      {Value<int>? id,
      Value<String>? entity,
      Value<String>? payloadJson,
      Value<String>? op,
      Value<DateTime>? createdAt,
      Value<int>? retries,
      Value<bool>? synced,
      Value<DateTime?>? syncedAt}) {
    return OutboxesCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      payloadJson: payloadJson ?? this.payloadJson,
      op: op ?? this.op,
      createdAt: createdAt ?? this.createdAt,
      retries: retries ?? this.retries,
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retries.present) {
      map['retries'] = Variable<int>(retries.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxesCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('op: $op, ')
          ..write('createdAt: $createdAt, ')
          ..write('retries: $retries, ')
          ..write('synced: $synced, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $StopsTable stops = $StopsTable(this);
  late final $AttendancesTable attendances = $AttendancesTable(this);
  late final $OutboxesTable outboxes = $OutboxesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [trips, stops, attendances, outboxes];
}

typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  required DateTime date,
  Value<String?> routeName,
  required String driverId,
  Value<String?> vehicleId,
  required String direction,
  Value<String?> status,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<String?> routeName,
  Value<String> driverId,
  Value<String?> vehicleId,
  Value<String> direction,
  Value<String?> status,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routeName => $composableBuilder(
      column: $table.routeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routeName => $composableBuilder(
      column: $table.routeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get routeName =>
      $composableBuilder(column: $table.routeName, builder: (column) => column);

  GeneratedColumn<String> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TripsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TripsTable,
    Trip,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
    Trip,
    PrefetchHooks Function()> {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> routeName = const Value.absent(),
            Value<String> driverId = const Value.absent(),
            Value<String?> vehicleId = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TripsCompanion(
            id: id,
            date: date,
            routeName: routeName,
            driverId: driverId,
            vehicleId: vehicleId,
            direction: direction,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            Value<String?> routeName = const Value.absent(),
            required String driverId,
            Value<String?> vehicleId = const Value.absent(),
            required String direction,
            Value<String?> status = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TripsCompanion.insert(
            id: id,
            date: date,
            routeName: routeName,
            driverId: driverId,
            vehicleId: vehicleId,
            direction: direction,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TripsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TripsTable,
    Trip,
    $$TripsTableFilterComposer,
    $$TripsTableOrderingComposer,
    $$TripsTableAnnotationComposer,
    $$TripsTableCreateCompanionBuilder,
    $$TripsTableUpdateCompanionBuilder,
    (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
    Trip,
    PrefetchHooks Function()>;
typedef $$StopsTableCreateCompanionBuilder = StopsCompanion Function({
  required String id,
  required String tripId,
  required String clientId,
  required String kind,
  Value<String?> plannedLatLng,
  Value<String?> actualLatLng,
  Value<String?> actualAddress,
  Value<DateTime?> timestamp,
  required String status,
  Value<String?> note,
  Value<String?> photoPath,
  Value<String?> signaturePath,
  Value<double?> accuracy,
  Value<double?> speed,
  Value<int> rowid,
});
typedef $$StopsTableUpdateCompanionBuilder = StopsCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> clientId,
  Value<String> kind,
  Value<String?> plannedLatLng,
  Value<String?> actualLatLng,
  Value<String?> actualAddress,
  Value<DateTime?> timestamp,
  Value<String> status,
  Value<String?> note,
  Value<String?> photoPath,
  Value<String?> signaturePath,
  Value<double?> accuracy,
  Value<double?> speed,
  Value<int> rowid,
});

class $$StopsTableFilterComposer extends Composer<_$AppDatabase, $StopsTable> {
  $$StopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plannedLatLng => $composableBuilder(
      column: $table.plannedLatLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actualLatLng => $composableBuilder(
      column: $table.actualLatLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actualAddress => $composableBuilder(
      column: $table.actualAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signaturePath => $composableBuilder(
      column: $table.signaturePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));
}

class $$StopsTableOrderingComposer
    extends Composer<_$AppDatabase, $StopsTable> {
  $$StopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripId => $composableBuilder(
      column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plannedLatLng => $composableBuilder(
      column: $table.plannedLatLng,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actualLatLng => $composableBuilder(
      column: $table.actualLatLng,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actualAddress => $composableBuilder(
      column: $table.actualAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signaturePath => $composableBuilder(
      column: $table.signaturePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));
}

class $$StopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StopsTable> {
  $$StopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get plannedLatLng => $composableBuilder(
      column: $table.plannedLatLng, builder: (column) => column);

  GeneratedColumn<String> get actualLatLng => $composableBuilder(
      column: $table.actualLatLng, builder: (column) => column);

  GeneratedColumn<String> get actualAddress => $composableBuilder(
      column: $table.actualAddress, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get signaturePath => $composableBuilder(
      column: $table.signaturePath, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);
}

class $$StopsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StopsTable,
    Stop,
    $$StopsTableFilterComposer,
    $$StopsTableOrderingComposer,
    $$StopsTableAnnotationComposer,
    $$StopsTableCreateCompanionBuilder,
    $$StopsTableUpdateCompanionBuilder,
    (Stop, BaseReferences<_$AppDatabase, $StopsTable, Stop>),
    Stop,
    PrefetchHooks Function()> {
  $$StopsTableTableManager(_$AppDatabase db, $StopsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tripId = const Value.absent(),
            Value<String> clientId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String?> plannedLatLng = const Value.absent(),
            Value<String?> actualLatLng = const Value.absent(),
            Value<String?> actualAddress = const Value.absent(),
            Value<DateTime?> timestamp = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> signaturePath = const Value.absent(),
            Value<double?> accuracy = const Value.absent(),
            Value<double?> speed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StopsCompanion(
            id: id,
            tripId: tripId,
            clientId: clientId,
            kind: kind,
            plannedLatLng: plannedLatLng,
            actualLatLng: actualLatLng,
            actualAddress: actualAddress,
            timestamp: timestamp,
            status: status,
            note: note,
            photoPath: photoPath,
            signaturePath: signaturePath,
            accuracy: accuracy,
            speed: speed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tripId,
            required String clientId,
            required String kind,
            Value<String?> plannedLatLng = const Value.absent(),
            Value<String?> actualLatLng = const Value.absent(),
            Value<String?> actualAddress = const Value.absent(),
            Value<DateTime?> timestamp = const Value.absent(),
            required String status,
            Value<String?> note = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> signaturePath = const Value.absent(),
            Value<double?> accuracy = const Value.absent(),
            Value<double?> speed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StopsCompanion.insert(
            id: id,
            tripId: tripId,
            clientId: clientId,
            kind: kind,
            plannedLatLng: plannedLatLng,
            actualLatLng: actualLatLng,
            actualAddress: actualAddress,
            timestamp: timestamp,
            status: status,
            note: note,
            photoPath: photoPath,
            signaturePath: signaturePath,
            accuracy: accuracy,
            speed: speed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StopsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StopsTable,
    Stop,
    $$StopsTableFilterComposer,
    $$StopsTableOrderingComposer,
    $$StopsTableAnnotationComposer,
    $$StopsTableCreateCompanionBuilder,
    $$StopsTableUpdateCompanionBuilder,
    (Stop, BaseReferences<_$AppDatabase, $StopsTable, Stop>),
    Stop,
    PrefetchHooks Function()>;
typedef $$AttendancesTableCreateCompanionBuilder = AttendancesCompanion
    Function({
  required String id,
  required String clientId,
  required DateTime date,
  Value<DateTime?> timeIn,
  Value<DateTime?> timeOut,
  required String capturedBy,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$AttendancesTableUpdateCompanionBuilder = AttendancesCompanion
    Function({
  Value<String> id,
  Value<String> clientId,
  Value<DateTime> date,
  Value<DateTime?> timeIn,
  Value<DateTime?> timeOut,
  Value<String> capturedBy,
  Value<String?> note,
  Value<int> rowid,
});

class $$AttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timeIn => $composableBuilder(
      column: $table.timeIn, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timeOut => $composableBuilder(
      column: $table.timeOut, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get capturedBy => $composableBuilder(
      column: $table.capturedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$AttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientId => $composableBuilder(
      column: $table.clientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timeIn => $composableBuilder(
      column: $table.timeIn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timeOut => $composableBuilder(
      column: $table.timeOut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get capturedBy => $composableBuilder(
      column: $table.capturedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$AttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get timeIn =>
      $composableBuilder(column: $table.timeIn, builder: (column) => column);

  GeneratedColumn<DateTime> get timeOut =>
      $composableBuilder(column: $table.timeOut, builder: (column) => column);

  GeneratedColumn<String> get capturedBy => $composableBuilder(
      column: $table.capturedBy, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$AttendancesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttendancesTable,
    Attendance,
    $$AttendancesTableFilterComposer,
    $$AttendancesTableOrderingComposer,
    $$AttendancesTableAnnotationComposer,
    $$AttendancesTableCreateCompanionBuilder,
    $$AttendancesTableUpdateCompanionBuilder,
    (Attendance, BaseReferences<_$AppDatabase, $AttendancesTable, Attendance>),
    Attendance,
    PrefetchHooks Function()> {
  $$AttendancesTableTableManager(_$AppDatabase db, $AttendancesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> clientId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime?> timeIn = const Value.absent(),
            Value<DateTime?> timeOut = const Value.absent(),
            Value<String> capturedBy = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttendancesCompanion(
            id: id,
            clientId: clientId,
            date: date,
            timeIn: timeIn,
            timeOut: timeOut,
            capturedBy: capturedBy,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String clientId,
            required DateTime date,
            Value<DateTime?> timeIn = const Value.absent(),
            Value<DateTime?> timeOut = const Value.absent(),
            required String capturedBy,
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttendancesCompanion.insert(
            id: id,
            clientId: clientId,
            date: date,
            timeIn: timeIn,
            timeOut: timeOut,
            capturedBy: capturedBy,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AttendancesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttendancesTable,
    Attendance,
    $$AttendancesTableFilterComposer,
    $$AttendancesTableOrderingComposer,
    $$AttendancesTableAnnotationComposer,
    $$AttendancesTableCreateCompanionBuilder,
    $$AttendancesTableUpdateCompanionBuilder,
    (Attendance, BaseReferences<_$AppDatabase, $AttendancesTable, Attendance>),
    Attendance,
    PrefetchHooks Function()>;
typedef $$OutboxesTableCreateCompanionBuilder = OutboxesCompanion Function({
  Value<int> id,
  required String entity,
  required String payloadJson,
  required String op,
  required DateTime createdAt,
  Value<int> retries,
  Value<bool> synced,
  Value<DateTime?> syncedAt,
});
typedef $$OutboxesTableUpdateCompanionBuilder = OutboxesCompanion Function({
  Value<int> id,
  Value<String> entity,
  Value<String> payloadJson,
  Value<String> op,
  Value<DateTime> createdAt,
  Value<int> retries,
  Value<bool> synced,
  Value<DateTime?> syncedAt,
});

class $$OutboxesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxesTable> {
  $$OutboxesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get op => $composableBuilder(
      column: $table.op, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retries => $composableBuilder(
      column: $table.retries, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxesTable> {
  $$OutboxesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get op => $composableBuilder(
      column: $table.op, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retries => $composableBuilder(
      column: $table.retries, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxesTable> {
  $$OutboxesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retries =>
      $composableBuilder(column: $table.retries, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$OutboxesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxesTable,
    Outboxe,
    $$OutboxesTableFilterComposer,
    $$OutboxesTableOrderingComposer,
    $$OutboxesTableAnnotationComposer,
    $$OutboxesTableCreateCompanionBuilder,
    $$OutboxesTableUpdateCompanionBuilder,
    (Outboxe, BaseReferences<_$AppDatabase, $OutboxesTable, Outboxe>),
    Outboxe,
    PrefetchHooks Function()> {
  $$OutboxesTableTableManager(_$AppDatabase db, $OutboxesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entity = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> op = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retries = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              OutboxesCompanion(
            id: id,
            entity: entity,
            payloadJson: payloadJson,
            op: op,
            createdAt: createdAt,
            retries: retries,
            synced: synced,
            syncedAt: syncedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entity,
            required String payloadJson,
            required String op,
            required DateTime createdAt,
            Value<int> retries = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
          }) =>
              OutboxesCompanion.insert(
            id: id,
            entity: entity,
            payloadJson: payloadJson,
            op: op,
            createdAt: createdAt,
            retries: retries,
            synced: synced,
            syncedAt: syncedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxesTable,
    Outboxe,
    $$OutboxesTableFilterComposer,
    $$OutboxesTableOrderingComposer,
    $$OutboxesTableAnnotationComposer,
    $$OutboxesTableCreateCompanionBuilder,
    $$OutboxesTableUpdateCompanionBuilder,
    (Outboxe, BaseReferences<_$AppDatabase, $OutboxesTable, Outboxe>),
    Outboxe,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$StopsTableTableManager get stops =>
      $$StopsTableTableManager(_db, _db.stops);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db, _db.attendances);
  $$OutboxesTableTableManager get outboxes =>
      $$OutboxesTableTableManager(_db, _db.outboxes);
}
