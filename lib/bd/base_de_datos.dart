import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

late Database miDb;

List<String> tiposDeGastos = [
  '', 'GASOLINA', 'CAMBIO DE ACEITE', 'CAMBIO DE LLANTAS', 'REPARACION DE BUJIAS'
];

List<String> marcasDeCarros = [
  'Toyota', 'Ford', 'Chevrolet', 'Honda', 'Volkswagen', 'BMW', 'Mercedes-Benz', 'Audi', 'Nissan', 'Hyundai',
  'Subaru', 'Kia', 'Tesla', 'Ferrari', 'Porsche', 'Jaguar', 'Land Rover', 'Jeep', 'Dodge', 'Volvo',
  'Mazda', 'Lexus', 'Acura', 'Infiniti', 'Fiat', 'Alfa Romeo', 'Buick', 'Cadillac', 'GMC', 'Ram',
  'Chrysler', 'Maserati', 'Mini', 'Aston Martin', 'Bentley', 'Rolls-Royce', 'Bugatti', 'Lotus', 'McLaren', 'Genesis',
  'Smart', 'Dacia', 'Lada', 'Geely', 'BYD', 'Chery', 'Great Wall Motors', 'Proton', 'Tata Motors', 'Mahindra',
  'Perodua', 'SsangYong', 'Isuzu', 'Daihatsu', 'Suzuki', 'Mitsubishi', 'Scion', 'Saab', 'Fisker',
  'Alpine', 'Rimac', 'Lucid Motors', 'Polestar', 'NIO', 'Rivian', 'Karma Automotive', 'Faraday Future', 'Bollinger Motors',
  'Lucra Cars', 'Spyker', 'Venturi', 'Pagani', 'Datsun', 'Borgward', 'BYTON', 'VinFast', 'Arcimoto', 'Elio Motors', 'Karma Revero'
];

