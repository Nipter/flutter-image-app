import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_viewer_app/assets.dart';
import 'package:image_viewer_app/providers/settings_provider.dart';
import 'package:image_viewer_app/widgets/container/background_container.dart';
import 'package:image_viewer_app/widgets/container/loading_container.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String _monitoringUrl = "";
  Map<String, List<FlSpot>> metricsSpots = {};
  Map<String, dynamic> metrics = {
    'storageUsed': 0,
    'totalUsers': 0,
    'totalDocs': 0,
  };

  Future<void> _loadSettings() async {
    setState(() {
      var settings = ref.read(settingsProvider.notifier).settings;
      _monitoringUrl =
          settings[EnvironmentalVariables.monitoringUrl.variable]?.asString() ??
              "";
    });
  }

  Future<List<DataPoint>> _fetchMetrics(String filterType, String valueType) async {
    String url = '$_monitoringUrl/monitoring?filterType=$filterType';
    if (_monitoringUrl.trim().isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(url),
        );

        if (response.statusCode == 200) {
          List<dynamic> rawPoints = jsonDecode(response.body) as List<dynamic>;
          List<DataPoint> dataPoints = rawPoints.map((point) {
            DateTime x = DateTime.fromMillisecondsSinceEpoch(
                point['interval']['end_time']['seconds'] * 1000);
            double y = point['value']['Value'][valueType] ;
            return DataPoint(x, y);
          }).toList();
          return dataPoints;
        } else {
          throw Exception('Error while fetching metrics');
        }
      } catch (e) {
            print(e);
        throw Exception(
            'Error while fetching metrics. Please try again or contact administrators.');
      }
    } else {
      return [];
    }
  }



  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchStatsAndMetrics();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  List<FlSpot> _accumulateBucketsStorage(List<FlSpot> points) {
    Map<double, FlSpot> accPoints = {};
    for (var point in points) {
      //FlSpot foundPoint = accPoints.putIfAbsent(point.x, () => point);
      accPoints.update(point.x, (p) => FlSpot(p.x, point.y + p.y), ifAbsent: () => point);
    }
    return accPoints.values.toList();
  }

  Future<void> _fetchStatsAndMetrics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      //'localhost:8080/monitoring?filterType=storage.googleapis.com/network/received_bytes_count' | jq

      List<DataPoint> dataPointsBytes = await _fetchMetrics(
          //'storage.googleapis.com/network/received_bytes_count');
          'storage.googleapis.com/storage/total_bytes', 'DoubleValue');
       List<FlSpot> bytesSpots= dataPointsBytes.map((point) {
        return FlSpot(
          point.timestamp.millisecondsSinceEpoch.toDouble(), point.amount);
      }).toList();
      metricsSpots['total_bytes'] = _accumulateBucketsStorage(bytesSpots);
      metricsSpots['total_bytes']?.sort((pointA, pointB) => pointA.x.compareTo(pointB.x));
