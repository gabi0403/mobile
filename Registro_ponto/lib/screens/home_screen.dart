import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../models/local_user.dart';
import '../models/point_record.dart';
import '../services/local_database.dart';
import '../services/ponto_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user, required this.onSignOut});

  final LocalUser user;
  final VoidCallback onSignOut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pontoService = PontoService();
  final _localAuth = LocalAuthentication();
  bool _busy = false;
  late Future<List<PointRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = LocalDatabase.instance.recentRecords(widget.user.id);
  }

  Future<void> _registerPoint() async {
    setState(() => _busy = true);
    try {
      final biometricUsed = await _authenticateIfAvailable();
      final receipt = await _pontoService.registerPoint(widget.user);
      if (!mounted) return;
      setState(() {
        _recordsFuture = LocalDatabase.instance.recentRecords(widget.user.id);
      });
      _showMessage(
        biometricUsed
            ? 'Ponto registrado com biometria a ${receipt.distanceMeters.round()} m do local.'
            : 'Ponto registrado a ${receipt.distanceMeters.round()} m. '
                  'Biometria indisponível; sessão autenticada.',
        success: true,
      );
    } on PontoException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível registrar. Verifique o GPS.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _authenticateIfAvailable() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty || !await _localAuth.canCheckBiometrics) {
        return false;
      }
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Confirme sua identidade para registrar o ponto.',
        biometricOnly: true,
      );
      if (!authenticated) {
        throw const PontoException('A confirmação biométrica foi cancelada.');
      }
      return true;
    } on LocalAuthException catch (error) {
      if (error.code == LocalAuthExceptionCode.noBiometricHardware ||
          error.code == LocalAuthExceptionCode.noBiometricsEnrolled ||
          error.code == LocalAuthExceptionCode.noCredentialsSet ||
          error.code ==
              LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable) {
        return false;
      }
      rethrow;
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? const Color(0xFF126B5B) : null,
        ),
      );
  }

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha jornada'),
        actions: [
          IconButton(
            tooltip: 'Sair da conta',
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _dateLabel(today),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Olá, ${widget.user.email.split('@').first}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _LocationPanel(configured: PontoService.workplaceConfigured),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _busy || !PontoService.workplaceConfigured
                        ? null
                        : _registerPoint,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(
                      _busy ? 'Verificando...' : 'Registrar ponto',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Text(
                        'Registros recentes',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.storage_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Salvos no aparelho',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _RecentRecords(recordsFuture: _recordsFuture),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationPanel extends StatelessWidget {
  const _LocationPanel({required this.configured});

  final bool configured;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF173D36),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFFD7E67A)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  configured ? 'Local de trabalho' : 'Local não configurado',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                configured ? Icons.verified_outlined : Icons.warning_amber,
                color: configured ? const Color(0xFFD7E67A) : Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '100',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'm de raio',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const Spacer(),
              Icon(Icons.my_location, color: colorScheme.tertiary, size: 26),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            configured
                ? 'O registro é liberado somente dentro desta área.'
                : 'Defina WORKPLACE_LATITUDE e WORKPLACE_LONGITUDE para habilitar o registro.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _RecentRecords extends StatelessWidget {
  const _RecentRecords({required this.recordsFuture});

  final Future<List<PointRecord>> recordsFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PointRecord>>(
      future: recordsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _RecordMessage(
            icon: Icons.storage_outlined,
            text: 'Não foi possível carregar os registros.',
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return const _RecordMessage(
            icon: Icons.event_available_outlined,
            text: 'Nenhum ponto registrado ainda.',
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE1E5DF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (var index = 0; index < records.length; index++) ...[
                _RecordRow(record: records[index]),
                if (index < records.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});

  final PointRecord record;

  @override
  Widget build(BuildContext context) {
    final distance = record.distanceMeters.round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF126B5B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.time,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(record.date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$distance m do local'),
              Text(
                '${record.latitude.toStringAsFixed(4)}, '
                '${record.longitude.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordMessage extends StatelessWidget {
  const _RecordMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E5DF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
