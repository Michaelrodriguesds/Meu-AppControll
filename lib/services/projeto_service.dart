import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/projeto_model.dart';

/// Classe responsável por todas as operações de CRUD (Create, Read, Update, Delete)
/// relacionadas a projetos no backend.
class ProjetoService {
  // URL base da API - substitua pela sua URL real
  static const String baseUrl = 'https://backendapp-0bcg.onrender.com/api';
  /// 🔄 Busca todos os projetos do usuário
  /// Parâmetros:
  /// - `token`: Token JWT para autenticação
  /// Retorna:
  /// - Lista de `Projeto` em caso de sucesso
  /// - Lança Exception em caso de erro
  static Future<List<Projeto>> getProjetos({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // ✅ Status 200 (OK)
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Projeto.fromJson(json)).toList();
      } 
      // ❌ Outros status (erro)
      else {
        throw Exception('Erro ao carregar projetos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha na conexão: ${e.toString()}');
    }
  }

  /// ➕ Cria um novo projeto
  /// Parâmetros:
  /// - `p`: Objeto Projeto com os dados
  /// - `token`: Token JWT para autenticação
  /// Retorna:
  /// - Map com: 
  ///   - 'success': bool (indica sucesso)
  ///   - 'message': String (feedback para usuário)
  ///   - 'data': Projeto criado (opcional)
  static Future<Map<String, dynamic>> criarProjeto(Projeto p, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(p.toJson()),
      );

      // ✅ Status 201 (Created)
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Projeto criado com sucesso!',
          'data': Projeto.fromJson(jsonDecode(response.body))
        };
      } 
      // ❌ Erros do backend
      else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Erro ao criar projeto',
          'statusCode': response.statusCode
        };
      }
    } 
    // 💥 Erros de conexão
    catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}'
      };
    }
  }

  /// ✏️ Atualiza um projeto existente
  /// Parâmetros:
  /// - `p`: Objeto Projeto com dados atualizados
  /// - `token`: Token JWT para autenticação
  /// Retorna:
  /// - Map com status e mensagem
  static Future<Map<String, dynamic>> atualizarProjeto(Projeto p, String token) async {
    try {
      // Validação do ID
      if (p.id == null || p.id!.isEmpty) {
        return {
          'success': false,
          'message': 'Projeto sem ID válido'
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/projects/${p.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(p.toJson()),
      );

      // ✅ Status 200 (OK)
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Projeto atualizado com sucesso!',
          'data': Projeto.fromJson(jsonDecode(response.body))
        };
      } 
      // ❌ Erros do backend
      else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Erro ao atualizar projeto',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}'
      };
    }
  }

  /// 🗑️ Exclui um projeto
  /// Parâmetros:
  /// - `id`: ID do projeto a ser excluído
  /// - `token`: Token JWT para autenticação
  /// Retorna:
  /// - Map com status e mensagem
  static Future<Map<String, dynamic>> deletarProjeto(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/projects/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // ✅ Status 204 (No Content)
      if (response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Projeto excluído com sucesso!'
        };
      } 
      // ❌ Erros do backend
      else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Erro ao excluir projeto',
          'statusCode': response.statusCode
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: ${e.toString()}'
      };
    }
  }
}