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
        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px 15px;
        }

        .contenedor {
            background: rgba(10, 15, 25, 0.85);
            padding: 40px 35px;
            border-radius: 25px;
            color: white;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
            width: 98%;
            max-width: 1300px;
        }

        h2 {
            text-align: center;
            font-size: 40px;
            font-weight: bold;
            margin-bottom: 30px;
        }

        table {
            width: 100%;
            color: white;
            border-collapse: collapse;
            margin-top: 20px;
            background: rgba(255,255,255,0.03);
            border-radius: 15px;
            overflow: hidden;
        }

        th, td {
            padding: 14px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.08);
            vertical-align: middle;
        }

        th {
            background: rgba(255,255,255,0.08);
            font-size: 16px;
        }

        tr:hover td {
            background: rgba(255,255,255,0.04);
        }

        .foto-mini {
            width: 90px;
            height: 70px;
            object-fit: cover;
            border-radius: 10px;
            border: 2px solid rgba(255,255,255,0.08);
            margin: 3px;
        }

        .acciones-form {
            margin: 0;
        }

        .btn-eliminar {
            background: linear-gradient(35deg, #f74040, #f50404);
            color: white; 
            border-radius: 20px;
            padding: 8px 18px;
            font-weight: bold;
        }

        .btn-volver {
            background: linear-gradient(35deg, #f74040, #f50404);
            color: white; 
            font-weight: bold; 
            display: inline-block;
            margin-top: 25px;
            border-radius: 25px;
            padding: 12px 26px;
            font-size: 16px;
            text-decoration: none; 
        }
        .btn-volver:hover {
            color: white;           
            text-decoration: none;  
            cursor: pointer;        
        }

        .mensaje {
            margin-bottom: 20px;
        }

        .sin-registros {
            text-align: center;
            padding: 20px;
            color: #d0d8df;
        }

        .boton-centro {
            text-align: center;
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Personas Registradas</h2>

<%
String mensaje = null;
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
Statement st = null;

try {
    Class.forName("org.postgresql.Driver");

  String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String idEliminar = request.getParameter("idEliminar");

        if (idEliminar != null && !idEliminar.trim().equals("")) {
            ps = con.prepareStatement("delete from personas where id = ?");
            ps.setInt(1, Integer.parseInt(idEliminar));
            ps.executeUpdate();
            ps.close();
            mensaje = "registro eliminado correctamente.";
        }
    }

    st = con.createStatement();
    rs = st.executeQuery("select * from personas order by id desc");

    if (mensaje != null) {
%>
        <div class="alert alert-success mensaje"><%= mensaje %></div>
<%
    }
%>

    <table>
        <thead>
            <tr>
                <th>id</th>
                <th>nombre</th>
                <th>ci</th>
                <th>fecha y hora</th>
                <th>fotos</th>
                <th>acción</th>
            </tr>
        </thead>
        <tbody>
<%
    boolean hayRegistros = false;
    SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

    while (rs.next()) {
        hayRegistros = true;
        Timestamp fecha = rs.getTimestamp("fecha_registro");
%>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("nombre") %></td>
                <td><%= rs.getString("ci") %></td>
                <td><%= fecha != null ? formato.format(fecha) : "" %></td>
                <td>
                    <% if (rs.getString("foto1") != null) { %><img src="<%= rs.getString("foto1") %>" class="foto-mini"><% } %>
                    <% if (rs.getString("foto2") != null) { %><img src="<%= rs.getString("foto2") %>" class="foto-mini"><% } %>
                    <% if (rs.getString("foto3") != null) { %><img src="<%= rs.getString("foto3") %>" class="foto-mini"><% } %>
                    <% if (rs.getString("foto4") != null) { %><img src="<%= rs.getString("foto4") %>" class="foto-mini"><% } %>
                    <% if (rs.getString("foto5") != null) { %><img src="<%= rs.getString("foto5") %>" class="foto-mini"><% } %>
                </td>
                <td>
                    <form method="post" class="acciones-form">
                        <input type="hidden" name="idEliminar" value="<%= rs.getInt("id") %>">
                        <button type="submit" class="btn btn-danger btn-eliminar">eliminar</button>
                    </form>
                </td>
            </tr>
<%
    }

    if (!hayRegistros) {
%>
            <tr>
                <td colspan="6" class="sin-registros">no hay registros guardados.</td>
            </tr>
<%
    }
%>
        </tbody>
    </table>

<%
} catch (Exception e) {
%>
    <div class="alert alert-danger mensaje">
        Error: <%= e.getMessage() %>
    </div>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (st != null) st.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

    <div class="boton-centro">
        <a href="admin.jsp" class="btn-volver">Volver al inicio</a>
    </div>
</div>

</body>
</html>