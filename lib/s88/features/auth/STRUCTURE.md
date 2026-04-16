# Auth Feature - Clean Architecture Structure

## 📁 Current Structure (Updated)

```
lib/features/auth/
│
├── 📂 data/                           ← Data Layer (External)
│   ├── 📂 datasources/
│   │   └── 📄 auth_remote_datasource.dart
│   │       ├── AuthRemoteDataSource (abstract)
│   │       └── AuthRemoteDataSourceImpl (with LoggerMixin)
│   │           ├── login()
│   │           ├── register()
│   │           ├── logout()
│   │           ├── refreshToken()
│   │           └── changePassword() → SbApiResponse<dynamic>
│   │
│   ├── 📂 models/
│   │   ├── 📄 auth_model.dart
│   │   │   ├── AuthModel (sealed class)
│   │   │   ├── LoginRequestModel (sealed class)
│   │   │   └── RegisterRequestModel (sealed class)
│   │   ├── 📄 auth_model.freezed.dart (generated)
│   │   └── 📄 auth_model.g.dart (generated)
│   │
│   └── 📂 repositories/
│       └── 📄 auth_repository_impl.dart
│           └── AuthRepositoryImpl implements AuthRepository
│
├── 📂 domain/                         ← Domain Layer (Business Logic)
│   ├── 📂 entities/
│   │   ├── 📄 auth_entity.dart
│   │   │   ├── AuthEntity (sealed class)
│   │   │   ├── LoginRequest (sealed class)
│   │   │   └── RegisterRequest (sealed class)
│   │   └── 📄 auth_entity.freezed.dart (generated)
│   │
│   ├── 📂 repositories/
│   │   └── 📄 auth_repository.dart
│   │       └── AuthRepository (abstract interface)
│   │
│   ├── 📂 usecases/
│   │   ├── 📄 login_usecase.dart
│   │   ├── 📄 register_usecase.dart
│   │   ├── 📄 logout_usecase.dart
│   │   └── 📄 forgot_password_usecase.dart
│   │
│   ├── 📂 state/                     ← State Definitions
│   │   ├── 📄 auth_state.dart
│   │   │   ├── AuthState (sealed class)
│   │   │   ├── LoginFormState (sealed class)
│   │   │   └── RegisterFormState (sealed class)
│   │   └── 📄 auth_state.freezed.dart (generated)
│   │
│   ├── 📂 notifiers/                 ← Business Logic Controllers
│   │   └── 📄 auth_notifiers.dart
│   │       ├── AuthNotifier
│   │       ├── LoginFormNotifier
│   │       └── RegisterFormNotifier
│   │
│   └── 📂 providers/                 ← Dependency Injection
│       └── 📄 auth_providers.dart
│           ├── authNotifierProvider
│           ├── loginFormNotifierProvider
│           ├── registerFormNotifierProvider
│           ├── loginUseCaseProvider
│           ├── registerUseCaseProvider
│           └── authRepositoryProvider
│
└── 📂 presentation/                   ← Presentation Layer (UI Only)
    ├── 📂 desktop/
    │   ├── 📂 screens/
    │   │   └── 📄 auth_desktop_screen.dart
    │   └── 📂 widgets/
    │       ├── 📄 auth_desktop_login_form.dart
    │       └── 📄 auth_desktop_register_form.dart
    │
    ├── 📂 tablet/
    │   └── 📂 screens/
    │       └── 📄 auth_tablet_screen.dart
    │
    ├── 📂 widgets/
    │   └── 📄 auth_text_field.dart
    │
    └── 📄 auth_screen.dart (Responsive wrapper)
```

---

## 🔄 Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER (UI)                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  AuthDesktopLoginForm                                │   │
│  │  - Hiển thị UI                                       │   │
│  │  - Lắng nghe user input                             │   │
│  │  - Gọi domain providers                             │   │
│  └─────────────────┬───────────────────────────────────┘   │
└────────────────────┼───────────────────────────────────────┘
                     │
                     ↓ ref.read(authNotifierProvider.notifier)
