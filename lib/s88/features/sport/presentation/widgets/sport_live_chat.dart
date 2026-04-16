import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_caro_flame/s88/core/services/providers/auth_provider.dart';
import 'package:co_caro_flame/s88/core/utils/extensions/image_helper.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/shared/widgets/cards/inner_shadow_card.dart';
import 'package:co_caro_flame/s88/core/services/websocket/sb_chat_websocket.dart';
import 'package:co_caro_flame/s88/core/services/providers/websocket_provider.dart';
import 'package:co_caro_flame/s88/core/providers/live_chat_expanded_provider.dart';
import 'package:co_caro_flame/s88/shared/widgets/toast/app_toast.dart';

class SportLiveChat extends ConsumerStatefulWidget {
  final String onlineCount;
  final String placeholderText;
  final bool isMobile;
  final String? currentUserName;

  const SportLiveChat({
    super.key,
    this.onlineCount = '65,000',
    this.placeholderText = ' Nhắn tin',
    this.isMobile = false,
    this.currentUserName,
  });

  @override
  ConsumerState<SportLiveChat> createState() => _SportLiveChatState();
}

class _SportLiveChatState extends ConsumerState<SportLiveChat> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  int _previousMessageCount = 0;
  bool _hasText = false;

  /// Max retry attempts for chat connection from widget
  static const int _maxWidgetRetries = 3;
  int _widgetRetryCount = 0;

  @override
  void initState() {
    super.initState();

    // Delay connect to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectChat();
      // Scroll to bottom if messages already exist (e.g. widget recreated
      // while messages were already loaded - ref.listen won't fire for
      // existing data, only for changes)
      _scrollToBottomIfNeeded();
    });

    // Listen to expanded state changes to focus/unfocus
    _focusNode.addListener(_onFocusChange);

    // Listen to text changes to show/hide send icon
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onFocusChange() {
    // Auto-focus when expanded on mobile
    if (widget.isMobile && mounted) {
      final isExpanded = ref.read(liveChatExpandedProvider);
      if (isExpanded && !_focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      }
    }
  }

  /// Connect to chat WebSocket if not already connected
  Future<void> _connectChat() async {
    if (!mounted) return;

    final manager = ref.read(websocketProvider.notifier).manager;

    // Only connect if not already connected or connecting
    if (!manager.chat.isConnected && !manager.chat.isLoggedIn) {
      await ref.read(websocketProvider.notifier).connectChat();

      // If still not connected after attempt, retry with limit
      if (mounted && !manager.chat.isConnected) {
        _widgetRetryCount++;
        if (_widgetRetryCount < _maxWidgetRetries) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _connectChat();
          });
        }
        // Stop retrying after max attempts to prevent infinite loop
      } else {
        // Connected successfully, reset retry count
        _widgetRetryCount = 0;
      }
    } else if (manager.chat.isLoggedIn) {
      // Already connected and logged in - check if we need to fetch history
      // This handles the race condition where history was emitted before
      // WebSocketNotifier was created/subscribed
      final currentMessages = ref.read(chatMessagesProvider);
      if (currentMessages.isEmpty) {
        ref.read(websocketProvider.notifier).fetchChatHistory();
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        // Jump again after next frame because ListView.builder estimates
        // maxScrollExtent based on average item size. After the first jump
        // renders items near the bottom, the estimate becomes accurate.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
      }
    });
  }

  void _scrollToBottomIfNeeded() {
    if (!mounted) return;
    final messages = ref.read(chatMessagesProvider);
    if (messages.isNotEmpty) {
      _previousMessageCount = messages.length;
      _scrollToBottom();
    }
  }

  void _handleSendMessage(bool isConnected) {
    final userBalance = ref.read(userBalanceProvider);
    if (userBalance <= 0) {
      AppToast.showError(
        context,
        message: 'Vui lòng nạp tối thiểu 20k để sử dụng tính năng này',
      );
      return;
    }
    final text = _messageController.text.trim();
    if (text.isNotEmpty && isConnected) {
      // Send via WebSocket
      ref.read(websocketProvider.notifier).sendChatMessage(text);

      // Clear text field
      _messageController.clear();
    }
  }

  /// Get username color based on message properties
  Color _getUsernameColor(ChatMessageData message) {
    // VIP/highlighted message - yellow
    if (message.isHighlighted) {
      return const Color(0xFFF9BF5A);
    }

    // Current user's message - yellow
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null && message.displayName == currentUser.displayName) {
      return const Color(0xFFF9BF5A);
    }

    // System/error message - red
    if (message.isSystemMessage || message.isError) {
      return const Color(0xFFFF5252);
    }

    // Normal message - orange
    return const Color(0xFFF38744);
  }

  /// Get message text color
  Color _getMessageColor(ChatMessageData message) {
    if (message.isError) {
      return const Color(0xFFFF5252);
    }
    return const Color(0xFFFFFEF5);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to messages for scroll-to-bottom side effect
    ref.listen<List<ChatMessageData>>(chatMessagesProvider, (previous, next) {
      if (next.length != _previousMessageCount) {
        _previousMessageCount = next.length;
        _scrollToBottom();
      }
    });

    // Listen to expanded state for auto-focus on mobile
    ref.listen<bool>(liveChatExpandedProvider, (previous, next) {
      if (widget.isMobile && next && !_focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      }
    });

    // Only watch expanded state at top level since it affects overall structure
    final isExpanded = ref.watch(liveChatExpandedProvider);

    return GestureDetector(
      // Absorb tap events inside widget to prevent keyboard dismissal
      onTap: () {
        // Do nothing, just absorb the tap to prevent onTapOutside
      },
      behavior: HitTestBehavior.deferToChild,
      child: FocusScope(
        // Prevent keyboard dismissal when tapping inside the widget
        canRequestFocus: true,
        child: InnerShadowCard(
          child: Stack(
            children: [
              Positioned.fill(
                child: Stack(
                  children: [
                    Container(
                      clipBehavior: Clip.none,
                      decoration: BoxDecoration(
                        color: AppColorStyles.backgroundTertiary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: const Color.fromRGBO(255, 255, 255, 0.12),
                            width: 1.0,
                          ),
                        ),
                        // Add shadow when expanded and TextField is visible
                        boxShadow: (widget.isMobile && isExpanded)
                            ? [
                                // Outer shadow: 0 12px 20px 0 rgba(0, 0, 0, 0.50)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.50),
                                  offset: const Offset(0, 12),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          if (!widget.isMobile)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Live chat',
                                      style: AppTextStyles.displayStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFFCDA),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Chat messages
                          Expanded(
                            child: GestureDetector(
                              // Absorb tap events to prevent keyboard dismissal when tapping messages area
                              onTap: () {
                                // Do nothing, just absorb the tap
                              },
                              behavior: HitTestBehavior.opaque,
                              child: NotificationListener<ScrollNotification>(
                                // Allow scroll notifications to pass through
                                onNotification: (notification) => false,
                                // Use Consumer to isolate messages rebuild
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final messages = ref.watch(
                                      chatMessagesProvider,
                                    );
                                    final isConnected = ref.watch(
                                      chatLoggedInProvider,
                                    );
                                    return Container(
                                      padding: EdgeInsets.fromLTRB(
                                        12,
                                        0,
                                        12,
                                        widget.isMobile ? 6 : 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: widget.isMobile
                                            ? const BorderRadius.vertical(
                                                bottom: Radius.circular(16),
                                              )
                                            : const BorderRadius.all(
                                                Radius.circular(16),
                                              ),
                                        color: const Color(0xFF252423),
                                      ),
                                      child: messages.isEmpty
                                          ? Center(
                                              child: Text(
                                                isConnected
                                                    ? 'Chưa có tin nhắn'
                                                    : 'Đang kết nối...',
                                                style: AppTextStyles.textStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(
                                                    0xFFAAA49B,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : ScrollConfiguration(
                                              behavior: ScrollConfiguration.of(
                                                context,
                                              ).copyWith(scrollbars: false),
                                              child: MediaQuery.removePadding(
                                                context: context,
                                                removeTop: true,
                                                removeBottom: true,
                                                child: ListView.builder(
                                                  controller: _scrollController,
                                                  itemCount: messages.length,
                                                  itemBuilder: (context, index) {
                                                    final message =
                                                        messages[index];
                                                    return _buildMessageItem(
                                                      message,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Chat input - desktop or mobile when expanded
                          if (!widget.isMobile ||
                              (widget.isMobile && isExpanded))
                            // Use Consumer to isolate input rebuild
                            Consumer(
                              builder: (context, ref, _) {
                                final isConnected = ref.watch(
                                  chatLoggedInProvider,
                                );
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: widget.isMobile ? 14 : 16,
                                    vertical: widget.isMobile ? 8 : 0,
                                  ),
                                  margin: widget.isMobile
                                      ? const EdgeInsets.fromLTRB(12, 6, 12, 12)
                                      : EdgeInsets.zero,
                                  height: widget.isMobile ? null : 44,
                                  decoration: BoxDecoration(
                                    color: widget.isMobile
                                        ? AppColorStyles.backgroundQuaternary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                      widget.isMobile ? 12 : 10,
                                    ),
                                    boxShadow: widget.isMobile
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              offset: const Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _messageController,
                                          focusNode: _focusNode,
                                          enabled:
                                              true, // Always allow typing, check connection when sending
                                          cursorColor: const Color(0xFFE3A637),
                                          style: AppTextStyles.textStyle(
                                            fontSize: widget.isMobile ? 16 : 14,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                AppColorStyles.contentPrimary,
                                            height: widget.isMobile
                                                ? 24 / 16
                                                : null,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: isConnected
                                                ? widget.placeholderText
                                                : 'Nhập tin nhắn',
                                            hintStyle: AppTextStyles.textStyle(
                                              fontSize: widget.isMobile
                                                  ? 16
                                                  : 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColorStyles
                                                  .contentTertiary,
                                              height: widget.isMobile
                                                  ? 24 / 16
                                                  : null,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                          ),
                                          onChanged: (_) {
                                            // Trigger text change check immediately
                                            _onTextChanged();
                                          },
                                          onSubmitted: (_) =>
                                              _handleSendMessage(isConnected),
                                          textInputAction: TextInputAction.send,
                                          // onTapOutside: Only dismiss if tap is truly outside the widget
                                          // The parent screen's GestureDetector will handle dismissal
                                          onTapOutside: widget.isMobile
                                              ? (event) {
                                                  // Check if tap is inside the widget bounds
                                                  final RenderBox? renderBox =
                                                      context.findRenderObject()
                                                          as RenderBox?;
                                                  if (renderBox != null) {
                                                    final localPosition =
                                                        renderBox.globalToLocal(
                                                          event.position,
                                                        );
                                                    final isInsideWidget =
                                                        localPosition.dx >= 0 &&
                                                        localPosition.dx <=
                                                            renderBox
                                                                .size
                                                                .width &&
                                                        localPosition.dy >= 0 &&
                                                        localPosition.dy <=
                                                            renderBox
                                                                .size
                                                                .height;

                                                    // Only dismiss if tap is outside widget
                                                    if (!isInsideWidget) {
                                                      _focusNode.unfocus();
                                                      ref
                                                              .read(
                                                                liveChatExpandedProvider
                                                                    .notifier,
                                                              )
                                                              .state =
                                                          false;
                                                    }
                                                  }
                                                }
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    // Inset shadow overlay when expanded (mobile only)
                    // Inset shadow: 0 -0.5px 0.5px 0 rgba(255, 255, 255, 0.12) at bottom
                    if (widget.isMobile && isExpanded)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Gradient overlay on top when expanded (mobile only)
              if (widget.isMobile && isExpanded)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40, // Height of gradient overlay
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF000000), // #000000 (black)
                          Color(0x00000000), // #00000000 (transparent)
                        ],
                      ),
                    ),
                  ),
                ),
              if (widget.isMobile)
                Positioned(
                  bottom: !isExpanded ? 8 : 60,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(liveChatExpandedProvider.notifier).state =
                          !isExpanded;
                    },
                    child: Center(
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Transform.rotate(
                          angle: 90 * pi / 180,
                          child: ImageHelper.load(
                            path: AppIcons.btnArrowRight,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessageData message) {
    final usernameColor = _getUsernameColor(message);
    final messageColor = _getMessageColor(message);

    // System message (no sender)
    if (message.isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          message.message,
          style: AppTextStyles.textStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: messageColor,
            height: 1.43,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      );
    }

    // Regular message with sender
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP badge for highlighted messages
          if (message.isHighlighted) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9BF5A).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'TOP',
                style: AppTextStyles.textStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF9BF5A),
                ),
              ),
            ),
          ],
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${message.displayName}: ',
                    style: AppTextStyles.textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: usernameColor,
                      height: 1.23,
                    ),
                  ),
                  TextSpan(
                    text: message.message,
                    style: AppTextStyles.textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: messageColor,
                      height: 1.23,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
