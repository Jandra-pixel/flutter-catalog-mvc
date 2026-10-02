// views/login_view.dart

// IMPORTACIONES DE LIBRERÍAS Y ARCHIVOS LOCALES
// Importa la librería visual principal de Flutter para componentes Material Design (Scaffold, TextField, Container, etc.).
import 'package:flutter/material.dart';

// CONEXIÓN: Importa el controlador de autenticación que gestiona la lógica de inicio de sesión y peticiones backend/API.
import '../controllers/auth_controller.dart';

// CONEXIÓN: Importa el modelo de usuario para encapsular y estructurar las credenciales (usuario y contraseña).
import '../models/user_model.dart';

// CONEXIÓN: Importa la vista principal (HomeView) hacia donde se navegará cuando el login sea exitoso.
import 'home_view.dart';

// ==========================================
// PANTALLA 1: FORMULARIO DE LOGIN (US01)
// ==========================================
// Clase del widget con estado mutable que representa la pantalla de inicio de sesión.
class LoginView extends StatefulWidget {
  // Constructor constante del widget.
  const LoginView({super.key});

  // Crea y asocia la instancia del estado mutable (_LoginViewState) a este widget.
  @override
  State<LoginView> createState() => _LoginViewState();
}

// CLASE DE ESTADO MUTABLE DE LA VISTA DE LOGIN
// Maneja la interacción del usuario, la captura de credenciales y la navegación post-autenticación.
class _LoginViewState extends State<LoginView> {
  // Controlador para el campo de texto de usuario (captura lo escrito en el input 'Usuario').
  final _usernameController = TextEditingController();

  // Controlador para el campo de texto de contraseña (captura lo escrito en el input 'Contraseña').
  final _passwordController = TextEditingController();

  // Instancia del controlador de autenticación.
  // CONEXIÓN: Se conecta con AuthController en '../controllers/auth_controller.dart'.
  final _authController = AuthController();

  // Flag/Bandera para indicar si la autenticación está en progreso y mostrar la animación de carga.
  bool _cargando = false;

  // Variable de estado que almacena el mensaje de error para mostrarlo en la interfaz en caso de falla.
  String? _errorMessage;

  // MÉTODO ASÍNCRONO _HANDLELOGIN
  // Procesa la validación local de credenciales, invoca al controlador y gestiona la respuesta de login.
  Future<void> _handleLogin() async {
    // Obtiene los textos ingresados recortando espacios en blanco al inicio y final.
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Validar si los campos están vacíos antes de enviar la petición.
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa usuario y contraseña';
      });
      return; // Detiene la ejecución del método.
    }

    // Actualiza la UI para mostrar el spinner de carga y limpiar cualquier mensaje de error anterior.
    setState(() {
      _cargando = true;
      _errorMessage = null;
    });

    try {
      // CONEXIÓN: Instancia el objeto UserModel pasándole el usuario y la contraseña.
      final user = UserModel(username: username, password: password);

      // CONEXIÓN: Pasa el objeto UserModel al método login() de AuthController para validar credenciales.
      final result = await _authController.login(user);

      // Verifica si el widget sigue en el árbol visual antes de realizar cambios de estado o navegación.
      if (!mounted) return;

      // Oculta el spinner de carga.
      setState(() {
        _cargando = false;
      });

      // Evalúa si la respuesta del controlador indica un inicio de sesión exitoso.
      if (result['success'] == true) {
        // CONEXIÓN: Navega hacia la pantalla HomeView y destruye esta pantalla de login en la pila (pushReplacement).
        // Envía el username, el rol ('Administrador' o 'Cliente') y el userId a la pantalla de inicio.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeView(
              username: username,
              role: result['role'],
              userId: result['userId'],
            ),
          ),
        );
      } else {
        // Muestra el mensaje de error devuelto por la respuesta del controlador.
        setState(() {
          _errorMessage = result['message'] ?? 'Error de autenticación';
        });
      }
    } catch (e) {
      // Captura excepciones no controladas durante la conexión.
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _errorMessage = 'Error inesperado al conectar con el servidor';
      });
    }
  }

  // MÉTODO CICLO DE VIDA: DISPOSE
  // Se ejecuta automáticamente al destruir este widget.
  @override
  void dispose() {
    // Libera los controladores de texto de la memoria para evitar memory leaks.
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // MÉTODO BUILD: CONSTRUCCIÓN VISUAL
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior estática.
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      // Centra la tarjeta de login vertical y horizontalmente.
      body: Center(
        // Permite desplazar la pantalla para evitar errores de desbordamiento (overflow) cuando se despliega el teclado.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // Contenedor que da el aspecto de tarjeta flotante al formulario.
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400), // Ancho máximo adaptativo.
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Fondo gris oscuro de la tarjeta.
              borderRadius: BorderRadius.circular(20), // Bordes redondeados.
              boxShadow: const [
                // Sombra morada brillante alrededor del contenedor.
                BoxShadow(
                  color: Color(0x339C27B0),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono de candado superior.
                const Icon(Icons.lock_person, size: 80, color: Color(0xFFE040FB)),
                const SizedBox(height: 24),

                // INPUT 1: Campo de texto para ingresar el usuario.
                TextField(
                  controller: _usernameController, // CONEXIÓN: Asocia el controlador definido arriba.
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),

                // INPUT 2: Campo de texto para ingresar la contraseña.
                TextField(
                  controller: _passwordController, // CONEXIÓN: Asocia el controlador definido arriba.
                  obscureText: true, // Oculta los caracteres ingresados (formato contraseña).
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),

                // MENSAJE DE ERROR CONDICIONAL: Se dibuja únicamente si _errorMessage no es nulo.
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // BOTÓN DE INGRESAR / INDICADOR DE CARGA
                SizedBox(
                  width: double.infinity, // Ocupa todo el ancho horizontal del contenedor.
                  height: 48,
                  // Condicional: si _cargando es true muestra la animación de espera; si no, el botón de ingresar.
                  child: _cargando
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFE040FB)))
                      : ElevatedButton(
                          // CONEXIÓN: Ejecuta el método _handleLogin() al pulsar el botón.
                          onPressed: _handleLogin,
                          child: const Text('INGRESAR', style: TextStyle(fontSize: 16)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}