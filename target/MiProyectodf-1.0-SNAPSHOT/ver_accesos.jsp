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
    <title>Historial de Accesos</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
            font-family: Arial, sans-serif;
            color: white;
            padding: 30px 15px;
        }

        .contenedor {
            max-width: 1500px;
            margin: auto;
            background: rgba(10, 15, 25, 0.88);
            padding: 35px;
            border-radius: 25px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        h2 {
            text-align: center;
            margin-bottom: 30px;
            font-size: 38px;
            font-weight: bold;
        }

        table {
            width: 100%;
            margin-top: 25px;
            color: white;
            border-collapse: collapse;
            background: rgba(255,255,255,0.03);
            border-radius: 15px;
            overflow: hidden;
        }

        th, td {
            text-align: center;
            padding: 12px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
            vertical-align: middle;
        }

        th {
            background: rgba(255,255,255,0.08);
        }

        tr:hover td {
            background: rgba(255,255,255,0.04);
        }

        .btn-volver {
            background: linear-gradient(45deg, #0984e3, #74b9ff);
            border: none;
            border-radius: 25px;
            padding: 12px 24px;
            color: white;
            font-weight: bold;
            text-decoration: none;
            display: inline-block;
            margin-top: 25px;
        }

        .btn-volver:hover {
            color: white;
            text-decoration: none;
        }

        .boton-centro {
            text-align: center;
        }

        .sin-registros {
            text-align: center;
            padding: 20px;
            color: #d0d8df;
        }

        .ok {
            color: #00e676;
            font-weight: bold;
        }

        .tarde {
            color: #ffd54f;
            font-weight: bold;
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Historial de Accesos</h2>

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
        "select a.id, p.nombre, p.ci, a.fecha, a.hora_entrada, a.hora_salida, a.horas_trabajadas, a.estado, a.minutos_tardanza " +
        "from asistencias a join personas p on a.persona_id = p.id order by a.id desc"
    );
%>

    <table>
        <thead>
            <tr>
                <th>id</th>
                <th>nombre</th>
                <th>ci</th>
                <th>fecha</th>
                <th>entrada</th>
                <th>salida</th>
                <th>horas trabajadas</th>
                <th>minutos tardanza</th>
                <th>estado</th>
            </tr>
        </thead>
        <tbody>

<%
    boolean hay = false;

    while (rs.next()) {
        hay = true;
        String estado = rs.getString("estado");
%>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("nombre") %></td>
                <td><%= rs.getString("ci") %></td>
                <td><%= rs.getDate("fecha") %></td>
                <td><%= rs.getTime("hora_entrada") != null ? rs.getTime("hora_entrada") : "" %></td>
                <td><%= rs.getTime("hora_salida") != null ? rs.getTime("hora_salida") : "" %></td>
                <td><%= rs.getObject("horas_trabajadas") != null ? rs.getDouble("horas_trabajadas") : "" %></td>
                <td><%= rs.getInt("minutos_tardanza") %></td>
                <td>
                    <% if (estado != null && estado.toLowerCase().contains("tardanza")) { %>
                        <span class="tarde"><%= estado %></span>
                    <% } else { %>
                        <span class="ok"><%= estado %></span>
                    <% } %>
                </td>
            </tr>
<%
    }

    if (!hay) {
%>
            <tr>
                <td colspan="9" class="sin-registros">no hay accesos registrados.</td>
            </tr>
<%
    }
%>
        </tbody>
    </table>

<%
} catch (Exception e) {
%>
    <div class="alert alert-danger">Error: <%= e.getMessage() %></div>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (st != null) st.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

    <div class="boton-centro">
        <a href="index.jsp" class="btn-volver">Volver al inicio</a>
    </div>
</div>

</body>
</html>