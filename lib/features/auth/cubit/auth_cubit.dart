import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void signInWithGoogle() {
    // TODO: تنفيذ تسجيل الدخول بجوجل
    emit(AuthLoading());
    // بعد النجاح:
    // emit(AuthSuccess(user));
    // في حالة الخطأ:
    // emit(AuthFailure('حدث خطأ'));
  }

  void signOut() {
    emit(AuthInitial());
  }
}
