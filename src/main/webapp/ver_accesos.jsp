<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.time.format.TextStyle" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.HashMap" %>

<%
// 🔐 Verificación de sesión
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Obtenemos rol y ci de la sesión
String rol = (String) session.getAttribute("rol");
String ciUsuario = (String) session.getAttribute("ci");

// Si es admin y seleccionó un empleado mediante parámetro, o si es empleado toma su propia CI
String ciParam = request.getParameter("ci_filtro");
String ciConsulta = "admin".equals(rol) ? (ciParam != null && !ciParam.isEmpty() ? ciParam : ciUsuario) : ciUsuario;

// Parámetro de año y mes para el reporte
LocalDate hoyActual = LocalDate.now();
int anioFiltro = request.getParameter("anio") != null ? Integer.parseInt(request.getParameter("anio")) : hoyActual.getYear();
int mesFiltro = request.getParameter("mes") != null ? Integer.parseInt(request.getParameter("mes")) : hoyActual.getMonthValue();

String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
String mensajeAlerta = "";

try (Connection conReg = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm")) {
    conReg.createStatement().execute("SET TIME ZONE 'America/Asuncion'");

    // Lógica para procesar el registro manual
    if ("POST".equalsIgnoreCase(request.getMethod()) && "registrar_manual".equals(request.getParameter("accion"))) {
        String ciManual = request.getParameter("ci");
        String fechaManual = request.getParameter("fecha");
        String entradaManual = request.getParameter("entrada");
        String salidaManual = request.getParameter("salida");
        String estadoManual = request.getParameter("estado");

        int personaId = -1;
        try (PreparedStatement psPersona = conReg.prepareStatement("SELECT id FROM personas WHERE ci = ?")) {
            psPersona.setString(1, ciManual);
            try (ResultSet rsPersona = psPersona.executeQuery()) {
                if (rsPersona.next()) {
                    personaId = rsPersona.getInt("id");
                }
            }
        }

        if (personaId != -1) {
            LocalDate fechaParsed = LocalDate.parse(fechaManual);
            LocalTime entradaParsed = LocalTime.parse(entradaManual).minusHours(3);
            LocalTime salidaParsed = LocalTime.parse(salidaManual).minusHours(3);

            try (PreparedStatement psInsert = conReg.prepareStatement("INSERT INTO asistencias (persona_id, fecha, hora_entrada, hora_salida, estado) VALUES (?, ?, ?, ?, ?)")) {
                psInsert.setInt(1, personaId);
                psInsert.setDate(2, java.sql.Date.valueOf(fechaParsed));
                psInsert.setTime(3, java.sql.Time.valueOf(entradaParsed));
                psInsert.setTime(4, java.sql.Time.valueOf(salidaParsed));
                psInsert.setString(5, estadoManual);
                psInsert.executeUpdate();
                mensajeAlerta = "<div class='alert alert-success' style='margin-bottom:20px;'>¡Asistencia manual registrada con éxito!</div>";
            }
        } else {
            mensajeAlerta = "<div class='alert alert-danger' style='margin-bottom:20px;'>Error: No se encontró ninguna persona registrada con ese CI.</div>";
        }
    } 
    // Lógica para eliminar un registro de asistencia (Solo Admin)
    else if ("POST".equalsIgnoreCase(request.getMethod()) && "eliminar_asistencia".equals(request.getParameter("accion")) && "admin".equals(rol)) {
        int idAsistenciaDel = Integer.parseInt(request.getParameter("id_asistencia"));
        try (PreparedStatement psDel = conReg.prepareStatement("DELETE FROM asistencias WHERE id = ?")) {
            psDel.setInt(1, idAsistenciaDel);
            psDel.executeUpdate();
            mensajeAlerta = "<div class='alert alert-success' style='margin-bottom:20px;'>Registro de asistencia eliminado con éxito.</div>";
        }
    }
} catch (Exception e) {
    mensajeAlerta = "<div class='alert alert-danger' style='margin-bottom:20px;'>Error en la operación: " + e.getMessage() + "</div>";
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Informe de Asistencias y Ausencias</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 1500px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        
        .header-box { position: relative; display: flex; align-items: center; justify-content: center; margin-bottom: 20px; flex-direction: column; }
        h2 { text-align: center; font-size: 32px; font-weight: bold; margin: 0; width: 100%; color: white; }
        .subtitulo-informe { text-align: center; color: white; font-size: 15px; margin-top: 5px; }
        
        .btn-nuevo { 
            position: absolute; 
            right: 0; 
            top: 0;
            background: linear-gradient(30deg, #4225a3, #000738); 
            padding: 10px 20px; 
            border-radius: 20px; 
            border: none; 
            color: white !important; 
            font-weight: bold !important; 
            cursor: pointer; 
            transition: transform 0.3s ease; 
            text-decoration: none !important; 
            display: inline-block;
            font-size: 14px;
        }
        .btn-nuevo:hover { transform: scale(1.05); color: white !important; }

        .filtros-box { background: rgba(255,255,255,0.04); padding: 15px; border-radius: 15px; margin-bottom: 25px; display: flex; gap: 15px; align-items: center; justify-content: center; flex-wrap: wrap; color: white; }

        .info-resumen-container { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; margin-bottom: 15px; }
        .info-empleado-pill { font-size: 16px; font-weight: bold; background: rgba(255,255,255,0.05); padding: 10px 20px; border-radius: 12px; color: white; }
        .badge-ausencias { background: rgba(255, 82, 82, 0.15); border: 1px solid rgba(255, 82, 82, 0.3); color: #ff5252; font-size: 15px; font-weight: bold; padding: 10px 20px; border-radius: 12px; }

        table { width: 100%; margin-top: 15px; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { text-align: center; padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; font-size: 14px; color: white; }
        th { background: rgba(255,255,255,0.08); font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; color: white; }
        tr:hover td { background: rgba(255,255,255,0.04); }
        
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 25px; padding: 12px 24px; color: white; font-weight: bold; text-decoration: none; display: inline-block; margin-top: 25px; }
        .btn-volver:hover { color: white; text-decoration: none; }
        .boton-centro { text-align: center; }
        .sin-registros { text-align: center; padding: 20px; color: white; }
        
        .ok { color: #00e676; font-weight: bold; }
        .tarde { color: #ffd54f; font-weight: bold; }
        .ausente { color: #ff5252; font-weight: bold; background: rgba(255, 82, 82, 0.08); }
        .futuro { color: white; font-style: italic; }
        .icon2{ filter: brightness(0) invert(1); width: 24px; vertical-align: middle; }

        .modal-content { background: #030a12; color: white; border: 1px solid rgba(255,255,255,0.08); border-radius: 20px; box-shadow: 0 15px 40px rgba(0,0,0,0.9); }
        .modal-header { border-bottom: 1px solid rgba(255,255,255,0.08); }
        .modal-footer { border-top: 1px solid rgba(255,255,255,0.08); }
        .form-control { background: rgba(255, 255, 255, 0.06); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 10px; }
        .form-control option { background: #030a12; color: white; }
        .form-control:focus { background: rgba(255, 255, 255, 0.1); color: white; box-shadow: none; border-color: #4225a3; }
        .close { color: white; }
        
        .btn-cancelar-rojo {
            background: linear-gradient(35deg, #f74040, #f50404);
            border: none;
            border-radius: 20px;
            padding: 8px 20px;
            color: white;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: transform 0.3s ease;
        }
        .btn-cancelar-rojo:hover { transform: scale(1.03); color: white; text-decoration: none; }

        .btn-eliminar-tabla {
            background: linear-gradient(35deg, #f74040, #f50404);
            border: none;
            border-radius: 20px;
            padding: 6px 14px;
            color: white;
            font-weight: bold;
            font-size: 13px;
            cursor: pointer;
            transition: transform 0.3s ease;
        }
        .btn-eliminar-tabla:hover { transform: scale(1.05); color: white; }
    </style>
</head>
<body>

<div class="contenedor">
    <div class="header-box">
        <h2>Informe de Asistencias y Ausencias <img src="img/acceso.png" class="icon2"></h2>
        <div class="subtitulo-informe">Control mensual detallado de entradas, salidas y estado</div>
        <% if ("admin".equals(rol)) { %>
            <button type="button" class="btn-nuevo" data-toggle="modal" data-target="#modalManual">
                + Registrar Manual
            </button>
        <% } %>
    </div>

    <%= mensajeAlerta %>

<%
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
ResultSet rsConfig = null;
LocalTime horaOficial = LocalTime.of(8, 0); 
int tolerancia = 0;
String nombreEmpleado = "";
String ciEmpleado = "";

try {
    Class.forName("org.postgresql.Driver");
    con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");
    con.createStatement().execute("SET TIME ZONE 'America/Asuncion'");

    // Configuración de horario y tolerancia
    ps = con.prepareStatement("SELECT hora_entrada, tolerancia_minutos FROM configuracion_horario LIMIT 1");
    rsConfig = ps.executeQuery();
    if (rsConfig.next()) {
        horaOficial = rsConfig.getTime("hora_entrada").toLocalTime();
        tolerancia = rsConfig.getInt("tolerancia_minutos");
    }

    // Datos del empleado a consultar
    int personaId = -1;
    try (PreparedStatement psP = con.prepareStatement("SELECT id, nombre, ci FROM personas WHERE ci = ?")) {
        psP.setString(1, ciConsulta);
        try (ResultSet rsP = psP.executeQuery()) {
            if (rsP.next()) {
                personaId = rsP.getInt("id");
                nombreEmpleado = rsP.getString("nombre");
                ciEmpleado = rsP.getString("ci");
            }
        }
    }
%>

    <!-- Formulario de Filtros -->
    <form method="GET" class="filtros-box">
        <% if ("admin".equals(rol)) { %>
            <div>
                <label class="mr-2 mb-0 font-weight-bold text-white">Empleado (CI):</label>
                <input type="text" name="ci_filtro" value="<%= ciConsulta %>" class="form-control d-inline-block w-auto" placeholder="Ingrese CI" required>
            </div>
        <% } %>
        <div>
            <label class="mr-2 mb-0 font-weight-bold text-white">Mes:</label>
            <select name="mes" class="form-control d-inline-block w-auto">
                <% 
                String[] meses = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"};
                for(int i=1; i<=12; i++) { 
                %>
                    <option value="<%= i %>" <%= (i == mesFiltro) ? "selected" : "" %>><%= meses[i-1] %></option>
                <% } %>
            </select>
        </div>
        <div>
            <label class="mr-2 mb-0 font-weight-bold text-white">Año:</label>
            <input type="number" name="anio" value="<%= anioFiltro %>" class="form-control d-inline-block w-auto" style="width: 100px;" required>
        </div>
        <button type="submit" class="btn btn-primary" style="background: #4225a3; border: none; border-radius: 15px; padding: 6px 20px; font-weight: bold; color: white;">Filtrar</button>
    </form>

<%
    // Pre-cálculo de ausencias para mostrar el total en la cabecera de la tabla
    int totalAusencias = 0;
    if (personaId != -1) {
        HashMap<LocalDate, HashMap<String, Object>> mapaAsistenciasTemp = new HashMap<>();
        String sqlAsisTemp = "SELECT fecha FROM asistencias WHERE persona_id = ? AND EXTRACT(YEAR FROM fecha) = ? AND EXTRACT(MONTH FROM fecha) = ?";
        try (PreparedStatement psAsisT = con.prepareStatement(sqlAsisTemp)) {
            psAsisT.setInt(1, personaId);
            psAsisT.setInt(2, anioFiltro);
            psAsisT.setInt(3, mesFiltro);
            try (ResultSet rsAT = psAsisT.executeQuery()) {
                while (rsAT.next()) {
                    mapaAsistenciasTemp.put(rsAT.getDate("fecha").toLocalDate(), null);
                }
            }
        }
        YearMonth ymTemp = YearMonth.of(anioFiltro, mesFiltro);
        for (int d = 1; d <= ymTemp.lengthOfMonth(); d++) {
            LocalDate fd = LocalDate.of(anioFiltro, mesFiltro, d);
            // Cuenta como ausencia si pasó la fecha y no tiene registro cargado
            if (!fd.isAfter(hoyActual) && !mapaAsistenciasTemp.containsKey(fd)) {
                totalAusencias++;
            }
        }
    }
%>

    <% if (personaId != -1) { %>
        <div class="info-resumen-container">
            <div class="info-empleado-pill">
                👤 Empleado: <span style="color: white;"><%= nombreEmpleado %></span> | C.I. Nº: <span style="color: white;"><%= ciEmpleado %></span>
            </div>
            <div class="badge-ausencias">
                ❌ Total de Ausencias: <%= totalAusencias %>
            </div>
        </div>
    <% } %>

    <table>
        <thead>
            <tr>
                <th>Fecha</th>
                <th>Día</th>
                <th>Entrada</th>
                <th>Salida</th>
                <th>Horas Trabajadas</th>
                <th>Min. Tardanza</th>
                <th>Estado</th>
                <% if ("admin".equals(rol)) { %><th>Acciones</th><% } %>
            </tr>
        </thead>
        <tbody>
<%
    if (personaId != -1) {
        // Mapear asistencias del mes seleccionado desde la BD
        HashMap<LocalDate, HashMap<String, Object>> mapaAsistencias = new HashMap<>();
        String sqlAsis = "SELECT id, fecha, hora_entrada, hora_salida, estado FROM asistencias WHERE persona_id = ? AND EXTRACT(YEAR FROM fecha) = ? AND EXTRACT(MONTH FROM fecha) = ?";
        try (PreparedStatement psAsis = con.prepareStatement(sqlAsis)) {
            psAsis.setInt(1, personaId);
            psAsis.setInt(2, anioFiltro);
            psAsis.setInt(3, mesFiltro);
            try (ResultSet rsA = psAsis.executeQuery()) {
                while (rsA.next()) {
                    LocalDate f = rsA.getDate("fecha").toLocalDate();
                    HashMap<String, Object> datos = new HashMap<>();
                    datos.put("id", rsA.getInt("id"));
                    datos.put("entrada", rsA.getTime("hora_entrada"));
                    datos.put("salida", rsA.getTime("hora_salida"));
                    datos.put("estado", rsA.getString("estado"));
                    mapaAsistencias.put(f, datos);
                }
            }
        }

        // Determinar rango de días a mostrar (Desde el día 1 hasta el último día completo del mes seleccionado)
        YearMonth yearMonth = YearMonth.of(anioFiltro, mesFiltro);
        int diasEnMes = yearMonth.lengthOfMonth();

        for (int dia = 1; dia <= diasEnMes; dia++) {
            LocalDate fechaDia = LocalDate.of(anioFiltro, mesFiltro, dia);
            String nombreDiaSemana = fechaDia.getDayOfWeek().getDisplayName(TextStyle.FULL, new Locale("es", "ES"));
            nombreDiaSemana = nombreDiaSemana.substring(0, 1).toUpperCase() + nombreDiaSemana.substring(1);

            HashMap<String, Object> registroAsis = mapaAsistencias.get(fechaDia);
            
            Time horaEntradaDb = registroAsis != null ? (Time) registroAsis.get("entrada") : null;
            Time horaSalidaDb = registroAsis != null ? (Time) registroAsis.get("salida") : null;
            Integer idAsistencia = registroAsis != null ? (Integer) registroAsis.get("id") : null;

            long minutosTardanza = 0;
            if (horaEntradaDb != null) {
                LocalTime entrada = horaEntradaDb.toLocalTime();
                if (entrada.isAfter(horaOficial)) {
                    long totalDiferencia = ChronoUnit.MINUTES.between(horaOficial, entrada);
                    minutosTardanza = (totalDiferencia > tolerancia) ? (totalDiferencia - tolerancia) : 0;
                }
            }

            String horasTrabajadasTexto = "";
            if (horaEntradaDb != null && horaSalidaDb != null) {
                LocalTime entrada = horaEntradaDb.toLocalTime();
                LocalTime salida = horaSalidaDb.toLocalTime();
                long totalMinutosTrabajados = ChronoUnit.MINUTES.between(entrada, salida);
                if (totalMinutosTrabajados < 0) totalMinutosTrabajados = 0;
                
                long horasTotales = totalMinutosTrabajados / 60;
                long minutosRestantes = totalMinutosTrabajados % 60;
                
                if (horasTotales > 0 && minutosRestantes > 0) {
                    horasTrabajadasTexto = horasTotales + "h " + minutosRestantes + "m";
                } else if (horasTotales > 0) {
                    horasTrabajadasTexto = horasTotales + "h";
                } else {
                    horasTrabajadasTexto = minutosRestantes + " min";
                }
            }
%>
            <tr>
                <td><%= fechaDia %></td>
                <td><%= nombreDiaSemana %></td>
                <td><%= horaEntradaDb != null ? horaEntradaDb : "-" %></td>
                <td><%= horaSalidaDb != null ? horaSalidaDb : "-" %></td>
                <td><%= !horasTrabajadasTexto.isEmpty() ? horasTrabajadasTexto : "-" %></td>
                <td><%= horaEntradaDb != null ? minutosTardanza : "-" %></td>
                <td>
                    <% if (registroAsis != null) { %>
                        <span class="<%= minutosTardanza > 0 ? "tarde" : "ok" %>">
                            <%= minutosTardanza > 0 ? "Tardanza" : "Completado" %>
                        </span>
                    <% } else if (fechaDia.isAfter(hoyActual)) { %>
                        <span class="futuro">Próximo</span>
                    <% } else { %>
                        <span class="ausente">Ausente</span>
                    <% } %>
                </td>
                <% if ("admin".equals(rol)) { %>
                <td>
                    <% if (registroAsis != null) { %>
                        <form method="POST" onsubmit="return confirm('¿Está seguro de eliminar este registro de asistencia?');" style="margin: 0;">
                            <input type="hidden" name="accion" value="eliminar_asistencia">
                            <input type="hidden" name="id_asistencia" value="<%= idAsistencia %>">
                            <button type="submit" class="btn-eliminar-tabla">Eliminar</button>
                        </form>
                    <% } else { %>
                        <span style="color: #bbb; font-size: 12px;">Sin registro</span>
                    <% } %>
                </td>
                <% } %>
            </tr>
<%
        }
    } else {
%>
        <tr><td colspan="<%= "admin".equals(rol) ? 8 : 7 %>" class="sin-registros">No se encontró el empleado especificado.</td></tr>
<%
    }
%>
        </tbody>
    </table>

<%
} catch (Exception e) { %> <div class="alert alert-danger mt-3">Error: <%= e.getMessage() %></div> <% } 
finally {
    if (rs != null) rs.close();
    if (rsConfig != null) rsConfig.close();
    if (con != null) con.close();
}
%>

    <div class="boton-centro">
        <a href="<%= "admin".equals(rol) ? "admin.jsp" : "empleado_dashboard.jsp" %>" class="btn-volver">Volver al inicio</a>
    </div>
</div>

<!-- VENTANA MODAL PARA REGISTRO MANUAL -->
<div class="modal fade" id="modalManual" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title font-weight-bold text-white">📝 Registro Manual de Asistencia</h5>
        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <form method="POST">
          <div class="modal-body">
              <input type="hidden" name="accion" value="registrar_manual">
              
              <div class="form-group">
                  <label class="text-white">CI del Empleado:</label>
                  <input type="text" name="ci" class="form-control" required placeholder="Ej: 5023437">
              </div>
              <div class="form-group">
                  <label class="text-white">Fecha:</label>
                  <input type="date" name="fecha" class="form-control" required>
              </div>
              <div class="form-group">
                  <label class="text-white">Hora de Entrada:</label>
                  <input type="time" id="inputEntrada" name="entrada" class="form-control" required onchange="validarEstadoAsistencia()">
              </div>
              <div class="form-group">
                  <label class="text-white">Hora de Salida:</label>
                  <input type="time" name="salida" class="form-control" required>
              </div>
              <div class="form-group">
                  <label class="text-white">Estado:</label>
                  <select id="selectEstado" name="estado" class="form-control">
                      <option value="Completado">Completado</option>
                      <option value="Tardanza">Tardanza</option>
                      <option value="Ausente">Ausente</option>
                  </select>
                  <small id="avisoValidacion" class="form-text text-warning mt-1" style="display:none;"></small>
              </div>
          </div>
          <div class="modal-footer">
              <button type="button" class="btn-cancelar-rojo" data-dismiss="modal">Cancelar</button>
              <button type="submit" class="btn btn-nuevo" style="position:static;">Guardar Registro</button>
          </div>
      </form>
    </div>
  </div>
</div>

<!-- Scripts y lógica de validación automática en JS -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
const HORA_OFICIAL_STR = "<%= horaOficial.toString() %>"; 
const TOLERANCIA_MINUTOS = <%= tolerancia %>;

function validarEstadoAsistencia() {
    const inputEntrada = document.getElementById("inputEntrada").value;
    const selectEstado = document.getElementById("selectEstado");
    const aviso = document.getElementById("avisoValidacion");

    if (!inputEntrada) return;

    const [hOficial, mOficial] = HORA_OFICIAL_STR.split(':').map(Number);
    const totalMinutosOficiales = (hOficial * 60) + mOficial + TOLERANCIA_MINUTOS;

    const [hIngresada, mIngresada] = inputEntrada.split(':').map(Number);
    const totalMinutosIngresados = (hIngresada * 60) + mIngresada;

    for (let option of selectEstado.options) {
        option.disabled = false;
    }

    if (totalMinutosIngresados <= totalMinutosOficiales) {
        selectEstado.value = "Completado";
        selectEstado.querySelector("option[value='Tardanza']").disabled = true;
        selectEstado.querySelector("option[value='Ausente']").disabled = true;
        aviso.style.display = "block";
        aviso.innerText = "ℹ️ Como la entrada está dentro de la hora permitida o tolerancia, el estado se fija automáticamente como Completado.";
    } else {
        selectEstado.value = "Tardanza";
        selectEstado.querySelector("option[value='Completado']").disabled = true;
        aviso.style.display = "block";
        aviso.innerText = "⚠️ La hora ingresada supera el límite permitido. El estado se ha ajustado a Tardanza.";
    }
}
</script>
</body>
</html>
