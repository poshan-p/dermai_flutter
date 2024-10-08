import 'package:dermai/features/core/entities/appointment.dart';
import 'package:dermai/features/core/entities/diagnosed_disease.dart';
import 'package:dermai/features/core/entities/disease.dart';
import 'package:dermai/features/core/entities/doctor.dart';
import 'package:dermai/features/core/entities/message.dart';
import 'package:dermai/features/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as stream;

abstract interface class PatientRepository {
  Future<Either<Failure, List<(DiagnosedDisease, Disease, Doctor?)>>>
      getDiagnosedDiseases({required String patientID});
  Future<
          Either<Failure,
              List<(Appointment, DiagnosedDisease, Doctor, Disease)>>>
      getAppointments(
          {required String patientID, String? doctorID, String? diagnosedID});
  Future<Either<Failure, void>> cancelAppointment(
      {required String appointmentID});
  Future<Either<Failure, (DiagnosedDisease, Disease)>> submitCase(
      {required String imagePath, required String patientComment});
  Future<Either<Failure, void>> sendMessage(
      {required String diagnosedID,
      required String diseaseName,
      required List<Message> previousMessages});
  Stream<List<Message>> getMessages({required String diagnosedID});
  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, stream.Call>> callDoctor({required String appointmentID});
  Future<Either<Failure, void>> deleteDiagnosedDisease({required String diagnosedID});
}
