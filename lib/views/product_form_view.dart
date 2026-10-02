// views/product_form_view.dart

// IMPORTACIONES
// Importa componentes visuales de Material Design (Scaffold, Form, TextFormField, etc.).
import 'package:flutter/material.dart';

// CONEXIÓN: Importa el controlador que maneja la lógica de negocio para crear o editar productos.
import '../controllers/product_controller.dart';

// CONEXIÓN: Importa el modelo de datos para estructurar las propiedades del objeto producto.
import '../models/product_model.dart';

// CLASE PRINCIPAL DEL WIDGET CON ESTADO
// Vista que representa el formulario de creación o edición de un producto.
class ProductFormView extends StatefulWidget {
  // Variable que almacena el rol del usuario (ej. 'Administrador' o 'Cliente').
  final String role;

  // Variable opcional: Si no es nula, significa que se está editando un producto existente; de lo contrario, es una creación.
  // CONEXIÓN: Utiliza la clase ProductModel importada de '../models/product_model.dart'.
  final ProductModel? productToEdit;

  // Constructor que requiere el rol y permite recibir opcionalmente un producto a editar.
  const ProductFormView({
    super.key,
    required this.role,
    this.productToEdit,
  });

  // Crea el estado mutable asociado a esta vista.
  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

// CLASE DE ESTADO MUTABLE DE LA VISTA
// Mantiene los datos del formulario, controladores de texto y lógica de UI.
class _ProductFormViewState extends State<ProductFormView> {
  // Clave global para identificar, validar y gestionar el estado del Formulario (<Form>).
  final _formKey = GlobalKey<FormState>();

  // Instancia del controlador de productos.
  // CONEXIÓN: Se conecta directamente con ProductController de '../controllers/product_controller.dart'.
  final _productController = ProductController();

  // Declaración de los controladores de texto para capturar lo que el usuario ingresa en los inputs.
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;

  // Categoria asignada por defecto a los productos.
  String _category = 'electronics';

  // Flag que indica si la vista está procesando o guardando la información para mostrar un indicador de carga.
  bool _isLoading = false;

  // MÉTODO CICLO DE VIDA: INITSTATE
  // Se ejecuta automáticamente una sola vez al insertar este widget en el árbol.
  @override
  void initState() {
    super.initState();

    // Inicializa cada TextEditingController. Si se recibió 'productToEdit', precarga sus datos; de lo contrario, asigna texto vacío o valor por defecto.
    _titleController = TextEditingController(text: widget.productToEdit?.title ?? '');
    _priceController = TextEditingController(text: widget.productToEdit?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.productToEdit?.description ?? '');
    _imageController = TextEditingController(text: widget.productToEdit?.image ?? 'https://i.pravatar.cc/300');

    // Si se pasa un producto para editar, sincroniza la categoría existente.
    if (widget.productToEdit != null) {
      _category = widget.productToEdit!.category;
    }

    // Seguridad de UI: Verifica el rol del usuario después de renderizar el primer frame.
    if (widget.role != 'Administrador') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verifica si el widget sigue activo en el árbol antes de realizar acciones en la UI.
        if (!mounted) return;

        // Muestra una barra de notificación flotante (SnackBar) alertando sobre el permiso denegado.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Acceso denegado: Solo el Administrador puede modificar productos'),
            backgroundColor: Colors.redAccent,
          ),
        );

