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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bonificaciones</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 1200px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 38px; font-weight: bold; }
        .form-control, .custom-select { border-radius: 15px; padding: 12px; }
        .btn-custom { border: none; border-radius: 25px; padding: 12px 25px; font-weight: bold; color: white; transition: 0.3s; }
        .btn-guardar { background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); }
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 20px; padding: 8px 18px; color: white; font-weight: bold; }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
        table { width: 100%; margin-top: 30px; color: white; }
        th, td { text-align: center; padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); }
        th { background: rgba(255,255,255,0.08); }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Configuración de Bonificaciones</h2>

<%
Connection con = null;
PreparedStatement ps = null;
Statement st = null;
ResultSet rs = null;
String mensaje = null;

try {
    Class.forName("org.postgresql.Driver");
    con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String accion = request.getParameter("accion");
        if ("guardar".equals(accion)) {
            ps = con.prepareStatement("insert into tipos_bonificacion (nombre, tipo, valor, activo) values (?, ?, ?, true)");
            ps.setString(1, request.getParameter("nombre"));
            ps.setString(2, request.getParameter("tipo"));
            ps.setDouble(3, Double.parseDouble(request.getParameter("valor")));
            ps.executeUpdate();
            ps.close();
            mensaje = "Bonificación guardada correctamente.";
        } else if ("eliminar".equals(accion)) {
            // Borrado lógico: cambiamos activo a false en lugar de borrar la fila
            ps = con.prepareStatement("update tipos_bonificacion set activo = false where id = ?");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            ps.close();
            mensaje = "Bonificación desactivada correctamente.";
        }
    }
%>

<% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje %></div><% } %>

    <form method="post">
        <input type="hidden" name="accion" value="guardar">
        <div class="row">
            <div class="col-md-4 mb-3">
                <label>Nombre de la Bonificación</label>
                <input type="text" name="nombre" class="form-control" required>
            </div>
            <div class="col-md-4 mb-3">
                <label>Tipo</label>
                <select name="tipo" class="custom-select" required>
                    <option value="fijo">Monto fijo</option>
                    <option value="porcentaje">Porcentaje</option>
                </select>
            </div>
            <div class="col-md-4 mb-3">
                <label>Valor</label>
                <input type="number" step="0.01" name="valor" class="form-control" required>
            </div>
        </div>
        <div class="text-center mt-3">
            <button type="submit" class="btn-custom btn-guardar">Guardar Bonificación</button>
        </div>
    </form>

    <table>
        <thead>
            <tr>
                <th>ID</th><th>Nombre</th><th>Tipo</th><th>Valor</th><th>Acción</th>
            </tr>
        </thead>
        <tbody>
        <%
            st = con.createStatement();
            // Filtramos solo los activos
            rs = st.executeQuery("select * from tipos_bonificacion where activo = true order by id desc");
            while (rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("nombre") %></td>
                <td><%= rs.getString("tipo") %></td>
                <td><%= "porcentaje".equals(rs.getString("tipo")) ? rs.getDouble("valor")+"%" : "Gs. "+rs.getDouble("valor") %></td>
                <td>
                    <form method="post" onsubmit="return confirm('¿Desactivar esta bonificación?');">
                        <input type="hidden" name="accion" value="eliminar">
                        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
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
    try { if (rs != null) rs.close(); if (st != null) st.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
}
%>
    <div class="text-center mt-4"><a href="admin.jsp" class="btn-custom btn-volver">Volver al inicio</a></div>
</div>
</body>
</html>