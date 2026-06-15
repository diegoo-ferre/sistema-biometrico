<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Salarios</title>

    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

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
            max-width: 1200px;
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

        .btn-asignar {
            border-radius: 20px;
            padding: 8px 18px;
            font-weight: bold;
        }

        .btn-volver {
            display: inline-block;
            margin-top: 25px;
            border-radius: 25px;
            padding: 12px 26px;
            font-size: 16px;
            font-weight: bold;
        }

        .btn-ver {
            display: inline-block;
            margin-top: 25px;
            border-radius: 25px;
            padding: 12px 26px;
            font-size: 16px;
            font-weight: bold;
            margin-right: 10px;
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

    <h2>Gestión de Salarios</h2>

<%
Connection con = null;
Statement st = null;
ResultSet rs = null;

try {

    Class.forName("org.postgresql.Driver");

    String url =
        "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";

    String user = "neondb_owner";

    String pass = "npg_6rt8OdayAHcm";

    con = DriverManager.getConnection(url, user, pass);

    st = con.createStatement();

    rs = st.executeQuery(
        "SELECT p.id, p.nombre, p.ci, s.sueldo_final " +
        "FROM personas p " +
        "LEFT JOIN salarios s ON p.id = s.persona_id " +
        "ORDER BY p.id DESC"
    );
%>

    <table>

        <thead>

            <tr>

                <th>ID</th>

                <th>Nombre</th>

                <th>CI</th>

                <th>Sueldo</th>

                <th>Acción</th>

            </tr>

        </thead>

        <tbody>

<%
    boolean hayRegistros = false;

    while (rs.next()) {

        hayRegistros = true;
%>

            <tr>

                <td>
                    <%= rs.getInt("id") %>
                </td>

                <td>
                    <%= rs.getString("nombre") %>
                </td>

                <td>
                    <%= rs.getString("ci") %>
                </td>

                <td>

<%
    double sueldo = rs.getDouble("sueldo_final");

    if (rs.wasNull()) {
%>

                    Sin asignar

<%
    } else {
%>

                    Gs. <%= String.format("%,.0f", sueldo) %>

<%
    }
%>

                </td>

                <td>

                    <a href="editar_salario.jsp?id=<%= rs.getInt("id") %>"
                       class="btn btn-warning btn-asignar">

                        Editar

                    </a>

                </td>

            </tr>

<%
    }

    if (!hayRegistros) {
%>

            <tr>

                <td colspan="5"
                    class="sin-registros">

                    no hay personas registradas.

                </td>

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

    try {
        if (rs != null) rs.close();
    } catch (Exception e) {}

    try {
        if (st != null) st.close();
    } catch (Exception e) {}

    try {
        if (con != null) con.close();
    } catch (Exception e) {}
}
%>

    <div class="boton-centro">

        <a href="ver_salarios.jsp"
           class="btn btn-info btn-ver">

            Ver salarios

        </a>

        <a href="admin.jsp"
           class="btn btn-success btn-volver">

            Volver al inicio

        </a>

    </div>

</div>

</body>
</html>