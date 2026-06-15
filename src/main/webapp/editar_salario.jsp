<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asignar Sueldo</title>
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
            width: 100%;
            max-width: 700px;
        }

        h2 {
            text-align: center;
            font-size: 38px;
            font-weight: bold;
            margin-bottom: 30px;
        }

        label {
            font-weight: bold;
            margin-top: 10px;
        }

        .form-control {
            border-radius: 15px;
            padding: 12px;
        }

        .btn-guardar {
            border-radius: 25px;
            padding: 12px 25px;
            font-size: 16px;
            font-weight: bold;
            width: 100%;
            margin-top: 20px;
        }

        .btn-volver {
            display: inline-block;
            margin-top: 20px;
            border-radius: 25px;
            padding: 12px 26px;
            font-size: 16px;
            font-weight: bold;
        }

        .boton-centro {
            text-align: center;
        }

        .mensaje {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Asignar Sueldo</h2>

<%
Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

String idPersona = request.getParameter("id");
String nombre = "";
String ci = "";

try {
    if (idPersona == null || idPersona.trim().equals("")) {
%>
        <div class="alert alert-danger mensaje">id de persona no válido.</div>
        <div class="boton-centro">
            <a href="salarios.jsp" class="btn btn-success btn-volver">Volver</a>
        </div>
<%
    } else {
        Class.forName("org.postgresql.Driver");

        String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);

        ps = con.prepareStatement("select nombre, ci from personas where id = ?");
        ps.setInt(1, Integer.parseInt(idPersona));
        rs = ps.executeQuery();

        if (rs.next()) {
            nombre = rs.getString("nombre");
            ci = rs.getString("ci");
%>

    <form method="post" action="guardar_salario.jsp">

    <input type="hidden"
           name="persona_id"
           value="<%= idPersona %>">

    <div class="form-group">

        <label>Nombre</label>

        <input type="text"
               class="form-control"
               value="<%= nombre %>"
               readonly>

    </div>

    <div class="form-group">

        <label>CI</label>

        <input type="text"
               class="form-control"
               value="<%= ci %>"
               readonly>

    </div>

    <div class="form-group">

        <label>Sueldo base</label>

        <input type="number"
               step="0.01"
               name="sueldo_base"
               class="form-control"
               value="<%= sueldoBase %>"
               required>

    </div>

    <button type="submit"
            class="btn btn-warning btn-guardar">

        Guardar sueldo

    </button>

</form>

    <div class="boton-centro">
        <a href="salarios.jsp" class="btn btn-success btn-volver">Volver</a>
    </div>

<%
        } else {
%>
        <div class="alert alert-danger mensaje">persona no encontrada.</div>
        <div class="boton-centro">
            <a href="salarios.jsp" class="btn btn-success btn-volver">Volver</a>
        </div>
<%
        }
    }
} catch (Exception e) {
%>
    <div class="alert alert-danger mensaje">
        Error: <%= e.getMessage() %>
    </div>
    <div class="boton-centro">
        <a href="salarios.jsp" class="btn btn-success btn-volver">Volver</a>
    </div>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

</div>

</body>
</html>