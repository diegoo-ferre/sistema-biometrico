<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Actualizar Salario</title>
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
    <h2>Resultado de la Actualización</h2>

<%
Connection con = null;
PreparedStatement ps = null;

try {
    request.setCharacterEncoding("UTF-8");

    String idStr = request.getParameter("id");
    String sueldoBaseStr = request.getParameter("sueldo_base");
    String porcentajeStr = request.getParameter("porcentaje_descuento");
    String motivo = request.getParameter("motivo_descuento");

    if (idStr == null || idStr.trim().equals("") ||
        sueldoBaseStr == null || sueldoBaseStr.trim().equals("") ||
        porcentajeStr == null || porcentajeStr.trim().equals("")) {
%>
        <div class="alert alert-danger resultado">faltan datos obligatorios.</div>
<%
    } else {
        int id = Integer.parseInt(idStr);
        double sueldoBase = Double.parseDouble(sueldoBaseStr);
        double porcentaje = Double.parseDouble(porcentajeStr);

        if (sueldoBase < 0) {
%>
        <div class="alert alert-danger resultado">el sueldo base no puede ser menor a 0.</div>
<%
        } else if (porcentaje < 0 || porcentaje > 100) {
%>
        <div class="alert alert-danger resultado">el porcentaje debe estar entre 0 y 100.</div>
<%
        } else {

            if (motivo == null) {
                motivo = "";
            }

            if (porcentaje > 0 && motivo.trim().equals("")) {
%>
        <div class="alert alert-danger resultado">debe escribir el motivo del descuento.</div>
<%
            } else {

                double montoDescuento = sueldoBase * porcentaje / 100.0;
                double sueldoFinal = sueldoBase - montoDescuento;

                Class.forName("org.postgresql.Driver");

                String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);

                ps = con.prepareStatement(
                    "update salarios set sueldo_base = ?, porcentaje_descuento = ?, motivo_descuento = ?, monto_descuento = ?, sueldo_final = ? where id = ?"
                );

                ps.setDouble(1, sueldoBase);
                ps.setDouble(2, porcentaje);
                ps.setString(3, motivo);
                ps.setDouble(4, montoDescuento);
                ps.setDouble(5, sueldoFinal);
                ps.setInt(6, id);

                ps.executeUpdate();
%>
        <div class="alert alert-success resultado">
            salario actualizado correctamente.<br><br>
            <strong>monto descontado:</strong> <%= montoDescuento %><br>
            <strong>sueldo final:</strong> <%= sueldoFinal %>
        </div>
<%
            }
        }
    }

} catch (Exception e) {
%>
    <div class="alert alert-danger resultado">
        Error: <%= e.getMessage() %>
    </div>
<%
} finally {
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

    <a href="ver_salarios.jsp" class="btn btn-success btn-volver">Volver a salarios</a>
</div>

</body>
</html>