// views/home_view.dart

// IMPORTACIONES DE LIBRERÍAS Y ARCHIVOS LOCALES
// Importa la librería visual principal de Flutter para componentes Material Design (Scaffold, GridView, FutureBuilder, etc.).
import 'package:flutter/material.dart';

// CONEXIÓN: Importa el controlador de autenticación para gestionar el cierre de sesión (logout).
import '../controllers/auth_controller.dart';

// CONEXIÓN: Importa el controlador de productos para solicitar catálogos y categorías a la API/backend.
import '../controllers/product_controller.dart';

// CONEXIÓN: Importa el modelo de productos para tipar fuertemente las listas que provienen del controlador.
import '../models/product_model.dart';

// CONEXIÓN: Importa la vista de inicio de sesión para redirigir al usuario al cerrar sesión.
import 'login_view.dart';

// CONEXIÓN: Importa la vista de detalle para consultar, editar o eliminar un producto específico.
import 'product_detail_view.dart';

// CONEXIÓN: Importa el formulario de productos para la creación de nuevos ítems (exclusivo Administrador).
import 'product_form_view.dart';

// ==========================================================
// PANTALLA 2: CATÁLOGO Y FILTROS POR CATEGORÍA (US03, US04, US02)
// ==========================================================
// Widget con estado mutable que representa la pantalla principal / catálogo de la aplicación.
class HomeView extends StatefulWidget {
  // Propiedades recibidas desde el LoginView tras una autenticación exitosa.
  final String username; // Nombre del usuario autenticado.
  final String role;     // Rol del usuario ('Administrador' o 'Cliente') para control de permisos.
  final int userId;      // Identificador único del usuario en el sistema.

  // Constructor constante que exige los datos de sesión.
  const HomeView({
    super.key,
    required this.username,
    required this.role,
    required this.userId,
  });

  // Crea el estado mutable asociado a este widget.
  @override
  State<HomeView> createState() => _HomeViewState();
}

// CLASE DE ESTADO MUTABLE DE LA VISTA PRINCIPAL
class _HomeViewState extends State<HomeView> {
  // CONEXIÓN: Instancia del controlador que gestiona la carga de productos y categorías desde la API.
  final _productController = ProductController();

  // CONEXIÓN: Instancia del controlador de autenticación para cerrar sesión.
  final _authController = AuthController();

  // Variable de tipo Future que almacenará asíncronamente la lista de productos del catálogo.
  late Future<List<ProductModel>> _futureProducts;

  // Variable de tipo Future que almacenará asíncronamente la lista de categorías disponibles.
  late Future<List<String>> _futureCategories;

  // Guarda la categoría seleccionada por el usuario para filtrar los productos (null = sin filtro/todos).
  String? _categoriaSeleccionada;

  // MÉTODO CICLO DE VIDA: INITSTATE
  // Se ejecuta una sola vez cuando el widget se inserta en el árbol de widgets.
  @override
  void initState() {
    super.initState();
    // CONEXIÓN: Llama al método fetchCategories() de ProductController para obtener la lista de categorías.
    _futureCategories = _productController.fetchCategories();
    // Inicia la carga inicial de productos (sin filtro).
    _cargarProductos();
  }

  // MÉTODO _CARGARPRODUCTOS
  // Asigna el Future de productos correspondiente según si hay una categoría seleccionada o no, refrescando la UI.
  void _cargarProductos() {
    setState(() {
      if (_categoriaSeleccionada == null) {
        // CONEXIÓN: Solicita la lista completa de productos mediante fetchProducts().
        _futureProducts = _productController.fetchProducts();
      } else {
        // CONEXIÓN: Solicita productos filtrados por categoría usando fetchProductsByCategory().
        _futureProducts = _productController.fetchProductsByCategory(_categoriaSeleccionada!);
      }
    });
  }

  // MÉTODO _FILTRARPORCATEGORIA
  // Alterna la selección de categoría: si se toca la misma, se deselecciona; si es otra, se aplica el nuevo filtro.
  void _filtrarPorCategoria(String? categoria) {
    if (_categoriaSeleccionada == categoria) {
      _categoriaSeleccionada = null; // Remueve el filtro.
    } else {
      _categoriaSeleccionada = categoria; // Aplica el nuevo filtro.
    }
    _cargarProductos(); // Vuelve a consultar la API con el nuevo filtro.
  }

