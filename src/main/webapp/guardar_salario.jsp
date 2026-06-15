<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guardar Sueldo</title>

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
            width: 100%;
            max-width: 700px;
            text-align: center;
        }

        h2 {
            font-size: 35px;
            font-weight: bold;
            margin-bottom: 25px;
        }

        .btn-volver {
            display: inline-block;
            margin-top: 20px;
            border-radius: 25px;
            padding: 12px 26px;
            font-size: 16px;
            font-weight: bold;
        }

        .resultado {
            font-size: 18px;
            margin-top: 20px;
        }

    </style>
</head>

<body>

<div class="contenedor">

    <h2>Resultado del Registro</h2>

<%

Connection con = null;
PreparedStatement ps = null;
PreparedStatement verificar = null;
ResultSet rsVerificar = null;

try {

    request.setCharacterEncoding("UTF-8");

    String personaIdStr =
        request.getParameter("persona_id");

    String sueldoBaseStr =
        request.getParameter("sueldo_base");

    if (personaIdStr == null ||
        personaIdStr.trim().equals("") ||

        sueldoBaseStr == null ||
        sueldoBaseStr.trim().equals("")) {
%>

        <div class="alert alert-danger resultado">

            faltan datos obligatorios.

        </div>

<%
    } else {

        int personaId =
            Integer.parseInt(personaIdStr);

        double sueldoBase =
            Double.parseDouble(sueldoBaseStr);

        if (sueldoBase < 0) {
%>

        <div class="alert alert-danger resultado">

            el sueldo no puede ser menor a 0.

        </div>

<%
        } else {

            Class.forName("org.postgresql.Driver");

            String url =
                "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";

            String user =
                "neondb_owner";

            String pass =
                "npg_6rt8OdayAHcm";

            con = DriverManager.getConnection(
                url,
                user,
                pass
            );

            verificar = con.prepareStatement(
                "SELECT id FROM salarios WHERE persona_id = ?"
            );

            verificar.setInt(1, personaId);

            rsVerificar = verificar.executeQuery();

            // =========================
            // SI YA EXISTE -> UPDATE
            // =========================
            if (rsVerificar.next()) {

                ps = con.prepareStatement(
                    "UPDATE salarios " +
                    "SET sueldo_base = ?, sueldo_final = ? " +
                    "WHERE persona_id = ?"
                );

                ps.setDouble(1, sueldoBase);
                ps.setDouble(2, sueldoBase);
                ps.setInt(3, personaId);

            }

            // =========================
            // SI NO EXISTE -> INSERT
            // =========================
            else {

                ps = con.prepareStatement(
                    "INSERT INTO salarios(" +
                    "persona_id, sueldo_base, sueldo_final" +
                    ") VALUES (?, ?, ?)"
                );

                ps.setInt(1, personaId);
                ps.setDouble(2, sueldoBase);
                ps.setDouble(3, sueldoBase);

            }

            ps.executeUpdate();
%>

        <div class="alert alert-success resultado">

            sueldo guardado correctamente.<br><br>

            <strong>Sueldo:</strong>

            Gs.
            <%= String.format("%,.0f", sueldoBase) %>

        </div>

<%
        }
    }

} catch (Exception e) {
%>

    <div class="alert alert-danger resultado">

        Error: <%= e.getMessage() %>

    </div>

<%
} finally {

    try {
        if (rsVerificar != null) rsVerificar.close();
    } catch (Exception e) {}

    try {
        if (verificar != null) verificar.close();
    } catch (Exception e) {}

    try {
        if (ps != null) ps.close();
    } catch (Exception e) {}

    try {
        if (con != null) con.close();
    } catch (Exception e) {}
}
%>

    <a href="salarios.jsp"
       class="btn btn-success btn-volver">

        Volver a salarios

    </a>

</div>

</body>
</html>