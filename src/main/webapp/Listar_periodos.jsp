<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Historial de Liquidaciones</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 1200px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 38px; font-weight: bold; }
        .btn-custom { border: none; border-radius: 25px; padding: 12px 25px; font-weight: bold; color: white; transition: 0.3s; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); }
        .btn-volver:hover { transform: scale(1.03); color: white; text-decoration: none; }
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 20px; padding: 8px 18px; color: white; font-weight: bold; cursor: pointer; }
        .btn-editar { background: linear-gradient(30deg, #4225a3, #000738); border: none; border-radius: 20px; padding: 8px 18px; color: white; font-weight: bold; }
        .btn-editar:hover { color: white !important; text-decoration: none; }
        table { width: 100%; margin-top: 30px; color: white; border-collapse: collapse; }
        th, td { text-align: center; padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); }
        th { background: rgba(255,255,255,0.08); }
        .icon5 { filter: brightness(0) invert(1); }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Historial de Liquidaciones por Período <img src="img/calendario.png" class="icon5"></h2>

<%
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("org.postgresql.Driver");
    con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");

    // Lógica para eliminar el período completo basándose en las columnas mes y anio
    if ("POST".equalsIgnoreCase(request.getMethod()) && "eliminar_periodo".equals(request.getParameter("accion"))) {
        int mVal = Integer.parseInt(request.getParameter("mes"));
        int aVal = Integer.parseInt(request.getParameter("anio"));
        
        ps = con.prepareStatement("DELETE FROM salarios WHERE mes = ? AND anio = ?");
        ps.setInt(1, mVal);
        ps.setInt(2, aVal);
        ps.executeUpdate();
        ps.close();
        out.println("<div class='alert alert-success'>Período eliminado correctamente.</div>");
    }
%>

    <table>
        <thead>
            <tr>
                <th>Mes</th><th>Año</th><th>Acción</th>
            </tr>
        </thead>
        <tbody>
        <%
            Statement st = con.createStatement();
            // Agrupamos directamente por las columnas mes y anio de la tabla salarios
            rs = st.executeQuery("SELECT DISTINCT mes, anio FROM salarios WHERE mes IS NOT NULL AND anio IS NOT NULL ORDER BY anio DESC, mes DESC");
            
            while (rs.next()) {
                int mes = rs.getInt("mes");
                int anio = rs.getInt("anio");
        %>
            <tr>
                <td><%= mes %></td>
                <td><%= anio %></td>
                <td>
                    <a href="ver_liquidaciones.jsp?mes=<%= mes %>&anio=<%= anio %>" class="btn btn-editar">Ver Liquidaciones</a>
                    
                    <form method="post" style="display:inline;" onsubmit="return confirm('¿Seguro que deseas eliminar TODAS las liquidaciones de este mes/año?');">
                        <input type="hidden" name="accion" value="eliminar_periodo">
                        <input type="hidden" name="mes" value="<%= mes %>">
                        <input type="hidden" name="anio" value="<%= anio %>">
                        <button type="submit" class="btn-eliminar">Eliminar Todo</button>
                    </form>
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>

<%
} catch (Exception e) { 
    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
} finally {
    try { if (rs != null) rs.close(); if (con != null) con.close(); } catch (Exception e) {}
}
%>
    <div class="text-center mt-4"><a href="admin.jsp" class="btn-custom btn-volver">Volver al inicio</a></div>
</div>
</body>
</html>