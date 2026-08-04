<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lista de Personas</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <style>
        body { margin: 0; min-height: 100vh; font-family: Arial, sans-serif; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); display: flex; align-items: center; justify-content: center; padding: 30px 15px; }
        .contenedor { background: rgba(10, 15, 25, 0.85); padding: 40px 35px; border-radius: 25px; color: white; box-shadow: 0 10px 40px rgba(0,0,0,0.9); width: 98%; max-width: 1300px; }
        h2 { text-align: center; font-size: 40px; font-weight: bold; margin-bottom: 30px; }
        
        .btn-custom { display: block; width: 100%; max-width: 360px; margin: 10px auto; padding: 12px; border: none; border-radius: 30px; color: white; font-weight: bold; text-decoration: none; transition: 0.3s; background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-custom:hover { transform: scale(1.03); color: white; text-decoration: none; }

        .filtro-box { margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
        .filtro-box input { width: 100%; max-width: 300px; padding: 10px 15px; border-radius: 20px; border: none; background: rgba(255,255,255,0.1); color: white; outline: none; }
        table { width: 100%; color: white; border-collapse: collapse; margin-top: 10px; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { padding: 14px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); font-size: 16px; }
        tr:hover td { background: rgba(255,255,255,0.04); }
        .foto-mini { width: 55px; height: 45px; object-fit: cover; border-radius: 8px; border: 2px solid rgba(255,255,255,0.08); margin: 2px; }
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); color: white; border-radius: 20px; padding: 8px 18px; font-weight: bold; border: none; transition: 0.3s; }
        .btn-eliminar:hover { transform: scale(1.03); color: white; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); color: white; font-weight: bold; display: inline-block; margin-top: 25px; border-radius: 25px; padding: 12px 26px; font-size: 16px; text-decoration: none; transition: 0.3s; }
        .btn-volver:hover { color: white; text-decoration: none; cursor: pointer; transform: scale(1.03); }
        .boton-centro { text-align: center; }
        .icon { filter: brightness(0) invert(1); }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Personas Registradas <img src="img/personas (1).png" class="icon"></h2>

    <div class="filtro-box">
        <input type="text" id="filtroInput" onkeyup="filtrarTabla()" placeholder="🔍 Buscar por nombre...">
        <a href="registro.jsp" class="btn-custom" style="margin: 0; padding: 10px 25px; width: auto;">+ Nuevo Registro</a>
    </div>

<%
String mensaje = null;
Connection con = null;
try {
    Class.forName("org.postgresql.Driver");
    con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String idEliminar = request.getParameter("idEliminar");
        if (idEliminar != null) {
            PreparedStatement psDel = con.prepareStatement("delete from personas where id = ?");
            psDel.setInt(1, Integer.parseInt(idEliminar));
            psDel.executeUpdate();
            psDel.close();
            mensaje = "Registro eliminado.";
        }
    }
%>

    <table id="tablaPersonas">
        <thead>
            <tr><th>nombre</th><th>ci</th><th>fecha y hora</th><th>fotos</th><th>acción</th></tr>
        </thead>
        <tbody>
<%
    ResultSet rs = con.createStatement().executeQuery("select * from personas order by id desc");
    SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    while (rs.next()) {
%>
            <tr>
                <td><%= rs.getString("nombre") %></td>
                <td><%= rs.getString("ci") %></td>
                <td><%= formato.format(rs.getTimestamp("fecha_registro")) %></td>
                <td>
                    <div style="display: flex; flex-wrap: wrap; justify-content: center; max-width: 220px; margin: 0 auto;">
                        <% for(int i=1; i<=5; i++){ if(rs.getString("foto"+i)!=null){ %><img src="<%= rs.getString("foto"+i) %>" class="foto-mini"><% }} %>
                    </div>
                </td>
                <td>
                    <div style="display: flex; gap: 8px; justify-content: center; align-items: center;">
                        <form method="post" style="margin: 0;">
                            <input type="hidden" name="idEliminar" value="<%= rs.getInt("id") %>">
                            <button type="submit" class="btn-eliminar">Eliminar</button>
                        </form>
                        <a href="editar_persona.jsp?id=<%= rs.getInt("id") %>" class="btn-custom" style="margin:0; padding: 8px 18px; width:auto; font-size: 14px; display: inline-block;">Editar</a>
                    </div>
                </td>
            </tr>
<%  } rs.close(); con.close(); %>
        </tbody>
    </table>
<% } catch (Exception e) { out.println("Error: " + e.getMessage()); } %>

    <div class="boton-centro">
        <a href="admin.jsp" class="btn-volver">Volver al inicio</a>
    </div>
</div>

<script>
    function filtrarTabla() {
        let input = document.getElementById("filtroInput").value.toUpperCase();
        let tr = document.getElementById("tablaPersonas").getElementsByTagName("tr");
        for (let i = 1; i < tr.length; i++) {
            let td = tr[i].getElementsByTagName("td")[0];
            tr[i].style.display = (td && td.textContent.toUpperCase().indexOf(input) > -1) ? "" : "none";
        }
    }
</script>

</body>
</html>