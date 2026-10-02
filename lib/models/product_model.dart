// models/product_model.dart

// ============================================================================
// MODELO DE DATOS: PRODUCTO (PRODUCTMODEL)
// ============================================================================
// MODELO (Model):
// Define la estructura de datos del producto. Incluye ID, Título, Precio,
// Imagen, Descripción y Categoría para soportar el catálogo y el detalle.
// CONEXIÓN: Se relaciona con ProductController para mapear peticiones HTTP (GET, POST, PUT),
// con HomeView (para pintar tarjetas del catálogo) y con ProductDetailView/ProductFormView.
class ProductModel {
  // PROPIEDADES DEL MODELO
  
  // Número identificador único del producto (clave primaria devuelta por la API).
  final int id; 

  // Nombre o título del producto desplegado en el catálogo y detalle.
  final String title; 

  // Precio del producto expresado con punto flotante / decimales.
  final double price; 

  // Enlace de internet (URL) hacia la foto o imagen remota del producto.
  final String image; 

  // Texto largo con la información o especificaciones detalladas del producto.
  final String description; 

  // Tipo o categoría a la que pertenece el producto (usada para filtros en HomeView).
  final String category; 

  // CONSTRUCTOR INMUTABLE
  // Define los parámetros requeridos para instanciar objetos inmutables de tipo ProductModel.
  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
  });

  // CONSTRUCTOR DE FÁBRICA FROMJSON
  // Convierte la respuesta en formato JSON de la API en un objeto ProductModel.
  // CONEXIÓN: Invocado en ProductController para transformar respuestas HTTP en modelos fuertemente tipados.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parseo seguro del id para evitar fallos de tipo si el servidor devuelve enteros o cadenas numéricas.
    final rawId = json['id'];
    final int parsedId = rawId is int
        ? rawId
        : (rawId != null ? int.tryParse(rawId.toString()) ?? 0 : 0);

    return ProductModel(
      id: parsedId,
      // Extrae el título o asigna cadena vacía por defecto.
      title: json['title']?.toString() ?? '',
      // Conversión segura de valores numéricos (int/double) a double.
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      // Extrae la URL de la imagen o asigna cadena vacía.
      image: json['image']?.toString() ?? '',
      // Asigna la descripción recibida o un texto por defecto en caso de nulos.
      description: json['description']?.toString() ?? 'Sin descripción disponible.',
      // Asigna la categoría o la define como 'General' si el campo viene nulo.
      category: json['category']?.toString() ?? 'General',
    );
  }

  // MÉTODO TOJSON
  // Convierte el objeto en un mapa JSON para enviar al servidor (Crear / Editar).
  // CONEXIÓN: Utilizado en ProductController dentro de las operaciones POST (crear) y PUT (actualizar) en la API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'image': image,
      'description': description,
      'category': category,
    };
  }

  // MÉTODO COPYWITH
  // Método copyWith para crear copias modificadas del modelo preservando la inmutabilidad de la clase.
  // Permite clonar un producto alterando solo los atributos deseados sin modificar los demás.
  ProductModel copyWith({
    int? id,
    String? title,
    double? price,
    String? image,
    String? description,
    String? category,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  // SOBRESCRITURA DEL OPERADOR DE IGUALDAD (==)
  // Compara el contenido de los atributos de dos instancias de ProductModel para evaluar su equivalencia.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Comprueba si apuntan a la misma dirección en memoria.
    return other is ProductModel &&
        other.id == id &&
        other.title == title &&
        other.price == price &&
        other.image == image &&
        other.description == description &&
        other.category == category;
  }

  // SOBRESCRITURA DEL HASHCODE
  // Genera un código hash combinando las propiedades para su correcto funcionamiento en mapas o conjuntos.
  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      price.hashCode ^
      image.hashCode ^
      description.hashCode ^
      category.hashCode;

  // SOBRESCRITURA DE TOSTRING
  // Ofrece una representación corta y legible en consola para simplificar la depuración (logging).
  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, price: $price, category: $category)';
  }
}