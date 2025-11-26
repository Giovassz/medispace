import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';
import '../models/appointment_model.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class GraphicsPage extends StatefulWidget {
  const GraphicsPage({super.key});

  @override
  State<GraphicsPage> createState() => _GraphicsPageState();
}

class _GraphicsPageState extends State<GraphicsPage> {
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();
  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar que el usuario sea médico
      final user = await _authService.getCurrentUserData();
      if (user == null || user.role != 'doctor') {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esta pantalla es exclusiva para médicos'),
            ),
          );
        }
        return;
      }

      setState(() {
        _currentUser = user;
      });

      // Obtener todas las citas
      final appointments = await _appointmentService.getAllAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Obtener datos de citas por mes
  Map<String, int> _getAppointmentsByMonth() {
    Map<String, int> monthlyData = {};
    
    for (var appointment in _appointments) {
      // Usar formato sin locale para compatibilidad con web
      final monthKey = DateFormat('MMM yyyy').format(appointment.createdAt);
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
    }

    // Ordenar por fecha
    final sortedKeys = monthlyData.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('MMM yyyy').parse(a);
          final dateB = DateFormat('MMM yyyy').parse(b);
          return dateA.compareTo(dateB);
        } catch (e) {
          // Si hay error al parsear, comparar como strings
          return a.compareTo(b);
        }
      });

    Map<String, int> sortedData = {};
    for (var key in sortedKeys) {
      sortedData[key] = monthlyData[key]!;
    }

    return sortedData;
  }

  // Obtener datos de citas completadas vs canceladas
  Map<String, int> _getAppointmentsByStatus() {
    int completed = 0;
    int cancelled = 0;
    int scheduled = 0;
    int confirmed = 0;

    for (var appointment in _appointments) {
      switch (appointment.status) {
        case 'completed':
          completed++;
          break;
        case 'cancelled':
          cancelled++;
          break;
        case 'scheduled':
          scheduled++;
          break;
        case 'confirmed':
          confirmed++;
          break;
      }
    }

    return {
      'Completadas': completed,
      'Canceladas': cancelled,
      'Programadas': scheduled,
      'Confirmadas': confirmed,
    };
  }

  // Obtener datos de pacientes por doctor
  Map<String, int> _getPatientsByDoctor() {
    Map<String, Set<String>> doctorPatients = {};

    for (var appointment in _appointments) {
      if (!doctorPatients.containsKey(appointment.doctorName)) {
        doctorPatients[appointment.doctorName] = <String>{};
      }
      doctorPatients[appointment.doctorName]!.add(appointment.patientId);
    }

    Map<String, int> result = {};
    doctorPatients.forEach((doctor, patients) {
      result[doctor] = patients.length;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: Text(
            'Gráficas Interactivas',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF667EEA),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
          ),
        ),
      );
    }

    if (_currentUser == null || _currentUser!.role != 'doctor') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gráficas'),
          backgroundColor: const Color(0xFF667EEA),
        ),
        body: const Center(
          child: Text('Esta pantalla es exclusiva para médicos'),
        ),
      );
    }

    final monthlyData = _getAppointmentsByMonth();
    final statusData = _getAppointmentsByStatus();
    final doctorData = _getPatientsByDoctor();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          'Gráficas Interactivas',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF667EEA),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Gráfica 1: Citas por mes (Línea)
              if (monthlyData.isNotEmpty) ...[
                _buildChartCard(
                  title: 'Citas Creadas por Mes',
                  subtitle: 'Evolución mensual de citas creadas',
                  child: _buildLineChart(monthlyData),
                ),
                const SizedBox(height: 24),
              ],

              // Gráfica 2: Citas completadas vs canceladas (Pie)
              if (statusData.isNotEmpty) ...[
                _buildChartCard(
                  title: 'Estado de las Citas',
                  subtitle: 'Distribución por estado',
                  child: _buildPieChart(statusData),
                ),
                const SizedBox(height: 24),
              ],

              // Gráfica 3: Pacientes por doctor (Barras)
              if (doctorData.isNotEmpty) ...[
                _buildChartCard(
                  title: 'Pacientes Atendidos por Doctor',
                  subtitle: 'Número de pacientes únicos por médico',
                  child: _buildBarChart(doctorData),
                ),
                const SizedBox(height: 24),
              ],

              // Información adicional
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Análisis de Datos',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Visualización de estadísticas de citas',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total de citas analizadas: ${_appointments.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(Map<String, int> monthlyData) {
    if (monthlyData.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    final spots = <FlSpot>[];
    final months = monthlyData.keys.toList();
    
    for (int i = 0; i < months.length; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyData[months[i]]!.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFE2E8F0),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[value.toInt()],
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF718096),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
            left: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
          ),
        ),
        minX: 0,
        maxX: (months.length - 1).toDouble(),
        minY: 0,
        maxY: monthlyData.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF667EEA),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF667EEA).withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF667EEA),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                return LineTooltipItem(
                  '${months[touchedSpot.x.toInt()]}\n${touchedSpot.y.toInt()} citas',
                  GoogleFonts.poppins(
                    color: Colors.white,
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

  Widget _buildPieChart(Map<String, int> statusData) {
    if (statusData.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    final total = statusData.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    final colors = [
      const Color(0xFF48BB78), // Completadas - Verde
      const Color(0xFFF56565), // Canceladas - Rojo
      const Color(0xFFF6AD55), // Programadas - Naranja
      const Color(0xFF4299E1), // Confirmadas - Azul
    ];

    int colorIndex = 0;
    final pieChartSections = statusData.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}\n(${percentage.toStringAsFixed(1)}%)',
        color: color,
        radius: 80,
        titleStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: pieChartSections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    return;
                  }
                  // Aquí puedes agregar interactividad adicional
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
          Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: statusData.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final dataEntry = entry.value;
              final color = colors[index % colors.length];
              final percentage = (dataEntry.value / total) * 100;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dataEntry.key,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            '${dataEntry.value} (${percentage.toStringAsFixed(1)}%)',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, int> doctorData) {
    if (doctorData.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    final maxValue = doctorData.values.reduce((a, b) => a > b ? a : b);
    final doctors = doctorData.keys.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue.toDouble() + 2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF667EEA),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${doctors[group.x.toInt()]}\n${rod.toY.toInt()} pacientes',
                GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < doctors.length) {
                  final doctorName = doctors[value.toInt()];
                  // Abreviar nombres largos
                  final displayName = doctorName.length > 15
                      ? '${doctorName.substring(0, 15)}...'
                      : doctorName;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF718096),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFE2E8F0),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
            left: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
          ),
        ),
        barGroups: doctors.asMap().entries.map((entry) {
          final index = entry.key;
          final doctor = entry.value;
          final value = doctorData[doctor]!;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value.toDouble(),
                color: const Color(0xFF667EEA),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF667EEA),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Información de las Gráficas',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.show_chart,
            'Citas por Mes',
            'Muestra la evolución mensual de las citas creadas en el sistema.',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.pie_chart,
            'Estado de las Citas',
            'Distribución porcentual de citas según su estado (completadas, canceladas, programadas, confirmadas).',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.bar_chart,
            'Pacientes por Doctor',
            'Número de pacientes únicos atendidos por cada médico en el sistema.',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.touch_app,
            'Interactividad',
            'Toca las gráficas para ver información detallada de cada punto de datos.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF667EEA),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF718096),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

