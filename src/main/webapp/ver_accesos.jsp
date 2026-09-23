<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>

<%
// 🔐 Verificación de sesión
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Obtenemos rol y ci de la sesión
String rol = (String) session.getAttribute("rol");
String ciUsuario = (String) session.getAttribute("ci");

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
            // CORRECCIÓN: Restamos 3 horas directamente para contrarrestar el desfase del servidor en la nube
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
    <title>Historial de Accesos</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 1500px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        
        .header-box { position: relative; display: flex; align-items: center; justify-content: center; margin-bottom: 30px; }
        h2 { text-align: center; font-size: 38px; font-weight: bold; margin: 0; width: 100%; }
        
        .btn-nuevo { 
            position: absolute; 
            right: 0; 
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

        table { width: 100%; margin-top: 25px; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { text-align: center; padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); }
        tr:hover td { background: rgba(255,255,255,0.04); }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 25px; padding: 12px 24px; color: white; font-weight: bold; text-decoration: none; display: inline-block; margin-top: 25px; }
        .btn-volver:hover { color: white; text-decoration: none; }
        .boton-centro { text-align: center; }
        .sin-registros { text-align: center; padding: 20px; color: #d0d8df; }
        .ok { color: #00e676; font-weight: bold; }
        .tarde { color: #ffd54f; font-weight: bold; }
        .icon2{ filter: brightness(0) invert(1); }

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
        <h2>Historial de Accesos <img src="img/acceso.png" class="icon2"></h2>
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

try {
    Class.forName("org.postgresql.Driver");
    con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");
    con.createStatement().execute("SET TIME ZONE 'America/Asuncion'");

    ps = con.prepareStatement("SELECT hora_entrada, tolerancia_minutos FROM configuracion_horario LIMIT 1");
    rsConfig = ps.executeQuery();
    if (rsConfig.next()) {
        horaOficial = rsConfig.getTime("hora_entrada").toLocalTime();
        tolerancia = rsConfig.getInt("tolerancia_minutos");
    }

    String sql = "SELECT a.id, p.nombre, p.ci, a.fecha, a.hora_entrada, a.hora_salida, a.estado " +
                 "FROM asistencias a JOIN personas p ON a.persona_id = p.id ";
    
    if (!"admin".equals(rol)) {
        sql += "WHERE p.ci = ? ORDER BY a.id DESC";
        ps = con.prepareStatement(sql);
        ps.setString(1, ciUsuario);
    } else {
        sql += "ORDER BY a.id DESC";
        ps = con.prepareStatement(sql);
    }
    
    rs = ps.executeQuery();
%>

    <table>
        <thead>
            <tr>
                <th>id</th><th>nombre</th><th>ci</th><th>fecha</th><th>entrada</th>
                <th>salida</th><th>horas trabajadas</th><th>minutos tardanza</th><th>estado</th>
                <% if ("admin".equals(rol)) { %><th>acciones</th><% } %>
            </tr>
        </thead>
        <tbody>
<%
    boolean hay = false;
    while (rs.next()) {
        hay = true;
        int idAsistencia = rs.getInt("id");
        Time horaEntradaDb = rs.getTime("hora_entrada");
        Time horaSalidaDb = rs.getTime("hora_salida");
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
            
            if (totalMinutosTrabajados < 0) {
                totalMinutosTrabajados = 0;
            }
            
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
                <td><%= idAsistencia %></td>
                <td><%= rs.getString("nombre") %></td>
                <td><%= rs.getString("ci") %></td>
                <td><%= rs.getDate("fecha") %></td>
                <td><%= horaEntradaDb != null ? horaEntradaDb : "" %></td>
                <td><%= horaSalidaDb != null ? horaSalidaDb : "" %></td>
                <td><%= horasTrabajadasTexto %></td>
                <td><%= minutosTardanza %></td>
                <td>
                    <span class="<%= minutosTardanza > 0 ? "tarde" : "ok" %>">
                        <%= minutosTardanza > 0 ? "Tardanza" : "Completado" %>
                    </span>
                </td>
                <% if ("admin".equals(rol)) { %>
                <td>
                    <form method="POST" onsubmit="return confirm('¿Está seguro de eliminar este registro de asistencia?');" style="margin: 0;">
                        <input type="hidden" name="accion" value="eliminar_asistencia">
                        <input type="hidden" name="id_asistencia" value="<%= idAsistencia %>">
                        <button type="submit" class="btn-eliminar-tabla">Eliminar</button>
                    </form>
                </td>
                <% } %>
            </tr>
<%
    }
    if (!"admin".equals(rol)) {
        if (!hay) { %> <tr><td colspan="9" class="sin-registros">No hay accesos registrados para mostrar.</td></tr> <% }
    } else {
        if (!hay) { %> <tr><td colspan="10" class="sin-registros">No hay accesos registrados para mostrar.</td></tr> <% }
    }
%>
        </tbody>
    </table>

<%
} catch (Exception e) { %> <div class="alert alert-danger">Error: <%= e.getMessage() %></div> <% } 
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
        <h5 class="modal-title font-weight-bold">📝 Registro Manual de Asistencia</h5>
        <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <form method="POST">
          <div class="modal-body">
              <input type="hidden" name="accion" value="registrar_manual">
              
              <div class="form-group">
                  <label>CI del Empleado:</label>
                  <input type="text" name="ci" class="form-control" required placeholder="Ej: 6091399">
              </div>
              <div class="form-group">
                  <label>Fecha de la Hoja:</label>
                  <input type="date" name="fecha" class="form-control" required>
              </div>
              <div class="form-group">
                  <label>Hora de Entrada:</label>
                  <input type="time" id="inputEntrada" name="entrada" class="form-control" required onchange="validarEstadoAsistencia()">
              </div>
              <div class="form-group">
                  <label>Hora de Salida:</label>
                  <input type="time" name="salida" class="form-control" required>
              </div>
              <div class="form-group">
                  <label>Estado:</label>
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
