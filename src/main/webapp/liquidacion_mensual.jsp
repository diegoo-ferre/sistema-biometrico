<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.time.*" %>

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
    <title>Liquidación Mensual</title>
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
            max-width: 1600px;
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

        .resumen {
            text-align: center;
            margin-bottom: 15px;
            font-size: 18px;
            color: #dce6ef;
        }

        .final {
            color: #00e676;
            font-weight: bold;
        }

        .descuento {
            color: #ff7675;
            font-weight: bold;
        }

        .detalle {
            text-align: left;
            font-size: 14px;
            line-height: 1.6;
            color: #dfe6e9;
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Liquidación Mensual</h2>

<%
int mesSeleccionado = java.time.LocalDate.now().getMonthValue();
int anioSeleccionado = java.time.LocalDate.now().getYear();

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
                <option value="<%= i %>" <%= (i == mesSeleccionado ? "selected" : "") %>><%= i %></option>
            <% } %>
        </select>

        <select name="anio">
            <%
            int anioActual = java.time.LocalDate.now().getYear();
            for (int i = anioActual - 2; i <= anioActual + 2; i++) {
            %>
                <option value="<%= i %>" <%= (i == anioSeleccionado ? "selected" : "") %>><%= i %></option>
            <%
            }
            %>
        </select>

        <button type="submit" class="btn btn-info">Calcular</button>
    </form>

<%
Connection con = null;
PreparedStatement psPersonas = null;
PreparedStatement psSueldo = null;
PreparedStatement psDescuentos = null;
PreparedStatement psDetalle = null;
PreparedStatement psAsistencias = null;
PreparedStatement psMotivoAusencia = null;
PreparedStatement psMotivoTardanza = null;
ResultSet rsPersonas = null;
ResultSet rsSueldo = null;
ResultSet rsDescuentos = null;
ResultSet rsDetalle = null;
ResultSet rsAsistencias = null;
ResultSet rsMotivoAusencia = null;
ResultSet rsMotivoTardanza = null;

DecimalFormat guarani = new DecimalFormat("###,###,###");

try {
    Class.forName("org.postgresql.Driver");

   String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);

    double valorAusencia = 0;
    String tipoAusencia = "";
    double valorTardanza = 0;
    String tipoTardanza = "";

    psMotivoAusencia = con.prepareStatement(
        "select tipo, valor from motivos_descuento where lower(motivo) = 'ausencia' and activo = true order by id desc limit 1"
    );
    rsMotivoAusencia = psMotivoAusencia.executeQuery();
    if (rsMotivoAusencia.next()) {
        tipoAusencia = rsMotivoAusencia.getString("tipo");
        valorAusencia = rsMotivoAusencia.getDouble("valor");
    }
    rsMotivoAusencia.close();
    psMotivoAusencia.close();

    psMotivoTardanza = con.prepareStatement(
        "select tipo, valor from motivos_descuento where lower(motivo) = 'tardanza' and activo = true order by id desc limit 1"
    );
    rsMotivoTardanza = psMotivoTardanza.executeQuery();
    if (rsMotivoTardanza.next()) {
        tipoTardanza = rsMotivoTardanza.getString("tipo");
        valorTardanza = rsMotivoTardanza.getDouble("valor");
    }
    rsMotivoTardanza.close();
    psMotivoTardanza.close();

