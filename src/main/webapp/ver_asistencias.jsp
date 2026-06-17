<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

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
    <title>Historial de Asistencias</title>
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
            padding: 40px;
            border-radius: 25px;
            color: white;
            width: 98%;
            max-width: 1400px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        h2 {
            text-align: center;
            font-size: 38px;
            margin-bottom: 25px;
            font-weight: bold;
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
            padding: 12px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.08);
            vertical-align: middle;
        }

        th {
            background: rgba(255,255,255,0.1);
        }

        tr:hover td {
            background: rgba(255,255,255,0.05);
        }

        .btn-volver {
            margin-top: 20px;
            border-radius: 25px;
            padding: 12px 26px;
            font-size: 16px;
            font-weight: bold;
        }

        .boton-centro {
            text-align: center;
        }

        .sin-registros {
            text-align: center;
            padding: 20px;
            color: #d0d8df;
        }
    </style>
</head>
<body>

<div class="contenedor">
<h2>Historial de Asistencias</h2>

<%
Connection con = null;
Statement st = null;
ResultSet rs = null;

try {
    Class.forName("org.postgresql.Driver");

    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);

    st = con.createStatement();
    rs = st.executeQuery(
        "select a.*, p.nombre, p.ci from asistencias a join personas p on a.persona_id = p.id order by a.id desc"
    );
%>

<table>
    <thead>
        <tr>
            <th>id</th>
            <th>nombre</th>
            <th>ci</th>
            <th>fecha</th>
            <th>hora entrada</th>
            <th>hora salida</th>
            <th>horas trabajadas</th>
            <th>estado</th>
        </tr>
    </thead>
    <tbody>

<%
boolean hay = false;

while (rs.next()) {
    hay = true;
%>
<tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("nombre") %></td>
    <td><%= rs.getString("ci") %></td>
    <td><%= rs.getDate("fecha") %></td>
    <td><%= rs.getTime("hora_entrada") != null ? rs.getTime("hora_entrada") : "" %></td>
    <td><%= rs.getTime("hora_salida") != null ? rs.getTime("hora_salida") : "" %></td>
    <td><%= rs.getObject("horas_trabajadas") != null ? rs.getDouble("horas_trabajadas") : "" %></td>
    <td><%= rs.getString("estado") %></td>
</tr>
<%
}

if (!hay) {
%>
<tr>
    <td colspan="8" class="sin-registros">no hay asistencias registradas.</td>
</tr>
<%
}
%>

    </tbody>
</table>

<%
} catch (Exception e) {
%>
<div class="alert alert-danger">
    Error: <%= e.getMessage() %>
</div>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (st != null) st.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

<div class="boton-centro">
    <a href="admin.jsp" class="btn btn-success btn-volver">Volver al inicio</a>
</div>

</div>

</body>
</html>