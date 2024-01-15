import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_carros/bd/base_de_datos.dart';
import 'package:proyecto_carros/bloc/bloc.dart';
import 'package:proyecto_carros/bloc/bloc_gastos.dart';
import 'package:proyecto_carros/pagina_admin.dart';

void main() async {
  MiBaseDatos bdManejador = MiBaseDatos();
  await bdManejador.initDatabase();

  final carroBloc = CarroBloc(bd: bdManejador);
  final gastosBloc = GastosBloc(bd: bdManejador);

  runApp(MainApp(
    carroBloc: carroBloc,
    gastosBloc: gastosBloc,
  ));
}

class MainApp extends StatelessWidget {
  final CarroBloc carroBloc;
  final GastosBloc gastosBloc;

  const MainApp({super.key, required this.carroBloc, required this.gastosBloc});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            ' Pantalla Principal',
          ),
          backgroundColor: const Color(0xFFF7DB4C),
        ),
        backgroundColor: const Color(0xFF18191D),
        body: Center(
          child: PantallaPrincipal(
            carroBloc: carroBloc,
            gastosBloc: gastosBloc,
          ),
        ),
      ),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  final CarroBloc carroBloc;
  final GastosBloc gastosBloc;

  const PantallaPrincipal(
      {super.key, required this.carroBloc, required this.gastosBloc});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  TextEditingController controladorTCarro = TextEditingController();
  bool tipoDeCarroAgregarPresionado = false;
  TextEditingController controladorModelo = TextEditingController();
  TextEditingController controladorMatricula = TextEditingController();
  TextEditingController controladorFecha = TextEditingController();
  int? carroSeleccionado;
  bool carroYaSeleccionado = false;
  List<Map<String, dynamic>> lista = [];
  TextEditingController controladorFiltrarMatricula = TextEditingController();
  TextEditingController controladorFiltrarTCarro = TextEditingController();
  TextEditingController controladorFiltrarModelo = TextEditingController();
  String filtroSeleccionado = '';
  List<String> opcionesFiltrado = [
    'Sin filtro',
    'Tipo de carro y/o modelo',
    'Matrícula'
  ];
  bool mostrarTextFieldFiltroMatricula = false;
  bool mostrarTextFieldFiltroTYM = false;
  List<String> tiposDeCarro = [];
  String tipoDeCarroFiltrado = '';

  @override
  void dispose() {
    controladorTCarro.dispose();
    controladorModelo.dispose();
    controladorMatricula.dispose();
    controladorFecha.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = opcionesFiltrado.first;
    obtenerTiposDeCarroDesdeBD();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF18191D),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    dialogAgregar(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD4FF),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Visibility(
                  visible: false,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (carroSeleccionado != null) {
                        var carroSeleccionadoMap = lista.firstWhere(
                            (carro) => carro['ID'] == carroSeleccionado);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaginaAdmin(
                              carroSeleccionado: carroSeleccionadoMap,
                              carroBloc: widget.carroBloc,
                              gastosBloc: widget.gastosBloc,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF00AFE6),
                            content: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    'No se ha seleccionado ningún carro para gestionarlo.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DD4FF),
                    ),
                    icon: const Icon(
                      Icons.list_alt,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Gestionar carro',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Visibility(
                  visible: carroYaSeleccionado,
                  child: ElevatedButton(
                    onPressed: () {
                      if (carroSeleccionado != null) {
                        dialogConfirmacionEliminacion(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF00AFE6),
                            content: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    'No se ha seleccionado ningún carro para eliminar.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DD4FF),
                    ),
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right:8.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        Text('Eliminar carro',style: TextStyle(color: Colors.white),)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: const Color(0xFF18191D),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child:
                    Text('Filtrar por:', style: TextStyle(color: Colors.white)),
              ),
              DropdownButton<String>(
                value: filtroSeleccionado,
                onChanged: (String? newValue) {
                  setState(() {
                    filtroSeleccionado = newValue!;
                    mostrarTextFieldFiltroTYM =
                        filtroSeleccionado == 'Tipo de carro y/o modelo';
                    mostrarTextFieldFiltroMatricula =
                        filtroSeleccionado == 'Matrícula';
                    if (!mostrarTextFieldFiltroMatricula) {
                      widget.carroBloc.add(ActualizarCarrosEvent());
                      controladorFiltrarMatricula.clear();
                    }
                    if (!mostrarTextFieldFiltroTYM) {
                      widget.carroBloc.add(ActualizarCarrosEvent());
                      controladorFiltrarTCarro.clear();
                      controladorFiltrarModelo.clear();
                    }
                  });
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                iconSize: 24,
                underline: Container(height: 2, color: const Color(0xFF00AFE6)),
                dropdownColor: const Color(0xFF00AFE6),
                borderRadius: BorderRadius.circular(30),
                items: opcionesFiltrado
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Container(
          width: 380,
          color: const Color(0xFF18191D),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Visibility(
                    visible: mostrarTextFieldFiltroMatricula,
                    child: SizedBox(
                        width: 200.0,
                        child: TextField(
                          controller: controladorFiltrarMatricula,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.white),
                          inputFormatters: [
                            UpperCaseTextFormatter()
                          ],
                          decoration: InputDecoration(
                            labelText: 'Matrícula',
                            labelStyle:
                                const TextStyle(color: Color(0xFFF7DB4C)),
                            hintText: 'Ingrese la matrícula',
                            hintStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF00AFE6), width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            prefixIcon: const Icon(
                                Icons.indeterminate_check_box,
                                color: Color(0xFFF7DB4C)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                widget.carroBloc.add(ActualizarCarrosEvent());
                                controladorFiltrarMatricula.clear();
                              },
                            ),
                          ),
                          onChanged: (matricula) {
                            if (filtroSeleccionado == 'Matrícula') {
                              filtrarListaPorMatricula(matricula);
                            }
                          },
                        )),
                  ),
                  Visibility(
                    visible: mostrarTextFieldFiltroTYM,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          width: 200.0,
                          child: TextField(
                            controller: controladorFiltrarTCarro,
                            readOnly: true,
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Tipo de\n carro',
                              labelStyle:
                                  const TextStyle(color: Color(0xFFF7DB4C)),
                              hintText: 'Ingrese el tipo de carro',
                              hintStyle: const TextStyle(color: Colors.grey),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xFF00AFE6), width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              prefixIcon: const Icon(Icons.directions_car,
                                  color: Color(0xFFF7DB4C)),
                              suffixIcon: IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  controladorFiltrarTCarro.clear();
                                  if (controladorFiltrarModelo.text.isEmpty) {
                                    widget.carroBloc
                                        .add(ActualizarCarrosEvent());
                                  } else {
                                    filtrarListaPorModelo(
                                        controladorFiltrarModelo.text);
                                  }
                                },
                              ),
                            ),
                            onChanged: (tipoDeCarro) {
                              if (filtroSeleccionado ==
                                  'Tipo de carro y/o modelo') {
                                filtrarListaPorTCarroYModelo(
                                    tipoDeCarro, controladorFiltrarModelo.text);
                              }
                            },
                            onTap: () {
                              showDropdownMenuTCarros();
                            },
                          )),
                    ),
                  ),
                  Visibility(
                    visible: mostrarTextFieldFiltroTYM,
                    child: SizedBox(
                        width: 200.0,
                        child: TextField(
                          controller: controladorFiltrarModelo,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Modelo',
                            labelStyle:
                                const TextStyle(color: Color(0xFFF7DB4C)),
                            hintText: 'Ingrese Modelo',
                            hintStyle: const TextStyle(color: Colors.grey),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF00AFE6), width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            prefixIcon: const Icon(Icons.event_repeat,
                                color: Color(0xFFF7DB4C)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                controladorFiltrarModelo.clear();
                                if (controladorFiltrarTCarro.text.isEmpty) {
                                  widget.carroBloc.add(ActualizarCarrosEvent());
                                } else {
                                  filtrarListaPorTCarro(
                                      controladorFiltrarTCarro.text);
                                }
                              },
                            ),
                          ),
                          onChanged: (modelo) {
                            if (filtroSeleccionado ==
                                'Tipo de carro y/o modelo') {
                              filtrarListaPorTCarroYModelo(
                                  controladorFiltrarTCarro.text, modelo);
                            }
                          },
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Row(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Carros Registrados',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            )
          ],
        ),
        Expanded(
          child: BlocBuilder<CarroBloc, CarroState>(
            bloc: widget.carroBloc,
            builder: (context, state) {
              if (state is LoadedState) {
                lista = state.listaCarros;
                if (lista.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay carros registrados.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      var carro = lista[index];
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF7DB4C)),
                            borderRadius: BorderRadius.circular(20),
                            color: carroSeleccionado == carro['ID']
                                ? const Color(0xFF00AFE6)
                                : null,
                          ),
                          child: ListTile(
                            title: Text(
                                'Tipo de Carro: ${carro['Tipo de Carro']}\nModelo: ${carro['Modelo']}\nMatricula: ${carro['Matricula']}\nGasto Total: \$${carro['Gasto Total']}\nFecha de Registro: ${carro['Fecha de Registro']}'),
                            textColor: Colors.white,
                            onTap: () {
                              setState(() {
                                if (carroSeleccionado == carro['ID']) {
                                  carroSeleccionado = null;
                                  carroYaSeleccionado = false;
                                } else {
                                  carroSeleccionado = carro['ID'];
                                  carroYaSeleccionado = true;
                                }
                              });
                            },
                            onLongPress: (){
                              setState(() {
                                if (carroSeleccionado == carro['ID']) {
                                  carroSeleccionado = null;
                                  carroYaSeleccionado = false;
                                } else {
                                  carroSeleccionado = carro['ID'];
                                  carroYaSeleccionado = true;
                                }
                              });
                              if (carroSeleccionado != null) {
                        var carroSeleccionadoMap = lista.firstWhere(
                            (carro) => carro['ID'] == carroSeleccionado);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaginaAdmin(
                              carroSeleccionado: carroSeleccionadoMap,
                              carroBloc: widget.carroBloc,
                              gastosBloc: widget.gastosBloc,
                            ),
                          ),
                        );
                      }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              } else if (state is UpdateState) {
                lista = state.listaCarrosActualizada;
                if (lista.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay carros registrados.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      var carro = lista[index];
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF7DB4C)),
                            borderRadius: BorderRadius.circular(20),
                            color: carroSeleccionado == carro['ID']
                                ? const Color(0xFF00AFE6)
                                : null,
                          ),
                          child: ListTile(
                            title: Text(
                                'Tipo de Carro: ${carro['Tipo de Carro']}\nModelo: ${carro['Modelo']}\nMatricula: ${carro['Matricula']}\nGasto Total: \$${carro['Gasto Total']}\nFecha de Registro: ${carro['Fecha de Registro']}'),
                            textColor: Colors.white,
                            onTap: () {
                              setState(() {
                                if (carroSeleccionado == carro['ID']) {
                                  carroSeleccionado = null;
                                  carroYaSeleccionado = false;
                                } else {
                                  carroSeleccionado = carro['ID'];
                                  carroYaSeleccionado = true;
                                }
                              });
                            },
                            onLongPress: (){
                              setState(() {
                                if (carroSeleccionado == carro['ID']) {
                                  carroSeleccionado = null;
                                  carroYaSeleccionado = false;
                                } else {
                                  carroSeleccionado = carro['ID'];
                                  carroYaSeleccionado = true;
                                }
                              });
                              if (carroSeleccionado != null) {
                        var carroSeleccionadoMap = lista.firstWhere(
                            (carro) => carro['ID'] == carroSeleccionado);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaginaAdmin(
                              carroSeleccionado: carroSeleccionadoMap,
                              carroBloc: widget.carroBloc,
                              gastosBloc: widget.gastosBloc,
                            ),
                          ),
                        );
                      }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              } else if (state is LoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ErrorState) {
                return Center(
                  child: Text('Error: ${state.error}'),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        )
      ],
    );
  }

  Future<void> seleccionaFecha(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF00AFE6),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00AFE6),
              secondary: Colors.white,
              onSecondary: Colors.white,
              onPrimary: Colors.white,
              surface: Color(0xFF18191D),
              onSurface: Colors.white,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        controladorFecha.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> dialogConfirmacionEliminacion(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminacion',
              style: TextStyle(
                color: Colors.white,
              )),
          backgroundColor: const Color(0xFF18191D),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            side: BorderSide(color: Color(0xFF00AFE6)),
          ),
          content:
              const Text('¿Estás seguro de que quieres eliminar este carro?',
                  style: TextStyle(
                    color: Colors.white,
                  )),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              onPressed: () {
                borrarCarroSeleccionado();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void dialogAgregar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Carro',
              style: TextStyle(
                color: Colors.white,
              )),
          backgroundColor: const Color(0xFF18191D),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            side: BorderSide(color: Color(0xFF00AFE6)),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorTCarro,
                    readOnly: true,
                    cursorColor: const Color(0xFF00AFE6),
                    style: const TextStyle(color: Colors.white),
                    maxLength: 50,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Tipo de Carro',
                      labelStyle: const TextStyle(color: Color(0xFFF7DB4C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFFF7DB4C)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                    ),
                    onTap: () {
                      tipoDeCarroAgregarPresionado = true;
                      showDropdownMenuTCarros();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorModelo,
                    cursorColor: const Color(0xFF00AFE6),
                    style: const TextStyle(color: Colors.white),
                    maxLength: 50,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Modelo',
                      labelStyle: const TextStyle(color: Color(0xFFF7DB4C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFFF7DB4C)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorMatricula,
                    cursorColor: const Color(0xFF00AFE6),
                    style: const TextStyle(color: Colors.white),
                    maxLength: 10,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      UpperCaseTextFormatter()],
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Matricula',
                      labelStyle: const TextStyle(color: Color(0xFFF7DB4C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFFF7DB4C)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorFecha,
                    style: const TextStyle(color: Colors.white),
                    readOnly: true,
                    onTap: () {
                      seleccionaFecha(context);
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Fecha de Registro',
                      labelStyle: const TextStyle(color: Color(0xFFF7DB4C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFFF7DB4C)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controladorTCarro.clear();
                controladorModelo.clear();
                controladorMatricula.clear();
                controladorFecha.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
            TextButton(
              onPressed: () async {
                if (controladorTCarro.text.isEmpty ||
                    controladorModelo.text.isEmpty ||
                    controladorMatricula.text.isEmpty ||
                    controladorFecha.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          Icon(
                            Icons.highlight_off,
                            color: Colors.white,
                            size: 35,
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              'Se requieren todos los campos llenados',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if(controladorMatricula.text.length < 7){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          Icon(
                            Icons.highlight_off,
                            color: Colors.white,
                            size: 35,
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              'La matricula debe de tener minimo 7 caracteres',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  bool matriculaExistente = await widget.carroBloc.bd
                      .revisarMatricula(controladorMatricula.text);
                  if (matriculaExistente) {
                    mensajeDenegadoMatriculaExistente();
                  } else {
                    final evento = AgregarCarroEvent(
                      controladorTCarro.text,
                      controladorModelo.text,
                      controladorMatricula.text,
                      controladorFecha.text,
                    );
                    widget.carroBloc.add(evento);
                    mensajeAprobadoCarroAgregado();
                  }
                }
              },
              child: const Text('Agregar',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
          ],
        );
      },
    );
  }

  void mensajeAprobadoCarroAgregado() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF40DE00),
        content: Row(
          children: [
            const Icon(
              Icons.thumb_up,
              color: Colors.white,
              size: 35,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                '${controladorTCarro.text} agregado exitosamente',
              ),
            ),
          ],
        ),
      ),
    );
    controladorTCarro.clear();
    controladorModelo.clear();
    controladorMatricula.clear();
    controladorFecha.clear();
  }

  void mensajeDenegadoMatriculaExistente() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Row(
          children: [
            const Icon(
              Icons.highlight_off,
              color: Colors.white,
              size: 35,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'ya exsiste un carro con la matricula ${controladorMatricula.text}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void filtrarListaPorMatricula(String matricula) {
    if (matricula.isNotEmpty) {
      widget.carroBloc.add(FiltrarPorMatriculaEvent(matricula));
    } else {
      widget.carroBloc.add(ActualizarCarrosEvent());
    }
  }

  void filtrarListaPorTCarro(String tipoDeCarro) {
    if (tipoDeCarro.isNotEmpty) {
      widget.carroBloc.add(FiltrarPorTCarroEvent(tipoDeCarro));
    } else {
      widget.carroBloc.add(ActualizarCarrosEvent());
    }
  }

  void filtrarListaPorModelo(String modelo) {
    if (modelo.isNotEmpty) {
      widget.carroBloc.add(FiltrarPorModeloEvent(modelo));
    } else {
      widget.carroBloc.add(ActualizarCarrosEvent());
    }
  }

  void filtrarListaPorTCarroYModelo(String tipoDeCarro, String modelo) {
    if (tipoDeCarro.isNotEmpty && modelo.isNotEmpty) {
      widget.carroBloc.add(FiltrarPorTCarroYModeloEvent(tipoDeCarro, modelo));
    } else if (tipoDeCarro.isNotEmpty) {
      widget.carroBloc.add(FiltrarPorTCarroEvent(tipoDeCarro));
    } else if (modelo.isNotEmpty) {
      widget.carroBloc.add(FiltrarPorModeloEvent(modelo));
    } else {
      widget.carroBloc.add(ActualizarCarrosEvent());
    }
  }

  void showDropdownMenuTCarros() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Carro',
              style: TextStyle(
                color: Colors.white,
              )),
          backgroundColor: const Color(0xFF18191D),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            side: BorderSide(color: Color(0xFF00AFE6)),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: DropdownButton<String>(
              value: tipoDeCarroFiltrado,
              onChanged: (String? newValue) {
                setState(() {
                  tipoDeCarroFiltrado = newValue!;
                  if (filtroSeleccionado == 'Tipo de carro y/o modelo' &&
                      !tipoDeCarroAgregarPresionado) {
                    controladorFiltrarTCarro.text = tipoDeCarroFiltrado;
                    filtrarListaPorTCarroYModelo(
                        newValue, controladorFiltrarModelo.text);
                  }
                  if (tipoDeCarroAgregarPresionado) {
                    controladorTCarro.text = tipoDeCarroFiltrado;
                  }
                  tipoDeCarroAgregarPresionado = false;
                  Navigator.pop(context);
                });
              },
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              items: tiposDeCarro.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              underline: Container(
                height: 2,
                color: const Color(0xFF00AFE6),
              ),
              dropdownColor: const Color(0xFF18191D),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
          ],
        );
      },
    );
  }

  void borrarCarroSeleccionado() {
    if (carroSeleccionado != null) {
      final eventoGasto = EliminarGastoEvent(carroSeleccionado!);
      final evento = EliminarCarroEvent(carroSeleccionado!);
      widget.gastosBloc.add(eventoGasto);
      widget.carroBloc.add(evento);
      setState(() {
        carroSeleccionado = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF40DE00),
          content: Row(
            children: [
              Icon(
                Icons.thumb_up,
                color: Colors.white,
                size: 35,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Carro eliminado exitosamente',
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> obtenerTiposDeCarroDesdeBD() async {
    List<Map<String, dynamic>> resultados = await miDb
        .rawQuery('SELECT TIPODECARRO FROM TIPOSDECARRO ORDER BY TIPODECARRO');

    setState(() {
      tiposDeCarro = resultados
          .map((resultado) => resultado['TIPODECARRO'].toString())
          .toList();
      tipoDeCarroFiltrado = tiposDeCarro[0];
    });
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
