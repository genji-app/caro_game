/// WebSocket Connection State
enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket Message Type
enum WsMessageType {
  // ===== ODDS =====
  /// Odds update for an event
  oddsUpdate,

  /// New odds inserted
  oddsInsert,

  /// Odds removed
  oddsRemove,

  // ===== EVENT =====
  /// Event status change (live, finished, etc.)
  eventStatus,

  /// New event inserted
  eventInsert,

  /// Event removed
  eventRemove,

  // ===== MARKET =====
  /// Market suspended/active
  marketStatus,

  // ===== LEAGUE =====
  /// New league inserted
  leagueInsert,

  // ===== USER =====
  /// Balance update for user
  balanceUpdate,

  // ===== OTHER =====
  /// Score update
  scoreUpdate,

  /// Connection status
  connection,

  /// Ping/Pong
  heartbeat,

  /// Unknown message
  unknown,
}
