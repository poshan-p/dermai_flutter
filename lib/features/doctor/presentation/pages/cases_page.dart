import 'package:dermai/features/auth/presentation/pages/settings_page.dart';
import 'package:dermai/features/auth/presentation/pages/welcome_page.dart';
import 'package:dermai/features/core/cubits/app_user/app_user_cubit.dart';
import 'package:dermai/features/core/entities/diagnosed_disease.dart';
import 'package:dermai/features/core/entities/disease.dart';
import 'package:dermai/features/core/entities/doctor.dart';
import 'package:dermai/features/core/entities/patient.dart';
import 'package:dermai/features/doctor/domain/usecases/doctor_get_cases.dart';
import 'package:dermai/features/doctor/presentation/bloc/doctor_bloc.dart';
import 'package:dermai/features/doctor/presentation/components/case_card.dart';
import 'package:dermai/features/doctor/presentation/pages/case_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage>
    with SingleTickerProviderStateMixin {
  List<(DiagnosedDisease, Patient, Disease)> _cases = [];
  List<(DiagnosedDisease, Patient, Disease)> _filteredCases = [];
  var selectedCaseType = CasesType.values[1];
  late Doctor doctor;
  @override
  void initState() {
    super.initState();
    _fetchDiagnosedDiseases();
  }

  Future<void> _fetchDiagnosedDiseases() async {
    doctor = (context.read<AppUserCubit>().state as AppUserAuthenticated)
        .user
        .doctor();
    context
        .read<DoctorBloc>()
        .add(DoctorCases(doctorID: doctor.id, casesType: selectedCaseType));
  }

  void _handleCaseTypeChange(CasesType casesType) {
    setState(() {
      selectedCaseType = casesType;
      switch (casesType) {
        case CasesType.all:
          _filteredCases = _cases;
          break;
        case CasesType.available:
          _filteredCases =
              _cases.where((element) => element.$1.doctorID == null).toList();
          break;
        case CasesType.current:
          _filteredCases = _cases
              .where((element) =>
                  element.$1.doctorID == doctor.id && !element.$1.status)
              .toList();
          break;
        case CasesType.completed:
          _filteredCases = _cases
              .where((element) =>
                  element.$1.doctorID == doctor.id && element.$1.status)
              .toList();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DoctorBloc, DoctorState>(
        listener: (context, state) {
          if (state is DoctorFailureCases) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is DoctorSuccessCases) {
            setState(() {
              _cases = state.diagnosedDiseases;
              _handleCaseTypeChange(selectedCaseType);
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  title: Text(
                    doctor.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsPage()));
                        },
                        icon: const Icon(Icons.settings)),
                  ],
                ),
                SliverAppBar(
                    floating: true,
                    snap: true,
                    automaticallyImplyLeading: false,
                    titleSpacing: 0,
                    title: SizedBox(
                      height: 48,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: CasesType.values.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                SizedBox(
                                  width: index == 0 ? 16 : 4,
                                ),
                                ChoiceChip(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  label: Text(CasesType.values[index].caseName),
                                  selected: selectedCaseType ==
                                      CasesType.values[index],
                                  onSelected: (_) {
                                    setState(() {
                                      selectedCaseType =
                                          CasesType.values[index];
                                    });
                                    _handleCaseTypeChange(
                                        CasesType.values[index]);
                                  },
                                ),
                                SizedBox(
                                  width: index == 3 ? 16 : 4,
                                ),
                              ],
                            );
                          }),
                    )),
              ],
              body: state is DoctorInitial ||
                      (state is DoctorLoading && _cases.isEmpty)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchDiagnosedDiseases,
                      child: _filteredCases.isEmpty && state is! DoctorLoading
                          ? const Center(
                              child: Text('No cases'),
                            )
                          : ListView.builder(
                              itemCount: _filteredCases.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    CaseCard(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CaseDetailPage(
                                                diagnosedDisease:
                                                    _filteredCases[index].$1,
                                                patient:
                                                    _filteredCases[index].$2,
                                                disease:
                                                    _filteredCases[index].$3,
                                              ),
                                            ),
                                          ).then((value) {
                                            _fetchDiagnosedDiseases();
                                          });
                                        },
                                        diagnosedDisease:
                                            _filteredCases[index].$1,
                                        disease: _filteredCases[index].$3,
                                        patient: _filteredCases[index].$2),
                                    if (index >= _filteredCases.length)
                                      const SizedBox(
                                        height: 16,
                                      )
                                  ],
                                );
                              },
                            ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
