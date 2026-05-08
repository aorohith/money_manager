// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_parsed_transaction.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmsParsedTransactionCollection on Isar {
  IsarCollection<SmsParsedTransaction> get smsParsedTransactions =>
      this.collection();
}

const SmsParsedTransactionSchema = CollectionSchema(
  name: r'SmsParsedTransaction',
  id: 8366743219604330605,
  properties: {
    r'accountHint': PropertySchema(
      id: 0,
      name: r'accountHint',
      type: IsarType.string,
    ),
    r'amount': PropertySchema(
      id: 1,
      name: r'amount',
      type: IsarType.double,
    ),
    r'availableBalance': PropertySchema(
      id: 2,
      name: r'availableBalance',
      type: IsarType.double,
    ),
    r'confidence': PropertySchema(
      id: 3,
      name: r'confidence',
      type: IsarType.double,
    ),
    r'detectedAt': PropertySchema(
      id: 4,
      name: r'detectedAt',
      type: IsarType.dateTime,
    ),
    r'linkedTransactionId': PropertySchema(
      id: 5,
      name: r'linkedTransactionId',
      type: IsarType.long,
    ),
    r'merchantNormalized': PropertySchema(
      id: 6,
      name: r'merchantNormalized',
      type: IsarType.string,
    ),
    r'merchantRaw': PropertySchema(
      id: 7,
      name: r'merchantRaw',
      type: IsarType.string,
    ),
    r'paymentMethod': PropertySchema(
      id: 8,
      name: r'paymentMethod',
      type: IsarType.string,
    ),
    r'rawText': PropertySchema(
      id: 9,
      name: r'rawText',
      type: IsarType.string,
    ),
    r'referenceNumber': PropertySchema(
      id: 10,
      name: r'referenceNumber',
      type: IsarType.string,
    ),
    r'senderAddress': PropertySchema(
      id: 11,
      name: r'senderAddress',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 12,
      name: r'status',
      type: IsarType.byte,
      enumMap: _SmsParsedTransactionstatusEnumValueMap,
    ),
    r'suggestedCategoryId': PropertySchema(
      id: 13,
      name: r'suggestedCategoryId',
      type: IsarType.long,
    ),
    r'transactionDate': PropertySchema(
      id: 14,
      name: r'transactionDate',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _smsParsedTransactionEstimateSize,
  serialize: _smsParsedTransactionSerialize,
  deserialize: _smsParsedTransactionDeserialize,
  deserializeProp: _smsParsedTransactionDeserializeProp,
  idName: r'id',
  indexes: {
    r'amount': IndexSchema(
      id: 3252599345080253594,
      name: r'amount',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'amount',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'merchantNormalized': IndexSchema(
      id: -8471146453531931862,
      name: r'merchantNormalized',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'merchantNormalized',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'transactionDate': IndexSchema(
      id: 3386085016894654755,
      name: r'transactionDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transactionDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _smsParsedTransactionGetId,
  getLinks: _smsParsedTransactionGetLinks,
  attach: _smsParsedTransactionAttach,
  version: '3.1.0+1',
);

int _smsParsedTransactionEstimateSize(
  SmsParsedTransaction object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.accountHint;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.merchantNormalized.length * 3;
  bytesCount += 3 + object.merchantRaw.length * 3;
  bytesCount += 3 + object.paymentMethod.length * 3;
  bytesCount += 3 + object.rawText.length * 3;
  {
    final value = object.referenceNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.senderAddress.length * 3;
  return bytesCount;
}

void _smsParsedTransactionSerialize(
  SmsParsedTransaction object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountHint);
  writer.writeDouble(offsets[1], object.amount);
  writer.writeDouble(offsets[2], object.availableBalance);
  writer.writeDouble(offsets[3], object.confidence);
  writer.writeDateTime(offsets[4], object.detectedAt);
  writer.writeLong(offsets[5], object.linkedTransactionId);
  writer.writeString(offsets[6], object.merchantNormalized);
  writer.writeString(offsets[7], object.merchantRaw);
  writer.writeString(offsets[8], object.paymentMethod);
  writer.writeString(offsets[9], object.rawText);
  writer.writeString(offsets[10], object.referenceNumber);
  writer.writeString(offsets[11], object.senderAddress);
  writer.writeByte(offsets[12], object.status.index);
  writer.writeLong(offsets[13], object.suggestedCategoryId);
  writer.writeDateTime(offsets[14], object.transactionDate);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

SmsParsedTransaction _smsParsedTransactionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmsParsedTransaction(
    accountHint: reader.readStringOrNull(offsets[0]),
    amount: reader.readDouble(offsets[1]),
    availableBalance: reader.readDoubleOrNull(offsets[2]),
    confidence: reader.readDoubleOrNull(offsets[3]),
    linkedTransactionId: reader.readLongOrNull(offsets[5]),
    merchantNormalized: reader.readString(offsets[6]),
    merchantRaw: reader.readString(offsets[7]),
    paymentMethod: reader.readString(offsets[8]),
    rawText: reader.readString(offsets[9]),
    referenceNumber: reader.readStringOrNull(offsets[10]),
    senderAddress: reader.readString(offsets[11]),
    status: _SmsParsedTransactionstatusValueEnumMap[
            reader.readByteOrNull(offsets[12])] ??
        SmsReviewStatus.pending,
    suggestedCategoryId: reader.readLongOrNull(offsets[13]),
    transactionDate: reader.readDateTime(offsets[14]),
  );
  object.detectedAt = reader.readDateTime(offsets[4]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[15]);
  return object;
}

P _smsParsedTransactionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (_SmsParsedTransactionstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SmsReviewStatus.pending) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SmsParsedTransactionstatusEnumValueMap = {
  'pending': 0,
  'approved': 1,
  'skipped': 2,
  'duplicate': 3,
};
const _SmsParsedTransactionstatusValueEnumMap = {
  0: SmsReviewStatus.pending,
  1: SmsReviewStatus.approved,
  2: SmsReviewStatus.skipped,
  3: SmsReviewStatus.duplicate,
};

Id _smsParsedTransactionGetId(SmsParsedTransaction object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smsParsedTransactionGetLinks(
    SmsParsedTransaction object) {
  return [];
}

void _smsParsedTransactionAttach(
    IsarCollection<dynamic> col, Id id, SmsParsedTransaction object) {
  object.id = id;
}

extension SmsParsedTransactionQueryWhereSort
    on QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QWhere> {
  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhere>
      anyAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'amount'),
      );
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhere>
      anyTransactionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'transactionDate'),
      );
    });
  }
}

