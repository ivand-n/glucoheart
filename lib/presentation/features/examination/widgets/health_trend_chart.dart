import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../domain/entities/examination.dart';

class HealthTrendChart extends StatefulWidget {
  final List<Examination> examinations;
  final String title;

  const HealthTrendChart({
    super.key,
    required this.examinations,
    required this.title,
  });

  @override
  State<HealthTrendChart> createState() => _HealthTrendChartState();
}

class _HealthTrendChartState extends State<HealthTrendChart> {
  int _selectedIndex = 0;
  final List<String> _chartTypes = [
    'Gula Darah Puasa',
    'Gula Darah Sewaktu',
    'Tekanan Darah',
    'HbA1c',
  ];

  @override
  Widget build(BuildContext context) {
    // Sort examinations by date (oldest first for charting)
    final sortedExaminations = List<Examination>.from(widget.examinations)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartTypeSelector(),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: sortedExaminations.isEmpty
              ? _buildEmptyChart()
              : _buildChart(sortedExaminations),
        ),
      ],
    );
  }

  Widget _buildChartTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(
          _chartTypes.length,
              (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_chartTypes[index]),
              selected: _selectedIndex == index,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryLight,
              labelStyle: TextStyle(
                color: _selectedIndex == index
                    ? AppColors.primaryColor
                    : AppColors.textSecondary,
                fontWeight: _selectedIndex == index
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.show_chart,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data untuk ditampilkan',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan data pemeriksaan untuk melihat grafik',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<Examination> sortedExaminations) {
    switch (_selectedIndex) {
      case 0:
        return _buildBloodGlucoseFastingChart(sortedExaminations);
      case 1:
        return _buildBloodGlucoseRandomChart(sortedExaminations);
      case 2:
        return _buildBloodPressureChart(sortedExaminations);
      case 3:
        return _buildHbA1cChart(sortedExaminations);
      default:
        return _buildBloodGlucoseFastingChart(sortedExaminations);
    }
  }

  Widget _buildBloodGlucoseFastingChart(List<Examination> examinations) {
    // Filter out examinations without bloodGlucoseFasting
    final filteredExaminations = examinations
        .where((e) => e.bloodGlucoseFasting != null)
        .toList();

    if (filteredExaminations.isEmpty) {
      return _buildEmptyChart();
    }

    // Extract data for the chart
    final spots = filteredExaminations
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key.toDouble();
      final value = entry.value.bloodGlucoseFasting!;
      return FlSpot(index, value);
    })
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < filteredExaminations.length) {
                  final date = filteredExaminations[index].dateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 0.5),
        ),
        minX: 0,
        maxX: (filteredExaminations.length - 1).toDouble(),
        minY: 60,
        maxY: 200,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final value = spot.y;
                Color color;
                if (value < 70) {
                  color = AppColors.warning;
                } else if (value > 100) {
                  color = AppColors.error;
                } else {
                  color = AppColors.success;
                }

                return FlDotCirclePainter(
                  radius: 5,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryColor.withOpacity(0.2),
            ),
          ),
        ],
        // Add a horizontal line for the normal range (70-100)
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 70,
              color: AppColors.warning,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) => 'Min: 70',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.warning,
                ),
                alignment: Alignment.topLeft,
              ),
            ),
            HorizontalLine(
              y: 100,
              color: AppColors.success,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) => 'Max: 100',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.success,
                ),
                alignment: Alignment.topLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodGlucoseRandomChart(List<Examination> examinations) {
    // Similar to bloodGlucoseFasting chart with different data
    final filteredExaminations = examinations
        .where((e) => e.bloodGlucoseRandom != null)
        .toList();

    if (filteredExaminations.isEmpty) {
      return _buildEmptyChart();
    }

    // Extract data for the chart
    final spots = filteredExaminations
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key.toDouble();
      final value = entry.value.bloodGlucoseRandom!;
      return FlSpot(index, value);
    })
        .toList();

    // Similar implementation as above but with different normal ranges and colors
    return LineChart(
      // Chart data similar to above but with different values
      LineChartData(
        // Similar configuration but with different ranges for GDS
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 25,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < filteredExaminations.length) {
                  final date = filteredExaminations[index].dateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 0.5),
        ),
        minX: 0,
        maxX: (filteredExaminations.length - 1).toDouble(),
        minY: 70,
        maxY: 250,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.featureExamColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final value = spot.y;
                Color color;
                if (value < 70) {
                  color = AppColors.warning;
                } else if (value > 140) {
                  color = AppColors.error;
                } else {
                  color = AppColors.success;
                }

                return FlDotCirclePainter(
                  radius: 5,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.featureExamColor.withOpacity(0.2),
            ),
          ),
        ],
        // Add a horizontal line for the normal range (70-140)
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 70,
              color: AppColors.warning,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) => 'Min: 70',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.warning,
                ),
                alignment: Alignment.topLeft,
              ),
            ),
            HorizontalLine(
              y: 140,
              color: AppColors.success,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) => 'Max: 140',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.success,
                ),
                alignment: Alignment.topLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodPressureChart(List<Examination> examinations) {
    if (examinations.isEmpty) {
      return _buildEmptyChart();
    }

    // Extract data for the chart
    final systolicSpots = examinations
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key.toDouble();
      final value = entry.value.systolic.toDouble();
      return FlSpot(index, value);
    })
        .toList();

    final diastolicSpots = examinations
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key.toDouble();
      final value = entry.value.diastolic.toDouble();
      return FlSpot(index, value);
    })
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < examinations.length) {
                  final date = examinations[index].dateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 0.5),
        ),
        minX: 0,
        maxX: (examinations.length - 1).toDouble(),
        minY: 40,
        maxY: 180,
        lineBarsData: [
          // Systolic line
          LineChartBarData(
            spots: systolicSpots,
            isCurved: true,
            color: AppColors.error,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: false,
            ),
          ),
          // Diastolic line
          LineChartBarData(
            spots: diastolicSpots,
            isCurved: true,
            color: AppColors.info,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: false,
            ),
          ),
        ],
        // Add horizontal lines for the normal ranges
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 120,
              color: AppColors.error.withOpacity(0.7),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) => 'Sistole: 120',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.error,
                ),
                alignment: Alignment.topLeft,
              ),
            ),
            HorizontalLine(
              y: 80,
              color: AppColors.info.withOpacity(0.7),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) => 'Diastole: 80',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.info,
                ),
                alignment: Alignment.topLeft,
              ),
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedBarSpot) {
              return AppColors.accentColor;
            },
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final barIndex = touchedSpot.barIndex;
                final value = touchedSpot.y.round();
                final title = barIndex == 0 ? 'Sistole' : 'Diastole';
                final color = barIndex == 0 ? AppColors.error : AppColors.info;

                return LineTooltipItem(
                  '$title: $value mmHg',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHbA1cChart(List<Examination> examinations) {
    // Filter out examinations without hba1c
    final filteredExaminations = examinations
        .where((e) => e.hba1c != null)
        .toList();

    if (filteredExaminations.isEmpty) {
      return _buildEmptyChart();
    }

    // Extract data for the chart
    final spots = filteredExaminations
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key.toDouble();
      final value = entry.value.hba1c!;
      return FlSpot(index, value);
    })
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < filteredExaminations.length) {
                  final date = filteredExaminations[index].dateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 0.5),
        ),
        minX: 0,
        maxX: (filteredExaminations.length - 1).toDouble(),
        minY: 4,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.secondaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final value = spot.y;
                Color color;
                if (value < 4) {
                  color = AppColors.warning;
                } else if (value > 5.6) {
                  color = AppColors.error;
                } else {
                  color = AppColors.success;
                }

                return FlDotCirclePainter(
                  radius: 5,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.secondaryColor.withOpacity(0.2),
            ),
          ),
        ],
        // Add a horizontal line for the normal range (4-5.6%)
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 5.6,
              color: AppColors.success,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (line) => 'Max: 5.6%',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.success,
                ),
                alignment: Alignment.topLeft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}