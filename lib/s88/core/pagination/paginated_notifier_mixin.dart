// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:co_caro_flame/s88/core/misc/request_lock_mixin.dart';

part 'paginated_notifier_mixin.freezed.dart';

/// Implements common functionality for notifiers that handle paginated
/// responses.
mixin PaginatedNotifierMixin<R, D>
    on StateNotifier<PaginatedState<D>>, RequestLock {
  @protected
  Future<R> request([int? cursor]);

  /// Used to handle the [response] for [loadInitial].
  ///
  /// Usually used to emit a [PaginatedState.data] with a cursor for the next
  /// page or a [PaginatedState.noData]
  @protected
  Future<void> onInitialResponse(R response);

  /// Used to handle the [response] for [refresh].
  ///
  /// Usually used to emit a [PaginatedState.data] with a cursor for the next
  /// page or a [PaginatedState.noData]
  @protected
  Future<void> onRefreshResponse(R response);

  /// Used to handle the [response] for [loadMore].
  ///
  /// [data] is the data of the previous state.
  ///
  /// Usually used to emit a [PaginatedState.data] with the new data appended
  /// and a new cursor.
  @protected
  Future<void> onMoreResponse(R response, D data);

  @protected
  Future<void> onRequestError(Object error, StackTrace stackTrace);

  /// Loads the initial set of data and handles its response.
  ///
  /// This is used for the initialization and to refresh / reset the state.
  Future<void> loadInitial() async {
    final currentState = state;

    state = currentState.copyWith(status: PaginatedStatus.loading);

    try {
      final response = await request();

      await onInitialResponse(response);
    } catch (e, st) {
      state = const PaginatedState.error();

      await onRequestError(e, st);
    }
  }

  /// Loads the initial set of data and handles its response.
  /// Emit [PaginatedStatus.refreshing]
  ///
  /// This is used to refresh data.
  Future<void> refresh([bool clear = true]) async {
    if (lock()) return;

    final currentState = state;

    state = currentState.copyWith(
      status: PaginatedStatus.refreshing,
      data: clear ? null : currentState.data,
    );

    try {
      final response = await request();

      await onRefreshResponse(response);
    } catch (e, st) {
      state = const PaginatedState.error();

      await onRequestError(e, st);
    }
  }

  /// Loads the "next page" of data and handles its response.
  ///
  /// Does nothing if no next page is available.
  Future<void> loadMore() async {
    if (lock()) return;

    if (state.canLoadMore) {
      final currentState = state;

      state = currentState.copyWith(status: PaginatedStatus.loadingMore);

      try {
        final response = await request(currentState.cursor);

        await onMoreResponse(response, currentState.data as D);
      } catch (e, st) {
        state = state.copyWith(status: PaginatedStatus.error);

        await onRequestError(e, st);
      }
    }
  }
}

enum PaginatedStatus {
  initial,
  loading,
  data,
  noData,
  refreshing,
  loadingMore,
  error,
}

@freezed
class PaginatedState<T> with _$PaginatedState<T> {
  PaginatedState._({required this.status, this.data, this.cursor});

  const PaginatedState.initial()
    : status = PaginatedStatus.initial,
      data = null,
      cursor = null;

  const PaginatedState.error()
    : status = PaginatedStatus.error,
      data = null,
      cursor = null;

  /// Factory constructor for creating a data state with proper typing
  factory PaginatedState.withData({required T data, int? cursor}) =>
      PaginatedState._(
        status: PaginatedStatus.data,
        data: data,
        cursor: cursor,
      );

  /// Factory constructor for creating a noData state with proper typing
  factory PaginatedState.empty() => PaginatedState._(
    status: PaginatedStatus.noData,
    data: null,
    cursor: null,
  );

  @override
  final PaginatedStatus status;

  @override
  final T? data;

  @override
  final int? cursor;

  PaginatedState<T> loadingMore() =>
      copyWith(status: PaginatedStatus.loadingMore);

  PaginatedState<T> refreshing() =>
      copyWith(status: PaginatedStatus.refreshing);
}

extension PaginatedStateExtension<T> on PaginatedState<T> {
  bool get canLoadMore => switch (status) {
    PaginatedStatus.data => cursor != null && cursor != 0,
    _ => false,
  };

  // T? get data => data;
  // T? get data => mapOrNull(data: (value) => value.data, loadingMore: (value) => value.data);
  // bool get canLoadMore =>
  //     maybeMap(data: (value) => value.cursor != null && value.cursor != 0, orElse: () => false);
}

// @freezed
// class PaginatedState<T> with _$PaginatedState<T> {
//   PaginatedState({required PaginatedStatus status, T? data, int? cursor});

//   // const factory PaginatedState.initial() = PaginatedStateInitial;
//   // const factory PaginatedState.loading() = PaginatedStateLoading;

//   // const factory PaginatedState.data({required T data, int? cursor}) = PaginatedStateData;

//   // const factory PaginatedState.noData() = PaginatedStateNoData;

//   // const factory PaginatedState.refreshing({required T data}) = PaginatedStateRefreshing;

//   // const factory PaginatedState.loadingMore({required T data}) = PaginatedStateLoadingMore;

//   // const factory PaginatedState.error() = PaginatedStateError;
// }

// @freezed
// class PaginatedState<T> with _$PaginatedState<T> {
//   const factory PaginatedState.initial() = PaginatedStateInitial;
//   const factory PaginatedState.loading() = PaginatedStateLoading;

//   const factory PaginatedState.data({required T data, int? cursor}) = PaginatedStateData;

//   const factory PaginatedState.noData() = PaginatedStateNoData;

//   const factory PaginatedState.refreshing({required T data}) = PaginatedStateRefreshing;

//   const factory PaginatedState.loadingMore({required T data}) = PaginatedStateLoadingMore;

//   const factory PaginatedState.error() = PaginatedStateError;
// }
