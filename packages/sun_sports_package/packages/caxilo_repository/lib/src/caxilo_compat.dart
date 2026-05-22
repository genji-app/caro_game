import 'models/caxilo_game_block.dart';

// ---------------------------------------------------------------------------
// Backward-compatible type aliases (mirrors GameRepository public types)
//
// UI layer can continue to use these names during incremental migration.
// Remove once all references are updated to the Caxilo-prefixed variants.
// ---------------------------------------------------------------------------

/// Alias for [CaxiloGameBlockInHouse] — maintains compatibility with legacy [InHouseGameBlock].
typedef InHouseGameBlock = CaxiloGameBlockInHouse;

/// Alias for [CaxiloGameBlockLiveStream] — maintains compatibility with legacy [LiveStreamGameBlock].
typedef LiveStreamGameBlock = CaxiloGameBlockLiveStream;

/// Alias for [CaxiloGameBlock] — maintains compatibility with legacy [GameBlock].
typedef GameBlock = CaxiloGameBlock;
