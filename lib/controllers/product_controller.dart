// controllers/product_controller.dart

// IMPORTACIONES DE LIBRERÍAS Y MODELOS
// Permite convertir datos entre objetos nativos de Dart y representaciones JSON (jsonDecode, jsonEncode).
import 'dart:convert';

// Cliente HTTP para realizar peticiones REST (GET, POST, PUT, DELETE) hacia el servicio backend.
import 'package:http/http.dart' as http;

// CONEXIÓN: Importa el modelo ProductModel para mapear y estructurar la información de productos.
import '../models/product_model.dart';

// ============================================================================
// CONTROLADOR: PRODUCTOS (PRODUCTCONTROLLER)
// ============================================================================
// Gestiona las operaciones de negocio del catálogo de productos y la comunicación
// con la API externa (FakeStoreAPI). Implementa las Historias de Usuario US03 a US08.
class ProductController {
  // Dirección URL base del endpoint de productos de la API.
  static const String _baseUrl = 'https://fakestoreapi.com/products';

  // Instancia del cliente HTTP utilizada para ejecutar las peticiones de red.
  final http.Client _client;

  // Constructor que admite inyección de dependencias (útil para pruebas unitarias/mocking).
  ProductController({http.Client? client}) : _client = client ?? http.Client();

  // --------------------------------------------------------------------------
  // US03: OBTENER PRODUCTOS (GET)
  // --------------------------------------------------------------------------
  // Obtiene el catálogo completo de productos desde la API.
  // CONEXIÓN: Invocado por HomeView para renderizar la cuadrícula de productos.
  Future<List<ProductModel>> fetchProducts() async {
    try {
      // Petición GET a la URL base.
      final response = await _client.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        // Deserializa la lista JSON devuelta por el servidor.
        final List<dynamic> data = jsonDecode(response.body);
        // Convierte cada elemento JSON a una instancia de ProductModel.
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar los productos (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Fallo de conexión al cargar productos: $e');
    }
  }

  // --------------------------------------------------------------------------
  // US04: OBTENER CATEGORÍAS (GET)
  // --------------------------------------------------------------------------
  // Obtiene la lista de nombres de categorías disponibles desde la API.
  // CONEXIÓN: Invocado en HomeView para generar los FilterChip de navegación.
  Future<List<String>> fetchCategories() async {
    try {
      // Petición GET al endpoint /categories.
      final response = await _client.get(Uri.parse('$_baseUrl/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Convierte la lista dinámica a una lista de cadenas de texto.
        return data.map((item) => item.toString()).toList();
      } else {
        throw Exception('Error al cargar las categorías (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Fallo de conexión al obtener categorías: $e');
    }
  }

  // --------------------------------------------------------------------------
  // US04: OBTENER PRODUCTOS POR CATEGORÍA (GET)
  // --------------------------------------------------------------------------
  // Consulta la API para obtener únicamente los productos pertenecientes a una categoría.
  // CONEXIÓN: Invocado en HomeView cuando un usuario selecciona un filtro de categoría.
  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    try {
      // Codifica caracteres especiales de la categoría para una URL válida.
      final encodedCategory = Uri.encodeComponent(category);
      final response = await _client.get(Uri.parse('$_baseUrl/category/$encodedCategory'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos de la categoría');
      }
    } catch (e) {
      throw Exception('Fallo de conexión al filtrar productos: $e');
    }
  }

  // --------------------------------------------------------------------------
  // LÓGICA DE NEGOCIO (MVC): SELECCIÓN DE FILTROS
  // --------------------------------------------------------------------------
  // Lógica de negocio para calcular el nuevo estado de la categoría seleccionada.
  String? filtrarPorCategoria(String? categoriaActual, String? nuevaCategoria) {
    if (categoriaActual == nuevaCategoria) {
      return null; // Si hace clic en la misma categoría, quita el filtro.
    }
    return nuevaCategoria; // Aplica la nueva categoría como filtro activo.
  }

  // --------------------------------------------------------------------------
  // US05: DETALLE DE PRODUCTO (GET)
  // --------------------------------------------------------------------------
  // Recupera un producto específico mediante su ID.
  // CONEXIÓN: Invocado por ProductDetailView para cargar la información completa de un ítem.
  Future<ProductModel> fetchProductDetail(int id) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Mapea la respuesta a una instancia de ProductModel.
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Producto no disponible');
      }
    } catch (e) {
      throw Exception('Fallo de conexión al obtener detalle del producto: $e');
    }
  }

  // --------------------------------------------------------------------------
  // US06: CREAR NUEVO PRODUCTO (POST)
  // --------------------------------------------------------------------------
  // Envía un nuevo objeto de producto en formato JSON a la API.
  // CONEXIÓN: Utilizado internamente por saveProduct() cuando se registra un producto.
  Future<Map<String, dynamic>> createProduct(ProductModel product) async {
    try {
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      // Si el servidor responde 200 (OK) o 201 (Created).
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'id': data['id']};
      } else {
        return {'success': false, 'message': 'Error al crear producto en el servidor'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de red al crear el producto'};
    }
  }

  // --------------------------------------------------------------------------
  // US07: EDITAR PRODUCTO EXISTENTE (PUT)
  // --------------------------------------------------------------------------
  // Actualiza los datos de un producto en el servidor haciendo uso del método HTTP PUT.
  // CONEXIÓN: Utilizado internamente por saveProduct() durante el flujo de edición.
  Future<bool> updateProduct(ProductModel product) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // US08: ELIMINAR PRODUCTO (DELETE)
  // --------------------------------------------------------------------------
  // Solicita la eliminación de un producto según su ID en la API.
  // CONEXIÓN: Invocado en ProductDetailView al confirmar la eliminación (exclusivo Administrador).
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _client.delete(Uri.parse('$_baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // LÓGICA DE NEGOCIO (MVC): PROCESAMIENTO Y GUARDADO
  // --------------------------------------------------------------------------
  // Lógica de negocio MVC: Construye el objeto y procesa si es creación (US06) o edición (US07).
  // CONEXIÓN: Método invocado desde ProductFormView para abstraer las validaciones y peticiones al backend.
  Future<Map<String, dynamic>> saveProduct({
    ProductModel? productToEdit,
    required String title,
    required String priceText,
    required String description,
    required String image,
    required String category,
  }) async {
    // Convierte el texto recibido del formulario en un valor numérico decimal seguro.
    final price = double.tryParse(priceText.trim()) ?? 0.0;

    // Crea el objeto ProductModel con los datos limpios y formateados.
    final product = ProductModel(
      id: productToEdit?.id ?? 0,
      title: title.trim(),
      price: price,
      description: description.trim(),
      image: image.trim(),
      category: category,
    );

    // Si productToEdit es nulo, procede a ejecutar la creación (US06).
    if (productToEdit == null) {
      final result = await createProduct(product);
      return {
        'isEdit': false,
        'success': result['success'] ?? false,
        'id': result['id'],
        'product': product,
        'message': result['message'],
      };
    } else {
      // Si productToEdit contiene datos, procede a ejecutar la edición (US07).
      final ok = await updateProduct(product);
      return {
        'isEdit': true,
        'success': ok,
        'product': product,
      };
    }
  }
}