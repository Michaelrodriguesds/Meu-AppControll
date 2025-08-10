// lib/utils/network_checker.dart

import 'package:connectivity_plus/connectivity_plus.dart';

/// Classe utilitária para verificar a conexão com a internet.
class NetworkChecker {
  /// Retorna true se o dispositivo estiver online (Wi-Fi ou dados móveis).
  static Future<bool> isOnline() async {
    // A partir da versão 6.0.0, checkConnectivity() retorna uma lista
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();

    // Verifica se algum dos resultados é mobile ou wifi
    return results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
  }

  /// Retorna uma descrição legível do tipo de conexão atual.
  static Future<String> getConnectionStatus() async {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();

    if (results.contains(ConnectivityResult.mobile)) {
      return 'Conectado via dados móveis';
    } else if (results.contains(ConnectivityResult.wifi)) {
      return 'Conectado via Wi-Fi';
    } else if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return 'Sem conexão com a internet';
    } else {
      return 'Status de conexão desconhecido';
    }
  }
}
