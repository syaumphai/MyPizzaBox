import 'models/models.dart';
import 'user_repo.dart';

class MockUserRepo implements UserRepository {
  MyUser? _currentUser;

  @override
  Stream<MyUser?> get user {
    // Return a stream that emits the current user
    return Stream.value(_currentUser);
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    // Simulate a delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create a mock user with a userId
    final mockUser = MyUser(
      userId: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: myUser.email,
      name: myUser.name,
      hasActiveCart: false,
    );
    
    _currentUser = mockUser;
    return mockUser;
  }

  @override
  Future<void> setUserData(MyUser user) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = user;
  }

  @override
  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create a mock user for sign in
    _currentUser = MyUser(
      userId: 'mock_user_signed_in',
      email: email,
      name: 'Mock User',
      hasActiveCart: false,
    );
  }

  @override
  Future<void> logOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
} 