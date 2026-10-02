// main.dart

// IMPORTACIÓN DE LIBRERÍAS Y ARCHIVOS
// Importa la librería base de Material Design para componentes gráficos de Flutter (botones, barras, temas, etc.).
import 'package:flutter/material.dart';

// Importa el archivo local de la vista de login. 
// CONEXIÓN: Se conecta con 'views/login_view.dart' para poder usar la pantalla LoginView() como inicio.
import 'views/login_view.dart';

// PUNTO DE ENTRADA PRINCIPAL
// La función main() es lo primero que ejecuta la aplicación al iniciar.
void main() {
  // runApp() toma el widget raíz y lo renderiza en la pantalla del dispositivo.
  // CONEXIÓN: Se conecta e inicializa la clase MyApp.
  runApp(const MyApp());
}

// CLASE RAÍZ DE LA APLICACIÓN
// Define la configuración global de la aplicación.
// Extiende de StatelessWidget porque su estado interno no cambia dinámicamente.
class MyApp extends StatelessWidget {
  // Constructor de MyApp. 
  // Recibe la clave (key) opcional para el control del árbol de widgets en la clase padre.
  const MyApp({super.key});

  // MÉTODO BUILD
  // Sobrescribe el método build para construir la interfaz de usuario de este widget.
  @override
  Widget build(BuildContext context) {
    // Retorna MaterialApp, el contenedor principal que gestiona el tema, navegación y título de la app.
    return MaterialApp(
      // Título de la aplicación para el sistema operativo.
      title: 'Catálogo de Productos',
      
      // Desactiva la etiqueta/cinta de "DEBUG" en la esquina superior derecha.
      debugShowCheckedModeBanner: false,
      
      // CONFIGURACIÓN DEL TEMA VISUAL (ThemeData)
      // Parte del tema oscuro estándar (.dark()) y sobrescribe valores con .copyWith().
      theme: ThemeData.dark().copyWith(
        // Define el color de fondo general de las pantallas (Scaffold) en gris muy oscuro.
        scaffoldBackgroundColor: const Color(0xFF121212),
        
        // Define el color primario general de la aplicación (Magenta/Púrpura).
        primaryColor: const Color(0xFFE040FB),
        
        // Configura el estilo global para las barras superiores (AppBar).
        appBarTheme: const AppBarTheme(
          // Color de fondo de las barras superiores.
          backgroundColor: Color(0xFF1E1E1E),
          // Elimina la sombra bajo la barra (estilo plano).
          elevation: 0,
          // Centra el texto del título en la AppBar.
          centerTitle: true,
        ),
        
        // Esquema de colores para componentes de Material Design (botones, campos de texto, etc.).
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE040FB),   // Color primario interactivo.
          secondary: Color(0xFFE040FB), // Color secundario interactivo.
        ),
      ),
      
      // PANTALLA INICIAL DE LA APP
      // CONEXIÓN: Se conecta con el widget LoginView de 'views/login_view.dart' 
      // indicándole a Flutter que esta será la primera pantalla en mostrarse.
      home: const LoginView(),
    );
  }
}