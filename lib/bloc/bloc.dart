import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:proyecto_carros/bd/base_de_datos.dart';

//EVENTOS
abstract class CarroEvent {}

class AgregarCarroEvent extends CarroEvent {
  final String tipoDeCarro;
  final String modelo;
  final String matricula;
  final String fechaDeRegistro;

  AgregarCarroEvent(this.tipoDeCarro, this.modelo, this.matricula, this.fechaDeRegistro);
}

class EliminarCarroEvent extends CarroEvent {
  final int id;

  EliminarCarroEvent(this.id);
}

class EditarCarroEvent extends CarroEvent {
  final int id;
  final String tipoDeCarro;
  final String modelo;
  final String matricula;
  final String fechaDeRegistro;

  EditarCarroEvent(this.id, this.tipoDeCarro, this.modelo, this.matricula, this.fechaDeRegistro);
}

class ActualizarGastoTotalEvent extends CarroEvent {
  final int id;
  final double gastoTotal;


  ActualizarGastoTotalEvent(this.id, this.gastoTotal);
}

class FiltrarPorMatriculaEvent extends CarroEvent {
  final String matricula;

  FiltrarPorMatriculaEvent(this.matricula);
}

class FiltrarPorTCarroEvent extends CarroEvent {
  final String tipoDeCarro;

  FiltrarPorTCarroEvent(this.tipoDeCarro);
}

class FiltrarPorModeloEvent extends CarroEvent {
  final String modelo;

  FiltrarPorModeloEvent(this.modelo);
}

class FiltrarPorTCarroYModeloEvent extends CarroEvent {
  final String tipoDeCarro;
  final String modelo;

  FiltrarPorTCarroYModeloEvent(this.tipoDeCarro, this.modelo);
}

class ActualizarCarrosEvent extends CarroEvent {}

//ESTADOS
abstract class CarroState {}

class LoadingState extends CarroState {}

class LoadedState extends CarroState {
  final List<Map<String, dynamic>> listaCarros;

  LoadedState(this.listaCarros);
}

class UpdateState extends CarroState{
  final List<Map<String, dynamic>> listaCarrosActualizada;

  UpdateState(this.listaCarrosActualizada);
}

class ErrorState extends CarroState {
  final dynamic error;

  ErrorState(this.error);
}

class CarroBloc extends Bloc<CarroEvent, CarroState> {
  final MiBaseDatos bd;

  CarroBloc({required this.bd}) : super(LoadingState()) {
    _cargarDatosIniciales();
    on<AgregarCarroEvent>(_agregarCarro);
    on<EliminarCarroEvent>(_eliminarCarro);
    on<EditarCarroEvent>(_editarCarro); 
    on<ActualizarCarrosEvent>(_restablecerCarros);
    on<FiltrarPorTCarroEvent>(_filtrarPorTCarro);
    on<FiltrarPorMatriculaEvent>(_filtrarPorMatricula);
    on<FiltrarPorModeloEvent>(_filtrarPorModelo);
    on<FiltrarPorTCarroYModeloEvent>(_filtrarPorTCarroYModelo);
    on<ActualizarGastoTotalEvent>(_actualizarGastoTotal);
  }

  void _cargarDatosIniciales() async {
    try {
      final carros = await bd.todosLosCarros();
      final carrosConvertidos = carros.map((carro) => {
        'ID': carro['ID'],
        'Tipo de Carro': carro['TIPODECARRO'],
        'Modelo': carro['MODELO'],
        'Matricula': carro['MATRICULA'],
        'Gasto Total': carro['GASTOTOTAL'],
        'Fecha de Registro': carro['FECHADEREGISTRO'],
      }).toList();
      emit(LoadedState(carrosConvertidos));
    } catch (e) {

      emit(ErrorState(e));
    }
  }


  void _agregarCarro(AgregarCarroEvent event, Emitter<CarroState> emit) async {
    try {
      await bd.agregarCarro(event.tipoDeCarro, event.modelo, event.matricula, event.fechaDeRegistro);
      emit(await _actualizarCarros());
    } catch (e) {
      emit(ErrorState(e));
    }
  }

  void _eliminarCarro(EliminarCarroEvent event, Emitter<CarroState> emit) async {
    try {
      await bd.eliminarCarro(event.id);
      emit(await _actualizarCarros());
    } catch (e) {
      emit(ErrorState(e));
    }
  }

  void _editarCarro(EditarCarroEvent event, Emitter<CarroState> emit) async {
    try {
      await bd.editarCarro(event.id, event.tipoDeCarro, event.modelo, event.matricula, event.fechaDeRegistro);
      emit(await _actualizarCarros());
    } catch (e) {
      emit(ErrorState(e));
    }
  }

