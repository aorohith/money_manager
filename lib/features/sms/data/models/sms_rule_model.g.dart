// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_rule_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmsRuleModelCollection on Isar {
  IsarCollection<SmsRuleModel> get smsRuleModels => this.collection();
}

const SmsRuleModelSchema = CollectionSchema(
  name: r'SmsRuleModel',
  id: 2347353345591806953,
  properties: {
    r'alwaysApply': PropertySchema(
      id: 0,
      name: r'alwaysApply',
      type: IsarType.bool,
    ),
    r'categoryId': PropertySchema(
      id: 1,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'lastUsed': PropertySchema(
      id: 2,
      name: r'lastUsed',
      type: IsarType.dateTime,
    ),
    r'merchantKey': PropertySchema(
      id: 3,
      name: r'merchantKey',
      type: IsarType.string,
    ),
    r'useCount': PropertySchema(
      id: 4,
      name: r'useCount',
      type: IsarType.long,
    ),
    r'userAlias': PropertySchema(
      id: 5,
      name: r'userAlias',
      type: IsarType.string,
    )
  },
  estimateSize: _smsRuleModelEstimateSize,
  serialize: _smsRuleModelSerialize,
  deserialize: _smsRuleModelDeserialize,
  deserializeProp: _smsRuleModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'merchantKey': IndexSchema(
      id: 4631582392492474772,
      name: r'merchantKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'merchantKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _smsRuleModelGetId,
  getLinks: _smsRuleModelGetLinks,
  attach: _smsRuleModelAttach,
  version: '3.1.0+1',
);

int _smsRuleModelEstimateSize(
  SmsRuleModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.merchantKey.length * 3;
  {
    final value = object.userAlias;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _smsRuleModelSerialize(
  SmsRuleModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.alwaysApply);
  writer.writeLong(offsets[1], object.categoryId);
  writer.writeDateTime(offsets[2], object.lastUsed);
  writer.writeString(offsets[3], object.merchantKey);
  writer.writeLong(offsets[4], object.useCount);
  writer.writeString(offsets[5], object.userAlias);
}

SmsRuleModel _smsRuleModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmsRuleModel(
    categoryId: reader.readLong(offsets[1]),
    merchantKey: reader.readString(offsets[3]),
  );
  object.alwaysApply = reader.readBool(offsets[0]);
  object.id = id;
  object.lastUsed = reader.readDateTime(offsets[2]);
  object.useCount = reader.readLong(offsets[4]);
  object.userAlias = reader.readStringOrNull(offsets[5]);
  return object;
}

P _smsRuleModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smsRuleModelGetId(SmsRuleModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smsRuleModelGetLinks(SmsRuleModel object) {
  return [];
}

void _smsRuleModelAttach(
    IsarCollection<dynamic> col, Id id, SmsRuleModel object) {
  object.id = id;
}

extension SmsRuleModelByIndex on IsarCollection<SmsRuleModel> {
  Future<SmsRuleModel?> getByMerchantKey(String merchantKey) {
    return getByIndex(r'merchantKey', [merchantKey]);
  }

  SmsRuleModel? getByMerchantKeySync(String merchantKey) {
    return getByIndexSync(r'merchantKey', [merchantKey]);
  }

  Future<bool> deleteByMerchantKey(String merchantKey) {
    return deleteByIndex(r'merchantKey', [merchantKey]);
  }

  bool deleteByMerchantKeySync(String merchantKey) {
    return deleteByIndexSync(r'merchantKey', [merchantKey]);
  }

  Future<List<SmsRuleModel?>> getAllByMerchantKey(
      List<String> merchantKeyValues) {
    final values = merchantKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'merchantKey', values);
  }

  List<SmsRuleModel?> getAllByMerchantKeySync(List<String> merchantKeyValues) {
    final values = merchantKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'merchantKey', values);
  }

  Future<int> deleteAllByMerchantKey(List<String> merchantKeyValues) {
    final values = merchantKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'merchantKey', values);
  }

  int deleteAllByMerchantKeySync(List<String> merchantKeyValues) {
    final values = merchantKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'merchantKey', values);
  }

  Future<Id> putByMerchantKey(SmsRuleModel object) {
    return putByIndex(r'merchantKey', object);
  }

  Id putByMerchantKeySync(SmsRuleModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'merchantKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMerchantKey(List<SmsRuleModel> objects) {
    return putAllByIndex(r'merchantKey', objects);
  }

  List<Id> putAllByMerchantKeySync(List<SmsRuleModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'merchantKey', objects, saveLinks: saveLinks);
  }
}

