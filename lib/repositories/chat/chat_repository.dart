abstract class ChatRepository {
  Future<String> sendMessage({
    required String question,
    required String username,
    required String token,
    String model = 'gpt-4',
  });
}
