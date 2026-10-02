// controllers/auth_controller.dart

// IMPORTACIONES DE LIBRERÍAS Y MODELOS
// Permite convertir respuestas HTTP de texto plano a colecciones dinámicas de Dart (jsonDecode).
import 'dart:convert';

// Cliente HTTP utilizado para realizar la petición GET de usuarios al backend.
import 'package:http/http.dart' as http;

// CONEXIÓN: Importa UserModel para procesar y validar credenciales, ID y rol del usuario.
import '../models/user_model.dart';

// ============================================================================
// CONTROLADOR DE AUTENTICACIÓN (US01 y US02)
// ============================================================================
// Maneja el inicio de sesión y la limpieza de datos de sesión.
// CONEXIÓN: Utilizado en LoginView para validar al usuario y en HomeView para el cierre de sesión.
class AuthController {
  // URL base del endpoint de usuarios de FakeStoreAPI.
  static const String _baseUrl = 'https://fakestoreapi.com/users';

  // Cliente HTTP inyectable para realizar solicitudes a la red (facilita pruebas/mocking).
  final http.Client _client;

  // Constructor que asigna un cliente HTTP por defecto si no se proporciona uno.
  AuthController({http.Client? client}) : _client = client ?? http.Client();

  // --------------------------------------------------------------------------
  // US01: INICIO DE SESIÓN
  // --------------------------------------------------------------------------
  // Recibe las credenciales ingresadas por el usuario en LoginView dentro de una instancia de UserModel.
  // Realiza una consulta GET para autenticar las credenciales contra los usuarios del servidor.
  Future<Map<String, dynamic>> login(UserModel user) async {
    try {
      // Pide al servidor la lista de usuarios registrados para verificar datos
      final response = await _client.get(Uri.parse(_baseUrl));

      // Evaluación de respuesta HTTP 200 (Éxito)
      if (response.statusCode == 200) {
        // Convierte el cuerpo JSON en una lista dinámica de usuarios.
        final List<dynamic> usersJson = jsonDecode(response.body);

        // Búsqueda del usuario correspondiente comparando usuario y contraseña.
        final matchedUserJson = usersJson.firstWhere(
          (u) => u['username'] == user.username && u['password'] == user.password,
          orElse: () => null,
        );

        if (matchedUserJson != null) {
          // Instanciamos el modelo para obtener id y rol mediante las reglas del modelo
          final authenticatedUser = UserModel.fromJson(matchedUserJson);

          // Retorna la respuesta con éxito, asignando el rol y el ID procesados para la navegación.
          return {
            'success': true,
            'role': authenticatedUser.role ?? 'Cliente',
            'userId': authenticatedUser.id ?? 0,
            'message': 'Inicio de sesión exitoso',
          };
        } else {
          // Si las credenciales no coinciden con ningún registro de la API.
          return {
            'success': false,
            'message': 'Usuario o contraseña incorrectos',
          };
        }
      } else {
        // En caso de respuesta de error del servidor (404, 500, etc.).
        return {
          'success': false,
          'message': 'Error de conexión con el servidor (Código ${response.statusCode})',
        };
      }
    } catch (e) {
      // Manejo de excepciones de red o fallos de conexión local.
      return {
        'success': false,
        'message': 'Error al conectar con el servidor: $e',
      };
    }
  }

  // --------------------------------------------------------------------------
  // US02: CIERRE DE SESIÓN Y LIMPIEZA DE MEMORIA
  // --------------------------------------------------------------------------
  // Simula la finalización de sesión y eliminación de credenciales locales.
  // CONEXIÓN: Invocado desde el botón de cierre de sesión en HomeView.
  Future<void> logout() async {
    // Simulación de borrado de almacenamiento local o tokens de sesión
    await Future.delayed(const Duration(milliseconds: 200));
  }
}