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
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 1600px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 38px; font-weight: bold; }
        .filtros { display: flex; flex-wrap: wrap; gap: 15px; justify-content: center; margin-bottom: 30px; }
        .filtros select, .filtros button { padding: 12px 18px; border-radius: 18px; border: none; font-size: 16px; font-weight: bold; }
        table { width: 100%; margin-top: 25px; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { text-align: center; padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); }
        tr:hover td { background: rgba(255,255,255,0.04); }
        .btn-guardar { background: linear-gradient(40deg, #4225a3, #000738); border: none; border-radius: 15px; color: white; padding: 5px 15px; font-weight: bold; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 25px; padding: 12px 24px; color: white; font-weight: bold; text-decoration: none; display: inline-block; margin-top: 25px; }
        .btn-volver:hover { color: white; text-decoration: none; }
        .boton-centro { text-align: center; }
        .final { color: #00e676; font-weight: bold; }
         .btn-info { background: linear-gradient(40deg, #4225a3, #000738); }
        .descuento { color: #ff7675; font-weight: bold; }
        .detalle { text-align: left; font-size: 14px; color: #dfe6e9; }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Liquidación Mensual</h2>

    <%
    int mesSeleccionado = LocalDate.now().getMonthValue();
    int anioSeleccionado = LocalDate.now().getYear();
    try {
        if (request.getParameter("mes") != null) mesSeleccionado = Integer.parseInt(request.getParameter("mes"));
        if (request.getParameter("anio") != null) anioSeleccionado = Integer.parseInt(request.getParameter("anio"));
    } catch (Exception e) {}
    %>

    <form method="get" class="filtros">
        <select name="mes"> <% for (int i = 1; i <= 12; i++) { %> <option value="<%= i %>" <%= (i == mesSeleccionado ? "selected" : "") %>><%= i %></option> <% } %> </select>
        <select name="anio"> <% for (int i = anioSeleccionado - 2; i <= anioSeleccionado + 2; i++) { %> <option value="<%= i %>" <%= (i == anioSeleccionado ? "selected" : "") %>><%= i %></option> <% } %> </select>
        <button type="submit" class="btn btn-info">Calcular</button>
    </form>

    <table>
        <thead>
            <tr>
                <th>Nombre</th>
                <th>Sueldo Base</th>
                <th>Detalle</th>
                <th>Total Desc.</th>
                <th>Final</th>
                <th>Acción</th>
            </tr>
        </thead>
        <tbody>
        <%
        Connection con = null;
        PreparedStatement psPersonas = null, psSueldo = null, psDescuentos = null, psDetalle = null;
        ResultSet rsPersonas = null, rsSueldo = null, rsDescuentos = null, rsDetalle = null;
        DecimalFormat guarani = new DecimalFormat("###,###,###");

        try {
            Class.forName("org.postgresql.Driver");
            con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
            
            psPersonas = con.prepareStatement("select id, nombre from personas order by id desc");
            rsPersonas = psPersonas.executeQuery();

            while (rsPersonas.next()) {
                int personaId = rsPersonas.getInt("id");
                String nombre = rsPersonas.getString("nombre");
                double sueldoBase = 0, totalDescuentos = 0, salarioFinal = 0;
                StringBuilder detalleDescuentos = new StringBuilder();

                psSueldo = con.prepareStatement("select sueldo_base from salarios_base where persona_id = ? order by id desc limit 1");
                psSueldo.setInt(1, personaId);
                rsSueldo = psSueldo.executeQuery();
                if (rsSueldo.next()) sueldoBase = rsSueldo.getDouble("sueldo_base");
                rsSueldo.close(); psSueldo.close();

                psDescuentos = con.prepareStatement("select coalesce(sum(monto_aplicado), 0) as total from descuentos_persona where persona_id = ? and mes = ? and anio = ?");
                psDescuentos.setInt(1, personaId);
                psDescuentos.setInt(2, mesSeleccionado);
                psDescuentos.setInt(3, anioSeleccionado);
                rsDescuentos = psDescuentos.executeQuery();
                if (rsDescuentos.next()) totalDescuentos = rsDescuentos.getDouble("total");
                rsDescuentos.close(); psDescuentos.close();

                psDetalle = con.prepareStatement("select m.motivo, dp.monto_aplicado from descuentos_persona dp join motivos_descuento m on dp.motivo_id = m.id where dp.persona_id = ? and dp.mes = ? and dp.anio = ?");
                psDetalle.setInt(1, personaId);
                psDetalle.setInt(2, mesSeleccionado);
                psDetalle.setInt(3, anioSeleccionado);
                rsDetalle = psDetalle.executeQuery();
                while (rsDetalle.next()) {
                    detalleDescuentos.append(rsDetalle.getString("motivo")).append(": Gs. ").append(guarani.format(rsDetalle.getDouble("monto_aplicado"))).append("<br>");
                }
                rsDetalle.close(); psDetalle.close();

                salarioFinal = sueldoBase - totalDescuentos;
                
                // Preparar texto limpio para guardar en base de datos
                String motivoGuardar = detalleDescuentos.length() > 0 ? detalleDescuentos.toString().replace("<br>", " + ") : "Sin descuentos";
        %>
            <tr>
                <td><%= nombre %></td>
                <td>Gs. <%= guarani.format(sueldoBase) %></td>
                <td class="detalle"><%= detalleDescuentos.length() > 0 ? detalleDescuentos.toString() : "Sin descuentos" %></td>
                <td class="descuento">Gs. <%= guarani.format(totalDescuentos) %></td>
                <td class="final">Gs. <%= guarani.format(salarioFinal) %></td>
                <td>
                    <form action="guardar_liquidacion.jsp" method="post">
                        <input type="hidden" name="persona_id" value="<%= personaId %>">
                        <input type="hidden" name="sueldo_base" value="<%= sueldoBase %>">
                        <input type="hidden" name="monto_descuento" value="<%= totalDescuentos %>">
                        <input type="hidden" name="sueldo_final" value="<%= salarioFinal %>">
                        <input type="hidden" name="motivo" value="<%= motivoGuardar %>">
                        <button type="submit" class="btn-guardar">Guardar</button>
                    </form>
                </td>
            </tr>
        <%
            }
        } catch (Exception e) { out.println("Error: " + e.getMessage()); }
        %>
        </tbody>
    </table>
    
    <div class="boton-centro"><a href="admin.jsp" class="btn-volver">Volver al inicio</a></div>
</div>
</body>
</html>