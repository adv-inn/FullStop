import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../config/llm_config.dart';

/// Base interface for LLM providers
abstract class BaseLlmProvider {
  Future<String> complete(String prompt);
  Future<Map<String, dynamic>> completeJson(String prompt);
}

/// OpenAI-compatible API provider
/// Works with OpenAI, Ollama, and other OpenAI-compatible endpoints
class OpenAiCompatibleProvider implements BaseLlmProvider {
  final LlmConfig config;
  final Dio dio;

  OpenAiCompatibleProvider({required this.config, Dio? dio})
    : dio = dio ?? Dio();

  @override
  Future<String> complete(String prompt) async {
    // Build endpoint URL - append /chat/completions if not present
    String endpoint = config.baseUrl.trim();
    if (!endpoint.endsWith('/chat/completions')) {
      if (endpoint.endsWith('/')) {
        endpoint = '${endpoint}chat/completions';
      } else {
        endpoint = '$endpoint/chat/completions';
      }
    }

    try {
      final requestData = {
        'model': config.model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': config.temperature,
        'max_tokens': config.maxTokens,
      };

      // Debug logging
      AppLogger.info('[LLM] POST $endpoint');
      AppLogger.info('[LLM] Model: ${config.model}');

      final response = await dio.post(
        endpoint,
        options: Options(headers: config.headers),
        data: requestData,
      );

      AppLogger.info('[LLM] Response: ${response.statusCode}');

      final content =
          response.data['choices'][0]['message']['content'] as String;
      return content.trim();
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.error('[LLM] Error: $errorMessage');
      throw LlmException(message: errorMessage);
    } catch (e) {
      AppLogger.error('[LLM] Failed: $e');
      throw LlmException(message: 'LLM request failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> completeJson(String prompt) async {
    final response = await complete(prompt);
    try {
      // Try to extract JSON from the response
      final jsonMatch = RegExp(r'\{[\s\S]*\}|\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      }
      return {'result': response};
    } catch (e) {
      return {'result': response};
    }
  }

  String _extractErrorMessage(DioException e) {
    // Try to extract error message from response
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String? ?? 'API request failed';
      }
      if (error is String) {
        return error;
      }
    }

    // Handle connection errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Check if the LLM server is running.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. The model might be too slow.';
      case DioExceptionType.connectionError:
        return 'Connection error. Check if the LLM server is accessible.';
      default:
        return e.message ?? 'API request failed';
    }
  }
}

/// Factory for creating LLM providers
class LlmProviderFactory {
  static BaseLlmProvider create(LlmConfig config) {
    return OpenAiCompatibleProvider(config: config);
  }
}