class MiBaseDatos {
  Future<void> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    var fabricaBaseDatos = databaseFactory;
    String rutaBase = '${await fabricaBaseDatos.getDatabasesPath()}/miBase.miDb';
    miDb = await fabricaBaseDatos.openDatabase(
      rutaBase,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (miDb, version) async {
          await miDb.execute(
              'CREATE TABLE CARROSACTUALES (ID INTEGER PRIMARY KEY AUTOINCREMENT, TIPODECARRO TEXT(50), MODELO TEXT(50), MATRICULA TEXT(10), GASTOTOTAL DOUBLE DEFAULT 0, FECHADEREGISTRO TEXT(50))');
          await miDb.execute(
            'CREATE TABLE GASTOS (ID INTEGER PRIMARY KEY AUTOINCREMENT, ID_CARRO INT(4), MATRICULA TEXT(10), TIPO_GASTO TEXT(50), AUXILIAR TEXT(50), GASTO DOUBLE, FECHADELGASTO TEXT(50))');
          await miDb.execute(
            'CREATE TABLE TIPOSDECARRO (ID INTEGER PRIMARY KEY AUTOINCREMENT, TIPODECARRO TEXT(50))');
          await miDb.execute(
            'CREATE TABLE TIPOSDEGASTO (ID INTEGER PRIMARY KEY AUTOINCREMENT, TIPODEGASTO TEXT(50))');
          await miDb.rawInsert(
            'INSERT INTO TIPOSDECARRO (TIPODECARRO) VALUES ${marcasDeCarros.map((marca) => '("$marca")').join(', ')};'
          );
          await miDb.rawInsert(
            'INSERT INTO TIPOSDEGASTO (TIPODEGASTO) VALUES ${tiposDeGastos.map((gasto) => '("$gasto")').join(', ')};'
          );
        },
      ),
    );
  }
  
  

  Future<List<Map<String, dynamic>>> todosLosCarros() async {
  var resultadoConsulta = await miDb.rawQuery('SELECT ID, TIPODECARRO, MODELO, MATRICULA, GASTOTOTAL, FECHADEREGISTRO FROM CARROSACTUALES ORDER BY TIPODECARRO');
  return resultadoConsulta;
  }

  Future<List<Map<String, dynamic>>> obtenerTiposDeCarroDesdeBD() async {
  var resultadoConsulta = await miDb.rawQuery('SELECT TIPODECARRO FROM TIPOSDECARRO ORDER BY TIPODECARRO');

  return resultadoConsulta;
  }

  Future<List<Map<String, dynamic>>> dropDownTCarros() async {
  var resultadoConsulta = await miDb.rawQuery('SELECT TIPODECARRO FROM CATEGORIAS');
  return resultadoConsulta;
  }

  Future<List<Map<String, dynamic>>> listaCarrosFiltradosMatricula(String matricula) async {
  var resultadoConsulta = await miDb.rawQuery('SELECT ID, TIPODECARRO ,MODELO, MATRICULA, GASTOTOTAL, FECHADEREGISTRO FROM CARROSACTUALES WHERE MATRICULA = ?',
  [matricula]
  );
  return resultadoConsulta;
  }

  Future<List<Map<String, dynamic>>> listaCarrosFiltradosTCarro(String tipoDeCarro) async {
  var resultadoConsulta = await miDb.rawQuery('SELECT ID, TIPODECARRO ,MODELO, MATRICULA, GASTOTOTAL, FECHADEREGISTRO FROM CARROSACTUALES WHERE TIPODECARRO = ?',
  [tipoDeCarro]
  );
  return resultadoConsulta;
  }

  Future<List<Map<String, dynamic>>> listaCarrosFiltradosModelo(String modelo) async {
  var resultadoConsulta = await miDb.rawQuery('SELECT ID, TIPODECARRO ,MODELO, MATRICULA, GASTOTOTAL, FECHADEREGISTRO FROM CARROSACTUALES WHERE MODELO = ?',
  [modelo]
  );
  return resultadoConsulta;
  }

  Future<List<Map<String, dynamic>>> listaCarrosFiltradosTCarrosYModelo(String tipoDeCarro ,String modelo) async {
  var resultadoConsulta = await miDb.rawQuery('SELECT ID, TIPODECARRO ,MODELO, MATRICULA, GASTOTOTAL, FECHADEREGISTRO FROM CARROSACTUALES WHERE TIPODECARRO = ? AND MODELO = ?',
  [tipoDeCarro,modelo]
  );
  return resultadoConsulta;
  }

  Future<void> agregarCarro(String tipoDeCarro, String modelo, String matricula, String fechaDeRegistro) async {
    await miDb.rawInsert(
      'INSERT INTO CARROSACTUALES (TIPODECARRO, MODELO, MATRICULA, FECHADEREGISTRO) VALUES (?, ?, ?, ?)',
      [tipoDeCarro, modelo, matricula, fechaDeRegistro],
    );
  }

  Future<bool> revisarMatricula(String matricula) async {
  var resultadoConsulta = await miDb.rawQuery(
    'SELECT MATRICULA FROM CARROSACTUALES WHERE MATRICULA = ?',
    [matricula],
  );
  return resultadoConsulta.isNotEmpty;
}

Future<int?> idObtenido(String matricula) async {
  var resultadoConsulta = await miDb.rawQuery(
    'SELECT ID FROM CARROSACTUALES WHERE MATRICULA = ?',
    [matricula],
  );

  if (resultadoConsulta.isNotEmpty) {
    var idEncontrada = resultadoConsulta.first['ID'] as int?;
    return idEncontrada;
  } else {
    return null;
  }
}

  Future<void> eliminarCarro(int id) async {
    await miDb.rawDelete(
      'DELETE FROM GASTOS WHERE ID_CARRO = ?',
      [id],
    );
    await miDb.rawDelete(
      'DELETE FROM CARROSACTUALES WHERE ID = ?',
      [id],
    );
  }

  Future<void> editarCarro(int id, String tipoDeCarro, String modelo, String matricula, String fechaDeRegistro) async {
  await miDb.rawUpdate(
    'UPDATE CARROSACTUALES SET TIPODECARRO = ?, MODELO = ?, MATRICULA = ?, FECHADEREGISTRO = ? WHERE ID = ?',
    [tipoDeCarro, modelo, matricula, fechaDeRegistro, id],
  );
}

