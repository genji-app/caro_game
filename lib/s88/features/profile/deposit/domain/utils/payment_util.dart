import 'package:co_caro_flame/s88/core/utils/styles/app_icons.dart';

class PaymentUtil {
  static String formatAccountNumber(String accountNumber) {
    return accountNumber.replaceAll(RegExp(r'\s+'), '');
  }

  static String getIconPayment({
    required String name,
    String patchIconDefault = '',
  }) {
    switch (name.toLowerCase()) {
      case 'vietcombank':
        return AppIcons.iconBankVietcombank;
      case 'bidv':
        return AppIcons.iconBankBIDV;
      case 'acb':
        return AppIcons.iconBankACB;
      case 'techcombank':
        return AppIcons.iconBankTechcombank;
      case 'shb':
        return AppIcons.iconBankSHB;
      case 'vietinbank':
        return AppIcons.iconBankVietinbank;
      case 'mbbank':
        return AppIcons.iconBankMB;
      case 'vikkibank':
        return AppIcons.iconBankVikki;
      case 'eximbank':
        return AppIcons.iconBankEximbank;
      case 'vpbank':
        return AppIcons.iconBankVp;
      case 'maritimebank':
        return AppIcons.iconBankMSB;
      case 'namabank':
        return AppIcons.iconBankNamA;
      case 'pvcombank':
        return AppIcons.iconBankPVCom;
      case 'ocb':
        return AppIcons.iconBankOCB;
      case 'kienlongbank':
        return AppIcons.iconBankKienLong;
      case 'vietbank':
        return AppIcons.iconBankVietBank;
      case 'tpbank':
        return AppIcons.iconBankTp;
      case 'ivb':
        return AppIcons.iconBankIvb;
      case 'bacabank':
        return AppIcons.iconBankBacA;
      case 'publicbank':
        return AppIcons.iconBankPublic;
      //card---------------------
      case 'viettel':
        return AppIcons.iconCardViettel;
      case 'vinaphone':
        return AppIcons.iconCardVinaphone;
      case 'mobifone':
        return AppIcons.iconCardMobifone;
      case 'vietnamobile':
        return AppIcons.iconCardVietnamobile;
      case 'momo':
        return AppIcons.icPaymentMomoItem;
      case 'zalopay':
        return AppIcons.icPaymentZaloPay;
      case 'viettelpay':
        return AppIcons.icPaymentViettelPay;
      case 'napnhanh247':
        return AppIcons.iconNapNhanh247;
      case 'indovinabank':
        return AppIcons.iconBankIndovina;
      default:
        return patchIconDefault;
    }
  }
}
