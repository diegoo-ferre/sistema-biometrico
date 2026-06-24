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
        .contenedor { max-width: 1200px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 32px; font-weight: bold; }
        .periodo-info { text-align: center; margin-bottom: 25px; padding: 20px; background: rgba(255,255,255,0.05); border-radius: 20px; font-size: 18px; border: 1px solid rgba(255,255,255,0.1); }
        table { width: 100%; color: white; border-collapse: collapse; background: rgba(0,0,0,0.2); border-radius: 15px; overflow: hidden; margin-top: 20px; }
        th, td { text-align: center; padding: 15px; border: 1px solid rgba(255,255,255,0.08); }
        th { background: rgba(255,255,255,0.08); }
        .btn-guardar { background: linear-gradient(40deg, #4225a3, #000738); border: none; color: white; padding: 8px 20px; border-radius: 15px; font-weight: bold; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; color: white; padding: 12px 24px; border-radius: 15px; text-decoration: none; display: inline-block; margin-top: 25px; font-weight: bold; }
        .btn-volver:hover { color: white; text-decoration: none; }
        .boton-centro { text-align: center; }
        .final { color: #00e676; font-weight: bold; }
        .descuento { color: #ff7675; font-weight: bold; }
        .bono { color: #55efc4; font-weight: bold; }
        .detalle { text-align: left; font-size: 13px; color: #dfe6e9; }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Liquidación Mensual</h2>

    <%
    int mesSeleccionado = 0;
    int anioSeleccionado = 0;
    String fechaCierre = "No definida";
    Connection con = null;
    DecimalFormat guarani = new DecimalFormat("###,###,###");

    try {
        Class.forName("org.postgresql.Driver");
        con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
        
        PreparedStatement psPeriodo = con.prepareStatement("SELECT mes, anio, fecha_cierre FROM periodo_activo LIMIT 1");
        ResultSet rsPeriodo = psPeriodo.executeQuery();
        if (rsPeriodo.next()) {
            mesSeleccionado = rsPeriodo.getInt("mes");
            anioSeleccionado = rsPeriodo.getInt("anio");
            if(rsPeriodo.getDate("fecha_cierre") != null) fechaCierre = rsPeriodo.getDate("fecha_cierre").toString();
        }
    } catch (Exception e) { out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>"); }
    %>

    <div class="periodo-info">
        Periodo: <strong><%= (mesSeleccionado != 0) ? mesSeleccionado + " / " + anioSeleccionado : "No definido" %></strong> | 
        Fecha de Cierre: <strong><%= fechaCierre %></strong>
    </div>

    <table>
        <thead>
            <tr>
                <th>Nombre</th><th>Sueldo Base</th><th>Detalle (Bonos/Desc)</th><th>Total Desc</th><th>Total Bonos</th><th>Final</th><th>Acción</th>
            </tr>
        </thead>
        <tbody>
        <%
        PreparedStatement psPersonas = null, psSueldo = null, psDescuentos = null, psBonos = null;
        try {
            if (con != null) {
                psPersonas = con.prepareStatement("select id, nombre from personas order by id desc");
                ResultSet rsPersonas = psPersonas.executeQuery();

                while (rsPersonas.next()) {
                    int personaId = rsPersonas.getInt("id");
                    String nombre = rsPersonas.getString("nombre");
                    double sueldoBase = 0, totalDescuentos = 0, totalBonos = 0, salarioFinal = 0;
                    StringBuilder detalle = new StringBuilder();

                    psSueldo = con.prepareStatement("select sueldo_base from salarios_base where persona_id = ? order by id desc limit 1");
                    psSueldo.setInt(1, personaId);
                    ResultSet rsSueldo = psSueldo.executeQuery();
                    if (rsSueldo.next()) sueldoBase = rsSueldo.getDouble("sueldo_base");
                    
                    psDescuentos = con.prepareStatement("select sum(monto_aplicado) as total from descuentos_persona where persona_id = ? and mes = ? and anio = ?");
                    psDescuentos.setInt(1, personaId); psDescuentos.setInt(2, mesSeleccionado); psDescuentos.setInt(3, anioSeleccionado);
                    ResultSet rsD = psDescuentos.executeQuery();
                    if (rsD.next()) totalDescuentos = rsD.getDouble("total");

                    psBonos = con.prepareStatement("select sum(monto_aplicado) as total from bonos_persona where persona_id = ? and mes = ? and anio = ?");
                    psBonos.setInt(1, personaId); psBonos.setInt(2, mesSeleccionado); psBonos.setInt(3, anioSeleccionado);
                    ResultSet rsB = psBonos.executeQuery();
                    if (rsB.next()) totalBonos = rsB.getDouble("total");

                    Statement stDet = con.createStatement();
                    ResultSet rsDet = stDet.executeQuery("SELECT m.motivo as nombre, dp.monto_aplicado, 'D' as tipo FROM descuentos_persona dp JOIN motivos_descuento m ON dp.motivo_id = m.id WHERE dp.persona_id = "+personaId+" AND dp.mes = "+mesSeleccionado+" AND dp.anio = "+anioSeleccionado+" UNION ALL SELECT t.nombre, bp.monto_aplicado, 'B' FROM bonos_persona bp JOIN tipos_bonificacion t ON bp.bono_id = t.id WHERE bp.persona_id = "+personaId+" AND bp.mes = "+mesSeleccionado+" AND bp.anio = "+anioSeleccionado);
                    while (rsDet.next()) {
                        detalle.append(rsDet.getString("tipo").equals("B") ? "[B] " : "[D] ").append(rsDet.getString("nombre")).append(": Gs. ").append(guarani.format(rsDet.getDouble("monto_aplicado"))).append("<br>");
                    }

                    salarioFinal = sueldoBase + totalBonos - totalDescuentos;
        %>
            <tr>
                <td><%= nombre %></td>
                <td>Gs. <%= guarani.format(sueldoBase) %></td>
                <td class="detalle"><%= detalle.length() > 0 ? detalle.toString() : "Sin movimientos" %></td>
                <td class="descuento">Gs. <%= guarani.format(totalDescuentos) %></td>
                <td class="bono">Gs. <%= guarani.format(totalBonos) %></td>
                <td class="final">Gs. <%= guarani.format(salarioFinal) %></td>
                <td>
                    <form action="guardar_liquidacion.jsp" method="post">
                        <input type="hidden" name="persona_id" value="<%= personaId %>">
                        <input type="hidden" name="sueldo_base" value="<%= sueldoBase %>">
                        <input type="hidden" name="monto_descuento" value="<%= totalDescuentos %>">
                        <input type="hidden" name="sueldo_final" value="<%= salarioFinal %>">
                        <input type="hidden" name="motivo" value="<%= detalle.toString().replace("<br>", " ") %>">
                        <input type="hidden" name="mes" value="<%= mesSeleccionado %>">
                        <input type="hidden" name="anio" value="<%= anioSeleccionado %>">
                        <button type="submit" class="btn-guardar">Guardar</button>
                    </form>
                </td>
            </tr>
        <%
                }
            }
        } catch (Exception e) { out.println("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>"); }
        finally { if(con != null) con.close(); }
        %>
        </tbody>
    </table>
    
    <div class="boton-centro"><a href="admin.jsp" class="btn-volver">Volver al inicio</a></div>
</div>
</body>
</html>