// import 'package:flutter_test/flutter_test.dart';
// import 'package:sun_sports/core/services/auth/jwt_decoder_service.dart';
// import 'package:sun_sports/features/auth/data/models/jwt_user_info_model.dart';

// void main() {
//   group('JWT Decoder Service', () {
//     late JwtDecoderService jwtDecoder;

//     setUp(() {
//       jwtDecoder = JwtDecoderServiceImpl();
//     });

//     test('should decode valid JWT token', () {
//       // This is the actual wsToken from the API response
//       const wsToken =
//           'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJnZW5kZXIiOjAsImNhblZpZXdTdGF0IjpmYWxzZSwiZGlzcGxheU5hbWUiOiJjaHVjaGE0NTYiLCJib3QiOjAsImlzTWVyY2hhbnQiOmZhbHNlLCJ2ZXJpZmllZEJhbmtBY2NvdW50IjpmYWxzZSwicGxheUV2ZW50TG9iYnkiOmZhbHNlLCJjdXN0b21lcklkIjozMjkzMjgxMzQsImFmZklkIjoiU3Vud2luIiwiYmFubmVkIjpmYWxzZSwiYnJhbmQiOiJzdW4ud2luIiwidGltZXN0YW1wIjoxNzcwNDU4MjE2OTY5LCJsb2NrR2FtZXMiOltdLCJhbW91bnQiOjAsImxvY2tDaGF0IjpmYWxzZSwicGhvbmVWZXJpZmllZCI6ZmFsc2UsImlwQWRkcmVzcyI6IjEwOC4xNjUuNjguMTAxIiwibXV0ZSI6ZmFsc2UsImF2YXRhciI6Imh0dHBzOi8vaW1hZ2VzLnN3aW5zaG9wLm5ldC9pbWFnZXMvYXZhdGFyL2F2YXRhcl8xMC5wbmciLCJwbGF0Zm9ybUlkIjo0LCJ1c2VySWQiOiI0OTU0OTBmZi0yMzY0LTQ3NzMtYTdmYi1lMzc3NzkyYThkN2MiLCJyZWdUaW1lIjoxNzY1MDE0MTAwNDMyLCJwaG9uZSI6IiIsImRlcG9zaXQiOmZhbHNlLCJ1c2VybmFtZSI6IlNDX3Rlc3RnYW1lMDcxMiJ9.QBPo0F-SC75lwc1b1A7YbF0_FPKDOnfrrKWozc9Gm9U';

//       final payload = jwtDecoder.decodeToken(wsToken);

//       expect(payload, isNotNull);
//       expect(payload!['userId'], '495490ff-2364-4773-a7fb-e377792a8d7c');
//       expect(payload['username'], 'SC_testgame0712');
//       expect(payload['displayName'], 'chucha456');
//       expect(payload['customerId'], 329328134);
//       expect(payload['brand'], 'sun.win');
//     });

//     test('should return null for invalid JWT', () {
//       final payload = jwtDecoder.decodeToken('invalid_token');
//       expect(payload, isNull);
//     });

//     test('should return null for empty JWT', () {
//       final payload = jwtDecoder.decodeToken('');
//       expect(payload, isNull);
//     });
//   });

//   group('JWT User Info Model', () {
//     test('should parse JWT payload to model', () {
//       final payload = {
//         'userId': '495490ff-2364-4773-a7fb-e377792a8d7c',
//         'username': 'SC_testgame0712',
//         'displayName': 'chucha456',
//         'avatar': 'https://images.swinshop.net/images/avatar/avatar_10.png',
//         'brand': 'sun.win',
//         'customerId': 329328134,
//         'platformId': 4,
//         'amount': 1000,
//         'gender': 0,
//         'banned': false,
//         'phoneVerified': false,
//         'deposit': false,
//         'phone': '',
//       };

//       final model = JwtUserInfoModel.fromJson(payload);

//       expect(model.userId, '495490ff-2364-4773-a7fb-e377792a8d7c');
//       expect(model.username, 'SC_testgame0712');
//       expect(model.displayName, 'chucha456');
//       expect(model.customerId, 329328134);
//       expect(model.amount, 1000);
//       expect(model.brand, 'sun.win');
//     });

//     test('should convert to UserInfo entity', () {
//       final model = JwtUserInfoModel(
//         userId: '12345',
//         username: 'testuser',
//         displayName: 'Test User',
//         avatar: 'https://example.com/avatar.png',
//         brand: 'sun.win',
//         customerId: 123,
//         platformId: 4,
//         amount: 5000,
//       );

//       final userInfo = model.toUserInfoEntity();

