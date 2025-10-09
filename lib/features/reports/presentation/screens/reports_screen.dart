import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_state.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/sidebar_nav.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final String _selectedRange = 'Today';

  @override
  Widget build(BuildContext context) {
    // Clamp text scaling
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Row(
          children: [
            // Sidebar navigation
            if (isDesktop) const SidebarNav(activeRoute: AppRouter.reports),

            // Main content
            Expanded(
              child: BlocConsumer<ReportsBloc, ReportsState>(
                listener: (context, state) {
                  if (state is ReportsError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return CustomScrollView(
                    slivers: [
                      // Header
                      _buildHeader(),

                      // KPI Cards
                      _buildKPICards(),

                      // Content Grid
                      _buildContentGrid(),

                      // Footer Snapshot
                      _buildSnapshotBanner(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            // Title section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'R',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Restaurant Reports',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Main Branch',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Controls
            Row(
              children: [
                // Date range selector
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedRange,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Export buttons
                _buildIconButton(Icons.picture_as_pdf, 'PDF'),
                const SizedBox(width: 4),
                _buildIconButton(Icons.table_chart, 'Excel'),
                const SizedBox(width: 4),
                _buildIconButton(Icons.print, 'Print'),
                const SizedBox(width: 8),

                // Advanced Reports
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Advanced Reports'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: () {},
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildKPICards() {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildKPICard(context, index),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildKPICard(BuildContext context, int index) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoaded &&
            index < state.reportsData.kpiCards.length) {
          final kpi = state.reportsData.kpiCards[index];
          final color = _parseColor(kpi.color);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.1), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      kpi.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      kpi.positive ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: kpi.positive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  kpi.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kpi.delta,
                  style: TextStyle(
                    fontSize: 11,
                    color: kpi.positive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Color _parseColor(String colorHex) {
    return Color(int.parse(colorHex.substring(2), radix: 16));
  }

  Widget _buildContentGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        delegate: SliverChildListDelegate([
          _buildOrderFunnelCard(),
          _buildServiceSpeedCard(),
          _buildPaymentMethodsCard(),
          _buildDiscountsImpactCard(),
          _buildHourlySalesCard(),
          _buildCategorySalesCard(),
          _buildTopSellingCard(),
          _buildNeedsAttentionCard(),
          _buildStaffPerformanceCard(),
        ]),
      ),
    );
  }

  Widget _buildOrderFunnelCard() {
    return _buildCard(
      'Order Funnel',
      Icons.filter_list,
      BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoaded) {
            return Column(
              children: state.reportsData.orderFunnel.map((stage) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildFunnelBar(
                    stage.label,
                    stage.value,
                    stage.max,
                    _parseColor(stage.color),
                  ),
                );
              }).toList(),
            );
          }

          return Column(
            children: [
              _buildFunnelBar('Orders Placed', 0, 100, Colors.grey.shade300),
              const SizedBox(height: 8),
              _buildFunnelBar('In Kitchen', 0, 100, Colors.grey.shade300),
              const SizedBox(height: 8),
              _buildFunnelBar('Served', 0, 100, Colors.grey.shade300),
              const SizedBox(height: 8),
              _buildFunnelBar('Paid', 0, 100, Colors.grey.shade300),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFunnelBar(String label, int value, int max, Color color) {
    final percentage = value / max;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          flex: 7,
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSpeedCard() {
    return _buildCard(
      'Service Speed',
      Icons.access_time,
      BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoaded) {
            final serviceSpeed = state.reportsData.serviceSpeed;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sections: serviceSpeed.chartSections.map((section) {
                            return PieChartSectionData(
                              value: section.value.toDouble(),
                              color: _parseColor(section.color),
                              radius: 30,
                              showTitle: false,
                            );
                          }).toList(),
                          sectionsSpace: 0,
                          centerSpaceRadius: 45,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              serviceSpeed.avgTime,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              serviceSpeed.avgTimeLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Prep Time',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          serviceSpeed.prepTime,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Service Time',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          serviceSpeed.serviceTime,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 50,
                            color: Colors.grey.shade300,
                            radius: 30,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 50,
                            color: Colors.grey.shade200,
                            radius: 30,
                            showTitle: false,
                          ),
                        ],
                        sectionsSpace: 0,
                        centerSpaceRadius: 45,
                      ),
                    ),
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '--',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Avg Time',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Prep Time',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const Text(
                        '--',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Service Time',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const Text(
                        '--',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodsCard() {
    return _buildCard(
      'Payment Methods',
      Icons.payment,
      BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoaded) {
            return Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: state.reportsData.paymentMethods.map((method) {
                        return PieChartSectionData(
                          value: method.percentage.toDouble(),
                          color: _parseColor(method.color),
                          title: '${method.percentage}%',
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: state.reportsData.paymentMethods.map((method) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildLegendItem(
                        method.method,
                        '${method.percentage}%',
                        _parseColor(method.color),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 25,
                        color: Colors.grey.shade300,
                        title: '',
                        titleStyle: const TextStyle(fontSize: 11),
                      ),
                      PieChartSectionData(
                        value: 25,
                        color: Colors.grey.shade400,
                        title: '',
                        titleStyle: const TextStyle(fontSize: 11),
                      ),
                      PieChartSectionData(
                        value: 25,
                        color: Colors.grey.shade500,
                        title: '',
                        titleStyle: const TextStyle(fontSize: 11),
                      ),
                      PieChartSectionData(
                        value: 25,
                        color: Colors.grey.shade600,
                        title: '',
                        titleStyle: const TextStyle(fontSize: 11),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Card', '--', Colors.grey.shade300),
                  const SizedBox(height: 8),
                  _buildLegendItem('Cash', '--', Colors.grey.shade400),
                  const SizedBox(height: 8),
                  _buildLegendItem('Online', '--', Colors.grey.shade500),
                  const SizedBox(height: 8),
                  _buildLegendItem('Wallet', '--', Colors.grey.shade600),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label: $value', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDiscountsImpactCard() {
    return _buildCard(
      'Discounts Impact',
      Icons.local_offer,
      BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 250,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 238,
                  color: const Color(0xFF3B82F6),
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 82,
                  color: const Color(0xFF10B981),
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 45,
                  color: const Color(0xFFF97316),
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: 15,
                  color: const Color(0xFF8B5CF6),
                  width: 20,
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Full', '5%', '10%', 'Voucher'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      titles[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildHourlySalesCard() {
    return _buildCard(
      'Hourly Sales Trend',
      Icons.show_chart,
      LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                const FlLine(color: Color(0xFFF3F4F6), strokeWidth: 1),
          ),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 600),
                const FlSpot(2, 1200),
                const FlSpot(4, 800),
                const FlSpot(6, 1800),
                const FlSpot(8, 1400),
                const FlSpot(10, 2100),
              ],
              isCurved: true,
              color: const Color(0xFF3B82F6),
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySalesCard() {
    return _buildCard(
      'Category Sales',
      Icons.category,
      BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoaded) {
            return Column(
              children: state.reportsData.categorySales.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCategoryItem(
                    category.name,
                    category.amount,
                    category.percentage,
                    _parseColor(category.color),
                  ),
                );
              }).toList(),
            );
          }

          return Column(
            children: [
              _buildCategoryItem('Burgers', '--', 0.0, Colors.grey.shade300),
              const SizedBox(height: 8),
              _buildCategoryItem('Pizza', '--', 0.0, Colors.grey.shade300),
              const SizedBox(height: 8),
              _buildCategoryItem('Drinks', '--', 0.0, Colors.grey.shade300),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    String amount,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              amount,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}% of total',
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildTopSellingCard() {
    return _buildCard(
      'Top Selling Items',
      Icons.star,
      BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoaded) {
            return Column(
              children: state.reportsData.topSellingItems.map((item) {
                final index = state.reportsData.topSellingItems.indexOf(item);
                return Column(
                  children: [
                    _buildTopItem(
                      item.emoji,
                      item.name,
                      item.revenue,
                      item.rank,
                      item.orders,
                    ),
                    if (index < state.reportsData.topSellingItems.length - 1)
                      const Divider(height: 16),
                  ],
                );
              }).toList(),
            );
          }

          return Column(
            children: [
              _buildTopItem('🍔', 'Loading...', '--', '#1', '--'),
              const Divider(height: 16),
              _buildTopItem('🍕', 'Loading...', '--', '#2', '--'),
              const Divider(height: 16),
              _buildTopItem('🍗', 'Loading...', '--', '#3', '--'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopItem(
    String emoji,
    String name,
    String revenue,
    String rank,
    String orders,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  orders,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                revenue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rank,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeedsAttentionCard() {
    return _buildCard(
      'Needs Attention',
      Icons.warning_amber,
      BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoaded) {
            return Column(
              children: [
                ...state.reportsData.needsAttention.map((item) {
                  final index = state.reportsData.needsAttention.indexOf(item);
                  return Column(
                    children: [
                      _buildAttentionItem(
                        item.emoji,
                        item.name,
                        item.revenue,
                        item.orders,
                      ),
                      if (index < state.reportsData.needsAttention.length - 1)
                        const Divider(height: 16),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF97316),
                      side: const BorderSide(color: Color(0xFFF97316)),
                    ),
                    child: const Text('View Marketing Suggestions'),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildAttentionItem('🌮', 'Loading...', '--', '--'),
              const Divider(height: 16),
              _buildAttentionItem('🥗', 'Loading...', '--', '--'),
              const Divider(height: 16),
              _buildAttentionItem('🌯', 'Loading...', '--', '--'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF97316),
                    side: const BorderSide(color: Color(0xFFF97316)),
                  ),
                  child: const Text('View Marketing Suggestions'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAttentionItem(
    String emoji,
    String name,
    String revenue,
    String orders,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  orders,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                revenue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF97316),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Review',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffPerformanceCard() {
    return _buildCard(
      'Staff Performance Today',
      Icons.people,
      BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoaded) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.reportsData.staffPerformance.map((staff) {
                return _buildStaffCard(
                  staff.initial,
                  staff.name,
                  staff.orders,
                  staff.upsells,
                  staff.efficiency,
                  _parseColor(staff.color),
                );
              }).toList(),
            );
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStaffCard(
                'S',
                'Loading...',
                '--',
                '--',
                '--',
                Colors.grey.shade300,
              ),
              _buildStaffCard(
                'M',
                'Loading...',
                '--',
                '--',
                '--',
                Colors.grey.shade300,
              ),
              _buildStaffCard(
                'L',
                'Loading...',
                '--',
                '--',
                '--',
                Colors.grey.shade300,
              ),
              _buildStaffCard(
                'T',
                'Loading...',
                '--',
                '--',
                '--',
                Colors.grey.shade300,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStaffCard(
    String initial,
    String name,
    String orders,
    String upsells,
    String efficiency,
    Color color,
  ) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Orders: $orders', style: const TextStyle(fontSize: 10)),
          Text(
            'Upsells: $upsells',
            style: TextStyle(fontSize: 10, color: Colors.green[700]),
          ),
          Text(
            'Efficiency: $efficiency',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            if (state is ReportsLoaded) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.reportsData.snapshotBanner.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.reportsData.snapshotBanner.summary,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View Advanced Online Reports'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Snapshot",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading...',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View Advanced Online Reports'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