        // CONEXIÓN: Cierra la pantalla actual y regresa a la vista anterior (ej. lista de productos).
        Navigator.pop(context);
      });
    }
  }

  // MÉTODO CICLO DE VIDA: DISPOSE
  // Se ejecuta automáticamente cuando el widget es removido del árbol de widgets.
  @override
  void dispose() {
    // Libera los recursos en memoria consumidos por los controladores de texto para evitar fugas de memoria (memory leaks).
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // MÉTODO ASÍNCRONO _GUARDAR
  // Procesa la validación y el guardado/actualización del producto.
  Future<void> _guardar() async {
    // Ejecuta las funciones validator de todos los TextFormField del formulario. Si alguna falla, cancela el guardado.
    if (!_formKey.currentState!.validate()) return;

    // Activa la bandera de carga para actualizar la interfaz.
    setState(() => _isLoading = true);

    // CONEXIÓN: Delega la lógica de negocio al método saveProduct() de ProductController.
    final result = await _productController.saveProduct(
      productToEdit: widget.productToEdit,
      title: _titleController.text,
      priceText: _priceController.text,
      description: _descriptionController.text,
      image: _imageController.text,
      category: _category,
    );

    // Verifica que el widget continúe montado antes de actualizar la UI tras la petición asíncrona.
    if (!mounted) return;

    // Desactiva el estado de carga.
    setState(() => _isLoading = false);

    // Evalúa si la operación en el controlador fue exitosa.
    if (result['success'] == true) {
      if (result['isEdit'] == true) {
        // US07: Notificación de actualización.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto actualizado (Simulación)'),
            backgroundColor: Colors.green,
          ),
        );

        // CONEXIÓN: Cierra el formulario devolviendo el producto actualizado a la vista que lo invocó.
        Navigator.pop(context, result['product']);
      } else {
        // US06: Notificación de creación.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto creado con éxito (ID simulación: ${result['id']})'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpia los campos del formulario tras crear un nuevo producto.
        _formKey.currentState!.reset();
      }
    } else {
      // Notificación en caso de error retornado por el controlador.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error al procesar la solicitud'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // MÉTODO BUILD: CONSTRUCCIÓN VISUAL
  @override
  Widget build(BuildContext context) {
    // Evalúa si el flujo actual es para edición o creación para cambiar títulos en la UI.
    final esEdicion = widget.productToEdit != null;

    return Scaffold(
      // Barra superior con título dinámico dependiendo de la acción (Editar o Crear).
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      // ScrollView para evitar desbordamiento visual (overflow) al desplegarse el teclado digital.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        // Widget contenedor para validar todos los campos de entrada como un grupo.
        child: Form(
          key: _formKey, // CONEXIÓN: Asocia la clave global _formKey definida arriba.
          child: Column(
            children: [
              // CAMPO 1: Título del producto
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título del producto'),
                // Regla de validación: Comprueba que el texto no esté vacío ni contenga solo espacios.
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un título válido' : null,
              ),
              const SizedBox(height: 12),

              // CAMPO 2: Precio del producto
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true), // Despliega teclado numérico.
                decoration: const InputDecoration(labelText: 'Precio (\$)'),
                // Regla de validación: Verifica que no esté vacío y sea convertible a tipo double.
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa un precio';
                  if (double.tryParse(val) == null) return 'Ingresa un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // CAMPO 3: URL de la Imagen
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'URL Imagen'),
                // Regla de validación: Comprueba que la URL no esté vacía.
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa una URL' : null,
              ),
              const SizedBox(height: 12),

              // CAMPO 4: Descripción del producto
              TextFormField(
                controller: _descriptionController,
                maxLines: 3, // Expande la caja de texto a 3 líneas visibles.
                decoration: const InputDecoration(labelText: 'Descripción'),
                // Regla de validación: Comprueba que no esté vacía.
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la descripción' : null,
              ),
              const SizedBox(height: 20),

              // BOTÓN DE ACCIÓN PRINCIPAL (Guardar / Crear)
              SizedBox(
                width: double.infinity, // Ocupa todo el ancho disponible.
                height: 48,
                child: ElevatedButton(
                  // CONEXIÓN: Deshabilita el botón mientras carga (_isLoading == true); si no, ejecuta el método _guardar.
                  onPressed: _isLoading ? null : _guardar,
                  // Renderiza un indicador de carga circular o el texto correspondiente según el estado.
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR PRODUCTO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}