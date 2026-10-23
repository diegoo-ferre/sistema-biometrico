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
    <title>Historial de Liquidaciones</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; display: flex; align-items: center; justify-content: center; }
        .contenedor { max-width: 1200px; width: 100%; margin: auto; background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 32px; font-weight: bold; }
        
        .btn-custom { border: none; border-radius: 30px; padding: 12px 30px; font-weight: bold; color: white; transition: 0.3s; text-decoration: none; display: inline-block; text-align: center; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); }
        .btn-volver:hover { transform: scale(1.03); color: white; text-decoration: none; }
        
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 20px; padding: 8px 18px; color: white; font-weight: bold; cursor: pointer; transition: 0.3s; font-size: 13px; }
        .btn-eliminar:hover { transform: scale(1.05); color: white; }
        
        .btn-editar { background: linear-gradient(30deg, #4225a3, #000738); border: none; border-radius: 20px; padding: 8px 18px; color: white; font-weight: bold; transition: 0.3s; font-size: 13px; display: inline-block; text-decoration: none; }
        .btn-editar:hover { color: white !important; text-decoration: none; transform: scale(1.05); }
        
        .table-responsive { margin-top: 30px; }
        table { width: 100%; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { text-align: center; padding: 15px; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        tr:hover td { background: rgba(255,255,255,0.04); }
        
        .icon5 { filter: brightness(0) invert(1); width: 32px; vertical-align: middle; margin-left: 5px; }

        .alert-success-custom { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 15px; padding: 12px 20px; margin-bottom: 25px; font-weight: bold; font-size: 14px; text-align: center; }
        .alert-danger-custom { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 15px; padding: 12px 20px; margin-bottom: 25px; font-weight: bold; font-size: 14px; text-align: center; }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Historial de Liquidaciones por Período <img src="img/calendario.png" class="icon5"></h2>

<%
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
String mensaje = null;
String tipoMensaje = "exito";

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
        mensaje = "¡Período eliminado correctamente!";
        tipoMensaje = "exito";
    }
%>

<% if (mensaje != null) { %>
    <% if ("exito".equals(tipoMensaje)) { %>
        <div class="alert-success-custom" role="alert"><%= mensaje %></div>
    <% } else { %>
        <div class="alert-danger-custom" role="alert"><%= mensaje %></div>
    <% } %>
<% } %>

    <div class="table-responsive">
        <table>
            <thead>
                <tr>
                    <th>Mes</th>
                    <th>Año</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
            <%
                Statement st = con.createStatement();
                rs = st.executeQuery("SELECT DISTINCT mes, anio FROM salarios WHERE mes IS NOT NULL AND anio IS NOT NULL ORDER BY anio DESC, mes DESC");
                
                boolean hay = false;
                while (rs.next()) {
                    hay = true;
                    int mes = rs.getInt("mes");
                    int anio = rs.getInt("anio");
            %>
                <tr>
                    <td><strong><%= mes %></strong></td>
                    <td><strong><%= anio %></strong></td>
                    <td>
                        <div style="display:flex; gap:10px; justify-content:center; align-items:center;">
                            <a href="ver_liquidaciones.jsp?mes=<%= mes %>&anio=<%= anio %>" class="btn-editar">Ver Liquidaciones</a>
                            
                            <form method="post" style="margin:0;" onsubmit="return confirm('¿Seguro que deseas eliminar TODAS las liquidaciones de este mes/año?');">
                                <input type="hidden" name="accion" value="eliminar_periodo">
                                <input type="hidden" name="mes" value="<%= mes %>">
                                <input type="hidden" name="anio" value="<%= anio %>">
                                <button type="submit" class="btn-eliminar">Eliminar Todo</button>
                            </form>
                        </div>
                    </td>
                </tr>
            <% 
                } 
                rs.close();
                st.close();
                if (!hay) {
            %>
                <tr><td colspan="3" class="text-center text-muted py-4">No hay períodos de liquidación registrados.</td></tr>
            <% } %>
            </tbody>
        </table>
    </div>

<%
} catch (Exception e) { 
    out.println("<div class='alert-danger-custom'>Error: " + e.getMessage() + "</div>");
} finally {
    try { if (rs != null) rs.close(); if (con != null) con.close(); } catch (Exception e) {}
}
%>
    <div class="text-center mt-4">
        <a href="admin.jsp" class="btn-custom btn-volver">Volver al Inicio</a>
    </div>
</div>
</body>
</html>