┌────────────────────┼───────────────────────────────────────┐
│                    │    DOMAIN LAYER (Business Logic)      │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  AuthNotifier (StateNotifier)                       │   │
│  │  - Validate business rules                          │   │
│  │  - Call use cases                                   │   │
│  │  - Manage state transitions                         │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ↓ loginUseCase.call()                   │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  LoginUseCase                                        │   │
│  │  - Pure business logic                               │   │
│  │  - Call repository interface                         │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ↓ authRepository.login()                │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  AuthRepository (Abstract Interface)                 │   │
│  │  - Define contract                                   │   │
│  └─────────────────┬───────────────────────────────────┘   │
└────────────────────┼───────────────────────────────────────┘
                     │
                     ↓ Implementation
┌────────────────────┼───────────────────────────────────────┐
│                    │       DATA LAYER (External)            │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  AuthRepositoryImpl                                  │   │
│  │  - Implement AuthRepository                          │   │
│  │  - Handle errors                                     │   │
│  │  - Call data source                                  │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ↓ remoteDataSource.login()              │
│  ┌─────────────────▼───────────────────────────────────┐   │
│  │  AuthRemoteDataSourceImpl                            │   │
│  │  - Make API calls                                    │   │
│  │  - Parse JSON                                        │   │
│  │  - Return AuthModel                                  │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ↓ HTTP POST /auth/login                 │
│                [ Backend API ]                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Dependency Graph

```
                    ┌──────────────────┐
                    │   Presentation   │
                    │   (UI Widgets)   │
                    └────────┬─────────┘
                             │
                             │ import domain/providers
                             │ import domain/state
                             │
                    ┌────────▼─────────┐
                    │      Domain      │
                    │  (Business Logic)│
                    └────────┬─────────┘
                             │
                   ┌─────────┼─────────┐
                   │                   │
       domain/     │         domain/   │     domain/
       state/      │         notifiers/│     providers/
    ┌──────────┐   │      ┌──────────┐ │  ┌──────────┐
    │  States  │◄──┘      │Notifiers │◄┘  │Providers │
    └──────────┘          └─────┬────┘    └──────────┘
                                │
                      domain/   │     domain/
                      usecases/ │     entities/
                   ┌──────────┐ │  ┌──────────┐
                   │Use Cases │◄┘  │ Entities │
                   └────┬─────┘    └──────────┘
                        │
              domain/   │
              repositories/
           ┌──────────┐ │
           │Repository│◄┘
           │Interface │
           └────┬─────┘
                │
                │ implemented by
                │
        ┌───────▼──────────┐
        │       Data       │
        │  (External Data) │
        └───────┬──────────┘
                │
      ┌─────────┼─────────┐
      │                   │
data/ │         data/     │     data/
repositories/   models/   │     datasources/
┌──────────┐ ┌──────────┐ │  ┌──────────┐
│Repository│ │  Models  │◄┘  │DataSource│
│   Impl   │ └──────────┘    └─────┬────┘
└──────────┘                       │
                                   │
                          ┌────────▼────────┐
                          │   Backend API   │
                          └─────────────────┘
```

---

## 🎯 Layer Responsibilities

### 🔵 Presentation Layer
**Trách nhiệm:**
- ✅ Render UI
- ✅ Handle user interactions
- ✅ Navigate between screens
- ✅ Display loading/error states

**KHÔNG làm:**
- ❌ Business logic
- ❌ API calls
- ❌ Data transformation
- ❌ State management logic

**Import từ:**
- ✅ `domain/providers`
- ✅ `domain/state`
- ✅ `shared/widgets`
- ❌ KHÔNG import từ `data/`

---

### 🔷 Domain Layer
**Trách nhiệm:**
- ✅ Business logic
- ✅ Use cases
- ✅ State management
- ✅ Validation rules
- ✅ Dependency injection

**KHÔNG làm:**
- ❌ UI rendering
- ❌ API calls (trực tiếp)
- ❌ JSON parsing

**Import từ:**
- ✅ `domain/*` (internal)
- ✅ `flutter_riverpod`
- ✅ `dartz` (Either)
- ❌ KHÔNG import từ `presentation/`
- ❌ KHÔNG import từ `data/` (chỉ interface)

---

