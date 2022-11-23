import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';

class SaveIgDataUpdateUseCase {
  final LocalRepository localRepository;

  SaveIgDataUpdateUseCase({required this.localRepository});

  Future<void> execute({required IgDataUpdate igDataUpdate}) async {
    return await localRepository.cacheIgDataUpdate(boxKey: IgDataUpdate.boxKey, igDataUpdate: igDataUpdate);
  }
}
