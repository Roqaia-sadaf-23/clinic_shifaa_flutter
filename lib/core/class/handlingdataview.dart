import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../Error/Failure.dart';
import '../constant/Appimagesassent.dart';

class Handlingdataview extends StatelessWidget {
  final Failure? failure;
  final Widget widget;

  const Handlingdataview({
    super.key,
    required this.failure,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    if (failure == null) {
      return widget;
    }

    if (failure is NetworkFailure) {
      return Center(child: Lottie.asset(Appimagesassent.offline));
    }

    if (failure is ServerFailure) {
      return const Center(child: Text("Server Failure"));
    }

    if (failure is CacheFailure) {
      return const Center(child: Text("Cache Failure"));
    }

    if (failure is DatabaseFailure) {
      return const Center(child: Text("Database Failure"));
    }

    return Center(child: Text(failure!.message));
  }
}