%>

    <div class="resumen">
        liquidación calculada para el periodo:
        <strong><%= mesSeleccionado %>/<%= anioSeleccionado %></strong>
    </div>

    <table>
        <thead>
            <tr>
                <th>id</th>
                <th>nombre</th>
                <th>ci</th>
                <th>sueldo base</th>
                <th>ausencias</th>
                <th>tardanzas</th>
                <th>detalle descuentos</th>
                <th>total descuentos</th>
                <th>salario final</th>
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
        double totalDescuentosManual = 0;
        double descuentoAusenciaAuto = 0;
        double descuentoTardanzaAuto = 0;
        double totalDescuentos = 0;
        double salarioFinal = 0;
        int diasCompletos = 0;
        int tardanzas = 0;
        int diasLaborales = 0;

        StringBuilder detalleDescuentos = new StringBuilder();

        psSueldo = con.prepareStatement(
            "select sueldo_base from salarios_base where persona_id = ? order by id desc limit 1"
        );
        psSueldo.setInt(1, personaId);
        rsSueldo = psSueldo.executeQuery();

        if (rsSueldo.next()) {
            sueldoBase = rsSueldo.getDouble("sueldo_base");
        }

        if (rsSueldo != null) rsSueldo.close();
        if (psSueldo != null) psSueldo.close();

        psDescuentos = con.prepareStatement(
            "select coalesce(sum(monto_aplicado), 0) as total from descuentos_persona where persona_id = ? and mes = ? and anio = ?"
        );
        psDescuentos.setInt(1, personaId);
        psDescuentos.setInt(2, mesSeleccionado);
        psDescuentos.setInt(3, anioSeleccionado);
        rsDescuentos = psDescuentos.executeQuery();

        if (rsDescuentos.next()) {
            totalDescuentosManual = rsDescuentos.getDouble("total");
        }

        if (rsDescuentos != null) rsDescuentos.close();
        if (psDescuentos != null) psDescuentos.close();

        psDetalle = con.prepareStatement(
            "select m.motivo, dp.monto_aplicado " +
            "from descuentos_persona dp " +
            "join motivos_descuento m on dp.motivo_id = m.id " +
            "where dp.persona_id = ? and dp.mes = ? and dp.anio = ? " +
            "order by dp.id desc"
        );
        psDetalle.setInt(1, personaId);
        psDetalle.setInt(2, mesSeleccionado);
        psDetalle.setInt(3, anioSeleccionado);
        rsDetalle = psDetalle.executeQuery();

        while (rsDetalle.next()) {
            String motivo = rsDetalle.getString("motivo");
            double monto = rsDetalle.getDouble("monto_aplicado");
            detalleDescuentos.append(motivo)
                             .append(" (Gs. ")
                             .append(guarani.format(monto).replace(',', '.'))
                             .append(")")
                             .append("<br>");
        }

        if (rsDetalle != null) rsDetalle.close();
        if (psDetalle != null) psDetalle.close();

        if (sueldoBase > 0) {
            LocalDate inicioMes = LocalDate.of(anioSeleccionado, mesSeleccionado, 1);
            LocalDate finMes = inicioMes.withDayOfMonth(inicioMes.lengthOfMonth());

            LocalDate fecha = inicioMes;
            while (!fecha.isAfter(finMes)) {
                DayOfWeek dia = fecha.getDayOfWeek();
                if (dia != DayOfWeek.SATURDAY && dia != DayOfWeek.SUNDAY) {
                    diasLaborales++;
                }
                fecha = fecha.plusDays(1);
            }

            psAsistencias = con.prepareStatement(
                "select " +
                "count(case when hora_entrada is not null and hora_salida is not null then 1 end) as dias_completos, " +
                "count(case when minutos_tardanza > 0 then 1 end) as tardanzas " +
                "from asistencias " +
                "where persona_id = ? and extract(month from fecha) = ? and extract(year from fecha) = ?"
            );
            psAsistencias.setInt(1, personaId);
            psAsistencias.setInt(2, mesSeleccionado);
            psAsistencias.setInt(3, anioSeleccionado);
            rsAsistencias = psAsistencias.executeQuery();

            if (rsAsistencias.next()) {
                diasCompletos = rsAsistencias.getInt("dias_completos");
                tardanzas = rsAsistencias.getInt("tardanzas");
            }

            if (rsAsistencias != null) rsAsistencias.close();
            if (psAsistencias != null) psAsistencias.close();

            int ausencias = diasLaborales - diasCompletos;
            if (ausencias < 0) ausencias = 0;

            if ("porcentaje".equals(tipoAusencia)) {
                descuentoAusenciaAuto = (sueldoBase * valorAusencia / 100.0) * ausencias;
            } else if ("fijo".equals(tipoAusencia)) {
                descuentoAusenciaAuto = valorAusencia * ausencias;
            }

            if ("porcentaje".equals(tipoTardanza)) {
                descuentoTardanzaAuto = (sueldoBase * valorTardanza / 100.0) * tardanzas;
            } else if ("fijo".equals(tipoTardanza)) {
                descuentoTardanzaAuto = valorTardanza * tardanzas;
            }

            if (ausencias > 0) {
                detalleDescuentos.append("ausencias automáticas (")
                                 .append(ausencias)
                                 .append(") - Gs. ")
                                 .append(guarani.format(descuentoAusenciaAuto).replace(',', '.'))
                                 .append("<br>");
            }

            if (tardanzas > 0) {
                detalleDescuentos.append("tardanzas automáticas (")
                                 .append(tardanzas)
                                 .append(") - Gs. ")
                                 .append(guarani.format(descuentoTardanzaAuto).replace(',', '.'))
                                 .append("<br>");
            }

            totalDescuentos = totalDescuentosManual + descuentoAusenciaAuto + descuentoTardanzaAuto;
            salarioFinal = sueldoBase - totalDescuentos;
            if (salarioFinal < 0) salarioFinal = 0;

            String sueldoTexto = guarani.format(sueldoBase).replace(',', '.');
            String descuentoTexto = guarani.format(totalDescuentos).replace(',', '.');
            String finalTexto = guarani.format(salarioFinal).replace(',', '.');
%>
            <tr>
                <td><%= personaId %></td>
                <td><%= nombre %></td>
                <td><%= ci %></td>
                <td>Gs. <%= sueldoTexto %></td>
                <td><%= ausencias %></td>
                <td><%= tardanzas %></td>
                <td class="detalle">
                    <%= detalleDescuentos.length() > 0 ? detalleDescuentos.toString() : "sin descuentos aplicados" %>
                </td>
                <td class="descuento">Gs. <%= descuentoTexto %></td>
                <td class="final">Gs. <%= finalTexto %></td>
            </tr>
<%
        } else {
%>
            <tr>
                <td><%= personaId %></td>
                <td><%= nombre %></td>
                <td><%= ci %></td>
                <td>sin sueldo base</td>
                <td>-</td>
                <td>-</td>
                <td class="detalle">sin sueldo base asignado</td>
                <td class="descuento">-</td>
                <td class="final">-</td>
            </tr>
<%
        }
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
    try { if (rsMotivoAusencia != null) rsMotivoAusencia.close(); } catch (Exception e) {}
    try { if (psMotivoAusencia != null) psMotivoAusencia.close(); } catch (Exception e) {}
    try { if (rsMotivoTardanza != null) rsMotivoTardanza.close(); } catch (Exception e) {}
    try { if (psMotivoTardanza != null) psMotivoTardanza.close(); } catch (Exception e) {}
    try { if (rsAsistencias != null) rsAsistencias.close(); } catch (Exception e) {}
    try { if (psAsistencias != null) psAsistencias.close(); } catch (Exception e) {}
    try { if (rsDetalle != null) rsDetalle.close(); } catch (Exception e) {}
    try { if (psDetalle != null) psDetalle.close(); } catch (Exception e) {}
    try { if (rsDescuentos != null) rsDescuentos.close(); } catch (Exception e) {}
    try { if (psDescuentos != null) psDescuentos.close(); } catch (Exception e) {}
    try { if (rsSueldo != null) rsSueldo.close(); } catch (Exception e) {}
    try { if (psSueldo != null) psSueldo.close(); } catch (Exception e) {}
    try { if (rsPersonas != null) rsPersonas.close(); } catch (Exception e) {}
    try { if (psPersonas != null) psPersonas.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>
    
<div class="text-center mb-3">
    <a href="reporte_liquidacion.jsp?mes=<%= mesSeleccionado %>&anio=<%= anioSeleccionado %>" class="btn btn-danger" style="border-radius:20px; padding:10px 20px; font-weight:bold;">
        Descargar PDF general
    </a>
</div>

    <div class="boton-centro">
        <a href="admin.jsp" class="btn-volver">Volver al inicio</a>
    </div>
</div>

</body>
</html>