extension SmsRuleModelQueryWhereSort
    on QueryBuilder<SmsRuleModel, SmsRuleModel, QWhere> {
  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmsRuleModelQueryWhere
    on QueryBuilder<SmsRuleModel, SmsRuleModel, QWhereClause> {
  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterWhereClause>
      merchantKeyEqualTo(String merchantKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'merchantKey',
        value: [merchantKey],
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterWhereClause>
      merchantKeyNotEqualTo(String merchantKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantKey',
              lower: [],
              upper: [merchantKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantKey',
              lower: [merchantKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantKey',
              lower: [merchantKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantKey',
              lower: [],
              upper: [merchantKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SmsRuleModelQueryFilter
    on QueryBuilder<SmsRuleModel, SmsRuleModel, QFilterCondition> {
  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      alwaysApplyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alwaysApply',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      categoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      categoryIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      categoryIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      categoryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      lastUsedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      lastUsedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      lastUsedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      lastUsedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'merchantKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'merchantKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'merchantKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'merchantKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'merchantKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'merchantKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'merchantKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantKey',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      merchantKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'merchantKey',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      useCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      useCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'useCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      useCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'useCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      useCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'useCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userAlias',
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userAlias',
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userAlias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userAlias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userAlias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userAlias',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userAlias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userAlias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userAlias',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userAlias',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userAlias',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterFilterCondition>
      userAliasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userAlias',
        value: '',
      ));
    });
  }
}

extension SmsRuleModelQueryObject
    on QueryBuilder<SmsRuleModel, SmsRuleModel, QFilterCondition> {}

extension SmsRuleModelQueryLinks
    on QueryBuilder<SmsRuleModel, SmsRuleModel, QFilterCondition> {}

extension SmsRuleModelQuerySortBy
    on QueryBuilder<SmsRuleModel, SmsRuleModel, QSortBy> {
  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> sortByAlwaysApply() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alwaysApply', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy>
      sortByAlwaysApplyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alwaysApply', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy>
      sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> sortByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> sortByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> sortByMerchantKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantKey', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy>
      sortByMerchantKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantKey', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> sortByUseCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> sortByUseCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> sortByUserAlias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAlias', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> sortByUserAliasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAlias', Sort.desc);
    });
  }
}

extension SmsRuleModelQuerySortThenBy
    on QueryBuilder<SmsRuleModel, SmsRuleModel, QSortThenBy> {
  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByAlwaysApply() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alwaysApply', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy>
      thenByAlwaysApplyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alwaysApply', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy>
      thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByMerchantKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantKey', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy>
      thenByMerchantKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantKey', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByUseCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByUseCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useCount', Sort.desc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByUserAlias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAlias', Sort.asc);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QAfterSortBy> thenByUserAliasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userAlias', Sort.desc);
    });
  }
}

extension SmsRuleModelQueryWhereDistinct
    on QueryBuilder<SmsRuleModel, SmsRuleModel, QDistinct> {
  QueryBuilder<SmsRuleModel, SmsRuleModel, QDistinct> distinctByAlwaysApply() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alwaysApply');
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QDistinct> distinctByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsed');
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QDistinct> distinctByMerchantKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QDistinct> distinctByUseCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useCount');
    });
  }

  QueryBuilder<SmsRuleModel, SmsRuleModel, QDistinct> distinctByUserAlias(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userAlias', caseSensitive: caseSensitive);
    });
  }
}

extension SmsRuleModelQueryProperty
    on QueryBuilder<SmsRuleModel, SmsRuleModel, QQueryProperty> {
  QueryBuilder<SmsRuleModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmsRuleModel, bool, QQueryOperations> alwaysApplyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alwaysApply');
    });
  }

  QueryBuilder<SmsRuleModel, int, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<SmsRuleModel, DateTime, QQueryOperations> lastUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsed');
    });
  }

  QueryBuilder<SmsRuleModel, String, QQueryOperations> merchantKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantKey');
    });
  }

  QueryBuilder<SmsRuleModel, int, QQueryOperations> useCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useCount');
    });
  }

  QueryBuilder<SmsRuleModel, String?, QQueryOperations> userAliasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userAlias');
    });
  }
}
