import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/report.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';
import 'package:dartz/dartz.dart';

class GetReportFromLocalUseCase {
  final LocalRepository localRepository;
  GetReportFromLocalUseCase({required this.localRepository});

  Future<Either<Failure, Report?>> execute() async {
    return localRepository.getCachedReport();
  }
}
