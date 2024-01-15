import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_carros/bloc/bloc.dart';
import 'package:proyecto_carros/bloc/bloc_gastos.dart';

class PaginaAdmin extends StatelessWidget {
  final Map<String, dynamic>? carroSeleccionado;
  final CarroBloc carroBloc;
  final GastosBloc gastosBloc;

  const PaginaAdmin(
      {super.key,
      required this.carroSeleccionado,
      required this.carroBloc,
      required this.gastosBloc});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar ${carroSeleccionado!['Tipo de Carro']}'),
        backgroundColor: const Color(0xFFF7DB4C),
      ),
      backgroundColor: const Color(0xFF18191D),
      body: Center(
        child: PantallaDeAdmin(
            carroSeleccionado: carroSeleccionado,
            carroBloc: carroBloc,
            gastosBloc: gastosBloc),
      ),
    );
  }
}

class PantallaDeAdmin extends StatefulWidget {
  final Map<String, dynamic>? carroSeleccionado;
  final CarroBloc carroBloc;
  final GastosBloc gastosBloc;

  const PantallaDeAdmin(
      {super.key,
      required this.carroSeleccionado,
      required this.carroBloc,
      required this.gastosBloc});

  @override
  State<PantallaDeAdmin> createState() => _PantallaDeAdminState();
}

class _PantallaDeAdminState extends State<PantallaDeAdmin> {
  TextEditingController controladorTCarro = TextEditingController();
  bool tipoDeCarroAgregarPresionado = false;
  bool tipoDeGastoAgregarPresionado = false;
  TextEditingController controladorModelo = TextEditingController();
  TextEditingController controladorMatricula = TextEditingController();
  TextEditingController controladorFecha = TextEditingController();
  TextEditingController controladorGastoTotal = TextEditingController();
  TextEditingController controladorTGasto = TextEditingController();
  TextEditingController controladorAuxiliar = TextEditingController();
  TextEditingController controladorGasto = TextEditingController();
  TextEditingController controladorFechaGasto = TextEditingController();
  TextEditingController controladorNuevoTGasto = TextEditingController();
  int? gastoSeleccionado;
  String? gastoSeleccionadoTGasto;
  String? gastoSeleccionadoAuxiliar;
  double? gastoSeleccionadoGasto;
  String? gastoSeleccionadoFGasto;
  String filtroSeleccionado = '';
  List<String> opcionesFiltrado = ['Sin filtro', 'Tipo de gasto'];
  TextEditingController controladorFiltrarTGasto = TextEditingController();
  bool verDatosCarro = true;
  bool mostrarTextFieldFiltroTGasto = false;
  List<Map<String, dynamic>> listaGastos = [];
  List<Map<String, dynamic>> listaGastosFiltrados = [];
  List<String> tiposDeCarro = [];
  String tipoDeCarroFiltrado = '';
  String tipoDeGastoFiltrado = '';

  @override
  void initState() {
    super.initState();
    if (widget.carroSeleccionado != null) {
      controladorTCarro.text = widget.carroSeleccionado!['Tipo de Carro'] ?? '';
      controladorModelo.text = widget.carroSeleccionado!['Modelo'] ?? '';
      controladorMatricula.text = widget.carroSeleccionado!['Matricula'] ?? '';
      controladorFecha.text =
          widget.carroSeleccionado!['Fecha de Registro'] ?? '';
      controladorGastoTotal.value = TextEditingValue(
        text: widget.carroSeleccionado!['Gasto Total'].toString(),
      );
    }
    filtroSeleccionado = opcionesFiltrado.first;
    listaGastosFiltrados = listaGastos;
    obtenerTiposDeCarroDesdeBD();
  }

