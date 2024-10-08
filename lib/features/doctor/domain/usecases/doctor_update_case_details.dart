import 'package:dermai/features/core/entities/diagnosed_disease.dart';
import 'package:dermai/features/core/entities/disease.dart';
import 'package:dermai/features/core/entities/patient.dart';
import 'package:dermai/features/core/error/failure.dart';
import 'package:dermai/features/core/usecase/usecase.dart';
import 'package:dermai/features/doctor/domain/repository/doctor_repository.dart';
import 'package:fpdart/fpdart.dart';

class DoctorUpdateCaseDetails implements UseCase<(DiagnosedDisease, Patient, Disease), DoctorUpdateCaseDetailsParams> {
  final DoctorRepository caseRepository;

  DoctorUpdateCaseDetails(this.caseRepository);

  @override
  Future<Either<Failure, (DiagnosedDisease, Patient, Disease)>> call(DoctorUpdateCaseDetailsParams params) async {
    return await caseRepository.updateCase(diagnosedDisease: params.diagnosedDisease);
  }  
}

class DoctorUpdateCaseDetailsParams {
  final DiagnosedDisease diagnosedDisease;

  DoctorUpdateCaseDetailsParams({required this.diagnosedDisease});
}