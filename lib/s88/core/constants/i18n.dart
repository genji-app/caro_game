class I18n {
  I18n._();
  // ---------- Words ----------//
  // General
  static const String txtSuccess = 'Thành công';
  static const String txtFailure = 'Thất bại';
  static const String txtProcessing = 'Đang xử lý';
  static const String txtGoBack = 'Quay lại';
  static const String txtHistory = 'Lịch sử';
  static const String txtToday = 'Hôm nay';
  static const String txtSettings = 'Cài đặt';
  static const String txtYesterday = 'Hôm qua';
  static const String txtContent = 'Nội dung';
  static const String txtNotAvailable = 'N/A';
  static const String txtStatus = 'Trạng thái';
  static const String txtLogin = 'Đăng nhập';
  static const String txtRegister = 'Đăng ký';
  static const String txtLogout = 'Thoát';
  static const String txtUser = 'User';
  static const String txtNickname = 'Nickname';
  static const String txtWithdraw = 'Rút tiền';
  static const String txtDeposit = 'Nạp tiền';
  static const String txtSell = 'Bán';
  static const String txtID = 'ID';
  static const String txtMethod = 'Phương thức';
  static const String txtOdds = 'Tỉ Lệ Cược';
  static const String txtCancel = 'Hủy';
  static const String txtSellTicket = 'Bán vé';
  static const String txtConfirmSellTicket = 'Xác nhận bán vé';
  static const String txtCasino = 'Casino';
  static const String txtSports = 'Thể thao';
  static const String txtRetry = 'Thử lại';
  static const String txtBackToHome = 'Về trang chủ';

  // Profile
  static const String txtUserInfo = 'Thông tin User';
  static const String txtPersonal = 'Cá nhân';
  static const String txtAccount = 'Tài khoản';
  static const String txtMailbox = 'Hòm thư';
  static const String txtSupport = 'Hỗ trợ';
  static const String txtPromo = 'Khuyến mãi';

  // Account Activation
  static const String txtActivate = 'Kích hoạt';
  static const String txtActivated = 'Đã kích hoạt';
  static const String txtActivateAccount = 'Kích hoạt tài khoản';
  static const String txtActivateByPhone = 'Kích hoạt bằng số điện thoại';
  static const String txtActivateByPhoneSuccess =
      'Kích hoạt bằng số điện thoại thành công';
  static const String txtPhoneNumber = 'Số điện thoại';
  static const String txtOTP = 'OTP';
  static const String txtContinue = 'Tiếp tục';
  static const String txtVerify = 'Xác minh';
  static const String txtResendCode = 'Gửi lại mã';

  // Phone Verification (aliases for renamed feature)
  static const String txtVerifyByPhone = txtActivateByPhone;
  static const String txtVerifyByPhoneSuccess = txtActivateByPhoneSuccess;

  // Account Activation - Messages
  static const String msgEnterPhoneToReceiveOTP =
      'Nhập số điện thoại để nhận mã OTP';
  static const String msgEnterOTPSentTo =
      'Nhập mã OTP gồm 6 ký tự được gửi đến số';
  static const String msgOTPSent = 'OTP đã được gửi';
  static const String msgOTPResent = 'OTP đã được gửi lại';
  static const String msgAccountVerificationDescription =
      msgAccountActivationDescription;

  // Account Activation - Validation
  static const String errPhoneRequired = 'Số điện thoại không được để trống';
  static const String errPhoneMinLength = 'Số điện thoại phải có ít nhất 10 số';
  static const String errPhoneMaxLength =
      'Số điện thoại không được vượt quá 15 số';
  static const String errPhoneInvalid = 'Số điện thoại không hợp lệ';
  static const String errOTPRequired = 'Vui lòng nhập OTP';
  static const String errOTPInvalid = 'OTP phải gồm đúng 6 chữ số';

  // Payment method
  static const String txtCodepay = 'Codepay';
  static const String txtScratchCard = 'Thẻ cào';
  static const String txtCrypto = 'Tiền ảo';
  static const String txteWallet = 'Ví điện tử';
  static const String txtBank = 'Ngân hàng';
  static const String txtIBanking = 'Internet Banking';
  static const String txtATM = 'ATM';
  static const String txtOffice = 'Quầy giao dịch';
  static const String txtDigitalWallets = 'Ví điện tử';
  static const String txtSmartPay = 'Smartpay';
  static const String txtQRPay = 'QRPay';
  static const String txtIAP = 'In-App Purchase';

  // Password
  static const String txtSecurity = 'Bảo mật';
  static const String txtSecurtity =
      txtSecurity; // Alias for backward compatibility
  static const String txtPassword = 'Mật khẩu';
  static const String txtChangePassword = 'Đổi Mật khẩu';
  static const String txtAuth2FA = 'Xác thực hai yếu tố (2FA)';
  static const String txtReEnterNewPassword = 'Nhập lại mật khẩu mới';
  static const String txtCurrentPassword = 'Mật khẩu hiện tại';
  static const String txtNewPassword = 'Mật khẩu mới';

  // Transactions
  // Lịch sử nạp rút
  static const String txtAmountOfMoney = 'Số tiền';
  static const String txtAccountName = 'Tên TK';
  static const String txtAccountNumber = 'Số TK';
  static const String txtDepositAndWithdrawalHistory = 'Lịch sử nạp rút';
  static const String txtBankDeposit = 'Nạp tiền ngân hàng';
  static const String txtBankWithdraw = 'Rút tiền ngân hàng';

  static const String txtCodepayDeposit = 'Nạp tiền Codepay';
  static const String txtCodepayWithdraw = 'Rút tiền Codepay';

  static const String txtScratchCardDeposit = 'Nạp tiền thẻ cào';
  static const String txtScratchCardWithdraw = 'Rút tiền thẻ cào';

  static const String txtCryptoDeposit = 'Nạp tiền mã hóa';
  static const String txtCryptoWithdraw = 'Rút tiền mã hóa';

  static const String txtDepositDetails = 'Chi tiết nạp tiền';
  static const String txtWithdrawalDetails = 'Chi tiết rút tiền';

  // Transactions bet
  static const String txtBetCount = 'Cược';
  static const String txtBet = 'Cá cược';
  static const String txtBetHistory = 'Lịch sử cược';
  static const String txtBetDetails = 'Chi tiết cược';
  static const String txtResellTickets = 'Bán lại vé';

  static const String txtCurrentlyActive = 'Đang hoạt động';
  static const String txtPaymentHasBeenMade = 'Đã thanh toán';
  static const String txtEstimatedPayout = 'Thanh toán dự kiến';
  static const String txtStake = 'Đặt cược';
  static const String txtChange = 'Thay đổi';

  // Bet Status
  static const String txtWon = 'Thắng';
  static const String txtLost = 'Thua';
  static const String txtHalfWon = 'Thắng 1/2';
  static const String txtHalfLost = 'Thua 1/2';
  static const String txtDraw = 'Hoà';
  static const String txtRefunded = 'Hoàn tiền';
  static const String txtSold = 'Đã bán';
  static const String txtPending = 'Đang chờ';
  static const String txtTransfered = 'Đã chuyển';
  static const String txtNewRequest = 'Yêu cầu mới';

  static const String txtResellTicketTitle = 'Xác nhận bán lại vé';
  static const String txtOriginalStake = 'Số tiền cược gốc';
  static const String txtReceivedAmount = 'Số tiền nhận được';
  static const String txtResellNote =
      'Lưu ý: Sau khi xác nhận, vé cược sẽ được thanh toán ngay lập tức với số tiền trên.';
  static const String txtResellTicketButton = 'Bán vé';
  static const String txtResellNotAllowed =
      'Vé cược này hiện tại không cho phép bán lại';
  static const String txtCannotGetPrice =
      'Không thể lấy thông tin giá mới nhất';
  static const String txtPriceConnectionError =
      'Lỗi kết nối khi lấy thông tin giá';
  static const String txtPriceChangedError =
      'Giá đã thay đổi hoặc không thể lấy thông tin giá mới nhất';
  static const String txtBettingSlip = 'Phiếu cược';
  static const String txtMyBets = 'Cược của tôi';
  static const String txtSportsFootball = 'Thể thao - Bóng đá';

  // Message
  static const String msgNoDataAvailable = 'Không có dữ liệu';
  static const String msgNoResultFound = 'Không tìm thấy kết quả';
  static const String msgSomethingWentWrong = 'Đã xảy ra lỗi.';
  static const String msgEmptyBettingSlip = 'Phiếu cược trống';
  static const String msgStartBettingNow = 'Bắt đầu đặt cược ngay bây giờ!';
  static const String msgNoTransaction = 'Bạn chưa có giao dịch nào';
  static const String msgDepositNow = 'Nạp tiền ngay';
  static const String msgAccountNotActivated =
      'Bạn chưa kích hoạt số điện thoại!';
  static const String msgAccountActivationDescription =
      'Kích hoạt số điện thoại ngay để bảo mật tài khoản và nạp rút không giới hạn.';
  static const String txtFeatureUnderDevelopment =
      'Tính năng đang được phát triển!';

  // ---------- Games ----------//
  // Game Types
  static const String txtGameSlots = 'Slots';
  static const String txtGameSports = 'Thể thao';
  static const String txtGameJackpot = 'Jackpot';
  static const String txtGameCard = 'Game bài';
  static const String txtGameDice = 'Xúc xắc';
  static const String txtGameLive = 'Live Casino';
  static const String txtGameLottery = 'Xổ số';
  static const String txtGameMiniGame = 'Mini Game';
  static const String txtGameFishing = 'Bắn cá';
  static const String txtGameOthers = 'Khác';
  static const String txtGameUnknown = 'Không xác định';

  // Category Labels
  static const String txtGameCategoryAll = 'Sảnh';
  static const String txtGameCategorySunwin = 'Sunwin';
  static const String txtGameCategoryNewGames = 'New Games';
  static const String txtGameCategoryLiveDealer = 'Live Dealer';
  static const String txtGameCategoryCards = 'Cards';
  static const String txtGameCategoryCasino = 'Casino';
  static const String txtGameCategoryArcade = 'Arcade';
  static const String txtGameCategoryLotto = 'Lotto';
  static const String txtGameCategoryFish = 'Fish';

  // UI Labels & Messages
  static const String txtSearchGame = 'Tìm trò chơi';
  static const String txtShowMore = 'Hiển thị thêm ';
  static const String txtLoadingGame = 'Loading game...';
  static const String txtPlayNow = 'Chơi ngay';
  static const String txtNoGamesAvailable = 'Không có trò chơi nào';
  static const String txtUnknownError = 'Lỗi không xác định';
}