  @override
  void dispose() {
    controladorTCarro.dispose();
    controladorModelo.dispose();
    controladorMatricula.dispose();
    controladorFecha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: const Color(0xFF18191D),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Datos de ${controladorTCarro.text}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(.0),
                child: IconButton(
                  icon: Icon(
                    verDatosCarro ? Icons.visibility : Icons.visibility_off,
                    color: verDatosCarro
                        ? const Color(0xFF4DD4FF)
                        : Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      verDatosCarro = !verDatosCarro;
                      filtroSeleccionado = 'Sin filtro';
                      mostrarTextFieldFiltroTGasto = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          color: const Color(0xFF18191D),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF7DB4C)),
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF18191D)),
            child: Row(
              children: [
                Visibility(
                  visible: verDatosCarro,
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de Carro: ${controladorTCarro.text}',
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.white),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Modelo: ${controladorModelo.text}',
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.white),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Matricula: ${controladorMatricula.text}',
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.white),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Fecha de Registro: ${controladorFecha.text}',
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.white),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Gasto Total: \$${controladorGastoTotal.text}',
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: verDatosCarro,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            mostrarDialogoEditar(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF00AFE6)),
                          ),
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Editar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: const Color(0xFF18191D),
          child: const Row(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Gastos Registrados del Carro',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Filtrar por: ',
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
            DropdownButton<String>(
              value: filtroSeleccionado,
              onChanged: (String? newValue) {
                setState(() {
                  filtroSeleccionado = newValue!;
                  mostrarTextFieldFiltroTGasto =
                      filtroSeleccionado == 'Tipo de gasto';
                  if (mostrarTextFieldFiltroTGasto) {
                    verDatosCarro = false;
                  }
                  if (!mostrarTextFieldFiltroTGasto) {
                    widget.gastosBloc.add(ActualizarGastosEvent());
                    controladorFiltrarTGasto.clear();
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
                  child:
                      Text(value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 15),
              child: ElevatedButton.icon(
                onPressed: () {
                  administrarTiposDeGastos();
                },
                icon: const Icon(
                  Icons.list_alt,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Gestionar\nTipos de\nGastos',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF00AFE6)),
                ),
              ),
            )
          ],
        ),
        Container(
          color: const Color(0xFF18191D),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: mostrarTextFieldFiltroTGasto,
                    child: SizedBox(
                      width: 290.0,
                      child: TextField(
                        controller: controladorFiltrarTGasto,
                        readOnly: true,
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Tipo de gasto',
                          labelStyle: const TextStyle(color: Color(0xFFF7DB4C)),
                          hintText: 'Ingrese el tipo de gasto',
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
                          prefixIcon:
                              const Icon(Icons.sell, color: Color(0xFFF7DB4C)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              controladorFiltrarTGasto.clear();
                              widget.gastosBloc.add(ActualizarGastosEvent());
                            },
                          ),
                        ),
                        onChanged: (tipoDeGasto) {
                          if (filtroSeleccionado == 'Tipo de gasto') {
                            filtrarListaPorTGasto(tipoDeGasto);
                          }
                        },
                        onTap: () {
                          showDropdownMenuTGastos();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            color: const Color(0xFF18191D),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      dialogAgregarGasto(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF00AFE6)),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Agregar gasto nuevo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (gastoSeleccionado != null) {
                        mostrarDialogoEditarGasto(context);
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
                                    'No se ha seleccionado ningún gasto para editar.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF00AFE6)),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Editar gasto seleccionado',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (gastoSeleccionado != null) {
                        borrarGastoSeleccionado();
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
                                    'No se ha seleccionado ningún gasto para eliminar.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF00AFE6)),
                    ),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Eliminar gasto seleccionado',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<GastosBloc, GastosState>(
            bloc: widget.gastosBloc,
            builder: (context, state) {
              if (state is LoadedGastosState) {
                listaGastos = state.listaGastos;
                listaGastosFiltrados = listaGastos
                    .where((gasto) =>
                        gasto['ID del carro'] ==
                        widget.carroSeleccionado!['ID'])
                    .toList();
                if (listaGastosFiltrados.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay gastos registrados.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: listaGastosFiltrados.length,
                    itemBuilder: (context, index) {
                      var gasto = listaGastosFiltrados[index];
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF7DB4C)),
                            borderRadius: BorderRadius.circular(20),
                            color: gastoSeleccionado == gasto['ID']
                                ? const Color(0xFF00AFE6)
                                : null,
                          ),
                          child: ListTile(
                            title: Text(
                              'Tipo de Gasto: ${gasto['Tipo de gasto']}\nAuxiliar: ${gasto['Auxiliar']}\nGasto: \$${gasto['Gasto']}\nFecha del gasto: ${gasto['Fecha del gasto']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              setState(() {
                                if (gastoSeleccionado == gasto['ID']) {
                                  gastoSeleccionado = null;
                                  gastoSeleccionadoTGasto = null;
                                  gastoSeleccionadoAuxiliar = null;
                                  gastoSeleccionadoGasto = null;
                                  gastoSeleccionadoFGasto = null;
                                } else {
                                  gastoSeleccionado = gasto['ID'];
                                  gastoSeleccionadoTGasto =
                                      gasto['Tipo de gasto'];
                                  gastoSeleccionadoAuxiliar = gasto['Auxiliar'];
                                  gastoSeleccionadoGasto = gasto['Gasto'];
                                  gastoSeleccionadoFGasto =
                                      gasto['Fecha del gasto'];
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              } else if (state is LoadingGastosState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ErrorGastosState) {
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

  void filtrarListaPorTGasto(String tipoDeGasto) {
    if (tipoDeGasto.isNotEmpty) {
      widget.gastosBloc.add(FiltrarPorTGastoEvent(tipoDeGasto));
    } else {
      widget.gastosBloc.add(ActualizarGastosEvent());
    }
  }

  void mostrarDialogoEditarGasto(BuildContext context) {
    controladorTGasto.text = gastoSeleccionadoTGasto!;
    controladorAuxiliar.text = gastoSeleccionadoAuxiliar!;
    controladorGasto.text = gastoSeleccionadoGasto!.toString();
    controladorFechaGasto.text = gastoSeleccionadoFGasto!;
    double gastoResta = gastoSeleccionadoGasto!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Text('Editar Gasto', style: TextStyle(color: Colors.white)),
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
                    controller: controladorTGasto,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Gasto',
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
                    style: const TextStyle(color: Colors.white),
                    onTap: () {
                      tipoDeGastoAgregarPresionado = true;
                      showDropdownMenuTGastos();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorAuxiliar,
                    maxLength: 50,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Auxiliar',
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorGasto,
                    maxLength: 10,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Gasto',
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorFechaGasto,
                    readOnly: true,
                    onTap: () {
                      seleccionaFecha(context);
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Fecha del Gasto',
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controladorTGasto.clear();
                controladorAuxiliar.clear();
                controladorGasto.clear();
                controladorFechaGasto.clear();
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                double gasto = double.tryParse(controladorGasto.text) ?? 0.0;
                final evento = EditarGastoEvent(
                  gastoSeleccionado!,
                  controladorTGasto.text,
                  controladorAuxiliar.text,
                  gasto,
                  controladorFechaGasto.text,
                );
                widget.gastosBloc.add(evento);
                double gastoTotal =
                    double.tryParse(controladorGastoTotal.text) ?? 0.0;
                gastoTotal = gastoTotal - gastoResta;
                gastoTotal = gastoTotal + gasto;
                final eventoGastoTotal = ActualizarGastoTotalEvent(
                    widget.carroSeleccionado!['ID'], gastoTotal);
                widget.carroBloc.add(eventoGastoTotal);
                setState(() {
                  gastoSeleccionado = null;
                  controladorGastoTotal.text = gastoTotal.toStringAsFixed(2);
                });

                controladorTGasto.clear();
                controladorAuxiliar.clear();
                controladorGasto.clear();
                controladorFechaGasto.clear();

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
                            'Cambios guardados exitosamente',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
              child:
                  const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void mostrarDialogoEditar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Text('Editar Carro', style: TextStyle(color: Colors.white)),
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
                    maxLength: 43,
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
                      UpperCaseTextFormatter()
                    ],
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
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white)),
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
                } else if (controladorMatricula.text.length < 7) {
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
                  int? idObtenido = await widget.carroBloc.bd
                      .idObtenido(controladorMatricula.text);
                  if (matriculaExistente &&
                      idObtenido != widget.carroSeleccionado!['ID']) {
                    mensajeDenegado();
                  } else {
                    final evento = EditarCarroEvent(
                      widget.carroSeleccionado!['ID'],
                      controladorTCarro.text,
                      controladorModelo.text,
                      controladorMatricula.text,
                      controladorFecha.text,
                    );
                    widget.carroBloc.add(evento);
                    setState(() {
                      controladorTCarro.text = evento.tipoDeCarro;
                      controladorModelo.text = evento.modelo;
                      controladorMatricula.text = evento.matricula;
                      controladorFecha.text = evento.fechaDeRegistro;
                    });
                    mensajeAprobado();
                  }
                }
              },
              child:
                  const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void mensajeDenegado() {
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

  void dialogAgregarGasto(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Gasto',
              style: TextStyle(color: Colors.white)),
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
                    controller: controladorTGasto,
                    maxLength: 50,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    readOnly: true,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Tipo de gasto',
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
                    style: const TextStyle(color: Colors.white),
                    onTap: () {
                      tipoDeGastoAgregarPresionado = true;
                      showDropdownMenuTGastos();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorAuxiliar,
                    maxLength: 50,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Auxiliar',
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorGasto,
                    maxLength: 10,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Gasto',
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'[^\d\.]')),
                      FilteringTextInputFormatter.singleLineFormatter,
                      LengthLimitingTextInputFormatter(10),
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) {
                          final newText = newValue.text;
                          final pointIndex = newText.indexOf('.');
                          if (pointIndex >= 0 &&
                              newText.length - pointIndex > 3) {
                            return oldValue;
                          }
                          return newValue;
                        },
                      ),
                    ],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controladorFechaGasto,
                    readOnly: true,
                    onTap: () {
                      seleccionaFecha(context);
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Fecha de gasto',
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controladorTGasto.clear();
                controladorAuxiliar.clear();
                controladorGasto.clear();
                controladorFechaGasto.clear();
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                if (controladorTGasto.text.isEmpty ||
                    controladorAuxiliar.text.isEmpty ||
                    controladorFechaGasto.text.isEmpty) {
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
                } else {
                  double gasto = double.tryParse(controladorGasto.text) ?? 0.0;
                  final evento = AgregarGastoEvent(
                    widget.carroSeleccionado!['ID'],
                    widget.carroSeleccionado!['Matricula'],
                    controladorTGasto.text,
                    controladorAuxiliar.text,
                    gasto,
                    controladorFechaGasto.text,
                  );
                  widget.gastosBloc.add(evento);
                  double gastoTotal =
                      double.tryParse(controladorGastoTotal.text) ?? 0.0;
                  gastoTotal = gastoTotal + gasto;
                  final eventoGastoTotal = ActualizarGastoTotalEvent(
                      widget.carroSeleccionado!['ID'], gastoTotal);
                  widget.carroBloc.add(eventoGastoTotal);
                  setState(() {
                    controladorGastoTotal.text = gastoTotal.toStringAsFixed(2);
                  });
                  controladorTGasto.clear();
                  controladorAuxiliar.clear();
                  controladorGasto.clear();
                  controladorFechaGasto.clear();
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
                              'Nuevo gasto agregado exitosamente',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child:
                  const Text('Agregar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> borrarGastoSeleccionado() async {
    if (gastoSeleccionado != null) {
      double gasto =
          await widget.gastosBloc.bd.obtenerGasto(gastoSeleccionado!);
      double gastoTotal = double.tryParse(controladorGastoTotal.text) ?? 0.0;
      final evento = EliminarGastoEvent(gastoSeleccionado!);
      widget.gastosBloc.add(evento);
      gastoTotal = gastoTotal - gasto;
      final eventoGastoTotal = ActualizarGastoTotalEvent(
          widget.carroSeleccionado!['ID'], gastoTotal);
      widget.carroBloc.add(eventoGastoTotal);
      setState(() {
        gastoSeleccionado = null;
        controladorGastoTotal.text = gastoTotal.toStringAsFixed(2);
      });
      mensajeAprobadoEliminado();
    }
  }

  void mensajeAprobadoEliminado() {
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
                'Gasto eliminado exitosamente',
              ),
            ),
          ],
        ),
      ),
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
        controladorFechaGasto.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
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

  Future<List<String>> obtenerTiposDeGastos() async {
    List<String> tiposDeGasto =
        await widget.gastosBloc.bd.todosLosTiposGastos();
    return tiposDeGasto;
  }

  Future<void> showDropdownMenuTGastos() async {
    obtenerTiposDeGastos().then((List<String> tiposDeGasto) {
      if (tiposDeGasto.isEmpty) {
        return ScaffoldMessenger.of(context).showSnackBar(
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
                    'No hay tipos de gastos registrados',
                  ),
                ),
              ],
            ),
          ),
        );
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          tipoDeGastoFiltrado = tiposDeGasto[0];
          return AlertDialog(
            title: const Text('Seleccionar Gasto',
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
                value: tipoDeGastoFiltrado,
                onChanged: (String? newValue) {
                  setState(() {
                    tipoDeGastoFiltrado = newValue!;
                    if (filtroSeleccionado == 'Tipo de gasto' &&
                        !tipoDeGastoAgregarPresionado) {
                      controladorFiltrarTGasto.text = tipoDeGastoFiltrado;
                      filtrarListaPorTGasto(newValue);
                    }
                    if (tipoDeGastoAgregarPresionado) {
                      controladorTGasto.text = tipoDeGastoFiltrado;
                    }
                    tipoDeGastoAgregarPresionado = false;
                    Navigator.pop(context);
                  });
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                items:
                    tiposDeGasto.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(color: Colors.white)),
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
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  agregarNuevoTipoDeGasto();
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text(
                  '¿Nuevo tipo\n de gasto?',
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF00AFE6)),
                ),
              )
            ],
          );
        },
      );
    });
  }

  Future<void> showListViewTGastos() async {
    obtenerTiposDeGastos().then((List<String> tiposDeGasto) {
      if (tiposDeGasto.isEmpty) {
        return ScaffoldMessenger.of(context).showSnackBar(
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
                    'No hay tipos de gastos registrados',
                  ),
                ),
              ],
            ),
          ),
        );
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Tipos de gastos registrados',
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
              child: ListView.builder(
                itemCount: tiposDeGasto.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      tiposDeGasto[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controladorTGasto.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Volver',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ],
          );
        },
      );
    });
  }

  void agregarNuevoTipoDeGasto() {
    obtenerTiposDeGastos().then((List<String> tiposDeGasto) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Agregar Nuevo Tipo de Gasto',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              backgroundColor: const Color(0xFF18191D),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                side: BorderSide(color: Color(0xFF00AFE6)),
              ),
              content: TextField(
                controller: controladorNuevoTGasto,
                style: const TextStyle(color: Colors.white),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                  UpperCaseTextFormatter(),
                ],
                maxLength: 50,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'Nuevo tipo de gasto',
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
              actions: [
                TextButton(
                  onPressed: () {
                    controladorNuevoTGasto.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
                TextButton(
                  onPressed: () {
                    if (controladorNuevoTGasto.text.isEmpty) {
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
                                  'No puedes agregar valores vacios',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      if (tiposDeGasto.contains(controladorNuevoTGasto.text)) {
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
                                    'Ya exsiste este tipo de gasto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        final evento =
                            AgregarNuevoTipoGasto(controladorNuevoTGasto.text);
                        widget.gastosBloc.add(evento);
                        controladorNuevoTGasto.clear();
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
                                    'Nuevo tipo de gasto agregado exitosamente',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
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
          });
    });
  }

  void mensajeAprobado() {
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
                'Cambios guardados exitosamente',
              ),
            ),
          ],
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> obtenerTiposDeCarroDesdeBD() async {
    List<Map<String, dynamic>> resultados =
        await widget.carroBloc.bd.obtenerTiposDeCarroDesdeBD();

    setState(() {
      tiposDeCarro = resultados
          .map((resultado) => resultado['TIPODECARRO'].toString())
          .toList();
      tipoDeCarroFiltrado = tiposDeCarro[0];
    });
  }

  void administrarTiposDeGastos() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Gestionar Tipos de Gastos',
            style: TextStyle(color: Colors.white),
          ),
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
                  child: ElevatedButton(
                      onPressed: () {
                        showListViewTGastos();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF00AFE6)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Ver los tipos de datos registrados',
                            style: TextStyle(color: Colors.white)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        agregarNuevoTipoDeGasto();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF00AFE6)),
                      ),
                      child: const Text(
                        'Agregar nuevo tipo de gasto',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        dialogEliminarTipoDeGasto();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF00AFE6)),
                      ),
                      child: const Text(
                        'Eliminar Tipo de gasto',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void dialogEliminarTipoDeGasto() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Eliminar Tipo de Gasto',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF18191D),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              side: BorderSide(color: Color(0xFF00AFE6)),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: controladorTGasto,
                    maxLength: 50,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    readOnly: true,
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Tipo de gasto',
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
                    style: const TextStyle(color: Colors.white),
                    onTap: () {
                      tipoDeGastoAgregarPresionado = true;
                      showDropdownMenuTGastos();
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controladorTGasto.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  widget.gastosBloc
                      .add(EliminarTipoGastoEvent(controladorTGasto.text));
                  controladorTGasto.clear();
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
                              'Tipo de gasto eliminado exitosamente',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Eliminar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
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
