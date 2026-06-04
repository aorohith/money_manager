// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_identity_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMerchantIdentityModelCollection on Isar {
  IsarCollection<MerchantIdentityModel> get merchantIdentityModels =>
      this.collection();
}

const MerchantIdentityModelSchema = CollectionSchema(
  name: r'MerchantIdentityModel',
  id: 6124037883084053223,
  properties: {
    r'canonicalKey': PropertySchema(
      id: 0,
      name: r'canonicalKey',
      type: IsarType.string,
    ),
    r'categoryScores': PropertySchema(
      id: 1,
      name: r'categoryScores',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'displayName': PropertySchema(
      id: 3,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'isUserNamed': PropertySchema(
      id: 4,
      name: r'isUserNamed',
      type: IsarType.bool,
    ),
    r'lastSeen': PropertySchema(
      id: 5,
      name: r'lastSeen',
      type: IsarType.dateTime,
    ),
    r'nameAliases': PropertySchema(
      id: 6,
      name: r'nameAliases',
      type: IsarType.stringList,
    ),
    r'topCategoryId': PropertySchema(
      id: 7,
      name: r'topCategoryId',
      type: IsarType.long,
    ),
    r'topCategoryScore': PropertySchema(
      id: 8,
      name: r'topCategoryScore',
      type: IsarType.long,
    ),
    r'totalTransactions': PropertySchema(
      id: 9,
      name: r'totalTransactions',
      type: IsarType.long,
    ),
    r'upiHandles': PropertySchema(
      id: 10,
      name: r'upiHandles',
      type: IsarType.stringList,
    )
  },
  estimateSize: _merchantIdentityModelEstimateSize,
  serialize: _merchantIdentityModelSerialize,
  deserialize: _merchantIdentityModelDeserialize,
  deserializeProp: _merchantIdentityModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'canonicalKey': IndexSchema(
      id: 5726171637773322746,
      name: r'canonicalKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'canonicalKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'nameAliases': IndexSchema(
      id: -5552789554621980860,
      name: r'nameAliases',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nameAliases',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'upiHandles': IndexSchema(
      id: -255715415724113992,
      name: r'upiHandles',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'upiHandles',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _merchantIdentityModelGetId,
  getLinks: _merchantIdentityModelGetLinks,
  attach: _merchantIdentityModelAttach,
  version: '3.1.0+1',
);

int _merchantIdentityModelEstimateSize(
  MerchantIdentityModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.canonicalKey.length * 3;
  bytesCount += 3 + object.categoryScores.length * 3;
  {
    for (var i = 0; i < object.categoryScores.length; i++) {
      final value = object.categoryScores[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.nameAliases.length * 3;
  {
    for (var i = 0; i < object.nameAliases.length; i++) {
      final value = object.nameAliases[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.upiHandles.length * 3;
  {
    for (var i = 0; i < object.upiHandles.length; i++) {
      final value = object.upiHandles[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _merchantIdentityModelSerialize(
  MerchantIdentityModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.canonicalKey);
  writer.writeStringList(offsets[1], object.categoryScores);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.displayName);
  writer.writeBool(offsets[4], object.isUserNamed);
  writer.writeDateTime(offsets[5], object.lastSeen);
  writer.writeStringList(offsets[6], object.nameAliases);
  writer.writeLong(offsets[7], object.topCategoryId);
  writer.writeLong(offsets[8], object.topCategoryScore);
  writer.writeLong(offsets[9], object.totalTransactions);
  writer.writeStringList(offsets[10], object.upiHandles);
}

MerchantIdentityModel _merchantIdentityModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MerchantIdentityModel();
  object.canonicalKey = reader.readString(offsets[0]);
  object.categoryScores = reader.readStringList(offsets[1]) ?? [];
  object.createdAt = reader.readDateTime(offsets[2]);
  object.displayName = reader.readString(offsets[3]);
  object.id = id;
  object.isUserNamed = reader.readBool(offsets[4]);
  object.lastSeen = reader.readDateTime(offsets[5]);
  object.nameAliases = reader.readStringList(offsets[6]) ?? [];
  object.topCategoryId = reader.readLongOrNull(offsets[7]);
  object.topCategoryScore = reader.readLong(offsets[8]);
  object.totalTransactions = reader.readLong(offsets[9]);
  object.upiHandles = reader.readStringList(offsets[10]) ?? [];
  return object;
}

P _merchantIdentityModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _merchantIdentityModelGetId(MerchantIdentityModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _merchantIdentityModelGetLinks(
    MerchantIdentityModel object) {
  return [];
}

void _merchantIdentityModelAttach(
    IsarCollection<dynamic> col, Id id, MerchantIdentityModel object) {
  object.id = id;
}

extension MerchantIdentityModelByIndex
    on IsarCollection<MerchantIdentityModel> {
  Future<MerchantIdentityModel?> getByCanonicalKey(String canonicalKey) {
    return getByIndex(r'canonicalKey', [canonicalKey]);
  }

  MerchantIdentityModel? getByCanonicalKeySync(String canonicalKey) {
    return getByIndexSync(r'canonicalKey', [canonicalKey]);
  }

  Future<bool> deleteByCanonicalKey(String canonicalKey) {
    return deleteByIndex(r'canonicalKey', [canonicalKey]);
  }

  bool deleteByCanonicalKeySync(String canonicalKey) {
    return deleteByIndexSync(r'canonicalKey', [canonicalKey]);
  }

  Future<List<MerchantIdentityModel?>> getAllByCanonicalKey(
      List<String> canonicalKeyValues) {
    final values = canonicalKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'canonicalKey', values);
  }

  List<MerchantIdentityModel?> getAllByCanonicalKeySync(
      List<String> canonicalKeyValues) {
    final values = canonicalKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'canonicalKey', values);
  }

  Future<int> deleteAllByCanonicalKey(List<String> canonicalKeyValues) {
    final values = canonicalKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'canonicalKey', values);
  }

  int deleteAllByCanonicalKeySync(List<String> canonicalKeyValues) {
    final values = canonicalKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'canonicalKey', values);
  }

  Future<Id> putByCanonicalKey(MerchantIdentityModel object) {
    return putByIndex(r'canonicalKey', object);
  }

  Id putByCanonicalKeySync(MerchantIdentityModel object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'canonicalKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCanonicalKey(List<MerchantIdentityModel> objects) {
    return putAllByIndex(r'canonicalKey', objects);
  }

  List<Id> putAllByCanonicalKeySync(List<MerchantIdentityModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'canonicalKey', objects, saveLinks: saveLinks);
  }
}

extension MerchantIdentityModelQueryWhereSort
    on QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QWhere> {
  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MerchantIdentityModelQueryWhere on QueryBuilder<MerchantIdentityModel,
    MerchantIdentityModel, QWhereClause> {
  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      canonicalKeyEqualTo(String canonicalKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'canonicalKey',
        value: [canonicalKey],
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      canonicalKeyNotEqualTo(String canonicalKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'canonicalKey',
              lower: [],
              upper: [canonicalKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'canonicalKey',
              lower: [canonicalKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'canonicalKey',
              lower: [canonicalKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'canonicalKey',
              lower: [],
              upper: [canonicalKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      nameAliasesEqualTo(List<String> nameAliases) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nameAliases',
        value: [nameAliases],
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      nameAliasesNotEqualTo(List<String> nameAliases) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nameAliases',
              lower: [],
              upper: [nameAliases],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nameAliases',
              lower: [nameAliases],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nameAliases',
              lower: [nameAliases],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nameAliases',
              lower: [],
              upper: [nameAliases],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      upiHandlesEqualTo(List<String> upiHandles) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'upiHandles',
        value: [upiHandles],
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterWhereClause>
      upiHandlesNotEqualTo(List<String> upiHandles) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'upiHandles',
              lower: [],
              upper: [upiHandles],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'upiHandles',
              lower: [upiHandles],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'upiHandles',
              lower: [upiHandles],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'upiHandles',
              lower: [],
              upper: [upiHandles],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MerchantIdentityModelQueryFilter on QueryBuilder<
    MerchantIdentityModel, MerchantIdentityModel, QFilterCondition> {
  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> canonicalKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canonicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> canonicalKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'canonicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> canonicalKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'canonicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> canonicalKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'canonicalKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> canonicalKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'canonicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> canonicalKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'canonicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      canonicalKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'canonicalKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      canonicalKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'canonicalKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> canonicalKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'canonicalKey',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> canonicalKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'canonicalKey',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryScores',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryScores',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryScores',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryScores',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoryScores',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoryScores',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      categoryScoresElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoryScores',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      categoryScoresElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoryScores',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryScores',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoryScores',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categoryScores',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categoryScores',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categoryScores',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categoryScores',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categoryScores',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> categoryScoresLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categoryScores',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> isUserNamedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isUserNamed',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> lastSeenEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> lastSeenGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> lastSeenLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> lastSeenBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeen',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameAliases',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameAliases',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameAliases',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameAliases',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameAliases',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameAliases',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      nameAliasesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameAliases',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      nameAliasesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameAliases',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameAliases',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameAliases',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nameAliases',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nameAliases',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nameAliases',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nameAliases',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nameAliases',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> nameAliasesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'nameAliases',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'topCategoryId',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'topCategoryId',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topCategoryScore',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryScoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topCategoryScore',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryScoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topCategoryScore',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> topCategoryScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topCategoryScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> totalTransactionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalTransactions',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> totalTransactionsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalTransactions',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> totalTransactionsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalTransactions',
        value: value,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> totalTransactionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalTransactions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'upiHandles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'upiHandles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'upiHandles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'upiHandles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'upiHandles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'upiHandles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      upiHandlesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'upiHandles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
          QAfterFilterCondition>
      upiHandlesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'upiHandles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'upiHandles',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'upiHandles',
        value: '',
      ));
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'upiHandles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'upiHandles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'upiHandles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'upiHandles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'upiHandles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel,
      QAfterFilterCondition> upiHandlesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'upiHandles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension MerchantIdentityModelQueryObject on QueryBuilder<
    MerchantIdentityModel, MerchantIdentityModel, QFilterCondition> {}

extension MerchantIdentityModelQueryLinks on QueryBuilder<MerchantIdentityModel,
    MerchantIdentityModel, QFilterCondition> {}

extension MerchantIdentityModelQuerySortBy
    on QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QSortBy> {
  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByCanonicalKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalKey', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByCanonicalKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalKey', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByIsUserNamed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUserNamed', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByIsUserNamedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUserNamed', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByTopCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryId', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByTopCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryId', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByTopCategoryScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryScore', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByTopCategoryScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryScore', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByTotalTransactions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTransactions', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      sortByTotalTransactionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTransactions', Sort.desc);
    });
  }
}

extension MerchantIdentityModelQuerySortThenBy
    on QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QSortThenBy> {
  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByCanonicalKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalKey', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByCanonicalKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'canonicalKey', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByIsUserNamed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUserNamed', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByIsUserNamedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUserNamed', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByTopCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryId', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByTopCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryId', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByTopCategoryScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryScore', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByTopCategoryScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topCategoryScore', Sort.desc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByTotalTransactions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTransactions', Sort.asc);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QAfterSortBy>
      thenByTotalTransactionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTransactions', Sort.desc);
    });
  }
}

extension MerchantIdentityModelQueryWhereDistinct
    on QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct> {
  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByCanonicalKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'canonicalKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByCategoryScores() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryScores');
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByDisplayName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByIsUserNamed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUserNamed');
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeen');
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByNameAliases() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameAliases');
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByTopCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topCategoryId');
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByTopCategoryScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topCategoryScore');
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByTotalTransactions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalTransactions');
    });
  }

  QueryBuilder<MerchantIdentityModel, MerchantIdentityModel, QDistinct>
      distinctByUpiHandles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'upiHandles');
    });
  }
}

