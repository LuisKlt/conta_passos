import 'package:flutter/material.dart';
import '../models/step_data.dart';
import '../services/health_service.dart';

class StepsViewModel extends ChangeNotifier {
  final HealthService _healthService = HealthService();

  StepData? get stepData => _stepData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPermissions => _hasPermissions;

  StepData? _stepData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPermissions = false;

  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      bool isAvailable = await _healthService.isHealthConnectAvailable();
      if (!isAvailable) {
        _setError('Health Connect não está disponível neste dispositivo');
        return;
      }

      _hasPermissions = await _healthService.hasPermissions();

      if (_hasPermissions) {
        await _loadStepData();
      }
    } catch (e) {
      _setError('Erro ao inicializar: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> requestPermissions() async {
    _setLoading(true);
    _clearError();

    try {
      bool granted = await _healthService.requestPermissions();
      _hasPermissions = granted;

      if (granted) {
        await _loadStepData();
      } else {
        _setError('Permissões negada');
      }

      return granted;
    } catch (e) {
      _setError('Erro ao solicitar permissões: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadStepData() async {
    _setLoading(true);
    _clearError();

    try {
      StepData? data = await _healthService.getStepsLast24Hours();
      if (data != null) {
        _stepData = data;
      } else {
        _setError('Não foi possível carregar os dados');
      }
    } catch (e) {
      _setError('Erro: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStepData() async {
    if (!_hasPermissions) {
      _setError('Permissões negada');
      return;
    }

    await _loadStepData();
  }

  Future<void> refreshStepData() async {
    await _loadStepData();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