Future<void> actualizarGastoTotal(int id, double gastoTotal) async {
  await miDb.rawUpdate(
    'UPDATE CARROSACTUALES SET GASTOTOTAL = ? WHERE ID = ?',
    [gastoTotal, id],
  );
}

Future<List<Map<String, dynamic>>> todosLosGastos() async {
  var resultadoConsulta = await miDb.rawQuery('SELECT ID, ID_CARRO, TIPO_GASTO, AUXILIAR, GASTO, FECHADELGASTO FROM GASTOS');
  return resultadoConsulta;
}

Future <List<String>> todosLosTiposGastos() async {
  var resultadoConsulta = await miDb.rawQuery('SELECT TIPODEGASTO FROM TIPOSDEGASTO ORDER BY TIPODEGASTO');
  var tiposDeGasto = resultadoConsulta.map((resultado) => resultado['TIPODEGASTO'].toString()).toList();
  return tiposDeGasto;
  }

Future<List<Map<String, dynamic>>> gastosCarroSeleccionado(int idCarro) async {
  var resultadoConsulta = await miDb.rawQuery('SELECT ID, ID_CARRO, TIPO_GASTO, AUXILIAR, GASTO, FECHADELGASTO FROM GASTOS WHERE ID_CARRO = ?',
    [idCarro],
  );
  return resultadoConsulta;
}


Future<void> agregarGasto(int idCarro ,String matricula ,String tipoDeGasto, String auxiliar, double gasto, String fechaDelGasto) async {
    await miDb.rawInsert(
      'INSERT INTO GASTOS (ID_CARRO, MATRICULA, TIPO_GASTO, AUXILIAR, GASTO, FECHADELGASTO) VALUES (?, ?, ?, ?, ?, ?)',
      [idCarro,matricula,tipoDeGasto, auxiliar, gasto, fechaDelGasto],
    );
  }

  Future<void> eliminarGasto(int id) async {
    await miDb.rawDelete(
      'DELETE FROM GASTOS WHERE ID = ?',
      [id],
    );
  }

  Future<void> editarGasto(int id, String tipoDeGasto, String auxiliar, double gasto, String fechaDelGasto) async {
  await miDb.rawUpdate(
    'UPDATE GASTOS SET TIPO_GASTO = ?, AUXILIAR = ?, GASTO = ?, FECHADELGASTO = ? WHERE ID = ?',
    [tipoDeGasto, auxiliar, gasto, fechaDelGasto, id],
  );
}

Future<List<Map<String, dynamic>>> obtenerDatosGastoSeleccionado(int idGasto) async {
  var resultadoConsulta = await miDb.rawQuery('SELECT ID, ID_CARRO, TIPO_GASTO, AUXILIAR, GASTO, FECHADELGASTO FROM GASTOS WHERE ID = ?',
    [idGasto],
  );
  return resultadoConsulta;
}

Future<void> agregarNuevoTipoGasto(String tipoDeGasto) async {
    await miDb.rawInsert(
      'INSERT INTO TIPOSDEGASTO (TIPODEGASTO) VALUES (?)',
      [tipoDeGasto],
    );
  }

Future<void> eliminarTipoGasto(String tipoDeGasto) async {
    await miDb.rawInsert(
      'DELETE FROM TIPOSDEGASTO WHERE TIPODEGASTO = ?',
      [tipoDeGasto],
    );
  }

Future<List<Map<String, dynamic>>> listaGastosFiltradosTGasto(String tipoDeGasto) async {
  var resultadoConsulta = await miDb.rawQuery('SELECT ID, ID_CARRO ,TIPO_GASTO ,AUXILIAR, GASTO, FECHADELGASTO FROM GASTOS WHERE TIPO_GASTO = ?',
  [tipoDeGasto]
  );
  return resultadoConsulta;
  }

  Future<double> obtenerGasto(int id) async {
  var resultadoConsulta = await miDb.rawQuery(
    'SELECT GASTO FROM GASTOS WHERE ID = ?',
    [id],
  );
    var primerResultado = resultadoConsulta.first;
    var gasto = primerResultado['GASTO'];
    if (gasto is num) {
      return gasto.toDouble();
    }

  return 0.0;
}


}