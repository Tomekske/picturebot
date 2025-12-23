import '../models/hierarchy_node.dart';
import '../repositories/mock_repository.dart';

/// A service layer responsible for handling business logic related to the backend.
///
/// This class acts as an intermediary between the BLoC (state management) and
/// the Repository (data access). It abstracts the source of the data, allowing
/// the UI to request "Library Data" without knowing if it comes from a
/// local database, a mock file, or a remote REST API.
class BackendService {
  final MockRepository _repository;

  /// Creates a new instance of [BackendService].
  ///
  /// Requires a [MockRepository] to be injected. This dependency injection
  /// allows for easier testing and swapping of data sources in the future.
  BackendService(this._repository);

  /// Retrieves the complete folder and album structure of the user's library.
  ///
  /// This method triggers the data fetching process from the underlying repository.
  /// Returns a [Future] that resolves to the root [HierarchyNode] of the collection.
  Future<HierarchyNode> getLibraryData() {
    return MockRepository.getInitialData();
  }
}
