import 'package:dermai/features/core/entities/diagnosed_disease.dart';
import 'package:dermai/features/core/entities/disease.dart';
import 'package:dermai/features/core/entities/patient.dart';
import 'package:dermai/features/core/error/failure.dart';
import 'package:dermai/features/core/usecase/usecase.dart';
import 'package:dermai/features/doctor/domain/repository/doctor_repository.dart';
import 'package:fpdart/fpdart.dart';

class DoctorGetCaseDetails implements UseCase<(DiagnosedDisease, Patient, Disease), DoctorGetCaseDetailsParams> {
  final DoctorRepository caseRepository;

  DoctorGetCaseDetails(this.caseRepository);

  @override
  Future<Either<Failure, (DiagnosedDisease, Patient, Disease)>> call(DoctorGetCaseDetailsParams params) async{
    return await caseRepository.getCaseDetails(diagnosedID: params.diagnosedID);
  }  
}

class DoctorGetCaseDetailsParams {
  final String diagnosedID;

  DoctorGetCaseDetailsParams({required this.diagnosedID});
}