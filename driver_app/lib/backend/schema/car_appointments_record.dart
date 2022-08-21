import 'dart:async';

import 'index.dart';
import 'serializers.dart';
import 'package:built_value/built_value.dart';

part 'car_appointments_record.g.dart';

abstract class CarAppointmentsRecord
    implements Built<CarAppointmentsRecord, CarAppointmentsRecordBuilder> {
  static Serializer<CarAppointmentsRecord> get serializer =>
      _$carAppointmentsRecordSerializer;

  String? get carName;

  DateTime? get scheduledDate;

  DocumentReference? get carRef;

  String? get description;

  String? get status;

  String? get type;

  int? get appointmentNumber;

  @BuiltValueField(wireName: kDocumentReferenceField)
  DocumentReference? get ffRef;
  DocumentReference get reference => ffRef!;

  DocumentReference get parentReference => reference.parent.parent!;

  static void _initializeBuilder(CarAppointmentsRecordBuilder builder) =>
      builder
        ..carName = ''
        ..description = ''
        ..status = ''
        ..type = ''
        ..appointmentNumber = 0;

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('carAppointments')
          : FirebaseFirestore.instance.collectionGroup('carAppointments');

  static DocumentReference createDoc(DocumentReference parent) =>
      parent.collection('carAppointments').doc();

  static Stream<CarAppointmentsRecord> getDocument(DocumentReference ref) => ref
      .snapshots()
      .map((s) => serializers.deserializeWith(serializer, serializedData(s))!);

  static Future<CarAppointmentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then(
          (s) => serializers.deserializeWith(serializer, serializedData(s))!);

  CarAppointmentsRecord._();
  factory CarAppointmentsRecord(
          [void Function(CarAppointmentsRecordBuilder) updates]) =
      _$CarAppointmentsRecord;

  static CarAppointmentsRecord getDocumentFromData(
          Map<String, dynamic> data, DocumentReference reference) =>
      serializers.deserializeWith(serializer,
          {...mapFromFirestore(data), kDocumentReferenceField: reference})!;
}

Map<String, dynamic> createCarAppointmentsRecordData({
  String? carName,
  DateTime? scheduledDate,
  DocumentReference? carRef,
  String? description,
  String? status,
  String? type,
  int? appointmentNumber,
}) {
  final firestoreData = serializers.toFirestore(
    CarAppointmentsRecord.serializer,
    CarAppointmentsRecord(
      (c) => c
        ..carName = carName
        ..scheduledDate = scheduledDate
        ..carRef = carRef
        ..description = description
        ..status = status
        ..type = type
        ..appointmentNumber = appointmentNumber,
    ),
  );

  return firestoreData;
}