//metricsSpots['total_bytes']?.forEach((point) => print(point.toString()));

      List<DataPoint> dataPointsObjects = await _fetchMetrics(
          'storage.googleapis.com/storage/object_count', 'Int64Value');
      metricsSpots['object_count'] = dataPointsObjects.map((point) {
        return FlSpot(
            point.timestamp.millisecondsSinceEpoch.toDouble(), point.amount);
      }).toList();
      metricsSpots['object_count']?.sort((pointA, pointB) => pointA.x.compareTo(pointB.x));

      //var data = jsonDecode(resp);

      // Get storage usage
      final ListResult storageResult = await storage.ref('images').listAll();
      int totalBytes = 0;
      for (var item in storageResult.items) {
        final metadata = await item.getMetadata();
        totalBytes += metadata.size ?? 0;
      }

      // Get document counts from different collections
      final usersCount = await firestore.collection('users').count().get();
      final imagesCount = await firestore.collection('images').count().get();
      final foldersCount = await firestore.collection('folders').count().get();

      metrics['storageUsed'] = totalBytes;
      metrics['totalUsers'] = usersCount.count;
      metrics['totalDocs'] = (usersCount.count ?? 0) + (imagesCount.count ?? 0) + (foldersCount.count ?? 0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not load metrics. Please try again or contact administrators.'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Analytics"),
        ),
        body: BackgroundContainer(
            child: LoadingContainer(
                isLoading: _isLoading,
                child: SingleChildScrollView(
                    child: Row(children: [
                  // Left empty column
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 3, // Takes up 3/5 of the screen width
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            GridView.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _StatTile(
                                  title: 'Storage Used',
                                  value: _formatBytes(metrics['storageUsed']),
                                  icon: Icons.storage,
                                ),
                                _StatTile(
                                  title: 'Total Users',
                                  value: NumberFormat.compact()
                                      .format(metrics['totalUsers']),
                                  icon: Icons.people,
                                ),
                                _StatTile(
                                  title: 'Total Firebase Documents',
                                  value: NumberFormat.compact()
                                      .format(metrics['totalDocs']),
                                  icon: Icons.article,
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: LineChartWidget(
                                metricsSpots['object_count'],
                                "Firebase Storage Object Count",
                                "Day",
                                "Nr of objects",
                                metricsSpots['object_count']
                                    ?.map((spot) => spot.x)
                                    .reduce(min),
                                metricsSpots['object_count']
                                    ?.map((spot) => spot.y)
                                    .reduce(min),
                                metricsSpots['object_count']
                                    ?.map((spot) => spot.x)
                                    .reduce(max),
                                metricsSpots['object_count']
                                    ?.map((spot) => spot.y)
                                    .reduce(max),
                                false,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 60.0),
                              child: LineChartWidget(
                                metricsSpots['total_bytes'],
                                "Firebase Storage Amount Taken",
                                "Day",
                                "Storage",
                                metricsSpots['total_bytes']
                                    ?.map((spot) => spot.x)
                                    .reduce(min),
                                metricsSpots['total_bytes']
                                    ?.map((spot) => spot.y)
                                    .reduce(min),
                                metricsSpots['total_bytes']
                                    ?.map((spot) => spot.x)
                                    .reduce(max),
                                (metricsSpots['total_bytes']
                                    ?.map((spot) => spot.y)
                                    .reduce(max) ?? 0) * 1.2,
                                true,
                              ),
                            ),
                          ],
                        )),
                  ),

                  // Right empty column
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                ])))));
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final String title;
  final String xLablel;
  final String yLablel;
  final double? minX;
  final double? minY;
  final double? maxY;
  final double? maxX;
  final List<FlSpot>? spots;
  final bool isYAxisByte;

  const LineChartWidget(this.spots, this.title, this.xLablel, this.yLablel,
      this.minX, this.minY, this.maxX, this.maxY, this.isYAxisByte,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: LineChart(
                LineChartData(
                    minX: minX,
                    minY: minY,
                    maxX: maxX,
                    maxY: maxY,
                    backgroundColor: Colors.white,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots ?? [],
                        isCurved: false,
                      ),
                    ],
                    titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                            sideTitles: isYAxisByte
                                ? SideTitles(
                                    getTitlesWidget: (value, meta) {
                                      String formatBytes = _formatBytes(value.toInt());
                                      return SideTitleWidget( meta: meta, space:13, child: 
                                        Text(formatBytes),
                                      );
                                      //return Text(formatBytes);
                                    },
                                    interval: _calculateYInterval(),
                                    showTitles: true,
                                    reservedSize: 65)
                                : const SideTitles(showTitles: true, reservedSize: 50),
                            axisNameWidget: Text(yLablel)),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (value, meta) {
                                DateTime date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt());
                                String formattedDate =
                                    "${date.day} ${_monthAbbreviation(date.month)}";
                                return Text(formattedDate);
                              },
                              interval: _calculateXInterval(),

                              //getTitlesWidget: (value, meta) {
                              //  DateTime date = DateTime(2025, 2, value.toInt());
                              //  return Text("${date.month}/${date.day}");
                              //},
                            ),
                            axisNameWidget: Text(xLablel)))),
              ),
            )
          ],
        ));
  }

  double? _calculateXInterval() {
    double interval = ((maxX ?? 0) - (minX ?? 0)) / 4;
    return interval != 0 ? interval : null;
  }
    
  double? _calculateYInterval() {
    double interval = ((maxY ?? 0) - (minY ?? 0)) / 4;
    return interval != 0 ? interval : null;
  }

  String _monthAbbreviation(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }
}

class DataPoint {
  DateTime timestamp;
  double amount;
  DataPoint(this.timestamp, this.amount);
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
