import 'package:dermai/features/core/entities/appointment.dart';
import 'package:dermai/features/core/entities/diagnosed_disease.dart';
import 'package:dermai/features/core/entities/disease.dart';
import 'package:dermai/features/core/entities/doctor.dart';
import 'package:dermai/features/core/entities/message.dart';
import 'package:dermai/features/patient/domain/usecases/patient_call_doctor.dart';
import 'package:dermai/features/patient/domain/usecases/patient_cancel_appointment.dart';
import 'package:dermai/features/patient/domain/usecases/patient_delete_diagnosed_disease.dart';
import 'package:dermai/features/patient/domain/usecases/patient_get_appointments.dart';
import 'package:dermai/features/patient/domain/usecases/patient_get_diagnosed_diseases.dart';
import 'package:dermai/features/patient/domain/usecases/patient_get_messages.dart';
import 'package:dermai/features/patient/domain/usecases/patient_send_message.dart';
import 'package:dermai/features/patient/domain/usecases/patient_sign_out_usecase.dart';
import 'package:dermai/features/patient/domain/usecases/patient_submit_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import "package:collection/collection.dart";
import 'package:stream_video_flutter/stream_video_flutter.dart';

part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientGetDiagnosedDiseases _patientGetDiagnosedDiseases;
  final PatientSignOutUsecase _patientSignOut;
  final PatientGetAppointments _patientGetAppointments;
  final PatientSubmitCase _patientSubmitCase;
  final PatientCancelAppointment _patientCancelAppointment;
  final PatientSendMessage _patientSendMessage;
  final PatientGetMessages _patientGetMessages;
  final PatientCallDoctor _patientCallDoctor;
  final PatientDeleteDiagnosedDisease _patientDeleteDiagnosedDisease;

  PatientBloc({
    required PatientGetDiagnosedDiseases patientGetDiagnosedDiseases,
    required PatientSignOutUsecase patientSignOut,
    required PatientGetAppointments patientGetAppointments,
    required PatientSubmitCase patientSubmitCase,
    required PatientCancelAppointment patientCancelAppointment,
    required PatientSendMessage patientSendMessage,
    required PatientGetMessages patientGetMessages,
    required PatientCallDoctor patientCallDoctor,
    required PatientDeleteDiagnosedDisease patientDeleteDiagnosedDisease,
  })  : _patientGetDiagnosedDiseases = patientGetDiagnosedDiseases,
        _patientSignOut = patientSignOut,
        _patientGetAppointments = patientGetAppointments,
        _patientSubmitCase = patientSubmitCase,
        _patientCancelAppointment = patientCancelAppointment,
        _patientSendMessage = patientSendMessage,
        _patientGetMessages = patientGetMessages,
        _patientCallDoctor = patientCallDoctor,
        _patientDeleteDiagnosedDisease = patientDeleteDiagnosedDisease,
        super(PatientInitial()) {
    on<PatientDiagnosedDiseases>((event, emit) async {
      emit(PatientLoading());

      final failureOrDiseases = await _patientGetDiagnosedDiseases(
        PatientGetDiagnosedDiseasesParams(
          patientID: event.patientID,
        ),
      );
      failureOrDiseases.fold(
        (failure) => emit(PatientFailureDiagnosedDiseases(message: failure.message)),
        (response) =>
            emit(PatientSuccessDiagnosedDiseases(diagnosedDiseases: response)),
      );
    });

    on<PatientSignOut>((event, emit) async {
      final failureOrSuccess = await _patientSignOut(NoParams());
      failureOrSuccess.fold(
        (failure) => emit(PatientFailureSignOut(message: failure.message)),
        (_) => emit(PatientSuccessSignOut()),
      );
    });

    on<PatientAppointments>((event, emit) async {
      emit(PatientLoading());

      final failureOrAppointments = await _patientGetAppointments(
        PatientGetAppointmentsParams(
            patientID: event.patientID,
            doctorID: event.doctorID,
            diagnosedID: event.diagnosedID),
      );
      failureOrAppointments.fold(
        (failure) => emit(PatientFailureAppointments(message: failure.message)),
        (response) => emit(PatientSuccessAppointments(
            appointments: groupBy(
                response,
                (element) => DateTime(
                    element.$1.dateCreated.year,
                    element.$1.dateCreated.month,
                    element.$1.dateCreated.day)))),
      );
    });

    on<PatientSubmitCaseEvent>((event, emit) async {
      emit(PatientLoading());

      final failureOrSuccess = await _patientSubmitCase(
        PatientSubmitCaseParams(
          imagePath: event.imagePath,
          patientComment: event.patientComment,
        ),
      );
      failureOrSuccess.fold(
        (failure) => emit(PatientFailureSubmitCase(message: failure.message)),
        (response) => emit(PatientSuccessSubmitCase(
            diagnosedDisease: response.$1, disease: response.$2)),
      );
    });

    on<PatientCancelAppointmentEvent>((event, emit) async {
      emit(PatientLoading());

      final failureOrSuccess = await _patientCancelAppointment(
          PatientCancelAppointmentParams(appointmentID: event.appointmentID));
      failureOrSuccess.fold(
        (failure) => emit(PatientFailureCancelAppointment(message: failure.message)),
        (response) => emit(PatientSuccessCancelAppointment()),
      );
    });

    on<PatientSendMessageEvent>((event, emit) async {
      emit(PatientTyping());
      final failureOrSuccess = await _patientSendMessage(
        PatientSendMessageParams(
          diagnosedID: event.diagnosedID,
          diseaseName: event.diseaseName,
          previousMessages: event.previousMessages,
        ),
      );
      failureOrSuccess.fold(
        (failure) => emit(PatientFailureSendMessage(message: failure.message)),
        (_) => emit(PatientTyping()),
      );
    });

    on<PatientListenMessages>((event, emit) async {
      emit(PatientTyping());
      await for (final messages in _patientGetMessages(
          PatientGetMessagesParams(diagnosedID: event.diagnosedID))) {
        emit(PatientSuccessGetMessages(messages: messages));
      }
    });

    on<PatientCallDoctorEvent>((event, emit) async {
      final failureOrSuccess = await _patientCallDoctor(
        PatientCallDoctorParams(
          appointmentID: event.appointmentID,
        ),
      );
      failureOrSuccess.fold(
        (failure) => emit(PatientFailureCallDoctor(message: failure.message)),
        (response) => emit(PatientSuccessCallDoctor(call: response)),
      ); 
    });

    on<PatientDeleteDiagnosedDiseaseEvent>((event, emit) async {
      final failureOrSuccess = await _patientDeleteDiagnosedDisease(
        PatientDeleteDiagnosedDiseaseParams(
          diagnosedID: event.diagnosedID,
        ),
      );
      failureOrSuccess.fold(
        (failure) => emit(PatientFailureDeleteDiagnosedDisease(message: failure.message)),
        (_) => emit(PatientSuccessDeleteDiagnosedDisease()),
      );
    });
  }
}
