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
    <title>Dashboard del Sistema</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
            color: white;
            padding: 30px 15px;
        }

        .contenedor {
            max-width: 1300px;
            margin: auto;
        }

        h2 {
            text-align: center;
            font-size: 42px;
            font-weight: bold;
            margin-bottom: 35px;
        }

        .tarjeta {
            background: rgba(10, 15, 25, 0.88);
            border-radius: 25px;
            padding: 30px 20px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.8);
            margin-bottom: 25px;
            height: 100%;
        }

        .tarjeta h3 {
            font-size: 20px;
            margin-bottom: 15px;
        }

        .tarjeta p {
            font-size: 38px;
            font-weight: bold;
            margin: 0;
        }

        .color1 { border-left: 8px solid #00c853; }
        .color2 { border-left: 8px solid #00b0ff; }
        .color3 { border-left: 8px solid #ffab00; }
        .color4 { border-left: 8px solid #ff5252; }
        .color5 { border-left: 8px solid #7c4dff; }
        .color6 { border-left: 8px solid #e91e63; }

        .botones {
            text-align: center;
            margin-top: 20px;
        }

        .btn-custom {
            display: inline-block;
            margin: 10px;
            padding: 12px 24px;
            border-radius: 25px;
            font-size: 16px;
            font-weight: bold;
            color: white;
            text-decoration: none;
        }

        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); }

        .btn-custom:hover {
            color: white;
            text-decoration: none;
            transform: scale(1.03);
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Dashboard del Sistema</h2>

<%
Connection con = null;
Statement st = null;
ResultSet rs = null;

int totalPersonas = 0;
int asistenciasHoy = 0;
int tardanzasHoy = 0;
int salariosBase = 0;
int motivosActivos = 0;
int motivosBonificacionActivos = 0;

try {
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
    String user = "neondb_owner";
    String pass = "npg_6rt8OdayAHcm";

    con = DriverManager.getConnection(url, user, pass);
    st = con.createStatement();

    rs = st.executeQuery("select count(*) as total from personas");
    if (rs.next()) totalPersonas = rs.getInt("total");
    rs.close();

    rs = st.executeQuery("select count(*) as total from asistencias where fecha = current_date");
    if (rs.next()) asistenciasHoy = rs.getInt("total");
    rs.close();

    rs = st.executeQuery("select count(*) as total from asistencias where fecha = current_date and minutos_tardanza > 0");
    if (rs.next()) tardanzasHoy = rs.getInt("total");
    rs.close();

    rs = st.executeQuery("select count(distinct persona_id) as total from salarios_base");
    if (rs.next()) salariosBase = rs.getInt("total");
    rs.close();

    rs = st.executeQuery("select count(*) as total from motivos_descuento where activo = true");
    if (rs.next()) motivosActivos = rs.getInt("total");
    rs.close();

    // Nueva consulta para bonificaciones
    rs = st.executeQuery("select count(*) as total from tipos_bonificacion where activo = true");
    if (rs.next()) motivosBonificacionActivos = rs.getInt("total");
    rs.close();
%>

    <div class="row">
        <div class="col-md-6 col-lg-4">
            <div class="tarjeta color1">
                <h3>Total de personas</h3>
                <p><%= totalPersonas %></p>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="tarjeta color2">
                <h3>Asistencias hoy</h3>
                <p><%= asistenciasHoy %></p>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="tarjeta color3">
                <h3>Tardanzas hoy</h3>
                <p><%= tardanzasHoy %></p>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="tarjeta color4">
                <h3>Personas con sueldo base</h3>
                <p><%= salariosBase %></p>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="tarjeta color5">
                <h3>Motivos descuento activos</h3>
                <p><%= motivosActivos %></p>
            </div>
        </div>

        <div class="col-md-6 col-lg-4">
            <div class="tarjeta color6">
                <h3>Motivos bonificación activos</h3>
                <p><%= motivosBonificacionActivos %></p>
            </div>
        </div>
    </div>

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

    <div class="botones">
        <a href="admin.jsp" class="btn-custom btn-volver">Volver al inicio</a>
    </div>
</div>

</body>
</html>