  // MÉTODO BUILD: CONSTRUCCIÓN VISUAL
  @override
  Widget build(BuildContext context) {
    // Evalúa si el usuario en sesión posee el rol de Administrador.
    final esAdmin = widget.role == 'Administrador';

    return Scaffold(
      // Barra superior del catálogo.
      appBar: AppBar(
        title: Text('Catálogo (${widget.role})'),
        actions: [
          // Botón de salir / cerrar sesión.
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFE040FB)),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              // CONEXIÓN: Ejecuta logout() en AuthController para limpiar tokens/sesión.
              await _authController.logout();
              if (!mounted) return;

              // CONEXIÓN: Redirige a LoginView eliminando todas las rutas previas de la pila de navegación.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // US06: Botón flotante para crear productos, visible exclusivamente si esAdmin es true.
      floatingActionButton: esAdmin
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFE040FB),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                // CONEXIÓN: Navega al formulario ProductFormView enviando el rol.
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductFormView(role: widget.role),
                  ),
                );
                // Si la pantalla retornos true (producto creado con éxito), recarga la lista de productos.
                if (result == true) {
                  _cargarProductos();
                }
              },
            )
          : null, // Si es Cliente, no renderiza el botón flotante.

      body: Column(
        children: [
          // BARRA SUPERIOR DE FILTRADO POR CATEGORÍAS
          // Utiliza FutureBuilder para construir dinámicamente los chips de categoría según la API.
          FutureBuilder<List<String>>(
            future: _futureCategories,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final categorias = snapshot.data ?? [];
                return Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  // Lista con desplazamiento horizontal para mostrar las categorías en fila.
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      // Chip fijo para la opción 'Todos' (sin filtro).
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: const Text('Todos'),
                          selected: _categoriaSeleccionada == null,
                          onSelected: (_) => _filtrarPorCategoria(null),
                        ),
                      ),
                      // Genera dinámicamente los FilterChip para cada categoría retornada por el servidor.
                      ...categorias.map((cat) {
                        final estaSeleccionada = _categoriaSeleccionada == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(cat.toUpperCase()),
                            selected: estaSeleccionada,
                            onSelected: (_) => _filtrarPorCategoria(cat),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }
              // Oculta el contenedor mientras se cargan las categorías o si ocurre un error silencioso.
              return const SizedBox.shrink();
            },
          ),

          // CUADRÍCULA DE PRODUCTOS (CATÁLOGO)
          // Utiliza FutureBuilder para gestionar la carga asíncrona de los productos.
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                // Estado 1: Esperando respuesta del servidor (Muestra indicador de carga).
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE040FB)));
                }

                // Estado 2: Error de conexión o fallo en la petición API.
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 60, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        const Text('Error al cargar productos desde el servidor'),
                        const SizedBox(height: 16),
                        // Botón para reintentar la solicitud al servidor.
                        ElevatedButton.icon(
                          onPressed: _cargarProductos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                // Estado 3: Lista de productos vacía.
                if (products.isEmpty) {
                  return const Center(child: Text('No hay productos disponibles.'));
                }

                // Estado 4: Carga exitosa (Renderiza la cuadrícula de productos en 2 columnas).
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,     // 2 columnas horizontales.
                    childAspectRatio: 0.7,  // Relación de aspecto alto/ancho de cada tarjeta.
                    crossAxisSpacing: 12,  // Espacio horizontal entre tarjetas.
                    mainAxisSpacing: 12,   // Espacio vertical entre tarjetas.
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index]; // CONEXIÓN: Instancia del modelo ProductModel.

                    // Detecta el toque en la tarjeta para abrir el detalle.
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        // CONEXIÓN: Abre ProductDetailView enviando el ID del producto y el rol del usuario.
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailView(
                              productId: product.id,
                              role: widget.role,
                            ),
                          ),
                        );
                        // Si en la vista de detalle se modificó o eliminó el producto, actualiza el catálogo.
                        if (result == true) {
                          _cargarProductos();
                        }
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Contenedor que alberga la imagen remota del producto.
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    // Carga la imagen desde la URL remota especificada en la propiedad 'image' del modelo.
                                    child: Image.network(
                                      product.image,
                                      fit: BoxFit.contain,
                                      // Muestra un ícono alternativo en caso de error al descargar la imagen.
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Título del producto (limitado a 2 líneas).
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Precio formateado a dos decimales.
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFE040FB),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}