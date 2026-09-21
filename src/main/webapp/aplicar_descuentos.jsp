<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
    <title>Aplicar Descuentos</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 1250px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 38px; font-weight: bold; }
        .form-control, .custom-select { border-radius: 15px; padding: 12px; }
        .btn-guardar { background: linear-gradient(35deg, #4225a3, #000738); border: none; border-radius: 25px; padding: 12px 24px; color: white; font-weight: bold; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 25px; padding: 12px 24px; color: white; font-weight: bold; text-decoration: none; display: inline-block; margin-top: 25px; }
        .btn-volver:hover { color: white; text-decoration: none; }
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 20px; padding: 8px 18px; color: white; font-weight: bold; }
        table { width: 100%; margin-top: 30px; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { text-align: center; padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); }
        tr:hover td { background: rgba(255,255,255,0.04); }
        .mensaje { margin-bottom: 20px; }
        .sin-registros { text-align: center; padding: 20px; color: #d0d8df; }
        .boton-centro { text-align: center; }
        .periodo-badge { display: inline-block; background: linear-gradient(40deg, #4225a3, #000738); padding: 10px 20px; border-radius: 15px; margin-bottom: 20px; font-weight: bold; color: white; border: 1px solid #4225a3; }    
        .icon4{ filter: brightness(0) invert(1); }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Aplicar Descuentos <img src="img/eliminar.png" class="icon4"></img></h2>

<%
Connection con = null;
PreparedStatement ps = null;
Statement st = null;
ResultSet rs = null;
String mensaje = null;
String tipoMensaje = "info";
int mesPeriodo = 0, anioPeriodo = 0;
DecimalFormat guarani = new DecimalFormat("###,###,###");

try {
    Class.forName("org.postgresql.Driver");
    con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");

    ps = con.prepareStatement("SELECT mes, anio FROM periodo_activo LIMIT 1");
    rs = ps.executeQuery();
    if (rs.next()) {
        mesPeriodo = rs.getInt("mes");
        anioPeriodo = rs.getInt("anio");
    }
    rs.close(); ps.close();

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String accion = request.getParameter("accion");
        if ("guardar".equals(accion)) {
            int personaId = Integer.parseInt(request.getParameter("persona_id"));
            int motivoId = Integer.parseInt(request.getParameter("motivo_id"));
            
            // 1. Obtener datos de la persona (nombre y ci)
            String nombrePersona = "";
            String ciPersona = "";
            ps = con.prepareStatement("select nombre, ci from personas where id = ?");
            ps.setInt(1, personaId);
            rs = ps.executeQuery();
            if (rs.next()) {
                nombrePersona = rs.getString("nombre");
                ciPersona = rs.getString("ci");
            }
            rs.close(); ps.close();

            // 2. Obtener el nombre y valor del motivo
            String nombreMotivo = "";
            double valorMotivo = 0;
            String tipoMotivo = "";
            ps = con.prepareStatement("select motivo, tipo, valor from motivos_descuento where id = ?");
            ps.setInt(1, motivoId);
            rs = ps.executeQuery();
            if (rs.next()) {
                nombreMotivo = rs.getString("motivo");
                tipoMotivo = rs.getString("tipo");
                valorMotivo = rs.getDouble("valor");
            }
            rs.close(); ps.close();

            // 3. Obtener sueldo base
            ps = con.prepareStatement("select sueldo_base from salarios_base where persona_id = ? order by id desc limit 1");
            ps.setInt(1, personaId);
            rs = ps.executeQuery();
            double sueldoBase = rs.next() ? rs.getDouble("sueldo_base") : 0;
            rs.close(); ps.close();

            double monto = "porcentaje".equals(tipoMotivo) ? (sueldoBase * valorMotivo / 100.0) : valorMotivo;
            
            // 4. Calcular la suma de los descuentos ya aplicados a esta persona en el periodo actual
            ps = con.prepareStatement("select sum(monto_aplicado) as total_actual from descuentos_persona where persona_id = ? and mes = ? and anio = ?");
            ps.setInt(1, personaId);
            ps.setInt(2, mesPeriodo);
            ps.setInt(3, anioPeriodo);
            rs = ps.executeQuery();
            double totalDescuentosActuales = 0;
            if (rs.next()) {
                totalDescuentosActuales = rs.getDouble("total_actual");
            }
            rs.close(); ps.close();

            double topeMaximo = sueldoBase * 0.25;

            // VALIDACIÓN: La suma de los descuentos actuales más el nuevo no puede superar el 25% del sueldo base
            if ((totalDescuentosActuales + monto) > topeMaximo) {
                mensaje = "Error: El total de descuentos supera el 25% del sueldo base (Tope permitido: Gs. " + guarani.format(topeMaximo) + ", Ya acumulado: Gs. " + guarani.format(totalDescuentosActuales) + ").";
                tipoMensaje = "danger";
            } else {
                ps = con.prepareStatement("insert into descuentos_persona (persona_id, motivo_id, mes, anio, monto_aplicado, nombre, ci, motivo) values (?, ?, ?, ?, ?, ?, ?, ?)");
                ps.setInt(1, personaId); 
                ps.setInt(2, motivoId); 
                ps.setInt(3, mesPeriodo); 
                ps.setInt(4, anioPeriodo); 
                ps.setDouble(5, monto);
                ps.setString(6, nombrePersona);
                ps.setString(7, ciPersona);
                ps.setString(8, nombreMotivo);
                ps.executeUpdate();
                mensaje = "Descuento aplicado correctamente.";
                tipoMensaje = "info";
            }
            ps.close();
        } else if ("eliminar".equals(accion)) {
            ps = con.prepareStatement("delete from descuentos_persona where id = ?");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            ps.close();
            mensaje = "Descuento eliminado correctamente.";
            tipoMensaje = "info";
        }
    }
%>

<% if (mensaje != null) { %><div class="alert alert-<%= tipoMensaje %> mensaje"><%= mensaje %></div><% } %>

<div class="boton-centro">
    <div class="periodo-badge">Periodo Actual: <%= mesPeriodo %> / <%= anioPeriodo %></div>
</div>

<form method="post">
    <input type="hidden" name="accion" value="guardar">
    <div class="row">
        <div class="col-md-5 mb-3">
            <label>Persona</label>
            <select name="persona_id" class="custom-select" required>
                <option value="">Seleccionar persona...</option>
                <%
                st = con.createStatement();
                rs = st.executeQuery("select id, nombre, ci from personas order by nombre asc");
                while (rs.next()) { %>
                    <option value="<%= rs.getInt("id") %>"><%= rs.getString("nombre") %> - CI: <%= rs.getString("ci") %></option>
                <% } rs.close(); st.close(); %>
            </select>
        </div>
        <div class="col-md-5 mb-3">
            <label>Motivo</label>
            <select name="motivo_id" class="custom-select" required>
                <option value="">Seleccionar motivo...</option>
                <%
                st = con.createStatement();
                rs = st.executeQuery("select id, motivo, tipo, valor from motivos_descuento where activo = true order by id desc");
                while (rs.next()) { %>
                    <option value="<%= rs.getInt("id") %>"><%= rs.getString("motivo") %> (<%= "porcentaje".equals(rs.getString("tipo")) ? rs.getDouble("valor")+"%" : "Gs. "+guarani.format(rs.getDouble("valor")) %>)</option>
                <% } rs.close(); st.close(); %>
            </select>
        </div>
        <div class="col-md-2 mb-3 d-flex align-items-end">
            <button type="submit" class="btn-guardar w-100">Aplicar</button>
        </div>
    </div>
</form>

<table>
    <thead>
        <tr>
            <th>Persona</th>
            <th>CI</th>
            <th>Motivo</th>
            <th>Monto</th>
            <th>Acción</th>
        </tr>
    </thead>
    <tbody>
    <%
        rs = con.createStatement().executeQuery("select id, nombre, ci, motivo, monto_aplicado from descuentos_persona where mes = "+mesPeriodo+" and anio = "+anioPeriodo+" order by id desc");
        boolean hay = false;
        while (rs.next()) { hay = true; 
            String nom = rs.getString("nombre");
            String ced = rs.getString("ci");
            String mot = rs.getString("motivo");
    %>
        <tr>
            <td><%= (nom != null && !nom.trim().isEmpty() && !nom.equals("--")) ? nom : "Sin Nombre" %></td>
            <td><%= (ced != null && !ced.trim().isEmpty() && !ced.equals("--")) ? ced : "S/N" %></td>
            <td><%= (mot != null && !mot.trim().isEmpty() && !mot.equals("--")) ? mot : "Sin Motivo" %></td>
            <td>Gs. <%= guarani.format(rs.getDouble("monto_aplicado")) %></td>
            <td>
                <form method="post" onsubmit="return confirm('¿Eliminar?');">
                    <input type="hidden" name="accion" value="eliminar">
                    <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                    <button type="submit" class="btn-eliminar">Eliminar</button>
                </form>
            </td>
        </tr>
        <% } if (!hay) { %><tr><td colspan="5" class="sin-registros">No hay descuentos para el periodo actual.</td></tr><% } %>
    </tbody>
</table>

<div class="boton-centro"><a href="admin.jsp" class="btn-volver">Volver al inicio</a></div>

<%
} catch (Exception e) {
    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (st != null) st.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>
</div>
</body>
</html>