/// A single record in the system.
///
/// `tagNumber` is the value read by the camera/OCR step (e.g. an ear-tag
/// number or printed code). `fieldOne/Two/Three` are the three additional
/// values the user types in after the scan, as you described.
class FarmRecord {
  final String id;
  final String tagNumber; // value captured from the camera/OCR
  final String fieldOne; // e.g. animal/item name
  final String fieldTwo; // e.g. weight, location, etc.
  final String fieldThree; // e.g. date or notes
  final String createdBy;
  final DateTime createdAt;

  FarmRecord({
    required this.id,
    required this.tagNumber,
    required this.fieldOne,
    required this.fieldTwo,
    required this.fieldThree,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagNumber': tagNumber,
      'fieldOne': fieldOne,
      'fieldTwo': fieldTwo,
      'fieldThree': fieldThree,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FarmRecord.fromMap(Map<String, dynamic> map) {
    return FarmRecord(
      id: map['id'] as String,
      tagNumber: map['tagNumber'] as String,
      fieldOne: map['fieldOne'] as String,
      fieldTwo: map['fieldTwo'] as String,
      fieldThree: map['fieldThree'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
