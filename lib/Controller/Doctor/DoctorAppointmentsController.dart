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
  int _page = 1;
  static const pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    loadInitial();
  }

  Future<void> loadInitial() => _load(reset: true);
  Future<void> refreshList() => _load(reset: true, refreshing: true);
  Future<void> retry() => loadInitial();

  Future<void> loadMore() async {
    if (!hasMore || isInitialLoading || isRefreshing || isLoadingMore) return;
    await _load(reset: false);
  }

  Future<void> setStatus(String? value) async {
    if (selectedStatus == value) return;
    selectedStatus = value;
    await loadInitial();
  }

  Future<void> setDate(DateTime? value) async {
    selectedDate = value;
    await loadInitial();
  }

  Future<void> clearFilters() async {
    if (selectedStatus == null && selectedDate == null) return;
    selectedStatus = null;
    selectedDate = null;
    await loadInitial();
  }

  Future<void> _load({required bool reset, bool refreshing = false}) async {
    if (_disposed || isInitialLoading || isRefreshing || isLoadingMore) return;
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
    try {
      final result = await _data.getDoctorAppointments(
        status: selectedStatus,
        date: selectedDate,
        page: requestedPage,
        pageSize: pageSize,
      );
      if (_disposed) return;
      result.fold((value) => failure = value, (body) {
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
        }
      });
    } catch (_) {
      failure = const ServerFailure('Unable to load appointments.');
    } finally {
      isInitialLoading = false;
      isRefreshing = false;
      isLoadingMore = false;
      if (!_disposed && !isClosed) update();
    }
  }

  _AppointmentPage _parsePage(Object? body, {required int alreadyLoaded}) {
    List<dynamic> raw;
    int? totalCount;
    if (body is List) {
      raw = body;
    } else if (body is Map && body['items'] is List) {
      raw = body['items'] as List;
      totalCount = _int(body['totalCount']);
    } else {
      throw const FormatException();
    }
    final items = raw
        .map(
          (item) =>
              AppointmentModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
    final loaded = alreadyLoaded + items.length;
    return _AppointmentPage(
      items,
      totalCount == null ? items.length == pageSize : loaded < totalCount,
    );
  }

  int? _int(Object? value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '');

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
