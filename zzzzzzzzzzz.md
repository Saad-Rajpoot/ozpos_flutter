Please create unit and widget tests for each feature in the project, following Clean Architecture, Bloc state management, and SOLID principles.

🧱 Folder Structure for Tests

Each feature must have its own test folder, mirroring the main structure:

test/
└── features/
    ├── addons/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── docket/
    ├── delivery/
    ├── settings/
    ├── reports/
    ├── combo/
    ├── orders/
    └── pos/

🧩 Test Types
1. Domain Layer Tests

Test all use cases and repository contracts.

Use mock repositories (via mockito or mocktail).

Example:

get_addons_usecase_test.dart

fetch_orders_usecase_test.dart

2. Data Layer Tests

Test all data sources (mock, local, remote) and model serialization.

Validate JSON parsing and model mapping using actual mock JSON files.

Example:

addons_model_test.dart

addons_remote_datasource_test.dart

3. Presentation Layer Tests (Bloc & Widgets)

Test Bloc logic: events → states transitions.

Use bloc_test for verifying Bloc behavior.

Example:

blocTest<AddonsBloc, AddonsState>(
  'emits [Loading, Loaded] when data fetch succeeds',
  build: () => AddonsBloc(mockUseCase),
  act: (bloc) => bloc.add(FetchAddonsEvent()),
  expect: () => [AddonsLoading(), AddonsLoaded(mockData)],
);


Add Widget Tests for major screens:

Test that UI reacts correctly to state changes.

Example: addons_screen_test.dart

⚙️ Naming Convention

Follow the pattern:

<feature_name>_<layer>_<component>_test.dart


Example:

settings_domain_usecase_test.dart

orders_data_model_test.dart

docket_presentation_bloc_test.dart

✅ Test Data

Use mock JSON files already placed in assets/json/.

For negative scenarios, use the error JSON files (e.g., *_error.json).

🎯 Final Objective

Every feature must have minimum 80–90% test coverage.

Tests should be independent, isolated, and descriptive.

Ensure no direct dependency between layers in test logic.

Maintain consistent testing style and folder structure across all features.