<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.text.DecimalFormat" %>

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
    <title>Salario Automático Mensual</title>
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
            background: rgba(10, 15, 25, 0.88);
            padding: 35px;
            border-radius: 25px;
            width: 98%;
            max-width: 1500px;
            margin: auto;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        h2 {
            text-align: center;
            font-size: 38px;
            font-weight: bold;
            margin-bottom: 25px;
        }

        .filtros {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            justify-content: center;
            margin-bottom: 30px;
        }

        .filtros select, .filtros button {
            padding: 12px 18px;
            border-radius: 18px;
            border: none;
            font-size: 16px;
        }

        .filtros button {
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
            display: inline-block;
            margin-top: 25px;
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

        .resumen {
            text-align: center;
            margin-bottom: 15px;
            font-size: 18px;
            color: #dce6ef;
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Salario Automático Mensual</h2>

<%
int mesSeleccionado = LocalDate.now().getMonthValue();
int anioSeleccionado = LocalDate.now().getYear();

try {
    if (request.getParameter("mes") != null && !request.getParameter("mes").trim().equals("")) {
        mesSeleccionado = Integer.parseInt(request.getParameter("mes"));
    }
    if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals("")) {
        anioSeleccionado = Integer.parseInt(request.getParameter("anio"));
    }
} catch (Exception e) {
}
%>

    <form method="get" class="filtros">
        <select name="mes">
            <% for (int i = 1; i <= 12; i++) { %>
                <option value="<%= i %>" <%= (i == mesSeleccionado ? "selected" : "") %>>
                    <%= i %>
                </option>
            <% } %>
        </select>

        <select name="anio">
            <% for (int i = anioSeleccionado - 2; i <= anioSeleccionado + 2; i++) { %>
                <option value="<%= i %>" <%= (i == anioSeleccionado ? "selected" : "") %>>
                    <%= i %>
                </option>
            <% } %>
        </select>

        <button type="submit" class="btn btn-info">Calcular</button>
    </form>

<%
Connection con = null;
PreparedStatement psPersonas = null;
PreparedStatement psSalario = null;
PreparedStatement psAsistencia = null;
ResultSet rsPersonas = null;
ResultSet rsSalario = null;
ResultSet rsAsistencia = null;

DecimalFormat guarani = new DecimalFormat("###,###,###");

try {
    Class.forName("org.postgresql.Driver");

  String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);
    LocalDate inicioMes = LocalDate.of(anioSeleccionado, mesSeleccionado, 1);
    LocalDate finMes = inicioMes.withDayOfMonth(inicioMes.lengthOfMonth());
    int diasDelMes = inicioMes.lengthOfMonth();

%>
    <div class="resumen">
        periodo calculado: <strong><%= mesSeleccionado %>/<%= anioSeleccionado %></strong> |
        días del mes: <strong><%= diasDelMes %></strong>
    </div>

    <table>
        <thead>
            <tr>
                <th>id</th>
                <th>nombre</th>
                <th>ci</th>
                <th>sueldo base</th>
                <th>salario diario</th>
                <th>días trabajados</th>
                <th>ausencias</th>
                <th>descuento por ausencia</th>
                <th>salario estimado</th>
            </tr>
        </thead>
        <tbody>

<%
    psPersonas = con.prepareStatement("select id, nombre, ci from personas order by id desc");
    rsPersonas = psPersonas.executeQuery();

    boolean hay = false;

    while (rsPersonas.next()) {
        hay = true;

        int personaId = rsPersonas.getInt("id");
        String nombre = rsPersonas.getString("nombre");
        String ci = rsPersonas.getString("ci");

        double sueldoBase = 0;
        double salarioDiario = 0;
        int diasTrabajados = 0;
        int ausencias = 0;
        double descuentoAusencia = 0;
        double salarioEstimado = 0;

        psSalario = con.prepareStatement(
            "select sueldo_base from salarios where persona_id = ? order by id desc limit 1"
        );
        psSalario.setInt(1, personaId);
        rsSalario = psSalario.executeQuery();

        if (rsSalario.next()) {
            sueldoBase = rsSalario.getDouble("sueldo_base");
        }

        if (rsSalario != null) rsSalario.close();
        if (psSalario != null) psSalario.close();

        if (sueldoBase > 0) {
            salarioDiario = sueldoBase / 30.0;

            psAsistencia = con.prepareStatement(
                "select count(*) as total from asistencias where persona_id = ? and fecha between ? and ? and hora_entrada is not null and hora_salida is not null"
            );
            psAsistencia.setInt(1, personaId);
            psAsistencia.setDate(2, java.sql.Date.valueOf(inicioMes));
            psAsistencia.setDate(3, java.sql.Date.valueOf(finMes));
            rsAsistencia = psAsistencia.executeQuery();

            if (rsAsistencia.next()) {
                diasTrabajados = rsAsistencia.getInt("total");
            }

            if (rsAsistencia != null) rsAsistencia.close();
            if (psAsistencia != null) psAsistencia.close();

            ausencias = diasDelMes - diasTrabajados;
            if (ausencias < 0) ausencias = 0;

            descuentoAusencia = salarioDiario * ausencias;
            salarioEstimado = sueldoBase - descuentoAusencia;
            if (salarioEstimado < 0) salarioEstimado = 0;
        }

        String sueldoBaseTexto = guarani.format(sueldoBase).replace(',', '.');
        String salarioDiarioTexto = guarani.format(salarioDiario).replace(',', '.');
        String descuentoTexto = guarani.format(descuentoAusencia).replace(',', '.');
        String salarioFinalTexto = guarani.format(salarioEstimado).replace(',', '.');
%>
            <tr>
                <td><%= personaId %></td>
                <td><%= nombre %></td>
                <td><%= ci %></td>
                <td><%= sueldoBase > 0 ? "Gs. " + sueldoBaseTexto : "sin sueldo cargado" %></td>
                <td><%= sueldoBase > 0 ? "Gs. " + salarioDiarioTexto : "-" %></td>
                <td><%= diasTrabajados %></td>
                <td><%= sueldoBase > 0 ? ausencias : "-" %></td>
                <td><%= sueldoBase > 0 ? "Gs. " + descuentoTexto : "-" %></td>
                <td><%= sueldoBase > 0 ? "Gs. " + salarioFinalTexto : "-" %></td>
            </tr>
<%
    }

    if (!hay) {
%>
            <tr>
                <td colspan="9" class="sin-registros">no hay personas registradas.</td>
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
    try { if (rsAsistencia != null) rsAsistencia.close(); } catch (Exception e) {}
    try { if (psAsistencia != null) psAsistencia.close(); } catch (Exception e) {}
    try { if (rsSalario != null) rsSalario.close(); } catch (Exception e) {}
    try { if (psSalario != null) psSalario.close(); } catch (Exception e) {}
    try { if (rsPersonas != null) rsPersonas.close(); } catch (Exception e) {}
    try { if (psPersonas != null) psPersonas.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

    <div class="boton-centro">
        <a href="index.jsp" class="btn btn-success btn-volver">Volver al inicio</a>
    </div>
</div>

</body>
</html>