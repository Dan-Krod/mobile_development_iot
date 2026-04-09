import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/secret_mode/secret_mode_event.dart';
import 'package:mobile_development_iot/blocs/secret_mode/secret_mode_state.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:smart_fluid_flashlight_plugin/smart_fluid_flashlight_plugin.dart';

export 'secret_mode_event.dart';
export 'secret_mode_state.dart';

class SecretModeBloc extends Bloc<SecretModeEvent, SecretModeState> {
  final IAuthRepository _authRepo;
  final ApiClient _apiClient;

  static bool _isGloballyActive = false;

  int _tapCount = 0;
  Timer? _tapTimer;

  SecretModeBloc(this._authRepo, this._apiClient)
    : super(SecretModeState(isSecretModeActive: _isGloballyActive)) {
    on<RegisterSecretTapEvent>(_onRegisterTap);
  }

  Future<void> _onRegisterTap(
    RegisterSecretTapEvent event,
    Emitter<SecretModeState> emit,
  ) async {
    _tapCount++;
    _tapTimer?.cancel();

    _tapTimer = Timer(const Duration(milliseconds: 1000), () => _tapCount = 0);

    if (_tapCount >= 3) {
      _tapCount = 0;

      if (!Platform.isAndroid) {
        emit(SecretModeUnsupportedOS(state.isSecretModeActive));
        return;
      }

      final isOn = await SmartFluidFlashlightPlugin.toggleLight();

      _isGloballyActive = isOn;

      await _logSecretAction(isOn);

      emit(SecretModeToggled(isOn));
    }
  }

  Future<void> _logSecretAction(bool isOn) async {
    try {
      final user = await _authRepo.getCurrentUser();
      final email = user?.email ?? 'unknown_engineer';
      final action = isOn
          ? 'EMERGENCY OVERRIDE: FLASHLIGHT ENGAGED'
          : 'EMERGENCY OVERRIDE: FLASHLIGHT DISENGAGED';

      await _apiClient.postLog(email, action);
      debugPrint('📝 Лог записано: $action');
    } catch (e) {
      debugPrint('🚨 Помилка запису логу: $e');
    }
  }

  @override
  Future<void> close() {
    _tapTimer?.cancel();
    return super.close();
  }
}
