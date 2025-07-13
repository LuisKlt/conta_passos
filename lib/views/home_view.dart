import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/steps_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StepsViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Passos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar dados',
            onPressed: () {
              context.read<StepsViewModel>().refreshStepData();
            },
          ),
        ],
      ),
      body: Consumer<StepsViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.refreshStepData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeaderCard(viewModel),
                    const SizedBox(height: 16),
                    _buildStepCountCard(viewModel),
                    const SizedBox(height: 16),
                    _buildInfoCard(viewModel),
                    const SizedBox(height: 16),
                    _buildActionButtons(viewModel),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(StepsViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.watch, size: 48, color: Colors.indigo),
            const SizedBox(height: 10),
            const Text(
              'Passos do Relógio',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Dados sincronizados nas últimas 24 horas',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCountCard(StepsViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            if (viewModel.isLoading)
              const CircularProgressIndicator()
            else if (viewModel.errorMessage != null)
              Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else if (viewModel.stepData != null)
              Column(
                children: [
                  Text(
                    NumberFormat(
                      '#,###',
                    ).format(viewModel.stepData!.totalSteps),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Passos registrados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atualizado em: ${DateFormat('dd/MM/yyyy HH:mm').format(viewModel.stepData!.date)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              )
            else
              const Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Nenhum dado encontrado.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(StepsViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalhes da Sincronização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  viewModel.hasPermissions ? Icons.check_circle : Icons.cancel,
                  color: viewModel.hasPermissions ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.hasPermissions
                      ? 'Permissões concedidas'
                      : 'Permissões não concedidas',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            if (viewModel.stepData != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.source, color: Colors.deepPurple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fonte dos dados: ${viewModel.stepData!.source}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(StepsViewModel viewModel) {
    return Column(
      children: [
        if (!viewModel.hasPermissions)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: viewModel.isLoading
                  ? null
                  : viewModel.requestPermissions,
              icon: const Icon(Icons.security),
              label: const Text('Permitir acesso aos dados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        if (viewModel.hasPermissions) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: viewModel.isLoading ? null : viewModel.loadStepData,
              icon: const Icon(Icons.sync),
              label: const Text('Recarregar passos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showHelpDialog(context),
              icon: const Icon(Icons.help_outline),
              label: const Text('Ajuda'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda'),
        content: const Text(
          'Este aplicativo acessa dados de passos sincronizados do seu smartwatch via Health Connect.\n\n'
          'Para garantir que os dados sejam exibidos corretamente:\n\n'
          '1. Certifique-se de que o relógio está emparelhado e sincronizando\n'
          '2. Instale e configure o Health Connect no celular\n'
          '3. Conceda as permissões quando solicitado\n'
          '4. Aguarde alguns minutos para que os dados sejam sincronizados',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