extension SmsParsedTransactionQueryWhere
    on QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QWhereClause> {
  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      amountEqualTo(double amount) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'amount',
        value: [amount],
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      amountNotEqualTo(double amount) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'amount',
              lower: [],
              upper: [amount],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'amount',
              lower: [amount],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'amount',
              lower: [amount],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'amount',
              lower: [],
              upper: [amount],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      amountGreaterThan(
    double amount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'amount',
        lower: [amount],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      amountLessThan(
    double amount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'amount',
        lower: [],
        upper: [amount],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      amountBetween(
    double lowerAmount,
    double upperAmount, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'amount',
        lower: [lowerAmount],
        includeLower: includeLower,
        upper: [upperAmount],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      merchantNormalizedEqualTo(String merchantNormalized) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'merchantNormalized',
        value: [merchantNormalized],
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      merchantNormalizedNotEqualTo(String merchantNormalized) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantNormalized',
              lower: [],
              upper: [merchantNormalized],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantNormalized',
              lower: [merchantNormalized],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantNormalized',
              lower: [merchantNormalized],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'merchantNormalized',
              lower: [],
              upper: [merchantNormalized],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      transactionDateEqualTo(DateTime transactionDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'transactionDate',
        value: [transactionDate],
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      transactionDateNotEqualTo(DateTime transactionDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionDate',
              lower: [],
              upper: [transactionDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionDate',
              lower: [transactionDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionDate',
              lower: [transactionDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'transactionDate',
              lower: [],
              upper: [transactionDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      transactionDateGreaterThan(
    DateTime transactionDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'transactionDate',
        lower: [transactionDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      transactionDateLessThan(
    DateTime transactionDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'transactionDate',
        lower: [],
        upper: [transactionDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterWhereClause>
      transactionDateBetween(
    DateTime lowerTransactionDate,
    DateTime upperTransactionDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'transactionDate',
        lower: [lowerTransactionDate],
        includeLower: includeLower,
        upper: [upperTransactionDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SmsParsedTransactionQueryFilter on QueryBuilder<SmsParsedTransaction,
    SmsParsedTransaction, QFilterCondition> {
  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accountHint',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accountHint',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountHint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      accountHintContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountHint',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      accountHintMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountHint',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountHint',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> accountHintIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountHint',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> availableBalanceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'availableBalance',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> availableBalanceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'availableBalance',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> availableBalanceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'availableBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> availableBalanceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'availableBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> availableBalanceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'availableBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> availableBalanceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'availableBalance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> confidenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'confidence',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> confidenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'confidence',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> confidenceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> confidenceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> confidenceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> confidenceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> detectedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> detectedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'detectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> detectedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'detectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> detectedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'detectedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> linkedTransactionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'linkedTransactionId',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> linkedTransactionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'linkedTransactionId',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> linkedTransactionIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> linkedTransactionIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> linkedTransactionIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> linkedTransactionIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantNormalizedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantNormalized',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantNormalizedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'merchantNormalized',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantNormalizedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'merchantNormalized',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantNormalizedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'merchantNormalized',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantNormalizedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'merchantNormalized',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantNormalizedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'merchantNormalized',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      merchantNormalizedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'merchantNormalized',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      merchantNormalizedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'merchantNormalized',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantNormalizedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantNormalized',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantNormalizedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'merchantNormalized',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantRawEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantRawGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'merchantRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantRawLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'merchantRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantRawBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'merchantRaw',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantRawStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'merchantRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantRawEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'merchantRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      merchantRawContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'merchantRaw',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      merchantRawMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'merchantRaw',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantRawIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'merchantRaw',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> merchantRawIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'merchantRaw',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> paymentMethodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> paymentMethodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> paymentMethodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> paymentMethodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> paymentMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> paymentMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      paymentMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      paymentMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> paymentMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> paymentMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> rawTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> rawTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> rawTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> rawTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> rawTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> rawTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      rawTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      rawTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> rawTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawText',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> rawTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawText',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referenceNumber',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referenceNumber',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      referenceNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      referenceNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referenceNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> referenceNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referenceNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> senderAddressEqualTo(
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> senderAddressGreaterThan(
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> senderAddressLessThan(
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> senderAddressBetween(
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> senderAddressStartsWith(
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> senderAddressEndsWith(
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

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      senderAddressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
          QAfterFilterCondition>
      senderAddressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> senderAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> senderAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> statusEqualTo(SmsReviewStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> statusGreaterThan(
    SmsReviewStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> statusLessThan(
    SmsReviewStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> statusBetween(
    SmsReviewStatus lower,
    SmsReviewStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> suggestedCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'suggestedCategoryId',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> suggestedCategoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'suggestedCategoryId',
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> suggestedCategoryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'suggestedCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> suggestedCategoryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'suggestedCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> suggestedCategoryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'suggestedCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> suggestedCategoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'suggestedCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> transactionDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> transactionDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transactionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> transactionDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transactionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> transactionDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transactionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SmsParsedTransactionQueryObject on QueryBuilder<SmsParsedTransaction,
    SmsParsedTransaction, QFilterCondition> {}

extension SmsParsedTransactionQueryLinks on QueryBuilder<SmsParsedTransaction,
    SmsParsedTransaction, QFilterCondition> {}

extension SmsParsedTransactionQuerySortBy
    on QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QSortBy> {
  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByAccountHint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountHint', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByAccountHintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountHint', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByAvailableBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableBalance', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByAvailableBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableBalance', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByDetectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByLinkedTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTransactionId', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByLinkedTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTransactionId', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByMerchantNormalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantNormalized', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByMerchantNormalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantNormalized', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByMerchantRaw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantRaw', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByMerchantRawDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantRaw', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByReferenceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByReferenceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortBySenderAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAddress', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortBySenderAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAddress', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortBySuggestedCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedCategoryId', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortBySuggestedCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedCategoryId', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByTransactionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionDate', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByTransactionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionDate', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SmsParsedTransactionQuerySortThenBy
    on QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QSortThenBy> {
  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByAccountHint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountHint', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByAccountHintDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountHint', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByAvailableBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableBalance', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByAvailableBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableBalance', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidence', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByDetectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detectedAt', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByLinkedTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTransactionId', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByLinkedTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'linkedTransactionId', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByMerchantNormalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantNormalized', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByMerchantNormalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantNormalized', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByMerchantRaw() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantRaw', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByMerchantRawDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantRaw', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByPaymentMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByPaymentMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentMethod', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByReferenceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByReferenceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenBySenderAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAddress', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenBySenderAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAddress', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenBySuggestedCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedCategoryId', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenBySuggestedCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suggestedCategoryId', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByTransactionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionDate', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByTransactionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionDate', Sort.desc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SmsParsedTransactionQueryWhereDistinct
    on QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct> {
  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByAccountHint({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountHint', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByAvailableBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'availableBalance');
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidence');
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByDetectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detectedAt');
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByLinkedTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedTransactionId');
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByMerchantNormalized({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantNormalized',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByMerchantRaw({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantRaw', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByPaymentMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentMethod',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByRawText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByReferenceNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctBySenderAddress({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderAddress',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctBySuggestedCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suggestedCategoryId');
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByTransactionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionDate');
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsParsedTransaction, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SmsParsedTransactionQueryProperty on QueryBuilder<
    SmsParsedTransaction, SmsParsedTransaction, QQueryProperty> {
  QueryBuilder<SmsParsedTransaction, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmsParsedTransaction, String?, QQueryOperations>
      accountHintProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountHint');
    });
  }

  QueryBuilder<SmsParsedTransaction, double, QQueryOperations>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<SmsParsedTransaction, double?, QQueryOperations>
      availableBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'availableBalance');
    });
  }

  QueryBuilder<SmsParsedTransaction, double?, QQueryOperations>
      confidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidence');
    });
  }

  QueryBuilder<SmsParsedTransaction, DateTime, QQueryOperations>
      detectedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detectedAt');
    });
  }

  QueryBuilder<SmsParsedTransaction, int?, QQueryOperations>
      linkedTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedTransactionId');
    });
  }

  QueryBuilder<SmsParsedTransaction, String, QQueryOperations>
      merchantNormalizedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantNormalized');
    });
  }

  QueryBuilder<SmsParsedTransaction, String, QQueryOperations>
      merchantRawProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantRaw');
    });
  }

  QueryBuilder<SmsParsedTransaction, String, QQueryOperations>
      paymentMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentMethod');
    });
  }

  QueryBuilder<SmsParsedTransaction, String, QQueryOperations>
      rawTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawText');
    });
  }

  QueryBuilder<SmsParsedTransaction, String?, QQueryOperations>
      referenceNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceNumber');
    });
  }

  QueryBuilder<SmsParsedTransaction, String, QQueryOperations>
      senderAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderAddress');
    });
  }

  QueryBuilder<SmsParsedTransaction, SmsReviewStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SmsParsedTransaction, int?, QQueryOperations>
      suggestedCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suggestedCategoryId');
    });
  }

  QueryBuilder<SmsParsedTransaction, DateTime, QQueryOperations>
      transactionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionDate');
    });
  }

  QueryBuilder<SmsParsedTransaction, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
