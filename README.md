# Calculadora de Calorias

Aplicativo Flutter para calcular e acompanhar o consumo de calorias e nutrientes diários.

## Funcionalidades

- Registro de refeições (Café da Manhã, Almoço, Janta e Lanchinho)
- Cálculo automático de calorias, proteínas, lipídios, carboidratos e fibras
- Dashboard com gráficos para acompanhar o progresso
- Armazenamento local de dados
- Interface mobile otimizada

## Requisitos

- Flutter SDK 3.0.0 ou superior
- Android Studio ou VS Code

## Instalação

1. Clone este repositório
2. Navegue até o diretório do projeto
3. Execute `flutter pub get` para instalar as dependências
4. Execute `flutter run` para rodar o aplicativo

## Como Usar

### Adicionar Refeições

1. Na tela inicial, selecione o tipo de refeição (Café da Manhã, Almoço, Janta ou Lanchinho)
2. Toque no botão + para adicionar um alimento
3. Preencha as informações do alimento:
   - Nome
   - Quantidade em gramas
   - Calorias (por 100g)
   - Proteínas (por 100g)
   - Lipídios (por 100g)
   - Carboidratos (por 100g)
   - Fibras (por 100g)
4. Toque em "Adicionar"

### Visualizar Progresso

1. Acesse a aba "Dashboard" na parte inferior
2. Visualize o progresso diário de calorias
3. Veja os gráficos de macronutrientes
4. Acompanhe o progresso semanal

### Configurar Meta Diária

1. Toque no ícone de configurações no canto superior direito
2. Defina sua meta diária de calorias
3. Toque em "Salvar"

### Navegar Entre Datas

1. Na tela inicial, use as setas para navegar entre os dias
2. Ou toque na data para abrir o seletor de data

## Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do aplicativo
├── models/
│   ├── food_item.dart        # Modelo de alimento
│   └── meal.dart             # Modelo de refeição
├── providers/
│   └── meal_provider.dart    # Gerenciamento de estado
├── database/
│   └── database_helper.dart  # Banco de dados SQLite
└── screens/
    ├── home_screen.dart      # Tela principal
    ├── meal_screen.dart      # Tela de refeições
    └── dashboard_screen.dart # Tela de dashboard
```

## Dependências

- `provider`: Gerenciamento de estado
- `sqflite`: Banco de dados SQLite
- `fl_chart`: Gráficos
- `uuid`: Geração de identificadores únicos
- `intl`: Formatação de datas

## Licença

Este projeto é de uso pessoal.# food_calculator
