/// Mock success response data for testing
final kMockSuccessResponse = {
  'Locale': 'vi',
  'messageKey': 'paygate.success',
  'data': {
    'count': 5,
    'message': 'Thành công',
    'items': [
      {
        'requestTime': 1765640327433,
        'amount': 22000000,
        'statusDescription': 'Đã hủy',
        'notes':
            'Quý khách vui lòng liên hệ Livechat để xác minh tài khoản nạp rút chính chủ. Xin cám ơn!',
        'responseTime': 1765640363715,
        'bankReceive': {
          'bankId': '5c4f2d31606041e424f4840d', // Techcombank
          'accountName': 'NGUYEN VAN A',
          'publicRss': 0,
          'accountNumber': '19032456789',
          'type': 1,
        },
        'id': 876840732,
        'bankSent': {
          'bankId': '5c4f2d31606041e424f4840d',
          'publicRss': 0,
          'type': 1,
        },
        'transactionCode': 'TXN001',
        'type': 6, // CodePay
        'slipType': 2, // Withdraw
        'status': 6, // New Request
      },
      {
        'requestTime': 1765640327433,
        'amount': 5000000,
        'statusDescription': 'Thành công',
        'notes': 'Nạp tiền thành công',
        'responseTime': 1765640363715,
        'bankReceive': {
          'bankId': '5c4f2cb0606041e424f47832', // BIDV
          'accountName': 'NGUYEN VAN B',
          'publicRss': 0,
          'accountNumber': '32423424',
          'type': 1,
        },
        'id': 876840733,
        'bankSent': {
          'bankId': '5c4f2cb0606041e424f47832',
          'publicRss': 0,
          'type': 1,
        },
        'transactionCode': 'TXN002',
        'type': 1, // IBanking
        'slipType': 1, // Deposit
        'status': 2, // Success
      },
      {
        'requestTime': 1765640193859,
        'amount': 1000000,
        'statusDescription': 'Từ chối',
        'notes': 'Số dư không đủ',
        'responseTime': 1765640259328,
        'bankReceive': {
          'bankId': '5c7cd8d337ce56e0113c7f46', // MOMO
          'accountName': 'TRAN VAN C',
          'publicRss': 0,
          'accountNumber': '0912345678',
          'type': 2,
        },
        'id': 876839116,
        'bankSent': {
          'bankId': '5c7cd8d337ce56e0113c7f46',
          'publicRss': 0,
          'type': 2,
        },
        'transactionCode': 'TXN003',
        'type': 4, // Digital Wallet
        'slipType': 2, // Withdraw
        'status': 3, // Rejected
      },
      {
        'requestTime': 1765640193859,
        'amount': 500000,
        'statusDescription': 'Đang xử lý',
        'notes': '',
        'responseTime': 1765640259328,
        'bankReceive': {
          'bankId': '63770e1834cff12cbcbd8498', // Crypto (USDT)
          'accountName': 'WALLET_ADDRESS',
          'publicRss': 0,
          'accountNumber': 'TRC20_ADDRESS_HERE',
          'type': 4,
        },
        'id': 876832116,
        'bankSent': {
          'bankId': '63770e1834cff12cbcbd8498',
          'publicRss': 0,
          'type': 4,
        },
        'transactionCode': 'TXN004',
        'type': 8, // Crypto
        'slipType': 1, // Deposit
        'status': 5, // Processing
      },
      {
        'requestTime': 1765640193859,
        'amount': 2000000,
        'statusDescription': 'Đã chuyển',
        'notes': 'Rút tiền về ví ZaloPay',
        'responseTime': 1765640259328,
        'bankReceive': {
          'bankId': '5c7cd93737ce56e0113ca38b', // ZaloPay
          'accountName': 'LE VAN D',
          'publicRss': 0,
          'accountNumber': '0987654321',
          'type': 2,
        },
        'id': 876822116,
        'bankSent': {
          'bankId': '5c7cd93737ce56e0113ca38b',
          'publicRss': 0,
          'type': 2,
        },
        'transactionCode': 'TXN005',
        'type': 4, // Digital Wallet
        'slipType': 2, // Withdraw
        'status': 4, // Transferred
      },
    ],
  },
  'status': 0,
};
