// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeds_dao.dart';

// ignore_for_file: type=lint
mixin _$FeedsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FeedsTable get feeds => attachedDatabase.feeds;
  FeedsDaoManager get managers => FeedsDaoManager(this);
}

class FeedsDaoManager {
  final _$FeedsDaoMixin _db;
  FeedsDaoManager(this._db);
  $$FeedsTableTableManager get feeds =>
      $$FeedsTableTableManager(_db.attachedDatabase, _db.feeds);
}
