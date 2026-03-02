import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_mandu/features/dashboard/bottom_screen/profile_screen.dart';
import 'package:food_mandu/core/services/storage/user_session_service.dart';
import 'package:food_mandu/features/auth/presentation/providers/auth_provider.dart';
import 'package:food_mandu/features/auth/presentation/state/auth_state.dart';

// ================= MOCKS =================
class MockUserSessionService extends Mock implements UserSessionService {}

class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late MockUserSessionService mockSession;
  late MockAuthViewModel mockAuth;

  setUp(() {
    mockSession = MockUserSessionService();
    mockAuth = MockAuthViewModel();

    // Setup mock session data
    when(() => mockSession.userId).thenReturn('123');
    when(() => mockSession.userRole).thenReturn('admin');
    when(() => mockSession.fullName).thenReturn('Test User');
    when(() => mockSession.email).thenReturn('test@example.com');
    when(() => mockSession.profilePicture).thenReturn(null);

    // Setup mock auth state
    when(() => mockAuth.state).thenReturn(const AuthState());
  });

  testWidgets('displays user profile information', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSessionServiceProvider.overrideWithValue(mockSession),
          authViewModelProvider.overrideWith(() => mockAuth),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify profile info is displayed
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
  });

  testWidgets('shows logout option', (WidgetTester tester) async {
    when(() => mockAuth.logout()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSessionServiceProvider.overrideWithValue(mockSession),
          authViewModelProvider.overrideWith(() => mockAuth),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify logout option exists
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('shows admin options for admin user',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSessionServiceProvider.overrideWithValue(mockSession),
          authViewModelProvider.overrideWith(() => mockAuth),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify admin options are shown
    expect(find.text('My Food Items'), findsOneWidget);
    expect(find.text('Report Food Item'), findsOneWidget);
  });
}
