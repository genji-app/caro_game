import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/utils/money_formatter.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color.dart';
import 'package:co_caro_flame/s88/shared/widgets/bet_details/models/betting_popup_data.dart';
import 'package:co_caro_flame/s88/shared/widgets/scoin_icon.dart';

/// Custom formatter để thêm dấu phẩy vào số
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Loại bỏ tất cả dấu phẩy để lấy số thuần
    final numericOnly = newValue.text.replaceAll(',', '');

    // Nếu không phải số hợp lệ, giữ nguyên giá trị cũ
    if (numericOnly.isEmpty || int.tryParse(numericOnly) == null) {
      return oldValue;
    }

    // Format số với dấu phẩy
    final formattedText = _formatWithCommas(numericOnly);

    // Tính toán vị trí cursor
    // Đếm số chữ số (không bao gồm dấu phẩy) trước cursor trong newValue
    final newSelection = newValue.selection.baseOffset;
    var digitsBeforeCursor = 0;
    for (var i = 0; i < newValue.text.length && i < newSelection; i++) {
      if (newValue.text[i] != ',') {
        digitsBeforeCursor++;
      }
    }

    // Giới hạn trong phạm vi hợp lệ
    if (digitsBeforeCursor > numericOnly.length) {
      digitsBeforeCursor = numericOnly.length;
    }

    // Tìm vị trí cursor mới trong text đã format
    // Đặt cursor sau chữ số thứ digitsBeforeCursor
    var newCursorPosition = formattedText.length;
    if (digitsBeforeCursor == 0) {
      newCursorPosition = 0;
    } else {
      var digitCount = 0;
      for (var i = 0; i < formattedText.length; i++) {
        if (formattedText[i] != ',') {
          digitCount++;
          if (digitCount == digitsBeforeCursor) {
            newCursorPosition = i + 1;
            break;
          }
        }
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  String _formatWithCommas(String number) {
    if (number.isEmpty) return '';

    final buffer = StringBuffer();
    var counter = 0;

    // Duyệt từ phải sang trái
    for (var i = number.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(number[i]);
      counter++;
    }

    // Đảo ngược lại vì đã duyệt từ phải sang trái
    return buffer.toString().split('').reversed.join('');
  }
}

class BetAmountSection extends StatefulWidget {
  final String betAmount;
  final void Function(String) onBetAmountChanged;
  final BettingPopupData? data;
  final int minStake;
  final int maxStake;

  const BetAmountSection({
    super.key,
    required this.betAmount,
    required this.onBetAmountChanged,
    this.data,
    this.minStake = 0,
    this.maxStake = 0,
  });

  @override
  State<BetAmountSection> createState() => BetAmountSectionState();
}

class BetAmountSectionState extends State<BetAmountSection> {
  late TextEditingController _amountController;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final initialText = widget.betAmount == '0' || widget.betAmount.isEmpty
        ? ''
        : _formatNumber(widget.betAmount);
    _amountController = TextEditingController(text: initialText);

    // Lắng nghe sự kiện focus để scroll đến TextField
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Delay để đảm bảo bàn phím đã hiển thị
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _textFieldKey.currentContext != null) {
          Scrollable.ensureVisible(
            _textFieldKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.5, // Center the TextField in viewport
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(BetAmountSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.betAmount != oldWidget.betAmount) {
      final newText = widget.betAmount == '0' || widget.betAmount.isEmpty
          ? ''
          : _formatNumber(widget.betAmount);
      if (_amountController.text != newText) {
        _amountController.text = newText;
      }
    }
  }

  String _formatNumber(String number) {
    try {
      final num = int.parse(number.replaceAll(',', ''));
      return NumberFormat('#,###').format(num);
    } catch (e) {
      return number;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty) {
      widget.onBetAmountChanged(text);
    } else {
      widget.onBetAmountChanged('0');
    }
  }

  void _clearAmount() {
    _amountController.clear();
    widget.onBetAmountChanged('0');
  }

  /// Add amount to current bet amount - can be called via GlobalKey
  void addAmount(String amount) {
    try {
      final current = int.parse(
        _amountController.text.replaceAll(',', '').isEmpty
            ? '0'
            : _amountController.text.replaceAll(',', ''),
      );
      final add = int.parse(amount.replaceAll(',', ''));
      final newAmount = (current + add).toString();
      final formatted = _formatNumber(newAmount);
      _amountController.text = formatted;
      widget.onBetAmountChanged(formatted);
    } catch (e) {
      // Handle error
    }
  }

  /// Set all-in (max stake) - can be called via GlobalKey
  void setAllIn() {
    final formatted = _formatMoney(_maxStakeActual);
    _amountController.text = formatted;
    widget.onBetAmountChanged(formatted);
  }

  String _formatMoney(int amount) {
    if (amount == 0) return '0';
    return NumberFormat('#,###').format(amount);
  }

  int get _currentStake {
    final text = _amountController.text.replaceAll(',', '');
    return int.tryParse(text) ?? 0;
  }

  /// Get actual min stake (minStake * 1000) - minStake is in K units
  int get _minStakeActual => widget.minStake * 1000;

  /// Get actual max stake (maxStake * 1000) - maxStake is in K units
  int get _maxStakeActual => widget.maxStake * 1000;

  void _setMinStake() {
    final formatted = _formatMoney(_minStakeActual);
    _amountController.text = formatted;
    widget.onBetAmountChanged(formatted);
  }

  void _setMaxStake() {
    final formatted = _formatMoney(_maxStakeActual);
    _amountController.text = formatted;
    widget.onBetAmountChanged(formatted);
  }

  @override
  Widget build(BuildContext context) => Column(
    key: _textFieldKey,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Bet amount input
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColorStyles.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColorStyles.borderPrimary, width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    onTapOutside: (event) => _focusNode.unfocus(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    style: AppTextStyles.labelMedium(
                      color: AppColorStyles.contentPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Nhập số tiền',
                      hintStyle: AppTextStyles.labelMedium(
                        color: AppColorStyles.contentQuaternary,
                      ),
                    ),
                    onChanged: _onTextChanged,
                  ),
                ),
                const SizedBox(width: 8),
                const SCoinIcon(),
                // Clear button - chỉ hiển thị khi có value
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _amountController,
                  builder: (context, value, child) {
                    if (value.text.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: GestureDetector(
                          onTap: _clearAmount,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColorStyles.backgroundTertiary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColorStyles.contentPrimary,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // Min/Max labels - hiển thị theo trạng thái giống cược đơn
          _buildStakeLimitInfo(),
        ],
      ),

      // const SizedBox(height: 16),
      // Quick bet buttons
    ],
  );

  Widget _buildStakeLimitInfo() {
    final stake = _currentStake;
    final minStake = _minStakeActual;
    final maxStake = _maxStakeActual;

    // State 1: stake < min (and stake > 0)
    if (stake > 0 && stake < minStake) {
      return Row(
        children: [
          Text(
            'Mức cược tối thiểu: ',
            style: AppTextStyles.paragraphXSmall(color: AppColors.red500),
          ),
          GestureDetector(
            onTap: _setMinStake,
            child: Text(
              MoneyFormatter.formatCompact(minStake),
              style: AppTextStyles.paragraphXSmall(color: AppColors.yellow500)
                  .copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.yellow500,
                  ),
            ),
          ),
        ],
      );
    }

    // State 2: stake > max
    if (stake > maxStake && maxStake > 0) {
      return Row(
        children: [
          Text(
            'Mức cược tối đa: ',
            style: AppTextStyles.paragraphXSmall(color: AppColors.red500),
          ),
          GestureDetector(
            onTap: _setMaxStake,
            child: Text(
              MoneyFormatter.formatCompact(maxStake),
              style: AppTextStyles.paragraphXSmall(color: AppColors.yellow500)
                  .copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.yellow500,
                  ),
            ),
          ),
        ],
      );
    }

    // Normal state: show range
    return Row(
      children: [
        Text(
          'Mức cược: ',
          style: AppTextStyles.paragraphXSmall(
            color: AppColorStyles.contentSecondary,
          ),
        ),
        Text(
          '${MoneyFormatter.formatCompact(minStake)} - ${MoneyFormatter.formatCompact(maxStake)}',
          style: AppTextStyles.paragraphXSmall(
            color: AppColorStyles.contentSecondary,
          ),
        ),
      ],
    );
  }
}

class _QuickBetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickBetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: AppColors.yellow300.withValues(alpha: 0.08),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.buttonSmall(color: AppColors.yellow300),
        ),
      ),
    ),
  );
}
