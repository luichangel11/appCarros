import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:proyecto_carros/bd/base_de_datos.dart';

abstract class GastosEvent {}

class AgregarGastoEvent extends GastosEvent {
  final int idCarro;
  final String matricula;
  final String tipoDeGasto;
  final String auxiliar;
  final double gasto;
  final String fechaDelGasto;

  AgregarGastoEvent(this.idCarro ,this.matricula, this.tipoDeGasto, this.auxiliar, this.gasto ,this.fechaDelGasto,);
}

class EliminarGastoEvent extends GastosEvent {
  final int id;

  EliminarGastoEvent(this.id);
}

class EditarGastoEvent extends GastosEvent {
  final int id;
  final String tipoDeGasto;
  final String auxiliar;
  final double gasto;
  final String fechaDelGasto;

  EditarGastoEvent(this.id, this.tipoDeGasto, this.auxiliar, this.gasto, this.fechaDelGasto);
}

class CargarDatosInicialesEvent extends GastosEvent {
  final List<Map<String, dynamic>> gastos;

  CargarDatosInicialesEvent(this.gastos);
}

class ActualizarGastosEvent extends GastosEvent {}

class FiltrarPorTGastoEvent extends GastosEvent {
  final String tipoDeGasto;

  FiltrarPorTGastoEvent(this.tipoDeGasto);
}

class AgregarNuevoTipoGasto extends GastosEvent{
  final String tipoDeGasto;

  AgregarNuevoTipoGasto(this.tipoDeGasto);
}

class EliminarTipoGastoEvent extends GastosEvent{
  final String tipoDeGasto;

  EliminarTipoGastoEvent(this.tipoDeGasto);
}


abstract class GastosState {}

class LoadingGastosState extends GastosState {}

class LoadedGastosState extends GastosState {
  final List<Map<String, dynamic>> listaGastos;
  final List<String> listaTiposGastos;

  LoadedGastosState(this.listaGastos, this.listaTiposGastos);
}


class ErrorGastosState extends GastosState {
  final dynamic error;

  ErrorGastosState(this.error);
}

class GastosBloc extends Bloc<GastosEvent, GastosState> {
  final MiBaseDatos bd;

  GastosBloc({required this.bd}) : super(LoadingGastosState()) {
    _cargarDatosIniciales();
    on<AgregarGastoEvent>(_agregarGasto);
    on<EliminarGastoEvent>(_eliminarGasto);
    on<EditarGastoEvent>(_editarGasto);
    on<ActualizarGastosEvent>(_restablecerCarros);
    on<FiltrarPorTGastoEvent>(_filtrarPorTGasto);
    on<AgregarNuevoTipoGasto>(_agregarNuevoTipoGasto);
    on<EliminarTipoGastoEvent>(_eliminarTipoGasto);
  }
  

  void _cargarDatosIniciales() async {
    try {
      final listaTiposGastos = await bd.todosLosTiposGastos();
      final gastos = await bd.todosLosGastos();
      final gastosConvertidos = gastos.map((gasto) => {
        'ID': gasto['ID'],
        'ID del carro': gasto['ID_CARRO'], 
        'Matricula': gasto['MATRICULA'],
        'Tipo de gasto': gasto['TIPO_GASTO'],
        'Auxiliar': gasto['AUXILIAR'],
        'Gasto': gasto['GASTO'],
        'Fecha del gasto': gasto['FECHADELGASTO']
      }).toList();
      emit(LoadedGastosState(gastosConvertidos, listaTiposGastos));
    } catch (e) {

      emit(ErrorGastosState(e));
    }
  }

  void _agregarGasto(AgregarGastoEvent event, Emitter<GastosState> emit) async {
    try {
      await bd.agregarGasto(event.idCarro, event.matricula, event.tipoDeGasto, event.auxiliar, event.gasto, event.fechaDelGasto);
      emit(await _actualizarGastos());
    } catch (e) {
      emit(ErrorGastosState(e));
    }
  }

  void _eliminarGasto(EliminarGastoEvent event, Emitter<GastosState> emit) async {
    try {
      await bd.eliminarGasto(event.id);
      emit(await _actualizarGastos());
    } catch (e) {
      emit(ErrorGastosState(e));
    }
  }

  void _editarGasto(EditarGastoEvent event, Emitter<GastosState> emit) async {
    try {
      await bd.editarGasto(event.id, event.tipoDeGasto, event.auxiliar, event.gasto, event.fechaDelGasto);
      emit(await _actualizarGastos());
    } catch (e) {
      emit(ErrorGastosState(e));
    }
  }

  void _agregarNuevoTipoGasto(AgregarNuevoTipoGasto event, Emitter<GastosState> emit) async {
    try {
      await bd.agregarNuevoTipoGasto(event.tipoDeGasto);
      emit(await _actualizarGastos());
    } catch (e) {
      emit(ErrorGastosState(e));
    }
  }

  Future<void> _eliminarTipoGasto(EliminarTipoGastoEvent event, Emitter<GastosState> emit) async {
    try {
      await bd.eliminarTipoGasto(event.tipoDeGasto);
      emit(await _actualizarGastos());
    } catch (e) {
      emit(ErrorGastosState(e));
    }
  }

  Future<GastosState> _actualizarGastos() async {
    try {
      final listaTiposGastos = await bd.todosLosTiposGastos();
      final listaGastos = await bd.todosLosGastos();
      final gastosConvertidos = listaGastos.map((gasto) => {
        'ID': gasto['ID'],
        'ID del carro': gasto['ID_CARRO'], 
        'Matricula': gasto['MATRICULA'],
        'Tipo de gasto': gasto['TIPO_GASTO'],
        'Auxiliar': gasto['AUXILIAR'],
        'Gasto': gasto['GASTO'],
        'Fecha del gasto': gasto['FECHADELGASTO']
      }).toList();
      return LoadedGastosState(gastosConvertidos, listaTiposGastos);
    } catch (e) {
      return ErrorGastosState(e);
    }
  }

  void _restablecerCarros(ActualizarGastosEvent event, Emitter<GastosState> emit) async {
  try {
      final listaTiposGastos = await bd.todosLosTiposGastos();
      final listaGastos = await bd.todosLosGastos();
      final gastosConvertidos = listaGastos.map((gasto) => {
        'ID': gasto['ID'],
        'ID del carro': gasto['ID_CARRO'], 
        'Matricula': gasto['MATRICULA'],
        'Tipo de gasto': gasto['TIPO_GASTO'],
        'Auxiliar': gasto['AUXILIAR'],
        'Gasto': gasto['GASTO'],
        'Fecha del gasto': gasto['FECHADELGASTO']
      }).toList();
      emit (LoadedGastosState(gastosConvertidos, listaTiposGastos));
    } catch (e) {
      emit (ErrorGastosState(e));
    }
}

void _filtrarPorTGasto(FiltrarPorTGastoEvent event, Emitter<GastosState> emit) async {
  try {
    final listaTiposGastos = await bd.todosLosTiposGastos();
    final listaGastos = await bd.listaGastosFiltradosTGasto(event.tipoDeGasto);
    final gastosConvertidos = listaGastos.map((gasto) => {
      'ID': gasto['ID'],
      'ID del carro': gasto['ID_CARRO'],
      'Tipo de gasto': gasto['TIPO_GASTO'],
        'Auxiliar': gasto['AUXILIAR'],
        'Gasto': gasto['GASTO'],
        'Fecha del gasto': gasto['FECHADELGASTO']
    }).toList();
    emit(LoadedGastosState(gastosConvertidos, listaTiposGastos));
    }catch (e) {
      emit(ErrorGastosState(e));
    }
  }
  
}