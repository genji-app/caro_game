import 'package:flutter/material.dart' hide CloseButton;
import 'package:gap/gap.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:co_caro_flame/s88/core/constants/i18n.dart';
import 'package:co_caro_flame/s88/core/services/repositories/repositories.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_color_styles.dart';
import 'package:co_caro_flame/s88/core/utils/styles/app_text_styles.dart';
import 'package:co_caro_flame/s88/features/transaction/transaction.dart';
import 'package:co_caro_flame/s88/shared/widgets/divider/divider.dart';

class DateGroupedSliverList extends StatelessWidget {
  const DateGroupedSliverList(this.data, {super.key, this.onItemPressed});

  final List<Transaction> data;
  final ValueChanged<Transaction>? onItemPressed;

  // transaction
  // pathParameters: {'id': t.id},
  // final detailsPath = '${ProfileNavigator.transactionDetailsPath}${t.id}';
  // context.push(detailsPath, extra: t);
  // separator: const SizedBox(height: 40),
  // groupComparator: (e1, e2) => e1.difference(e2).inDays,
  // groupSeparatorBuilder: (date) => const SizedBox(height: 40),
  // groupSeparatorBuilder: (date) => _DateHeaderWidget(date: date),

  @override
  Widget build(BuildContext context) {
    return SliverGroupedListView(
      order: GroupedListOrder.DESC,
      elements: data,
      groupSeparatorBuilder: (t) => const Gap(40),
      groupHeaderBuilder: (item) => _DateTimeHeaderWidget(item.date),
      separator: const SBDivider.thin(indent: 28, endIndent: 28),
      groupBy: (item) =>
          DateTime(item.date.year, item.date.month, item.date.day),
      itemBuilder: (context, item) => TransactionListTile(
        transaction: item,
        onPressed: onItemPressed != null ? () => onItemPressed!(item) : null,
      ),
    );
  }
}

class _DateTimeHeaderWidget extends StatelessWidget {
  const _DateTimeHeaderWidget(this.date);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final differenceInDays = now.difference(date).inDays;

    final label = switch (differenceInDays) {
      0 => I18n.txtToday,
      1 => I18n.txtYesterday,
      _ => DateFormat('EEE, dd MMM yyyy').format(date),
    };

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      child: DefaultTextStyle(
        style: AppTextStyles.labelSmall(color: AppColorStyles.contentTertiary),
        child: Text(label),
      ),
    );
  }
}

// // --- Helper Classes for UI Grouping ---
// abstract class ListItem {}

// class DateHeaderItem implements ListItem {
//   final DateTime date;
//   DateHeaderItem(this.date);
// }

// class TransactionItem implements ListItem {
//   final Transaction transaction;
//   TransactionItem(this.transaction);
// }

// class DateGroupedSliverList extends StatelessWidget {
//   const DateGroupedSliverList(this.data, {super.key});
//   // const DateGroupedSliverList(this.data, {required this.itemBuilder, super.key});

//   // final Widget? Function(BuildContext, int) itemBuilder;
//   final List<Transaction> data;

//   // --- Helper to Flatten the list ---
//   static List<ListItem> groupTransactionsByDate(List<Transaction> transactions) {
//     final List<ListItem> flattenedList = [];
//     DateTime? lastDate;

//     for (var transaction in transactions) {
//       // Normalize date (remove time info) for comparison
//       final dateOnly = DateTime(
//         transaction.date.year,
//         transaction.date.month,
//         transaction.date.day,
//       );

//       if (lastDate == null || lastDate != dateOnly) {
//         flattenedList.add(DateHeaderItem(dateOnly));
//         lastDate = dateOnly;
//       }
//       flattenedList.add(TransactionItem(transaction));
//     }
//     return flattenedList;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 1. Group Data Logic (Flattening for UI)
//     final groupedItems = groupTransactionsByDate(data);

//     return SliverList.builder(
//       itemBuilder: (context, index) {
//         final item = groupedItems[index];
//         if (item is DateHeaderItem) {
//           return _DateHeaderWidget(date: item.date);
//         } else if (item is TransactionItem) {
//           return TransactionListTile(transaction: item.transaction);
//         }
//         return const SizedBox.shrink();
//       },
//       itemCount: groupedItems.length,
//     );
//   }
// }
