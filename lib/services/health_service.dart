import 'package:health/health.dart';
import '../models/step_data.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  static const List<HealthDataType> _dataTypes = [HealthDataType.STEPS];

  static const List<HealthDataAccess> _permissions = [HealthDataAccess.READ];

  Future<bool> isHealthConnectAvailable() async {
    return await _health.isDataTypeAvailable(HealthDataType.STEPS);
  }

  Future<bool> requestPermissions() async {
    try {
      bool requested = await _health.requestAuthorization(
        _dataTypes,
        permissions: _permissions,
      );

      if (requested) {
        bool? hasPermissions = await _health.hasPermissions(_dataTypes);
        return hasPermissions ?? false;
      }

      return false;
    } catch (e) {
      print('Erro ao solicitar permissões: $e');
      return false;
    }
  }

  Future<StepData?> getStepsLast24Hours() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.STEPS],
      );

      if (healthData.isEmpty) {
        return StepData(
          totalSteps: 0,
          date: now,
          source: 'Nenhum dado encontrado',
        );
      }

      List<HealthDataPoint> watchData = healthData.where((dataPoint) {
        String sourceName = dataPoint.sourceName.toLowerCase();
        return sourceName.contains('watch') ||
            sourceName.contains('wear') ||
            sourceName.contains('galaxy watch') ||
            sourceName.contains('pixel watch') ||
            sourceName.contains('fitbit');
      }).toList();

      List<HealthDataPoint> dataToProcess = watchData.isNotEmpty
          ? watchData
          : healthData;

      if (dataToProcess.isEmpty) {
        return StepData(
          totalSteps: 0,
          date: now,
          source: 'Nenhum dado de passos',
        );
      }

      int totalSteps = 0;
      String source = 'Health Connect';

      for (var dataPoint in dataToProcess) {
        if (dataPoint.value is NumericHealthValue) {
          totalSteps += (dataPoint.value as NumericHealthValue).numericValue
              .toInt();
          source = dataPoint.sourceName;
        }
      }

      return StepData(totalSteps: totalSteps, date: now, source: source);
    } catch (e) {
      print('Erro ao obter dados: $e');
      return null;
    }
  }

  Future<bool> hasPermissions() async {
    return await _health.hasPermissions(_dataTypes) ?? false;
  }
}
