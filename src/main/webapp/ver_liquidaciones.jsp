<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
DecimalFormat guarani = new DecimalFormat("###,###,###");
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liquidaciones del Período</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 1250px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 38px; font-weight: bold; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 25px; padding: 12px 24px; color: white; font-weight: bold; text-decoration: none; display: inline-block; margin-top: 25px; }
        .btn-volver:hover { color: white !important; text-decoration: none; }
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 20px; padding: 8px 18px; color: white; font-weight: bold; cursor: pointer; }
        /* Estilo para el filtro */
        .filtro-box { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
        .filtro-box input { width: 100%; max-width: 300px; padding: 10px 15px; border-radius: 20px; border: none; background: rgba(255,255,255,0.1); color: white; outline: none; }
        
        table { width: 100%; margin-top: 30px; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { text-align: center; padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); }
        .icon5 { filter: brightness(0) invert(1); }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Liquidaciones del Período: <%= mes %> / <%= anio %></h2>

    <div class="filtro-box">
        <input type="text" id="filtroInput" onkeyup="filtrarTabla()" placeholder="🔍 Buscar por nombre...">
    </div>

<%
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("org.postgresql.Driver");
    con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");

    ps = con.prepareStatement("SELECT s.*, p.nombre, p.ci FROM salarios s JOIN personas p ON s.persona_id = p.id WHERE EXTRACT(MONTH FROM s.fecha_registro) = ? AND EXTRACT(YEAR FROM s.fecha_registro) = ? ORDER BY s.id DESC");
    ps.setInt(1, Integer.parseInt(mes));
    ps.setInt(2, Integer.parseInt(anio));
    rs = ps.executeQuery();
%>

    <table id="tablaPersonas">
        <thead>
            <tr><th>ID</th><th>Nombre</th><th>CI</th><th>Sueldo Final</th><th>Fecha</th><th>Acción</th></tr>
        </thead>
        <tbody>
        <% while (rs.next()) { %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("nombre") %></td>
                <td><%= rs.getString("ci") %></td>
                <td>Gs. <%= guarani.format(rs.getDouble("sueldo_final")) %></td>
                <td><%= sdf.format(rs.getTimestamp("fecha_registro")) %></td>
                <td>
                    <form method="post" action="eliminar_historial.jsp" onsubmit="return confirm('¿Seguro de eliminar esta liquidación?');">
                        <input type="hidden" name="idEliminar" value="<%= rs.getInt("id") %>">
                        <button type="submit" class="btn-eliminar">Eliminar</button>
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
    if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close();
}
%>
    <div class="text-center"><a href="Listar_periodos.jsp" class="btn-volver">Volver al listado</a></div>
</div>

<script>
    function filtrarTabla() {
        let input = document.getElementById("filtroInput").value.toUpperCase();
        let tr = document.getElementById("tablaPersonas").getElementsByTagName("tr");
        for (let i = 1; i < tr.length; i++) {
            let td = tr[i].getElementsByTagName("td")[1];
            tr[i].style.display = (td && td.textContent.toUpperCase().indexOf(input) > -1) ? "" : "none";
        }
    }
</script>

</body>
</html>