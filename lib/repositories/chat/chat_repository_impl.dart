import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat_repository.dart';
import '../../constants/api_constants.dart';

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<String> sendMessage({
    required String question,
    required String username,
    required String token,
    String model = 'gpt-4',
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.chatEndpoint}?question=$question&model=$model&username=$username'),
        headers: {
          'accept': 'application/json',
          'api-key': token,
          'Accept-Language': 'en-GB,en-US;q=0.9,en;q=0.8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['message']?.toString() ?? '';
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to get response');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }
}
