// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_raw_log_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmsRawLogModelCollection on Isar {
  IsarCollection<SmsRawLogModel> get smsRawLogModels => this.collection();
}

const SmsRawLogModelSchema = CollectionSchema(
  name: r'SmsRawLogModel',
  id: -4185052070241097635,
  properties: {
    r'fingerprint': PropertySchema(
      id: 0,
      name: r'fingerprint',
      type: IsarType.string,
    ),
    r'seenAt': PropertySchema(
      id: 1,
      name: r'seenAt',
      type: IsarType.dateTime,
    ),
    r'senderAddress': PropertySchema(
      id: 2,
      name: r'senderAddress',
      type: IsarType.string,
    )
  },
  estimateSize: _smsRawLogModelEstimateSize,
  serialize: _smsRawLogModelSerialize,
  deserialize: _smsRawLogModelDeserialize,
  deserializeProp: _smsRawLogModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'fingerprint': IndexSchema(
      id: -8135929981755050833,
      name: r'fingerprint',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'fingerprint',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _smsRawLogModelGetId,
  getLinks: _smsRawLogModelGetLinks,
  attach: _smsRawLogModelAttach,
  version: '3.1.0+1',
);

int _smsRawLogModelEstimateSize(
  SmsRawLogModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fingerprint.length * 3;
  bytesCount += 3 + object.senderAddress.length * 3;
  return bytesCount;
}

void _smsRawLogModelSerialize(
  SmsRawLogModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fingerprint);
  writer.writeDateTime(offsets[1], object.seenAt);
  writer.writeString(offsets[2], object.senderAddress);
}

SmsRawLogModel _smsRawLogModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmsRawLogModel(
    fingerprint: reader.readString(offsets[0]),
    senderAddress: reader.readString(offsets[2]),
  );
  object.id = id;
  object.seenAt = reader.readDateTime(offsets[1]);
  return object;
}

P _smsRawLogModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smsRawLogModelGetId(SmsRawLogModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smsRawLogModelGetLinks(SmsRawLogModel object) {
  return [];
}

void _smsRawLogModelAttach(
    IsarCollection<dynamic> col, Id id, SmsRawLogModel object) {
  object.id = id;
}

extension SmsRawLogModelByIndex on IsarCollection<SmsRawLogModel> {
  Future<SmsRawLogModel?> getByFingerprint(String fingerprint) {
    return getByIndex(r'fingerprint', [fingerprint]);
  }

  SmsRawLogModel? getByFingerprintSync(String fingerprint) {
    return getByIndexSync(r'fingerprint', [fingerprint]);
  }

  Future<bool> deleteByFingerprint(String fingerprint) {
    return deleteByIndex(r'fingerprint', [fingerprint]);
  }

  bool deleteByFingerprintSync(String fingerprint) {
    return deleteByIndexSync(r'fingerprint', [fingerprint]);
  }

  Future<List<SmsRawLogModel?>> getAllByFingerprint(
      List<String> fingerprintValues) {
    final values = fingerprintValues.map((e) => [e]).toList();
    return getAllByIndex(r'fingerprint', values);
  }

  List<SmsRawLogModel?> getAllByFingerprintSync(
      List<String> fingerprintValues) {
    final values = fingerprintValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'fingerprint', values);
  }

  Future<int> deleteAllByFingerprint(List<String> fingerprintValues) {
    final values = fingerprintValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'fingerprint', values);
  }

  int deleteAllByFingerprintSync(List<String> fingerprintValues) {
    final values = fingerprintValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'fingerprint', values);
  }

  Future<Id> putByFingerprint(SmsRawLogModel object) {
    return putByIndex(r'fingerprint', object);
  }

  Id putByFingerprintSync(SmsRawLogModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'fingerprint', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByFingerprint(List<SmsRawLogModel> objects) {
    return putAllByIndex(r'fingerprint', objects);
  }

  List<Id> putAllByFingerprintSync(List<SmsRawLogModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'fingerprint', objects, saveLinks: saveLinks);
  }
}

extension SmsRawLogModelQueryWhereSort
    on QueryBuilder<SmsRawLogModel, SmsRawLogModel, QWhere> {
  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmsRawLogModelQueryWhere
    on QueryBuilder<SmsRawLogModel, SmsRawLogModel, QWhereClause> {
  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterWhereClause>
      fingerprintEqualTo(String fingerprint) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'fingerprint',
        value: [fingerprint],
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterWhereClause>
      fingerprintNotEqualTo(String fingerprint) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fingerprint',
              lower: [],
              upper: [fingerprint],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fingerprint',
              lower: [fingerprint],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fingerprint',
              lower: [fingerprint],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fingerprint',
              lower: [],
              upper: [fingerprint],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SmsRawLogModelQueryFilter
    on QueryBuilder<SmsRawLogModel, SmsRawLogModel, QFilterCondition> {
  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fingerprint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fingerprint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fingerprint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      fingerprintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fingerprint',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      seenAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      seenAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'seenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      seenAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'seenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      seenAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'seenAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderAddress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterFilterCondition>
      senderAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderAddress',
        value: '',
      ));
    });
  }
}

extension SmsRawLogModelQueryObject
    on QueryBuilder<SmsRawLogModel, SmsRawLogModel, QFilterCondition> {}

extension SmsRawLogModelQueryLinks
    on QueryBuilder<SmsRawLogModel, SmsRawLogModel, QFilterCondition> {}

extension SmsRawLogModelQuerySortBy
    on QueryBuilder<SmsRawLogModel, SmsRawLogModel, QSortBy> {
  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      sortByFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.asc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      sortByFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.desc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy> sortBySeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenAt', Sort.asc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      sortBySeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenAt', Sort.desc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      sortBySenderAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAddress', Sort.asc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      sortBySenderAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAddress', Sort.desc);
    });
  }
}

extension SmsRawLogModelQuerySortThenBy
    on QueryBuilder<SmsRawLogModel, SmsRawLogModel, QSortThenBy> {
  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      thenByFingerprint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.asc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      thenByFingerprintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fingerprint', Sort.desc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy> thenBySeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenAt', Sort.asc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      thenBySeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenAt', Sort.desc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      thenBySenderAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAddress', Sort.asc);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QAfterSortBy>
      thenBySenderAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAddress', Sort.desc);
    });
  }
}

extension SmsRawLogModelQueryWhereDistinct
    on QueryBuilder<SmsRawLogModel, SmsRawLogModel, QDistinct> {
  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QDistinct> distinctByFingerprint(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fingerprint', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QDistinct> distinctBySeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seenAt');
    });
  }

  QueryBuilder<SmsRawLogModel, SmsRawLogModel, QDistinct>
      distinctBySenderAddress({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderAddress',
          caseSensitive: caseSensitive);
    });
  }
}

extension SmsRawLogModelQueryProperty
    on QueryBuilder<SmsRawLogModel, SmsRawLogModel, QQueryProperty> {
  QueryBuilder<SmsRawLogModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmsRawLogModel, String, QQueryOperations> fingerprintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fingerprint');
    });
  }

  QueryBuilder<SmsRawLogModel, DateTime, QQueryOperations> seenAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seenAt');
    });
  }

  QueryBuilder<SmsRawLogModel, String, QQueryOperations>
      senderAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderAddress');
    });
  }
}
