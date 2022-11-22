import 'package:dartz/dartz.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/entities/ig_headers.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';

import '../entities/user.dart';

class GetIgDataUpdateUseCase {
  final LocalRepository localRepository;

  GetIgDataUpdateUseCase({required this.localRepository});

  Either<Failure, IgDataUpdate?> execute({required String dataName}) {
    return localRepository.getCachedIgDataUpdate(boxKey: IgDataUpdate.boxKey, dataName: dataName);
  }
}
