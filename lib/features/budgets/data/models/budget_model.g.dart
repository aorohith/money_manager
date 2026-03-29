// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBudgetModelCollection on Isar {
  IsarCollection<BudgetModel> get budgetModels => this.collection();
}

const BudgetModelSchema = CollectionSchema(
  name: r'BudgetModel',
  id: 7247118153370490723,
  properties: {
    r'categoryId': PropertySchema(
      id: 0,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'limitAmount': PropertySchema(
      id: 1,
      name: r'limitAmount',
      type: IsarType.double,
    ),
    r'month': PropertySchema(
      id: 2,
      name: r'month',
      type: IsarType.long,
    ),
    r'period': PropertySchema(
      id: 3,
      name: r'period',
      type: IsarType.byte,
      enumMap: _BudgetModelperiodEnumValueMap,
    ),
    r'rolloverAmount': PropertySchema(
      id: 4,
      name: r'rolloverAmount',
      type: IsarType.double,
    ),
    r'rolloverEnabled': PropertySchema(
      id: 5,
      name: r'rolloverEnabled',
      type: IsarType.bool,
    ),
  },
  estimateSize: _budgetModelEstimateSize,
  serialize: _budgetModelSerialize,
  deserialize: _budgetModelDeserialize,
  deserializeProp: _budgetModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'month': IndexSchema(
      id: 1234567890123456789,
      name: r'month',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'month',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'categoryId': IndexSchema(
      id: 3456789012345678901,
      name: r'categoryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoryId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _budgetModelGetId,
  getLinks: _budgetModelGetLinks,
  attach: _budgetModelAttach,
  version: '3.1.0+1',
);

const _BudgetModelperiodEnumValueMap = {
  'monthly': 0,
  'weekly': 1,
  'yearly': 2,
};
const _BudgetModelperiodValueEnumMap = {
  0: BudgetPeriod.monthly,
  1: BudgetPeriod.weekly,
  2: BudgetPeriod.yearly,
};

int _budgetModelEstimateSize(
  BudgetModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _budgetModelSerialize(
  BudgetModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.categoryId ?? -9223372036854775808);
  writer.writeDouble(offsets[1], object.limitAmount);
  writer.writeLong(offsets[2], object.month);
  writer.writeByte(offsets[3], object.period.index);
  writer.writeDouble(offsets[4], object.rolloverAmount);
  writer.writeBool(offsets[5], object.rolloverEnabled);
}

BudgetModel _budgetModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final long0 = reader.readLongOrNull(offsets[0]);
  final object = BudgetModel(
    categoryId: long0 == -9223372036854775808 ? null : long0,
    limitAmount: reader.readDouble(offsets[1]),
    month: reader.readLong(offsets[2]),
    period: _BudgetModelperiodValueEnumMap[reader.readByteOrNull(offsets[3])] ??
        BudgetPeriod.monthly,
    rolloverEnabled: reader.readBool(offsets[5]),
  );
  object.id = id;
  object.rolloverAmount = reader.readDouble(offsets[4]);
  return object;
}

P _budgetModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      final long = reader.readLongOrNull(offset);
      return (long == -9223372036854775808 ? null : long) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (_BudgetModelperiodValueEnumMap[reader.readByteOrNull(offset)] ??
          BudgetPeriod.monthly) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _budgetModelGetId(BudgetModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _budgetModelGetLinks(BudgetModel object) {
  return [];
}

void _budgetModelAttach(
    IsarCollection<dynamic> col, Id id, BudgetModel object) {
  object.id = id;
}

extension BudgetModelQueryWhereSort
    on QueryBuilder<BudgetModel, BudgetModel, QWhere> {
  QueryBuilder<BudgetModel, BudgetModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BudgetModelQueryWhere
    on QueryBuilder<BudgetModel, BudgetModel, QWhereClause> {
  QueryBuilder<BudgetModel, BudgetModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BudgetModel, BudgetModel, QAfterWhereClause> monthEqualTo(
      int month) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'month',
        value: [month],
      ));
    });
  }
}

extension BudgetModelQueryFilter
    on QueryBuilder<BudgetModel, BudgetModel, QFilterCondition> {
  QueryBuilder<BudgetModel, BudgetModel, QAfterFilterCondition>
      categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoryId',
      ));
    });
  }

  QueryBuilder<BudgetModel, BudgetModel, QAfterFilterCondition>
      categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoryId',
      ));
    });
  }

  QueryBuilder<BudgetModel, BudgetModel, QAfterFilterCondition>
      categoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetModel, BudgetModel, QAfterFilterCondition>
      monthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<BudgetModel, BudgetModel, QAfterFilterCondition>
      periodEqualTo(BudgetPeriod value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'period',
        value: value,
      ));
    });
  }
}

extension BudgetModelQuerySortBy
    on QueryBuilder<BudgetModel, BudgetModel, QSortBy> {
  QueryBuilder<BudgetModel, BudgetModel, QAfterSortBy> sortByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<BudgetModel, BudgetModel, QAfterSortBy> sortByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }
}

extension BudgetModelQueryWhereDistinct
    on QueryBuilder<BudgetModel, BudgetModel, QDistinct> {
  QueryBuilder<BudgetModel, BudgetModel, QDistinct> distinctByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'month');
    });
  }
}

extension BudgetModelQueryProperty
    on QueryBuilder<BudgetModel, BudgetModel, QQueryProperty> {
  QueryBuilder<BudgetModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BudgetModel, int?, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<BudgetModel, double, QQueryOperations> limitAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'limitAmount');
    });
  }

  QueryBuilder<BudgetModel, int, QQueryOperations> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'month');
    });
  }

  QueryBuilder<BudgetModel, BudgetPeriod, QQueryOperations> periodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'period');
    });
  }

  QueryBuilder<BudgetModel, double, QQueryOperations>
      rolloverAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rolloverAmount');
    });
  }

  QueryBuilder<BudgetModel, bool, QQueryOperations>
      rolloverEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rolloverEnabled');
    });
  }
}
