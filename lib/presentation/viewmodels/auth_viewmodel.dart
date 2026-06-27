import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'base_viewmodel.dart';

class AuthViewModel extends BaseViewModel {
  final AuthRepository _authRepository;

  UserModel? _currentUser;
  bool _isAuthenticated = false;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isCustomer => _currentUser?.isCustomer ?? false;
  bool get isSeller => _currentUser?.isSeller ?? false;
  bool get hasCompanyProfile => _currentUser?.isCompanyProfileExist ?? false;
  int? get companyId => _currentUser?.companyId;

  Future<void> checkAuthStatus() async {
    try {
      if (_authRepository.isAuthenticated()) {
        setLoading();
        _currentUser = await _authRepository.getUserInfo();
        _isAuthenticated = true;
        setSuccess();
      }
    } catch (e) {
      await _authRepository.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      setIdle();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      setLoading();
      _currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      setSuccess();
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Email not confirmed')) {
        setError('Please verify your email before signing in.');
      } else {
        setError(msg);
      }
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String userType,
  }) async {
    try {
      setLoading();
      await _authRepository.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        userType: userType,
      );
      setSuccess();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      setLoading();
      await _authRepository.forgotPassword(email);
      setSuccess();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      setIdle();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> refreshUser() async {
    try {
      _currentUser = await _authRepository.getUserInfo();
      notifyListeners();
    } catch (e) {
      // Silent fail for background refresh
    }
  }
}