### 🔶 Data Layer
**Trách nhiệm:**
- ✅ API calls
- ✅ Database access
- ✅ JSON serialization
- ✅ Caching
- ✅ Implement repository interfaces

**KHÔNG làm:**
- ❌ Business logic
- ❌ UI rendering
- ❌ State management

**Import từ:**
- ✅ `domain/entities`
- ✅ `domain/repositories` (interfaces)
- ✅ `core/network`
- ❌ KHÔNG import từ `presentation/`

---

## 🔄 Example: Login Flow

### 1️⃣ User taps Login button (Presentation)
```dart
// auth_desktop_login_form.dart
onPressed: () async {
  if (loginFormNotifier.validate()) {
    loginFormNotifier.setSubmitting(true);
    await authNotifier.login(username, password);
    loginFormNotifier.setSubmitting(false);
  }
}
```

### 2️⃣ AuthNotifier handles business logic (Domain)
```dart
// domain/notifiers/auth_notifiers.dart
Future<void> login(String username, String password) async {
  state = const AuthState.loading();
  
  final request = LoginRequest(username: username, password: password);
  final result = await loginUseCase(request);
  
  result.fold(
    (failure) => state = AuthState.error(failure.message),
    (auth) => state = AuthState.authenticated(auth),
  );
}
```

### 3️⃣ LoginUseCase executes business operation (Domain)
```dart
// domain/usecases/login_usecase.dart
Future<Either<Failure, AuthEntity>> call(LoginRequest request) async {
  return await repository.login(request);
}
```

### 4️⃣ AuthRepository interface (Domain)
```dart
// domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login(LoginRequest request);
}
```

### 5️⃣ AuthRepositoryImpl calls API (Data)
```dart
// data/repositories/auth_repository_impl.dart
Future<Either<Failure, AuthEntity>> login(LoginRequest request) async {
  try {
    final requestModel = LoginRequestModel.fromEntity(request);
    final result = await remoteDataSource.login(requestModel);
    return Right(result.toEntity());
  } catch (e) {
    return Left(Failure.server(message: e.toString()));
  }
}
```

### 6️⃣ DataSource makes HTTP call (Data)
```dart
// data/datasources/auth_remote_datasource.dart
Future<AuthModel> login(LoginRequestModel request) async {
  final response = await apiClient.post('/auth/login', data: {
    'username': request.username,
    'password': request.password,
  });
  return AuthModel.fromJson(response);
}
```

### 7️⃣ UI reacts to state change (Presentation)
```dart
// auth_desktop_login_form.dart
ref.listen<AuthState>(authNotifierProvider, (previous, next) {
  next.maybeWhen(
    authenticated: (auth) {
      // Navigate to home
      context.go('/home');
    },
    error: (message) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    },
    orElse: () {},
  );
});
```

---

## 📦 Key Benefits

### ✅ Testability
```dart
// Mock repository dễ dàng
class MockAuthRepository extends Mock implements AuthRepository {}

test('login success', () async {
  final mockRepo = MockAuthRepository();
  final useCase = LoginUseCase(mockRepo);
  
  when(() => mockRepo.login(any()))
    .thenAnswer((_) async => Right(mockAuthEntity));
  
  final result = await useCase(loginRequest);
  expect(result.isRight(), true);
});
```

### ✅ Maintainability
- Thay UI không ảnh hưởng business logic
- Thay API không ảnh hưởng UI

### ✅ Scalability
- Dễ thêm features mới
- Dễ refactor từng layer độc lập

---

## 🎓 Clean Architecture Checklist

- [x] Domain layer không depend vào Presentation
- [x] Domain layer không depend vào Data (chỉ interface)
- [x] Presentation chỉ depend vào Domain
- [x] Data depend vào Domain (implement interfaces)
- [x] State ở Domain layer
- [x] Notifiers ở Domain layer  
- [x] Providers ở Domain layer
- [x] UI components ở Presentation layer
- [x] Use sealed class cho Freezed
- [x] Repository pattern
- [x] Use case pattern
- [x] Dependency injection với Riverpod

✅ **All checks passed! Clean Architecture implemented correctly!**



