//       expect(userInfo.displayName, 'Test User');
//       expect(userInfo.visibleUserName, 'testuser');
//       expect(userInfo.visibleUserId, '12345');
//       expect(userInfo.gold, 5000);
//       expect(userInfo.chip, 5000);
//       expect(userInfo.avatar, 'https://example.com/avatar.png');
//       expect(userInfo.brand, 'sun.win');
//     });

//     test('should convert to ProfileEntity', () {
//       final model = JwtUserInfoModel(
//         userId: '12345',
//         username: 'testuser',
//         displayName: 'Test User',
//         avatar: 'https://example.com/avatar.png',
//         brand: 'sun.win',
//         customerId: 123,
//         platformId: 4,
//         amount: 5000,
//         deposit: true,
//       );

//       final profile = model.toProfileEntity();

//       expect(profile.displayName, 'Test User');
//       expect(profile.username, 'testuser');
//       expect(profile.custLogin, 'testuser');
//       expect(profile.custId, '123');
//       expect(profile.uid, '12345');
//       expect(profile.balance, 5000.0);
//       expect(profile.avatarUrl, 'https://example.com/avatar.png');
//       expect(profile.brand, 'sun.win');
//       expect(profile.isActivated, true);
//     });

//     test('should handle missing optional fields', () {
//       final payload = {
//         'userId': '12345',
//         'username': 'testuser',
//         'displayName': 'Test User',
//         'avatar': 'https://example.com/avatar.png',
//         'brand': 'sun.win',
//         'customerId': 123,
//         'platformId': 4,
//         'amount': 0,
//         // Optional fields not provided
//       };

//       final model = JwtUserInfoModel.fromJson(payload);

//       expect(model.gender, 0); // default
//       expect(model.banned, false); // default
//       expect(model.phoneVerified, false); // default
//       expect(model.deposit, false); // default
//       expect(model.phone, isNull);
//       expect(model.affId, isNull);
//     });
//   });

//   group('Integration Test', () {
//     test('should decode real JWT and convert to ProfileEntity', () {
//       const wsToken =
//           'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJnZW5kZXIiOjAsImNhblZpZXdTdGF0IjpmYWxzZSwiZGlzcGxheU5hbWUiOiJjaHVjaGE0NTYiLCJib3QiOjAsImlzTWVyY2hhbnQiOmZhbHNlLCJ2ZXJpZmllZEJhbmtBY2NvdW50IjpmYWxzZSwicGxheUV2ZW50TG9iYnkiOmZhbHNlLCJjdXN0b21lcklkIjozMjkzMjgxMzQsImFmZklkIjoiU3Vud2luIiwiYmFubmVkIjpmYWxzZSwiYnJhbmQiOiJzdW4ud2luIiwidGltZXN0YW1wIjoxNzcwNDU4MjE2OTY5LCJsb2NrR2FtZXMiOltdLCJhbW91bnQiOjAsImxvY2tDaGF0IjpmYWxzZSwicGhvbmVWZXJpZmllZCI6ZmFsc2UsImlwQWRkcmVzcyI6IjEwOC4xNjUuNjguMTAxIiwibXV0ZSI6ZmFsc2UsImF2YXRhciI6Imh0dHBzOi8vaW1hZ2VzLnN3aW5zaG9wLm5ldC9pbWFnZXMvYXZhdGFyL2F2YXRhcl8xMC5wbmciLCJwbGF0Zm9ybUlkIjo0LCJ1c2VySWQiOiI0OTU0OTBmZi0yMzY0LTQ3NzMtYTdmYi1lMzc3NzkyYThkN2MiLCJyZWdUaW1lIjoxNzY1MDE0MTAwNDMyLCJwaG9uZSI6IiIsImRlcG9zaXQiOmZhbHNlLCJ1c2VybmFtZSI6IlNDX3Rlc3RnYW1lMDcxMiJ9.QBPo0F-SC75lwc1b1A7YbF0_FPKDOnfrrKWozc9Gm9U';

//       final jwtDecoder = JwtDecoderServiceImpl();
//       final payload = jwtDecoder.decodeToken(wsToken);

//       expect(payload, isNotNull);

//       final model = JwtUserInfoModel.fromJson(payload!);
//       final profile = model.toProfileEntity();

//       expect(profile.displayName, 'chucha456');
//       expect(profile.username, 'SC_testgame0712');
//       expect(profile.custId, '329328134');
//       expect(profile.brand, 'sun.win');
//       expect(profile.balance, 0.0);
//       expect(profile.isActivated, false);
//     });
//   });
// }
