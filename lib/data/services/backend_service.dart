import '../models/hierarchy_node.dart';
import '../repositories/mock_repository.dart';

class BackendService {
  final MockRepository _mockRepository;

  BackendService(this._mockRepository);

  HierarchyNode getLibraryData() {
    return MockRepository.getInitialData();
  }
}
