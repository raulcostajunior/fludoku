class TimeoutTracker {
  final int _timeoutMillis;
  late int _startTimeMillis;

  TimeoutTracker(this._timeoutMillis, {int? startTimeMillis}) {
    _startTimeMillis = startTimeMillis ?? DateTime.now().millisecondsSinceEpoch;
  }

  bool get timedout =>
      DateTime.now().millisecondsSinceEpoch - _startTimeMillis >=
      _timeoutMillis;

  int get remainingMillis =>
      _timeoutMillis -
      (DateTime.now().millisecondsSinceEpoch - _startTimeMillis);
}
