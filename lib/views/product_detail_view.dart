// views/product_detail_view.dart

// IMPORTACIONES DE LIBRERÍAS Y ARCHIVOS
// Importa componentes visuales de Material Design para Flutter (Scaffold, FutureBuilder, AlertDialog, etc.).
import 'package:flutter/material.dart';

// CONEXIÓN: Importa el controlador para manejar las peticiones de detalle y eliminación de productos.
import '../controllers/product_controller.dart';

// CONEXIÓN: Importa el modelo de datos para mapear la información recibida del producto.
import '../models/product_model.dart';

// CONEXIÓN: Importa la vista del formulario para navegar hacia ella en caso de editar el producto.
import 'product_form_view.dart';

// CLASE PRINCIPAL DEL WIDGET CON ESTADO
// Vista que muestra la información detallada de un producto específico.
class ProductDetailView extends StatefulWidget {
  // Identificador único del producto que se va a consultar.
  final int productId;

  // Rol del usuario actual ('Administrador' o 'Cliente') para condicionales de permisos visuales.
  final String role;

  // Constructor que requiere el ID del producto y el rol del usuario.
  const ProductDetailView({
    super.key,
    required this.productId,
    required this.role,
  });

  // Crea el estado mutable asociado a esta vista.
  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

// CLASE DE ESTADO MUTABLE DE LA VISTA
// Mantiene las referencias asíncronas y el estado local del producto visualizado.
class _ProductDetailViewState extends State<ProductDetailView> {
  // Instancia del controlador de productos.
  // CONEXIÓN: Se conecta con ProductController en '../controllers/product_controller.dart'.
  final _productController = ProductController();

  // Variable de tipo Future que almacenará la promesa del producto obtenido del backend/API.
  late Future<ProductModel> _futureDetail;

  // Variable de estado local para reflejar actualizaciones inmediatas sin hacer un re-fetch a la API.
  ProductModel? _currentProduct;

  // MÉTODO CICLO DE VIDA: INITSTATE
  // Se ejecuta automáticamente al cargar el widget por primera vez.
  @override
  void initState() {
    super.initState();
    // Ejecuta la función para iniciar la carga del detalle del producto.
    _cargarDetalle();
  }

  // MÉTODO _CARGARDETALLE
  // Llama al controlador para solicitar los datos del producto mediante su ID.
  void _cargarDetalle() {
    // CONEXIÓN: Ejecuta fetchProductDetail() dentro de ProductController.
    _futureDetail = _productController.fetchProductDetail(widget.productId);
  }

  // MÉTODO ASÍNCRONO _CONFIRMARELIMINACION (US08)
  // Muestra un diálogo modal de confirmación y procesa la eliminación.
  Future<void> _confirmarEliminacion() async {
    // Muestra un AlertDialog modal solicitando confirmación al usuario (true/false).
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este producto?'),
        actions: [
          // Botón para cancelar la acción.
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // Cierra el diálogo retornando false.
            child: const Text('Cancelar'),
          ),
          // Botón para confirmar la eliminación.
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true), // Cierra el diálogo retornando true.
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    // Si el usuario confirmó la eliminación:
    if (confirmar == true) {
      // CONEXIÓN: Llama a deleteProduct() en ProductController pasando el ID.
      final ok = await _productController.deleteProduct(widget.productId);
      
      // Verifica que el widget continúe activo en el árbol tras la llamada asíncrona.
      if (!mounted) return;

      if (ok) {
        // Notificación de éxito al eliminar.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado exitosamente (Simulación)'),
            backgroundColor: Colors.green,
          ),
        );
        // CONEXIÓN: Cierra esta vista y retorna 'true' al catálogo para indicarle que debe refrescar la lista.
        Navigator.pop(context, true); 
      } else {
        // Notificación de error al eliminar.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo eliminar el producto'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // MÉTODO BUILD: CONSTRUCCIÓN VISUAL
  @override
  Widget build(BuildContext context) {
    // Evalúa si el usuario activo tiene rol de Administrador.
    final esAdmin = widget.role == 'Administrador';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
      ),
      // FutureBuilder gestiona automáticamente los estados de la petición asíncrona (espera, error, éxito).
      body: FutureBuilder<ProductModel>(
        future: _futureDetail, // CONEXIÓN: Escucha la promesa creada en _cargarDetalle().
        builder: (context, snapshot) {
          // ESTADO 1: Cargando datos.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE040FB)),
            );
          }

          // ESTADO 2: Ocurrió un error en la Petición.
          if (snapshot.hasError) {
            return const Center(child: Text('Error al obtener datos del producto.'));
          }

          // ESTADO 3: No se obtuvieron datos.
          if (!snapshot.hasData) {
            return const Center(child: Text('Producto no encontrado.'));
          }

          // ESTADO 4: Éxito. Utiliza el estado local actualizado si existe, o los datos originales devueltos por la API.
          final product = _currentProduct ?? snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del producto sobre un contenedor blanco redondeado.
                Center(
                  child: Container(
                    height: 220,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.network(product.image, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 20),

                // Título del producto.
                Text(
                  product.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),

                // Precio formateado con 2 decimales.
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE040FB)),
                ),
                const SizedBox(height: 12),

                // Descripción del producto.
                Text(product.description, style: const TextStyle(fontSize: 15, height: 1.4)),
                const SizedBox(height: 30),

                // BOTONES DE ACCIÓN: Se muestran únicamente si el usuario es Administrador (US07 & US08)
                if (esAdmin) ...[
                  Row(
                    children: [
                      // BOTÓN EDITAR
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // CONEXIÓN: Navega hacia ProductFormView pasando el rol y el producto a editar.
                            final updated = await Navigator.push<ProductModel>(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => ProductFormView(
                                  role: widget.role,
                                  productToEdit: product,
                                ),
                              ),
                            );

                            // Si se retornó un producto editado desde el formulario, actualiza el estado local.
                            if (updated != null) {
                              setState(() {
                                _currentProduct = updated;
                              });
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('EDITAR'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // BOTÓN ELIMINAR
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          // CONEXIÓN: Ejecuta el diálogo de confirmación de eliminación.
                          onPressed: _confirmarEliminacion,
                          icon: const Icon(Icons.delete),
                          label: const Text('ELIMINAR'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}