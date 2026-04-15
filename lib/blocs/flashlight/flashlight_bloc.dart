import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_development_iot/blocs/flashlight/flashlight_event.dart';
import 'package:mobile_development_iot/blocs/flashlight/flashlight_state.dart';
import 'package:mobile_development_iot/repositories/api_client.dart';
import 'package:mobile_development_iot/repositories/auth_repository.dart';
import 'package:smart_fluid_flashlight_plugin/smart_fluid_flashlight_plugin.dart';

export 'flashlight_event.dart';
export 'flashlight_state.dart';

class FlashlightBloc extends Bloc<FlashlightEvent, FlashlightState> {
  final IAuthRepository _authRepo;
  final ApiClient _apiClient;

  FlashlightBloc(this._authRepo, this._apiClient)
    : super(const FlashlightState()) {
    on<ToggleProfileFlashlightEvent>((event, emit) async {
      if (!Platform.isAndroid) {
        emit(FlashlightUnsupportedOS(state.isOn));
        emit(FlashlightState(isOn: state.isOn));
        return;
      }

      final isOn = await SmartFluidFlashlightPlugin.toggleLight();

      try {
        final user = await _authRepo.getCurrentUser();
        final action = isOn ? 'DIAGNOSTIC LIGHT: ON' : 'DIAGNOSTIC LIGHT: OFF';
        await _apiClient.postLog(user?.email ?? 'engineer', action);
      } catch (e) {
        debugPrint('Log failed: $e');
      }

      emit(FlashlightState(isOn: isOn));
    });
  }
}
