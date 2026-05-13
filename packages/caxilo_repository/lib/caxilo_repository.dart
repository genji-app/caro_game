/// Caxilo Repository
///
/// A repository layer for managing caxilo data with in-memory caching,
/// search, and error handling.
library;

// Hide filter types to avoid name collision with repository's own domain filter types.
export 'package:caxilo_config/caxilo_config.dart'
    hide CaxiloFilter, CaxiloFilterStrategy, $CaxiloFilterCopyWith, CaxiloFilterPatterns;
export 'package:game_api_client/game_api_client.dart' show ProviderGames;

export 'src/caxilo_compat.dart';
export 'src/caxilo_failure.dart';
export 'src/caxilo_mapper.dart';
export 'src/caxilo_repository.dart';
export 'src/caxilo_storage.dart';
export 'src/caxilo_utils.dart';
// Export mixins so that inherited methods are visible when importing the repository
export 'src/mixins/caxilo_category_mixin.dart';
export 'src/mixins/caxilo_data_processor_mixin.dart';
export 'src/mixins/caxilo_lobby_mixin.dart';
export 'src/mixins/caxilo_notification_mixin.dart';
export 'src/mixins/caxilo_search_engine_mixin.dart';
export 'src/mixins/caxilo_url_resolver_mixin.dart';
export 'src/models/models.dart';
