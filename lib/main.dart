import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Para verificar conexión a internet
import 'dart:io'; // Para manejar excepciones relacionadas con Internet
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Servicios',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserInfoPage(), // Pantalla inicial
    );
  }
}

// Primera pantalla para ingresar los datos del usuario
class UserInfoPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Llave para el formulario
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingrese sus datos'),
      ),
      body: SingleChildScrollView(
        // Para permitir desplazamiento si hay mucho contenido
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/images/cavilo.jpeg', // Ubicación del logo
                    width: 150, // Tamaño de la imagen ajustado
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: 'Correo electrónico'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su correo electrónico';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Número de teléfono',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su número de teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Si el formulario es válido, navega a la segunda pantalla
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceSelectionPage(
                            name: _nameController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Siguiente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Segunda pantalla: Selección de artefacto, servicio y marca
class ServiceSelectionPage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;

  const ServiceSelectionPage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  _ServiceSelectionPageState createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends State<ServiceSelectionPage> {
  final List<String> _devices = ['Terma', 'Cocina', 'Secadora'];
  final List<String> _services = [
    'Visita Técnica',
    'Mantenimiento',
    'Instalación'
  ];
  final List<String> _brands = [
    'Aghaso',
    'Alfano',
    'Aquamaxx',
    'Bosch',
    'Bryant',
    'Calorex',
    'Electec',
    'Rheem',
    'cavilo',
    'otras'
  ];
  String? _selectedDevice;
  String? _selectedService;
  String? _selectedBrand;
  bool _showOtherBrandField = false; // Para mostrar campo de "otras marcas"
  final TextEditingController _otherBrandController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); // Para la descripción opcional

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccione un servicio'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Image.asset(
                  'assets/images/cavilo.jpeg', // Ubicación del logo
                  width: 150, // Tamaño de la imagen ajustado
                  height: 150,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Selecciona un artefacto'),
                items: _devices.map((device) {
                  return DropdownMenuItem<String>(
                    value: device,
                    child: Text(device),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDevice = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione un artefacto' : null,
              ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Selecciona un servicio'),
                items: _services.map((service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedService = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione un servicio' : null,
              ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Selecciona una marca'),
                items: _brands.map((brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedBrand = newValue;
                    _showOtherBrandField = newValue == 'otras';
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione una marca' : null,
              ),
              if (_showOtherBrandField)
                TextFormField(
                  controller: _otherBrandController,
                  decoration:
                      const InputDecoration(labelText: 'Especificar marca'),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Descripción (opcional)'),
                maxLines: 4, // Campo más grande
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedDevice != null &&
                      _selectedService != null &&
                      _selectedBrand != null) {
                    // Aquí se enviarán los datos por correo
                    _sendEmail(widget.name, widget.email, widget.phone);
                  }
                },
                child: const Text('Confirmar y enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendEmail(String name, String email, String phone) async {
    String body = '''
      Nombre: $name
      Correo: $email
      Teléfono: $phone
      Artefacto: $_selectedDevice
      Servicio: $_selectedService
      Marca: $_selectedBrand
      Descripción: ${_descriptionController.text}
    ''';

    // Configuración del servidor SMTP para Gmail con la contraseña de aplicación
    String username = 'appservicio123@gmail.com'; // Tu correo de Gmail
    String password = 'eomxsehhsqeskcrw'; // Tu contraseña de aplicación

    // Servidor SMTP de Gmail
    final smtpServer = gmail(username, password);

    // Verificar la conexión a Internet antes de enviar
    var conectividad = await (Connectivity().checkConnectivity());
    if (conectividad == ConnectivityResult.none) {
      // Si no hay conexión a Internet
      _mostrarResultado(context, 'No hay conexión a Internet');
      return;
    }

    try {
      final message = Message()
        ..from = Address(username, 'App Servicios')
        ..recipients.add('ventas@cavilosac.com') // Destinatario del correo
        ..subject = 'Detalles del servicio solicitado'
        ..text = body;

      final sendReport = await send(message, smtpServer);

      // Si el correo fue enviado con éxito, mostrar mensaje de éxito
      _mostrarResultado(context, 'Correo enviado con éxito');
    } on MailerException catch (e) {
      // Si hubo un error al enviar el correo, mostrar mensaje de error
      _mostrarResultado(context, 'Error al enviar el correo: ${e.message}');
    } on SocketException {
      // Si hubo un problema de conexión
      _mostrarResultado(context, 'Error de conexión. Verifica tu Internet.');
    }
  }

  void _mostrarResultado(BuildContext context, String mensaje) {
    // Navegar a una nueva pantalla que muestra el resultado del envío
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultadoPage(mensaje: mensaje),
      ),
    );
  }
}

// Pantalla para mostrar el resultado del envío
class ResultadoPage extends StatelessWidget {
  final String mensaje;

  const ResultadoPage({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del envío'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                mensaje,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Volver a la pantalla principal
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
