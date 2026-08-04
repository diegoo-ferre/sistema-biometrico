<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Usuarios</title>
    <style>
        body { margin: 0; min-height: 100vh; font-family: Arial, sans-serif; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); display: flex; align-items: center; justify-content: center; padding: 30px; color: white; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); width: 95%; max-width: 900px; }
        h2 { text-align: center; margin-bottom: 30px; }
        
        /* Contenedor flex para alinear filtro y botón */
        .filtro-box { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; gap: 15px; }
        .filtro-box input { width: 100%; max-width: 300px; padding: 10px; border-radius: 20px; border: none; background: rgba(255,255,255,0.1); color: white; outline: none; }
        
        table { width: 100%; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { padding: 15px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.08); }
        th { background: rgba(255,255,255,0.08); }
        
        /* Botones estilo solicitado */
        .btn-accion { padding: 8px 15px; border-radius: 20px; border: none; color: white !important; font-weight: bold; cursor: pointer; transition: transform 0.3s ease; text-decoration: none !important; display: inline-block; }
        .btn-accion:hover { transform: scale(1.05); color: white !important; }
        .btn-edit { background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-del { background: linear-gradient(35deg, #f74040, #f50404); }
        
        /* Botón Nuevo Usuario */
        .btn-nuevo { background: linear-gradient(30deg, #4225a3, #000738); padding: 10px 20px; }
        
        .btn-custom { display: block; width: 100%; max-width: 360px; margin: 10px auto; padding: 12px; border: none; border-radius: 30px; color: white; font-weight: bold; text-decoration: none; transition: 0.3s; background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }
        .btn-cerrar { background: linear-gradient(35deg, #f74040, #f50404); margin-top: 20px; } 
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Gestión de Usuarios</h2>
    
    <div class="filtro-box">
        <input type="text" id="filtroUsuario" onkeyup="filtrarUsuarios()" placeholder="🔍 Buscar usuario...">
        <a href="registro_usuario.jsp" class="btn-accion btn-nuevo">+ Nuevo Usuario</a>
    </div>
    
<%
String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
try (Connection con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm")) {
    
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("idDel") != null) {
        try (PreparedStatement ps = con.prepareStatement("DELETE FROM usuarios WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(request.getParameter("idDel")));
            ps.executeUpdate();
        }
    }
%>

    <table id="tablaUsuarios">
        <thead>
            <tr><th>Usuario</th><th>CI (Password)</th><th>Rol</th><th>Acciones</th></tr>
        </thead>
        <tbody>
<%
    ResultSet rs = con.createStatement().executeQuery("SELECT * FROM usuarios ORDER BY id DESC");
    while (rs.next()) {
%>
            <tr>
                <td><%= rs.getString("usuario") %></td>
                <td><%= rs.getString("password") %></td>
                <td><%= rs.getString("rol") %></td>
                <td>
                    <div style="display:flex; gap:10px; justify-content:center;">
                        <a href="editar_usuario.jsp?id=<%= rs.getInt("id") %>" class="btn-accion btn-edit">Editar</a>
                        <form method="post" onsubmit="return confirm('¿Eliminar este usuario?');">
                            <input type="hidden" name="idDel" value="<%= rs.getInt("id") %>">
                            <button type="submit" class="btn-accion btn-del">Eliminar</button>
                        </form>
                    </div>
                </td>
            </tr>
<%  } rs.close(); %>
        </tbody>
    </table>
<% } catch (Exception e) { out.println("Error: " + e.getMessage()); } %>

    <div style="text-align:center;">
        <a href="admin.jsp" class="btn-custom btn-cerrar">Volver al Inicio</a>
    </div>
</div>

<script>
    function filtrarUsuarios() {
        let input = document.getElementById("filtroUsuario").value.toUpperCase();
        let tr = document.getElementById("tablaUsuarios").getElementsByTagName("tr");
        for (let i = 1; i < tr.length; i++) {
            let td = tr[i].getElementsByTagName("td")[0];
            tr[i].style.display = (td && td.textContent.toUpperCase().indexOf(input) > -1) ? "" : "none";
        }
    }
</script>
</body>
</html>