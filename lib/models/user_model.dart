// models/user_model.dart

// ============================================================================
// MODELO DE DATOS: USUARIO (USERMODEL)
// ============================================================================
// Representa la estructura de datos para la autenticación y gestión del usuario.
// Se conecta directamente con AuthController (para el manejo de credenciales y sesión)
// y con LoginView/HomeView (para propagar los datos de sesión y permisos de usuario).
class UserModel {
  // PROPIEDADES DEL MODELO
  
  // Identificador único del usuario (opcional al hacer login, asignado por la API al autenticar).
  final int? id;

  // Nombre de usuario ingresado en la pantalla de inicio de sesión (obligatorio).
  final String username;

  // Contraseña del usuario (obligatoria).
  final String password;

  // Rol de permisos dentro de la aplicación ('Administrador', 'Auditor', 'Cliente') (opcional).
  final String? role;

  // CONSTRUCTOR PRINCIPAL
  // Permite instanciar objetos inmutables de tipo UserModel.
  const UserModel({
    this.id,
    required this.username,
    required this.password,
    this.role,
  });

  // MÉTODO TOJSON
  // Convierte el objeto UserModel en un Map<String, dynamic> para ser serializado a JSON y enviado en peticiones HTTP al servidor (API).
  // CONEXIÓN: Utilizado en AuthController.login() al enviar credenciales mediante POST.
  Map<String, dynamic> toJson({bool includeAll = false}) {
    // Si includeAll es true, serializa el objeto completo con todas sus propiedades (incluyendo ID y rol).
    if (includeAll) {
      return {
        'id': id,
        'username': username,
        'password': password,
        'role': role,
      };
    }
    // Por defecto, serializa solo las credenciales necesarias para iniciar sesión (Login).
    return {
      'username': username,
      'password': password,
    };
  }

  // CONSTRUCTOR DE FÁBRICA FROMJSON
  // Construye una instancia de UserModel a partir de la respuesta JSON parseada entregada por el backend.
  // CONEXIÓN: Invocado en AuthController para deserializar la respuesta del servidor tras autenticar al usuario.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parseo seguro del id evitando excepciones de tipo cuando el JSON devuelve cadenas numéricas o enteros.
    final rawId = json['id'];
    final int? userId = rawId is int
        ? rawId
        : (rawId != null ? int.tryParse(rawId.toString()) : null);

    return UserModel(
      id: userId,
      // Extrae el usuario o asigna una cadena vacía en caso de valores nulos.
      username: json['username']?.toString() ?? '',
      // Extrae la contraseña o asigna una cadena vacía en caso de valores nulos.
      password: json['password']?.toString() ?? '',
      // Extrae el rol recibido o determina automáticamente uno según el ID mediante la lógica estática interna.
      role: json['role']?.toString() ?? (userId != null ? determinarRol(userId) : null),
    );
  }

  // MÉTODO ESTÁTICO DETERMINARROL
  // Asigna automáticamente un rol según el ID del usuario en caso de que la respuesta del backend no devuelva el campo 'role'.
  // CONEXIÓN: Define el nivel de acceso utilizado en HomeView y ProductDetailView/ProductFormView (ej. esAdmin).
  static String determinarRol(int userId) {
    if (userId == 1 || userId == 2) {
      return 'Administrador'; // Otorga permisos de creación, edición y eliminación de productos.
    } else if (userId == 3) {
      return 'Auditor';       // Permiso especial de solo lectura / monitoreo.
    } else {
      return 'Cliente';       // Usuario estándar, solo navegación y consulta en el catálogo.
    }
  }

  // MÉTODO COPYWITH
  // Facilita la inmutabilidad creando una copia modificada de la instancia actual del usuario.
  // Permite actualizar campos específicos (como asignar un rol o un ID) sin alterar las demás propiedades.
  UserModel copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  // SOBRESCRITURA DEL OPERADOR DE IGUALDAD (==)
  // Permite comparar dos instancias distintas de UserModel evaluando el contenido de sus propiedades en lugar de sus referencias de memoria.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Si es exactamente la misma instancia en memoria.
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.password == password &&
        other.role == role;
  }

  // SOBRESCRITURA DEL HASHCODE
  // Genera un código hash único basado en el contenido de sus propiedades para comparaciones eficientes en colecciones (Sets, Maps).
  @override
  int get hashCode =>
      id.hashCode ^ username.hashCode ^ password.hashCode ^ role.hashCode;

  // SOBRESCRITURA DE TOSTRING
  // Retorna una representación legible en texto del usuario para depuración (logs) en la consola durante el desarrollo.
  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, role: $role)';
  }
}