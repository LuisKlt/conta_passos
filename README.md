Este aplicativo Android, desenvolvido com Flutter e arquitetura MVVM, tem como objetivo exibir a quantidade de passos dados pelo usuário nas últimas 24 horas, utilizando exclusivamente os dados coletados de um smartwatch com Wear OS, sincronizados via Health Connect no smartphone. Nenhum dado do próprio celular é utilizado.

# Funcionamento do App
O app é dividido em três camadas principais:

- Model (StepData): representa os dados de passos (quantidade + intervalo de tempo).

- ViewModel (StepViewModel): contém a lógica de acesso ao Health Connect e controle do estado da UI.

- View (HomeScreen): interface do usuário que exibe o total de passos e permite atualizar os dados.

# Fluxo:
1. Ao abrir o app, o ViewModel solicita os dados de passos das últimas 24 horas via Health Connect (usando Kotlin).

2. O Health Connect retorna os dados agregados de passos sincronizados do smartwatch.

3. A UI exibe o total de passos e o intervalo de coleta (início e fim).

4. O usuário pode atualizar os dados clicando no botão de atualização.

# Permissões Utilizadas
Para acessar os dados de passos no Health Connect, a seguinte permissão foi solicitada:

`HealthPermission.getReadPermission(StepsRecord::class)`

Essa permissão foi:

- Solicitada dinamicamente em tempo de execução.

- Verificada antes de cada chamada para garantir que foi concedida.

- Obrigatória para que o app funcione corretamente.

Caso a permissão não esteja concedida, o app informa o usuário e não tenta acessar os dados.

# Acesso aos Dados via Health Connect
A integração com o Health Connect foi feita da seguinte forma:

- Utilizando Platform Channels (MethodChannel) para comunicação entre Flutter e código nativo (Kotlin).

No lado nativo (arquivo Kotlin):

- Foi utilizado o HealthConnectClient com uma AggregateRequest para obter a soma total de passos (AggregateMetrics.Steps.COUNT_TOTAL).

- A busca foi feita para o intervalo entre agora e agora - 24 horas.

- No Flutter, os dados foram recebidos por meio do MethodChannel e enviados ao ViewModel.