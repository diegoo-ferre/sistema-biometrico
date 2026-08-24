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
        h2 { text-align: center; margin-bottom: 30px; font-size: 38px; font-weight: bold; }
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
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Historial de Accesos <img src="img/acceso.png" class="icon2"></h2>

<%
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
ResultSet rsConfig = null;

try {
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
    con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");
    con.createStatement().execute("SET TIME ZONE 'America/Asuncion'");

    ps = con.prepareStatement("SELECT hora_entrada, tolerancia_minutos FROM configuracion_horario LIMIT 1");
    rsConfig = ps.executeQuery();
    LocalTime horaOficial = LocalTime.of(8, 0); 
    int tolerancia = 0;
    if (rsConfig.next()) {
        horaOficial = rsConfig.getTime("hora_entrada").toLocalTime();
        tolerancia = rsConfig.getInt("tolerancia_minutos");
    }

    // LÓGICA DE FILTRADO: Si es admin, ve todo. Si es empleado, solo su CI.
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
            </tr>
        </thead>
        <tbody>
<%
    boolean hay = false;
    while (rs.next()) {
        hay = true;
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

        // Lógica para formatear las horas trabajadas de forma entendible (sin decimales)
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
                <td><%= rs.getInt("id") %></td>
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
            </tr>
<%
    }
    if (!hay) { %> <tr><td colspan="9" class="sin-registros">No hay accesos registrados para mostrar.</td></tr> <% } %>
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

</body>
</html>
