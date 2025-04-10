import 'package:flutter/material.dart';

class RideStats {
  final String userId;
  final String userName;
  final DriverStats asDriver;
  final PassengerStats asPassenger;
  final AggregateStats aggregate;
  final List<TopDestination> topDestinations;
  final RideActivity rideActivity;

  RideStats({
    required this.userId,
    required this.userName,
    required this.asDriver,
    required this.asPassenger,
    required this.aggregate,
    required this.topDestinations,
    required this.rideActivity,
  });

  factory RideStats.fromJson(Map<String, dynamic> json) {
    return RideStats(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      asDriver: DriverStats.fromJson(json['asDriver'] ?? {}),
      asPassenger: PassengerStats.fromJson(json['asPassenger'] ?? {}),
      aggregate: AggregateStats.fromJson(json['aggregate'] ?? {}),
      topDestinations: (json['topDestinations'] as List<dynamic>?)
          ?.map((e) => TopDestination.fromJson(e))
          .toList() ?? [],
      rideActivity: RideActivity.fromJson(json['rideActivity'] ?? {}),
    );
  }
}

class DriverStats {
  final int totalRidesPublished;
  final int totalRidesCompleted;
  final int totalRidesCancelled;
  final int totalRidesUpcoming;
  final int totalRidesInProgress;
  final int totalPassengersServed;
  final double totalEarnings;

  DriverStats({
    required this.totalRidesPublished,
    required this.totalRidesCompleted,
    required this.totalRidesCancelled,
    required this.totalRidesUpcoming,
    required this.totalRidesInProgress,
    required this.totalPassengersServed,
    required this.totalEarnings,
  });

  factory DriverStats.fromJson(Map<String, dynamic> json) {
    return DriverStats(
      totalRidesPublished: json['totalRidesPublished'] ?? 0,
      totalRidesCompleted: json['totalRidesCompleted'] ?? 0,
      totalRidesCancelled: json['totalRidesCancelled'] ?? 0,
      totalRidesUpcoming: json['totalRidesUpcoming'] ?? 0,
      totalRidesInProgress: json['totalRidesInProgress'] ?? 0,
      totalPassengersServed: json['totalPassengersServed'] ?? 0,
      totalEarnings: json['totalEarnings']?.toDouble() ?? 0.0,
    );
  }
}

class PassengerStats {
  final int totalRidesBooked;
  final int totalRidesCompleted;
  final int totalRidesCancelled;
  final int totalRidesUpcoming;
  final double totalSpent;

  PassengerStats({
    required this.totalRidesBooked,
    required this.totalRidesCompleted,
    required this.totalRidesCancelled,
    required this.totalRidesUpcoming,
    required this.totalSpent,
  });

  factory PassengerStats.fromJson(Map<String, dynamic> json) {
    return PassengerStats(
      totalRidesBooked: json['totalRidesBooked'] ?? 0,
      totalRidesCompleted: json['totalRidesCompleted'] ?? 0,
      totalRidesCancelled: json['totalRidesCancelled'] ?? 0,
      totalRidesUpcoming: json['totalRidesUpcoming'] ?? 0,
      totalSpent: json['totalSpent']?.toDouble() ?? 0.0,
    );
  }
}

class AggregateStats {
  final int totalRides;
  final int totalDistance;
  final int totalRidesCompleted;
  final double netFinancial;

  AggregateStats({
    required this.totalRides,
    required this.totalDistance,
    required this.totalRidesCompleted,
    required this.netFinancial,
  });

  factory AggregateStats.fromJson(Map<String, dynamic> json) {
    return AggregateStats(
      totalRides: json['totalRides'] ?? 0,
      totalDistance: json['totalDistance'] ?? 0,
      totalRidesCompleted: json['totalRidesCompleted'] ?? 0,
      netFinancial: json['netFinancial']?.toDouble() ?? 0.0,
    );
  }
}

class TopDestination {
  final String city;
  final int count;

  TopDestination({
    required this.city,
    required this.count,
  });

  factory TopDestination.fromJson(Map<String, dynamic> json) {
    return TopDestination(
      city: json['city'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class RideActivity {
  final List<String> months;
  final List<MonthlyRideData> data;

  RideActivity({
    required this.months,
    required this.data,
  });

  factory RideActivity.fromJson(Map<String, dynamic> json) {
    final months = json['months'] as List<dynamic>? ?? [];
    final dataList = json['data'] as List<dynamic>? ?? [];
    
    return RideActivity(
      months: months.map((e) => e.toString()).toList(),
      data: dataList.map((e) => MonthlyRideData.fromJson(e)).toList(),
    );
  }
}

class MonthlyRideData {
  final int asDriver;
  final int asPassenger;

  MonthlyRideData({
    required this.asDriver,
    required this.asPassenger,
  });

  factory MonthlyRideData.fromJson(Map<String, dynamic> json) {
    return MonthlyRideData(
      asDriver: json['asDriver'] ?? 0,
      asPassenger: json['asPassenger'] ?? 0,
    );
  }
}