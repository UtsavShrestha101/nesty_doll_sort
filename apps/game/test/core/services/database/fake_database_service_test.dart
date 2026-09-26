import 'package:nesty_game/core/services/database/fake_database_service.dart';

import 'database_service_contract.dart';

void main() {
  runDatabaseServiceContract('FakeDatabaseService', () async {
    return FakeDatabaseService();
  });
}