extension MerchantIdentityModelQueryProperty on QueryBuilder<
    MerchantIdentityModel, MerchantIdentityModel, QQueryProperty> {
  QueryBuilder<MerchantIdentityModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MerchantIdentityModel, String, QQueryOperations>
      canonicalKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'canonicalKey');
    });
  }

  QueryBuilder<MerchantIdentityModel, List<String>, QQueryOperations>
      categoryScoresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryScores');
    });
  }

  QueryBuilder<MerchantIdentityModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MerchantIdentityModel, String, QQueryOperations>
      displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<MerchantIdentityModel, bool, QQueryOperations>
      isUserNamedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUserNamed');
    });
  }

  QueryBuilder<MerchantIdentityModel, DateTime, QQueryOperations>
      lastSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeen');
    });
  }

  QueryBuilder<MerchantIdentityModel, List<String>, QQueryOperations>
      nameAliasesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameAliases');
    });
  }

  QueryBuilder<MerchantIdentityModel, int?, QQueryOperations>
      topCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topCategoryId');
    });
  }

  QueryBuilder<MerchantIdentityModel, int, QQueryOperations>
      topCategoryScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topCategoryScore');
    });
  }

  QueryBuilder<MerchantIdentityModel, int, QQueryOperations>
      totalTransactionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalTransactions');
    });
  }

  QueryBuilder<MerchantIdentityModel, List<String>, QQueryOperations>
      upiHandlesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'upiHandles');
    });
  }
}
