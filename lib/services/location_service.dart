import 'package:geolocator/geolocator.dart';

/// Coordenadas aproximadas da Fatec Matão (Matão/SP).
const double _fatecMataoLatitude = -21.603;
const double _fatecMataoLongitude = -48.366;

/// Camada de serviço responsável pela validação e captura do GPS.
class LocationService {
  /// Obtém a posição atual, validando serviço e permissões.
  Future<Position> obterPosicaoAtual() async {
    final servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      throw Exception('O serviço de GPS está desativado no dispositivo.');
    }

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        throw Exception('Permissão de localização negada pelo usuário.');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'Permissões negadas permanentemente. Altere nas configurações do aplicativo.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Retorna um stream contínuo de posições (rastreamento).
  Stream<Position> monitorarPosicao() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  /// Calcula a distância, em metros, até a Fatec Matão.
  double calcularDistanciaParaFatecMatao(Position posicao) {
    return Geolocator.distanceBetween(
      posicao.latitude,
      posicao.longitude,
      _fatecMataoLatitude,
      _fatecMataoLongitude,
    );
  }
}
