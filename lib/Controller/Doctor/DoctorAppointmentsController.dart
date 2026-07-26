import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../data/datasource/remote/Appointments/DoctorAppointmentData.dart';
import '../../data/model/AppointmentModel.dart';

class DoctorAppointmentsController extends GetxController {
  DoctorAppointmentsController(this._data);
  final DoctorAppointmentData _data;

  static const statuses = ['Pending', 'Confirmed', 'Completed', 'Cancelled'];
  final appointments = <AppointmentModel>[];
  Failure? failure;
  String? selectedStatus;
  DateTime? selectedDate;
  bool isInitialLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool _disposed = false;
  bool _reloadRequested = false;
  int _filterRevision = 0;
  int _page = 1;
  static const pageSize = 10;

  bool get isBusy => isInitialLoading || isRefreshing || isLoadingMore;
  bool get _inactive => _disposed || isClosed;

  @override
  void onInit() {
    super.onInit();
    loadInitial();
  }

  Future<void> loadInitial() => _load(reset: true);
  Future<void> refreshList() => _load(reset: true, refreshing: true);
  Future<void> retry() => loadInitial();

  Future<void> loadMore() async {
    if (_inactive || !hasMore || isBusy) return;
    await _load(reset: false);
  }

  Future<void> setStatus(String? value) async {
    if (selectedStatus == value) return;
    selectedStatus = value;
    _filterRevision++;
    await loadInitial();
  }

  Future<void> setDate(DateTime? value) async {
    if (_sameDate(selectedDate, value)) return;
    selectedDate = value;
    _filterRevision++;
    await loadInitial();
  }

  Future<void> clearFilters() async {
    if (selectedStatus == null && selectedDate == null) return;
    selectedStatus = null;
    selectedDate = null;
    _filterRevision++;
    await loadInitial();
  }

  Future<void> _load({required bool reset, bool refreshing = false}) async {
    if (_inactive) return;
    if (isBusy) {
      if (reset) _reloadRequested = true;
      return;
    }
    if (reset) {
      failure = null;
      if (refreshing) {
        isRefreshing = true;
      } else {
        isInitialLoading = true;
      }
    } else {
      isLoadingMore = true;
    }
    update();
    final requestedPage = reset ? 1 : _page + 1;
    final requestRevision = _filterRevision;
    try {
      final result = await _data.getDoctorAppointments(
        status: selectedStatus,
        date: selectedDate,
        page: requestedPage,
        pageSize: pageSize,
      );
      if (_inactive || requestRevision != _filterRevision) return;
      result.fold(
        (value) {
          failure = value;
          if (!reset) hasMore = false;
        },
        (body) {
          try {
            final parsed = _parsePage(
              body,
              alreadyLoaded: reset ? 0 : appointments.length,
            );
            if (reset) appointments.clear();
            appointments.addAll(parsed.items);
            _page = requestedPage;
            hasMore = parsed.hasMore;
            failure = null;
          } catch (_) {
            failure = const ServerFailure('Invalid appointments response.');
            if (!reset) hasMore = false;
          }
        },
      );
    } catch (_) {
      if (requestRevision == _filterRevision) {
        failure = const ServerFailure('Unable to load appointments.');
        if (!reset) hasMore = false;
      }
    } finally {
      isInitialLoading = false;
      isRefreshing = false;
      isLoadingMore = false;
      if (!_inactive) update();
      if (_reloadRequested && !_inactive) {
        _reloadRequested = false;
        await _load(reset: true);
      }
    }
  }

  _AppointmentPage _parsePage(Object? body, {required int alreadyLoaded}) {
    final items = AppointmentModel.listFromResponse(body);
    final totalCount = _totalCount(body);
    final loaded = alreadyLoaded + items.length;
    return _AppointmentPage(
      items,
      totalCount == null ? items.length == pageSize : loaded < totalCount,
    );
  }

  int? _int(Object? value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');

  int? _totalCount(Object? response) {
    var current = response;
    for (var depth = 0; depth < 4 && current is Map; depth++) {
      Object? nested;
      for (final entry in current.entries) {
        final key = entry.key;
        if (key is String) {
          final normalized = key.toLowerCase();
          if (normalized == 'totalcount') return _int(entry.value);
          if (normalized == 'data' || normalized == 'result') {
            nested ??= entry.value;
          }
        }
      }
      current = nested;
    }
    return null;
  }

  bool _sameDate(DateTime? first, DateTime? second) {
    if (identical(first, second)) return true;
    if (first == null || second == null) return false;
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}

class _AppointmentPage {
  const _AppointmentPage(this.items, this.hasMore);
  final List<AppointmentModel> items;
  final bool hasMore;
}
