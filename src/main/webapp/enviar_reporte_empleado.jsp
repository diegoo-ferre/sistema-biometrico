<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
if (session == null || session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

String usuarioLogueado = (String) session.getAttribute("usuario");
String tipoIncidencia = request.getParameter("tipo_incidencia");
String fechaIncidente = request.getParameter("fecha");
String motivoJustificacion = request.getParameter("motivo");

if (tipoIncidencia == null || fechaIncidente == null || motivoJustificacion == null ||
    tipoIncidencia.trim().isEmpty() || fechaIncidente.trim().isEmpty() || motivoJustificacion.trim().isEmpty()) {
    response.sendRedirect("empleado_dashboard.jsp?error=campos_incompletos");
    return;
}

Connection con = null;
PreparedStatement psPersona = null;
PreparedStatement psInsert = null;
ResultSet rsPersona = null;

try {
    Class.forName("org.postgresql.Driver");
    con = DriverManager.getConnection(
        "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", 
        "neondb_owner", 
        "npg_6rt8OdayAHcm"
    );

    int personaId = 0;

    // 1. Intentar obtener el ID desde la sesión si ya fue guardado previamente
    if (session.getAttribute("persona_id") != null) {
        try {
            personaId = Integer.parseInt(session.getAttribute("persona_id").toString());
        } catch (Exception e) {}
    }

    // 2. Si no está en sesión, buscarlo directamente en la base de datos (por nombre o por la tabla usuarios)
    if (personaId <= 0) {
        psPersona = con.prepareStatement(
            "SELECT id FROM personas WHERE LOWER(nombre) = LOWER(?) OR ci IN " +
            "(SELECT usuario FROM usuarios WHERE LOWER(usuario) = LOWER(?)) LIMIT 1"
        );
        psPersona.setString(1, usuarioLogueado);
        psPersona.setString(2, usuarioLogueado);
        rsPersona = psPersona.executeQuery();

        if (rsPersona.next()) {
            personaId = rsPersona.getInt("id");
            // Guardarlo en sesión para futuras consultas
            session.setAttribute("persona_id", personaId);
        }
    }

    if (personaId > 0) {
        // 3. Insertar el reporte en la tabla reportes_empleado
        psInsert = con.prepareStatement(
            "INSERT INTO reportes_empleado (persona_id, tipo_incidencia, fecha, motivo, estado) VALUES (?, ?, ?, ?, 'Pendiente')"
        );
        psInsert.setInt(1, personaId);
        psInsert.setString(2, tipoIncidencia);
        psInsert.setDate(3, Date.valueOf(fechaIncidente));
        psInsert.setString(4, motivoJustificacion);
        psInsert.executeUpdate();

        response.sendRedirect("empleado_dashboard.jsp?reporte_enviado=exito");
    } else {
        response.sendRedirect("empleado_dashboard.jsp?error=persona_no_encontrada");
    }

} catch(Exception e) {
    out.println("Error: " + e.getMessage());
} finally {
    if (rsPersona != null) try { rsPersona.close(); } catch(Exception ex) {}
    if (psPersona != null) try { psPersona.close(); } catch(Exception ex) {}
    if (psInsert != null) try { psInsert.close(); } catch(Exception ex) {}
    if (con != null) try { con.close(); } catch(Exception ex) {}
}
%>
