import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/location_service.dart';

class GeolocalizacaoScreen extends StatefulWidget {
  const GeolocalizacaoScreen({super.key});

  @override
  State<GeolocalizacaoScreen> createState() => _GeolocalizacaoScreenState();
}

class _GeolocalizacaoScreenState extends State<GeolocalizacaoScreen> {
  final _locationService = LocationService();

  Position? _posicaoAtual;
  bool _carregando = false;
  String? _mensagemErro;
  StreamSubscription<Position>? _positionStreamSub;
  bool _rastreando = false;
  bool _abrindoMapa = false;

  Future<void> _buscarLocalizacao() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final posicao = await _locationService.obterPosicaoAtual();
      setState(() => _posicaoAtual = posicao);
    } catch (erro) {
      setState(() => _mensagemErro = erro.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _alternarRastreamento() {
    if (_rastreando) {
      _positionStreamSub?.cancel();
      setState(() => _rastreando = false);
    } else {
      setState(() {
        _rastreando = true;
        _mensagemErro = null;
      });
      _positionStreamSub = _locationService.monitorarPosicao().listen(
        (posicao) {
          if (!mounted) return;
          setState(() => _posicaoAtual = posicao);
        },
        onError: (erro) {
          if (!mounted) return;
          setState(() => _mensagemErro = erro.toString());
        },
      );
    }
  }

  Future<void> _abrirNoMapa() async {
    final posicao = _posicaoAtual;
    if (posicao == null) return;

    final uri = Uri.parse(
      'https://maps.google.com/?q=${posicao.latitude},${posicao.longitude}',
    );

    setState(() => _abrindoMapa = true);
    try {
      final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abriu && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o mapa.')),
        );
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir o mapa: $erro')),
        );
      }
    } finally {
      if (mounted) setState(() => _abrindoMapa = false);
    }
  }

  Widget _chipPrecisao(double precisao) {
    Color cor;
    String texto;
    if (precisao < 15) {
      cor = Colors.green;
      texto = 'Alta precisão';
    } else if (precisao <= 50) {
      cor = Colors.amber.shade700;
      texto = 'Precisão média';
    } else {
      cor = Colors.red;
      texto = 'Baixa precisão';
    }

    return Chip(
      label: Text('$texto (${precisao.toStringAsFixed(1)} m)'),
      backgroundColor: cor.withValues(alpha: 0.15),
      side: BorderSide(color: cor),
      labelStyle: TextStyle(color: cor, fontWeight: FontWeight.w600),
    );
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posicao = _posicaoAtual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in & GPS'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_carregando) const Center(child: CircularProgressIndicator()),
            if (_mensagemErro != null) ...[
              const SizedBox(height: 8),
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _mensagemErro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
            if (posicao != null) ...[
              const SizedBox(height: 8),
              Card(
                elevation: 3,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.my_location, color: Colors.blue),
                      title: const Text('Latitude'),
                      subtitle: Text('${posicao.latitude}'),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.location_on, color: Colors.green),
                      title: const Text('Longitude'),
                      subtitle: Text('${posicao.longitude}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.speed, color: Colors.orange),
                      title: const Text('Precisão / Altitude'),
                      subtitle: Text(
                        'Precisão: ${posicao.accuracy.toStringAsFixed(1)}m | '
                        'Alt: ${posicao.altitude.toStringAsFixed(1)}m',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _chipPrecisao(posicao.accuracy),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Distância até a Fatec Matão: '
                        '${_locationService.calcularDistanciaParaFatecMatao(posicao).toStringAsFixed(0)} m',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton.icon(
                        onPressed: _abrindoMapa ? null : _abrirNoMapa,
                        icon: _abrindoMapa
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.map),
                        label: const Text('Abrir no Mapa'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _carregando ? null : _buscarLocalizacao,
              icon: const Icon(Icons.gps_fixed),
              label: const Text('Capturar Localização Atual'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _alternarRastreamento,
              icon: Icon(_rastreando ? Icons.stop : Icons.play_arrow),
              label: Text(
                _rastreando
                    ? 'Parar Rastreamento'
                    : 'Iniciar Rastreamento Contínuo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