  Future<CarroState> _actualizarCarros() async {
    try {
      final listaCarros = await bd.todosLosCarros();
      final carrosConvertidos = listaCarros.map((carro) => {
        'ID': carro['ID'],
        'Tipo de Carro': carro['TIPODECARRO'],
        'Modelo': carro['MODELO'],
        'Matricula': carro['MATRICULA'],
        'Gasto Total': carro['GASTOTOTAL'],
        'Fecha de Registro': carro['FECHADEREGISTRO'],
      }).toList();
      return UpdateState(carrosConvertidos);
    } catch (e) {
      return ErrorState(e);
    }
  }

  void _actualizarGastoTotal(ActualizarGastoTotalEvent event, Emitter<CarroState> emit) async {
    try {
      await bd.actualizarGastoTotal(event.id, event.gastoTotal);
      emit(await _actualizarCarros());
    } catch (e) {
      emit(ErrorState(e));
    }
  }

  void _filtrarPorMatricula(FiltrarPorMatriculaEvent event, Emitter<CarroState> emit) async {
  try {
    final listaCarros = await bd.listaCarrosFiltradosMatricula(event.matricula);
    final carrosConvertidos = listaCarros.map((carro) => {
      'ID': carro['ID'],
      'Tipo de Carro': carro['TIPODECARRO'],
      'Modelo': carro['MODELO'],
      'Matricula': carro['MATRICULA'],
      'Gasto Total': carro['GASTOTOTAL'],
      'Fecha de Registro': carro['FECHADEREGISTRO'],
    }).toList();
    emit(UpdateState(carrosConvertidos));
    }catch (e) {
      emit(ErrorState(e));
    }
  }

  void _filtrarPorTCarro(FiltrarPorTCarroEvent event, Emitter<CarroState> emit) async {
  try {
    final listaCarros = await bd.listaCarrosFiltradosTCarro(event.tipoDeCarro);
    final carrosConvertidos = listaCarros.map((carro) => {
      'ID': carro['ID'],
      'Tipo de Carro': carro['TIPODECARRO'],
      'Modelo': carro['MODELO'],
      'Matricula': carro['MATRICULA'],
      'Gasto Total': carro['GASTOTOTAL'],
      'Fecha de Registro': carro['FECHADEREGISTRO'],
    }).toList();
    emit(UpdateState(carrosConvertidos));
    }catch (e) {
      emit(ErrorState(e));
    }
  }

  void _filtrarPorModelo(FiltrarPorModeloEvent event, Emitter<CarroState> emit) async {
  try {
    final listaCarros = await bd.listaCarrosFiltradosModelo(event.modelo);
    final carrosConvertidos = listaCarros.map((carro) => {
      'ID': carro['ID'],
      'Tipo de Carro': carro['TIPODECARRO'],
      'Modelo': carro['MODELO'],
      'Matricula': carro['MATRICULA'],
      'Gasto Total': carro['GASTOTOTAL'],
      'Fecha de Registro': carro['FECHADEREGISTRO'],
    }).toList();
    emit(UpdateState(carrosConvertidos));
    }catch (e) {
      emit(ErrorState(e));
    }
  }

  void _filtrarPorTCarroYModelo(FiltrarPorTCarroYModeloEvent event, Emitter<CarroState> emit) async {
  try {
    final listaCarros = await bd.listaCarrosFiltradosTCarrosYModelo(event.tipoDeCarro ,event.modelo);
    final carrosConvertidos = listaCarros.map((carro) => {
      'ID': carro['ID'],
      'Tipo de Carro': carro['TIPODECARRO'],
      'Modelo': carro['MODELO'],
      'Matricula': carro['MATRICULA'],
      'Gasto Total': carro['GASTOTOTAL'],
      'Fecha de Registro': carro['FECHADEREGISTRO'],
    }).toList();
    emit(UpdateState(carrosConvertidos));
    }catch (e) {
      emit(ErrorState(e));
    }
  }

  void _restablecerCarros(ActualizarCarrosEvent event, Emitter<CarroState> emit) async {
  try {
    final listaCarros = await bd.todosLosCarros();
    final carrosConvertidos = listaCarros.map((carro) => {
      'ID': carro['ID'],
      'Tipo de Carro': carro['TIPODECARRO'],
      'Modelo': carro['MODELO'],
      'Matricula': carro['MATRICULA'],
      'Gasto Total': carro['GASTOTOTAL'],
      'Fecha de Registro': carro['FECHADEREGISTRO'],
    }).toList();
    emit(UpdateState(carrosConvertidos));
  } catch (e) {
    emit(ErrorState(e));
  }
}

}