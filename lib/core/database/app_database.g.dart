// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FeedsTable extends Feeds with TableInfo<$FeedsTable, Feed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedTypeMeta = const VerificationMeta(
    'feedType',
  );
  @override
  late final GeneratedColumn<String> feedType = GeneratedColumn<String>(
    'feed_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedMeta = const VerificationMeta(
    'published',
  );
  @override
  late final GeneratedColumn<DateTime> published = GeneratedColumn<DateTime>(
    'published',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requiresExternalBrowserMeta =
      const VerificationMeta('requiresExternalBrowser');
  @override
  late final GeneratedColumn<bool> requiresExternalBrowser =
      GeneratedColumn<bool>(
        'requires_external_browser',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("requires_external_browser" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFetchErrorMeta = const VerificationMeta(
    'lastFetchError',
  );
  @override
  late final GeneratedColumn<String> lastFetchError = GeneratedColumn<String>(
    'last_fetch_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFetchAtMeta = const VerificationMeta(
    'lastFetchAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetchAt = GeneratedColumn<DateTime>(
    'last_fetch_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    feedType,
    title,
    description,
    link,
    published,
    deletedAt,
    folderId,
    requiresExternalBrowser,
    spaceId,
    lastFetchError,
    lastFetchAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Feed> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('feed_type')) {
      context.handle(
        _feedTypeMeta,
        feedType.isAcceptableOrUnknown(data['feed_type']!, _feedTypeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    if (data.containsKey('published')) {
      context.handle(
        _publishedMeta,
        published.isAcceptableOrUnknown(data['published']!, _publishedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('requires_external_browser')) {
      context.handle(
        _requiresExternalBrowserMeta,
        requiresExternalBrowser.isAcceptableOrUnknown(
          data['requires_external_browser']!,
          _requiresExternalBrowserMeta,
        ),
      );
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    }
    if (data.containsKey('last_fetch_error')) {
      context.handle(
        _lastFetchErrorMeta,
        lastFetchError.isAcceptableOrUnknown(
          data['last_fetch_error']!,
          _lastFetchErrorMeta,
        ),
      );
    }
    if (data.containsKey('last_fetch_at')) {
      context.handle(
        _lastFetchAtMeta,
        lastFetchAt.isAcceptableOrUnknown(
          data['last_fetch_at']!,
          _lastFetchAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Feed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Feed(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      feedType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_type'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
      published: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      requiresExternalBrowser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_external_browser'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      ),
      lastFetchError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_fetch_error'],
      ),
      lastFetchAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetch_at'],
      ),
    );
  }

  @override
  $FeedsTable createAlias(String alias) {
    return $FeedsTable(attachedDatabase, alias);
  }
}

class Feed extends DataClass implements Insertable<Feed> {
  final String id;
  final String url;
  final String? feedType;
  final String? title;
  final String? description;
  final String? link;
  final DateTime? published;
  final DateTime? deletedAt;
  final String? folderId;
  final bool requiresExternalBrowser;
  final String? spaceId;
  final String? lastFetchError;
  final DateTime? lastFetchAt;
  const Feed({
    required this.id,
    required this.url,
    this.feedType,
    this.title,
    this.description,
    this.link,
    this.published,
    this.deletedAt,
    this.folderId,
    required this.requiresExternalBrowser,
    this.spaceId,
    this.lastFetchError,
    this.lastFetchAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || feedType != null) {
      map['feed_type'] = Variable<String>(feedType);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    if (!nullToAbsent || published != null) {
      map['published'] = Variable<DateTime>(published);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['requires_external_browser'] = Variable<bool>(requiresExternalBrowser);
    if (!nullToAbsent || spaceId != null) {
      map['space_id'] = Variable<String>(spaceId);
    }
    if (!nullToAbsent || lastFetchError != null) {
      map['last_fetch_error'] = Variable<String>(lastFetchError);
    }
    if (!nullToAbsent || lastFetchAt != null) {
      map['last_fetch_at'] = Variable<DateTime>(lastFetchAt);
    }
    return map;
  }

  FeedsCompanion toCompanion(bool nullToAbsent) {
    return FeedsCompanion(
      id: Value(id),
      url: Value(url),
      feedType: feedType == null && nullToAbsent
          ? const Value.absent()
          : Value(feedType),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      published: published == null && nullToAbsent
          ? const Value.absent()
          : Value(published),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      requiresExternalBrowser: Value(requiresExternalBrowser),
      spaceId: spaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(spaceId),
      lastFetchError: lastFetchError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetchError),
      lastFetchAt: lastFetchAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetchAt),
    );
  }

  factory Feed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Feed(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      feedType: serializer.fromJson<String?>(json['feedType']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      link: serializer.fromJson<String?>(json['link']),
      published: serializer.fromJson<DateTime?>(json['published']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      requiresExternalBrowser: serializer.fromJson<bool>(
        json['requiresExternalBrowser'],
      ),
      spaceId: serializer.fromJson<String?>(json['spaceId']),
      lastFetchError: serializer.fromJson<String?>(json['lastFetchError']),
      lastFetchAt: serializer.fromJson<DateTime?>(json['lastFetchAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'feedType': serializer.toJson<String?>(feedType),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'link': serializer.toJson<String?>(link),
      'published': serializer.toJson<DateTime?>(published),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'folderId': serializer.toJson<String?>(folderId),
      'requiresExternalBrowser': serializer.toJson<bool>(
        requiresExternalBrowser,
      ),
      'spaceId': serializer.toJson<String?>(spaceId),
      'lastFetchError': serializer.toJson<String?>(lastFetchError),
      'lastFetchAt': serializer.toJson<DateTime?>(lastFetchAt),
    };
  }

  Feed copyWith({
    String? id,
    String? url,
    Value<String?> feedType = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> link = const Value.absent(),
    Value<DateTime?> published = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> folderId = const Value.absent(),
    bool? requiresExternalBrowser,
    Value<String?> spaceId = const Value.absent(),
    Value<String?> lastFetchError = const Value.absent(),
    Value<DateTime?> lastFetchAt = const Value.absent(),
  }) => Feed(
    id: id ?? this.id,
    url: url ?? this.url,
    feedType: feedType.present ? feedType.value : this.feedType,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    link: link.present ? link.value : this.link,
    published: published.present ? published.value : this.published,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    folderId: folderId.present ? folderId.value : this.folderId,
    requiresExternalBrowser:
        requiresExternalBrowser ?? this.requiresExternalBrowser,
    spaceId: spaceId.present ? spaceId.value : this.spaceId,
    lastFetchError: lastFetchError.present
        ? lastFetchError.value
        : this.lastFetchError,
    lastFetchAt: lastFetchAt.present ? lastFetchAt.value : this.lastFetchAt,
  );
  Feed copyWithCompanion(FeedsCompanion data) {
    return Feed(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      feedType: data.feedType.present ? data.feedType.value : this.feedType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      link: data.link.present ? data.link.value : this.link,
      published: data.published.present ? data.published.value : this.published,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      requiresExternalBrowser: data.requiresExternalBrowser.present
          ? data.requiresExternalBrowser.value
          : this.requiresExternalBrowser,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      lastFetchError: data.lastFetchError.present
          ? data.lastFetchError.value
          : this.lastFetchError,
      lastFetchAt: data.lastFetchAt.present
          ? data.lastFetchAt.value
          : this.lastFetchAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Feed(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('feedType: $feedType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('link: $link, ')
          ..write('published: $published, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('folderId: $folderId, ')
          ..write('requiresExternalBrowser: $requiresExternalBrowser, ')
          ..write('spaceId: $spaceId, ')
          ..write('lastFetchError: $lastFetchError, ')
          ..write('lastFetchAt: $lastFetchAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    feedType,
    title,
    description,
    link,
    published,
    deletedAt,
    folderId,
    requiresExternalBrowser,
    spaceId,
    lastFetchError,
    lastFetchAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Feed &&
          other.id == this.id &&
          other.url == this.url &&
          other.feedType == this.feedType &&
          other.title == this.title &&
          other.description == this.description &&
          other.link == this.link &&
          other.published == this.published &&
          other.deletedAt == this.deletedAt &&
          other.folderId == this.folderId &&
          other.requiresExternalBrowser == this.requiresExternalBrowser &&
          other.spaceId == this.spaceId &&
          other.lastFetchError == this.lastFetchError &&
          other.lastFetchAt == this.lastFetchAt);
}

class FeedsCompanion extends UpdateCompanion<Feed> {
  final Value<String> id;
  final Value<String> url;
  final Value<String?> feedType;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> link;
  final Value<DateTime?> published;
  final Value<DateTime?> deletedAt;
  final Value<String?> folderId;
  final Value<bool> requiresExternalBrowser;
  final Value<String?> spaceId;
  final Value<String?> lastFetchError;
  final Value<DateTime?> lastFetchAt;
  final Value<int> rowid;
  const FeedsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.feedType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.link = const Value.absent(),
    this.published = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.folderId = const Value.absent(),
    this.requiresExternalBrowser = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.lastFetchError = const Value.absent(),
    this.lastFetchAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedsCompanion.insert({
    required String id,
    required String url,
    this.feedType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.link = const Value.absent(),
    this.published = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.folderId = const Value.absent(),
    this.requiresExternalBrowser = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.lastFetchError = const Value.absent(),
    this.lastFetchAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url);
  static Insertable<Feed> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? feedType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? link,
    Expression<DateTime>? published,
    Expression<DateTime>? deletedAt,
    Expression<String>? folderId,
    Expression<bool>? requiresExternalBrowser,
    Expression<String>? spaceId,
    Expression<String>? lastFetchError,
    Expression<DateTime>? lastFetchAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (feedType != null) 'feed_type': feedType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (link != null) 'link': link,
      if (published != null) 'published': published,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (folderId != null) 'folder_id': folderId,
      if (requiresExternalBrowser != null)
        'requires_external_browser': requiresExternalBrowser,
      if (spaceId != null) 'space_id': spaceId,
      if (lastFetchError != null) 'last_fetch_error': lastFetchError,
      if (lastFetchAt != null) 'last_fetch_at': lastFetchAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedsCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String?>? feedType,
    Value<String?>? title,
    Value<String?>? description,
    Value<String?>? link,
    Value<DateTime?>? published,
    Value<DateTime?>? deletedAt,
    Value<String?>? folderId,
    Value<bool>? requiresExternalBrowser,
    Value<String?>? spaceId,
    Value<String?>? lastFetchError,
    Value<DateTime?>? lastFetchAt,
    Value<int>? rowid,
  }) {
    return FeedsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      feedType: feedType ?? this.feedType,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      published: published ?? this.published,
      deletedAt: deletedAt ?? this.deletedAt,
      folderId: folderId ?? this.folderId,
      requiresExternalBrowser:
          requiresExternalBrowser ?? this.requiresExternalBrowser,
      spaceId: spaceId ?? this.spaceId,
      lastFetchError: lastFetchError ?? this.lastFetchError,
      lastFetchAt: lastFetchAt ?? this.lastFetchAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (feedType.present) {
      map['feed_type'] = Variable<String>(feedType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (published.present) {
      map['published'] = Variable<DateTime>(published.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (requiresExternalBrowser.present) {
      map['requires_external_browser'] = Variable<bool>(
        requiresExternalBrowser.value,
      );
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (lastFetchError.present) {
      map['last_fetch_error'] = Variable<String>(lastFetchError.value);
    }
    if (lastFetchAt.present) {
      map['last_fetch_at'] = Variable<DateTime>(lastFetchAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('feedType: $feedType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('link: $link, ')
          ..write('published: $published, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('folderId: $folderId, ')
          ..write('requiresExternalBrowser: $requiresExternalBrowser, ')
          ..write('spaceId: $spaceId, ')
          ..write('lastFetchError: $lastFetchError, ')
          ..write('lastFetchAt: $lastFetchAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<String> feedId = GeneratedColumn<String>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedMeta = const VerificationMeta(
    'published',
  );
  @override
  late final GeneratedColumn<DateTime> published = GeneratedColumn<DateTime>(
    'published',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unreadMeta = const VerificationMeta('unread');
  @override
  late final GeneratedColumn<bool> unread = GeneratedColumn<bool>(
    'unread',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("unread" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _flaggedMeta = const VerificationMeta(
    'flagged',
  );
  @override
  late final GeneratedColumn<bool> flagged = GeneratedColumn<bool>(
    'flagged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("flagged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedId,
    title,
    link,
    summary,
    published,
    unread,
    flagged,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('published')) {
      context.handle(
        _publishedMeta,
        published.isAcceptableOrUnknown(data['published']!, _publishedMeta),
      );
    }
    if (data.containsKey('unread')) {
      context.handle(
        _unreadMeta,
        unread.isAcceptableOrUnknown(data['unread']!, _unreadMeta),
      );
    }
    if (data.containsKey('flagged')) {
      context.handle(
        _flaggedMeta,
        flagged.isAcceptableOrUnknown(data['flagged']!, _flaggedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      published: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published'],
      ),
      unread: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}unread'],
      )!,
      flagged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}flagged'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final String id;
  final String feedId;
  final String? title;
  final String? link;
  final String? summary;
  final DateTime? published;
  final bool unread;
  final bool flagged;
  const Entry({
    required this.id,
    required this.feedId,
    this.title,
    this.link,
    this.summary,
    this.published,
    required this.unread,
    required this.flagged,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['feed_id'] = Variable<String>(feedId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || published != null) {
      map['published'] = Variable<DateTime>(published);
    }
    map['unread'] = Variable<bool>(unread);
    map['flagged'] = Variable<bool>(flagged);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      feedId: Value(feedId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      published: published == null && nullToAbsent
          ? const Value.absent()
          : Value(published),
      unread: Value(unread),
      flagged: Value(flagged),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<String>(json['id']),
      feedId: serializer.fromJson<String>(json['feedId']),
      title: serializer.fromJson<String?>(json['title']),
      link: serializer.fromJson<String?>(json['link']),
      summary: serializer.fromJson<String?>(json['summary']),
      published: serializer.fromJson<DateTime?>(json['published']),
      unread: serializer.fromJson<bool>(json['unread']),
      flagged: serializer.fromJson<bool>(json['flagged']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'feedId': serializer.toJson<String>(feedId),
      'title': serializer.toJson<String?>(title),
      'link': serializer.toJson<String?>(link),
      'summary': serializer.toJson<String?>(summary),
      'published': serializer.toJson<DateTime?>(published),
      'unread': serializer.toJson<bool>(unread),
      'flagged': serializer.toJson<bool>(flagged),
    };
  }

  Entry copyWith({
    String? id,
    String? feedId,
    Value<String?> title = const Value.absent(),
    Value<String?> link = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<DateTime?> published = const Value.absent(),
    bool? unread,
    bool? flagged,
  }) => Entry(
    id: id ?? this.id,
    feedId: feedId ?? this.feedId,
    title: title.present ? title.value : this.title,
    link: link.present ? link.value : this.link,
    summary: summary.present ? summary.value : this.summary,
    published: published.present ? published.value : this.published,
    unread: unread ?? this.unread,
    flagged: flagged ?? this.flagged,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      title: data.title.present ? data.title.value : this.title,
      link: data.link.present ? data.link.value : this.link,
      summary: data.summary.present ? data.summary.value : this.summary,
      published: data.published.present ? data.published.value : this.published,
      unread: data.unread.present ? data.unread.value : this.unread,
      flagged: data.flagged.present ? data.flagged.value : this.flagged,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('title: $title, ')
          ..write('link: $link, ')
          ..write('summary: $summary, ')
          ..write('published: $published, ')
          ..write('unread: $unread, ')
          ..write('flagged: $flagged')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, feedId, title, link, summary, published, unread, flagged);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.feedId == this.feedId &&
          other.title == this.title &&
          other.link == this.link &&
          other.summary == this.summary &&
          other.published == this.published &&
          other.unread == this.unread &&
          other.flagged == this.flagged);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> id;
  final Value<String> feedId;
  final Value<String?> title;
  final Value<String?> link;
  final Value<String?> summary;
  final Value<DateTime?> published;
  final Value<bool> unread;
  final Value<bool> flagged;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.feedId = const Value.absent(),
    this.title = const Value.absent(),
    this.link = const Value.absent(),
    this.summary = const Value.absent(),
    this.published = const Value.absent(),
    this.unread = const Value.absent(),
    this.flagged = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String feedId,
    this.title = const Value.absent(),
    this.link = const Value.absent(),
    this.summary = const Value.absent(),
    this.published = const Value.absent(),
    this.unread = const Value.absent(),
    this.flagged = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       feedId = Value(feedId);
  static Insertable<Entry> custom({
    Expression<String>? id,
    Expression<String>? feedId,
    Expression<String>? title,
    Expression<String>? link,
    Expression<String>? summary,
    Expression<DateTime>? published,
    Expression<bool>? unread,
    Expression<bool>? flagged,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedId != null) 'feed_id': feedId,
      if (title != null) 'title': title,
      if (link != null) 'link': link,
      if (summary != null) 'summary': summary,
      if (published != null) 'published': published,
      if (unread != null) 'unread': unread,
      if (flagged != null) 'flagged': flagged,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? feedId,
    Value<String?>? title,
    Value<String?>? link,
    Value<String?>? summary,
    Value<DateTime?>? published,
    Value<bool>? unread,
    Value<bool>? flagged,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      title: title ?? this.title,
      link: link ?? this.link,
      summary: summary ?? this.summary,
      published: published ?? this.published,
      unread: unread ?? this.unread,
      flagged: flagged ?? this.flagged,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<String>(feedId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (published.present) {
      map['published'] = Variable<DateTime>(published.value);
    }
    if (unread.present) {
      map['unread'] = Variable<bool>(unread.value);
    }
    if (flagged.present) {
      map['flagged'] = Variable<bool>(flagged.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('title: $title, ')
          ..write('link: $link, ')
          ..write('summary: $summary, ')
          ..write('published: $published, ')
          ..write('unread: $unread, ')
          ..write('flagged: $flagged, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _parentMeta = const VerificationMeta('parent');
  @override
  late final GeneratedColumn<String> parent = GeneratedColumn<String>(
    'parent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    parent,
    order,
    spaceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('parent')) {
      context.handle(
        _parentMeta,
        parent.isAcceptableOrUnknown(data['parent']!, _parentMeta),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      parent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent'],
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      ),
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final String id;
  final String name;
  final int type;
  final String? parent;
  final int order;
  final String? spaceId;
  const Folder({
    required this.id,
    required this.name,
    required this.type,
    this.parent,
    required this.order,
    this.spaceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || parent != null) {
      map['parent'] = Variable<String>(parent);
    }
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || spaceId != null) {
      map['space_id'] = Variable<String>(spaceId);
    }
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      parent: parent == null && nullToAbsent
          ? const Value.absent()
          : Value(parent),
      order: Value(order),
      spaceId: spaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(spaceId),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<int>(json['type']),
      parent: serializer.fromJson<String?>(json['parent']),
      order: serializer.fromJson<int>(json['order']),
      spaceId: serializer.fromJson<String?>(json['spaceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>(type),
      'parent': serializer.toJson<String?>(parent),
      'order': serializer.toJson<int>(order),
      'spaceId': serializer.toJson<String?>(spaceId),
    };
  }

  Folder copyWith({
    String? id,
    String? name,
    int? type,
    Value<String?> parent = const Value.absent(),
    int? order,
    Value<String?> spaceId = const Value.absent(),
  }) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    parent: parent.present ? parent.value : this.parent,
    order: order ?? this.order,
    spaceId: spaceId.present ? spaceId.value : this.spaceId,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      parent: data.parent.present ? data.parent.value : this.parent,
      order: data.order.present ? data.order.value : this.order,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parent: $parent, ')
          ..write('order: $order, ')
          ..write('spaceId: $spaceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, parent, order, spaceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.parent == this.parent &&
          other.order == this.order &&
          other.spaceId == this.spaceId);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> type;
  final Value<String?> parent;
  final Value<int> order;
  final Value<String?> spaceId;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.parent = const Value.absent(),
    this.order = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    required String name,
    this.type = const Value.absent(),
    this.parent = const Value.absent(),
    this.order = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<String>? parent,
    Expression<int>? order,
    Expression<String>? spaceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (parent != null) 'parent': parent,
      if (order != null) 'order': order,
      if (spaceId != null) 'space_id': spaceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? type,
    Value<String?>? parent,
    Value<int>? order,
    Value<String?>? spaceId,
    Value<int>? rowid,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parent: parent ?? this.parent,
      order: order ?? this.order,
      spaceId: spaceId ?? this.spaceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (parent.present) {
      map['parent'] = Variable<String>(parent.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parent: $parent, ')
          ..write('order: $order, ')
          ..write('spaceId: $spaceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpacesTable extends Spaces with TableInfo<$SpacesTable, Space> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, icon, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<Space> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Space map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Space(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
    );
  }

  @override
  $SpacesTable createAlias(String alias) {
    return $SpacesTable(attachedDatabase, alias);
  }
}

class Space extends DataClass implements Insertable<Space> {
  final String id;
  final String name;
  final String? icon;
  final int order;
  const Space({
    required this.id,
    required this.name,
    this.icon,
    required this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['order'] = Variable<int>(order);
    return map;
  }

  SpacesCompanion toCompanion(bool nullToAbsent) {
    return SpacesCompanion(
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      order: Value(order),
    );
  }

  factory Space.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Space(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'order': serializer.toJson<int>(order),
    };
  }

  Space copyWith({
    String? id,
    String? name,
    Value<String?> icon = const Value.absent(),
    int? order,
  }) => Space(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    order: order ?? this.order,
  );
  Space copyWithCompanion(SpacesCompanion data) {
    return Space(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Space(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Space &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.order == this.order);
}

class SpacesCompanion extends UpdateCompanion<Space> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<int> order;
  final Value<int> rowid;
  const SpacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpacesCompanion.insert({
    required String id,
    required String name,
    this.icon = const Value.absent(),
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Space> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? order,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (order != null) 'order': order,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpacesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? icon,
    Value<int>? order,
    Value<int>? rowid,
  }) {
    return SpacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      order: order ?? this.order,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('order: $order, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FeedsTable feeds = $FeedsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $SpacesTable spaces = $SpacesTable(this);
  late final FeedsDao feedsDao = FeedsDao(this as AppDatabase);
  late final EntriesDao entriesDao = EntriesDao(this as AppDatabase);
  late final FoldersDao foldersDao = FoldersDao(this as AppDatabase);
  late final SpacesDao spacesDao = SpacesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    feeds,
    entries,
    folders,
    spaces,
  ];
}

typedef $$FeedsTableCreateCompanionBuilder =
    FeedsCompanion Function({
      required String id,
      required String url,
      Value<String?> feedType,
      Value<String?> title,
      Value<String?> description,
      Value<String?> link,
      Value<DateTime?> published,
      Value<DateTime?> deletedAt,
      Value<String?> folderId,
      Value<bool> requiresExternalBrowser,
      Value<String?> spaceId,
      Value<String?> lastFetchError,
      Value<DateTime?> lastFetchAt,
      Value<int> rowid,
    });
typedef $$FeedsTableUpdateCompanionBuilder =
    FeedsCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<String?> feedType,
      Value<String?> title,
      Value<String?> description,
      Value<String?> link,
      Value<DateTime?> published,
      Value<DateTime?> deletedAt,
      Value<String?> folderId,
      Value<bool> requiresExternalBrowser,
      Value<String?> spaceId,
      Value<String?> lastFetchError,
      Value<DateTime?> lastFetchAt,
      Value<int> rowid,
    });

class $$FeedsTableFilterComposer extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedType => $composableBuilder(
    column: $table.feedType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresExternalBrowser => $composableBuilder(
    column: $table.requiresExternalBrowser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spaceId => $composableBuilder(
    column: $table.spaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastFetchError => $composableBuilder(
    column: $table.lastFetchError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetchAt => $composableBuilder(
    column: $table.lastFetchAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedType => $composableBuilder(
    column: $table.feedType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresExternalBrowser => $composableBuilder(
    column: $table.requiresExternalBrowser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spaceId => $composableBuilder(
    column: $table.spaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastFetchError => $composableBuilder(
    column: $table.lastFetchError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetchAt => $composableBuilder(
    column: $table.lastFetchAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get feedType =>
      $composableBuilder(column: $table.feedType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<DateTime> get published =>
      $composableBuilder(column: $table.published, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<bool> get requiresExternalBrowser => $composableBuilder(
    column: $table.requiresExternalBrowser,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<String> get lastFetchError => $composableBuilder(
    column: $table.lastFetchError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFetchAt => $composableBuilder(
    column: $table.lastFetchAt,
    builder: (column) => column,
  );
}

class $$FeedsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FeedsTable,
          Feed,
          $$FeedsTableFilterComposer,
          $$FeedsTableOrderingComposer,
          $$FeedsTableAnnotationComposer,
          $$FeedsTableCreateCompanionBuilder,
          $$FeedsTableUpdateCompanionBuilder,
          (Feed, BaseReferences<_$AppDatabase, $FeedsTable, Feed>),
          Feed,
          PrefetchHooks Function()
        > {
  $$FeedsTableTableManager(_$AppDatabase db, $FeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> feedType = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<DateTime?> published = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<bool> requiresExternalBrowser = const Value.absent(),
                Value<String?> spaceId = const Value.absent(),
                Value<String?> lastFetchError = const Value.absent(),
                Value<DateTime?> lastFetchAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedsCompanion(
                id: id,
                url: url,
                feedType: feedType,
                title: title,
                description: description,
                link: link,
                published: published,
                deletedAt: deletedAt,
                folderId: folderId,
                requiresExternalBrowser: requiresExternalBrowser,
                spaceId: spaceId,
                lastFetchError: lastFetchError,
                lastFetchAt: lastFetchAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                Value<String?> feedType = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<DateTime?> published = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<bool> requiresExternalBrowser = const Value.absent(),
                Value<String?> spaceId = const Value.absent(),
                Value<String?> lastFetchError = const Value.absent(),
                Value<DateTime?> lastFetchAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedsCompanion.insert(
                id: id,
                url: url,
                feedType: feedType,
                title: title,
                description: description,
                link: link,
                published: published,
                deletedAt: deletedAt,
                folderId: folderId,
                requiresExternalBrowser: requiresExternalBrowser,
                spaceId: spaceId,
                lastFetchError: lastFetchError,
                lastFetchAt: lastFetchAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FeedsTable,
      Feed,
      $$FeedsTableFilterComposer,
      $$FeedsTableOrderingComposer,
      $$FeedsTableAnnotationComposer,
      $$FeedsTableCreateCompanionBuilder,
      $$FeedsTableUpdateCompanionBuilder,
      (Feed, BaseReferences<_$AppDatabase, $FeedsTable, Feed>),
      Feed,
      PrefetchHooks Function()
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      required String id,
      required String feedId,
      Value<String?> title,
      Value<String?> link,
      Value<String?> summary,
      Value<DateTime?> published,
      Value<bool> unread,
      Value<bool> flagged,
      Value<int> rowid,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<String> id,
      Value<String> feedId,
      Value<String?> title,
      Value<String?> link,
      Value<String?> summary,
      Value<DateTime?> published,
      Value<bool> unread,
      Value<bool> flagged,
      Value<int> rowid,
    });

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get unread => $composableBuilder(
    column: $table.unread,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get flagged => $composableBuilder(
    column: $table.flagged,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedId => $composableBuilder(
    column: $table.feedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get unread => $composableBuilder(
    column: $table.unread,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get flagged => $composableBuilder(
    column: $table.flagged,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get published =>
      $composableBuilder(column: $table.published, builder: (column) => column);

  GeneratedColumn<bool> get unread =>
      $composableBuilder(column: $table.unread, builder: (column) => column);

  GeneratedColumn<bool> get flagged =>
      $composableBuilder(column: $table.flagged, builder: (column) => column);
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, BaseReferences<_$AppDatabase, $EntriesTable, Entry>),
          Entry,
          PrefetchHooks Function()
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> feedId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<DateTime?> published = const Value.absent(),
                Value<bool> unread = const Value.absent(),
                Value<bool> flagged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                feedId: feedId,
                title: title,
                link: link,
                summary: summary,
                published: published,
                unread: unread,
                flagged: flagged,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String feedId,
                Value<String?> title = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<DateTime?> published = const Value.absent(),
                Value<bool> unread = const Value.absent(),
                Value<bool> flagged = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                feedId: feedId,
                title: title,
                link: link,
                summary: summary,
                published: published,
                unread: unread,
                flagged: flagged,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, BaseReferences<_$AppDatabase, $EntriesTable, Entry>),
      Entry,
      PrefetchHooks Function()
    >;
typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      required String id,
      required String name,
      Value<int> type,
      Value<String?> parent,
      Value<int> order,
      Value<String?> spaceId,
      Value<int> rowid,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> type,
      Value<String?> parent,
      Value<int> order,
      Value<String?> spaceId,
      Value<int> rowid,
    });

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parent => $composableBuilder(
    column: $table.parent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spaceId => $composableBuilder(
    column: $table.spaceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parent => $composableBuilder(
    column: $table.parent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spaceId => $composableBuilder(
    column: $table.spaceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get parent =>
      $composableBuilder(column: $table.parent, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => column);
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
          Folder,
          PrefetchHooks Function()
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String?> parent = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<String?> spaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                name: name,
                type: type,
                parent: parent,
                order: order,
                spaceId: spaceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> type = const Value.absent(),
                Value<String?> parent = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<String?> spaceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                name: name,
                type: type,
                parent: parent,
                order: order,
                spaceId: spaceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
      Folder,
      PrefetchHooks Function()
    >;
typedef $$SpacesTableCreateCompanionBuilder =
    SpacesCompanion Function({
      required String id,
      required String name,
      Value<String?> icon,
      Value<int> order,
      Value<int> rowid,
    });
typedef $$SpacesTableUpdateCompanionBuilder =
    SpacesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> icon,
      Value<int> order,
      Value<int> rowid,
    });

class $$SpacesTableFilterComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpacesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpacesTable> {
  $$SpacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $$SpacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpacesTable,
          Space,
          $$SpacesTableFilterComposer,
          $$SpacesTableOrderingComposer,
          $$SpacesTableAnnotationComposer,
          $$SpacesTableCreateCompanionBuilder,
          $$SpacesTableUpdateCompanionBuilder,
          (Space, BaseReferences<_$AppDatabase, $SpacesTable, Space>),
          Space,
          PrefetchHooks Function()
        > {
  $$SpacesTableTableManager(_$AppDatabase db, $SpacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion(
                id: id,
                name: name,
                icon: icon,
                order: order,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpacesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                order: order,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpacesTable,
      Space,
      $$SpacesTableFilterComposer,
      $$SpacesTableOrderingComposer,
      $$SpacesTableAnnotationComposer,
      $$SpacesTableCreateCompanionBuilder,
      $$SpacesTableUpdateCompanionBuilder,
      (Space, BaseReferences<_$AppDatabase, $SpacesTable, Space>),
      Space,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FeedsTableTableManager get feeds =>
      $$FeedsTableTableManager(_db, _db.feeds);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$SpacesTableTableManager get spaces =>
      $$SpacesTableTableManager(_db, _db.spaces);
}
