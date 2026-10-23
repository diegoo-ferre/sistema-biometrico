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
    <title>Aplicar Bonificaciones</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; display: flex; align-items: center; justify-content: center; }
        .contenedor { max-width: 1250px; width: 100%; margin: auto; background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 32px; font-weight: bold; }
        
        label { color: #dce6ef; font-size: 14px; }
        .form-control, .custom-select { background: rgba(255, 255, 255, 0.06); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 15px; padding: 12px; height: auto; }
        .custom-select option { background: #030a12; color: white; }
        .form-control:focus, .custom-select:focus { background: rgba(255, 255, 255, 0.1); color: white; border-color: #4225a3; box-shadow: none; }
        
        .btn-guardar { background: linear-gradient(30deg, #4225a3, #000738); border: none; border-radius: 30px; padding: 12px 24px; color: white; font-weight: bold; cursor: pointer; transition: 0.3s; width: 100%; }
        .btn-guardar:hover { transform: scale(1.03); color: white; }
        
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 30px; padding: 12px 30px; color: white; font-weight: bold; text-decoration: none; display: inline-block; transition: 0.3s; text-align: center; }
        .btn-volver:hover { color: white; text-decoration: none; transform: scale(1.03); }
        
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 20px; padding: 8px 18px; color: white; font-weight: bold; cursor: pointer; transition: 0.3s; font-size: 13px; }
        .btn-eliminar:hover { transform: scale(1.05); color: white; }
        
        table { width: 100%; margin-top: 30px; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { text-align: center; padding: 15px; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        tr:hover td { background: rgba(255,255,255,0.04); }
        
        .mensaje { margin-bottom: 20px; }
        .sin-registros { text-align: center; padding: 20px; color: #d0d8df; }
        .boton-centro { text-align: center; margin-top: 30px; }
        .periodo-badge { display: inline-block; background: linear-gradient(30deg, #4225a3, #000738); padding: 10px 20px; border-radius: 15px; margin-bottom: 25px; font-weight: bold; color: white; border: 1px solid #4225a3; }    
        .icon5 { filter: brightness(0) invert(1); width: 32px; vertical-align: middle; margin-left: 5px; }

        .alert-success-custom { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; border-radius: 15px; padding: 12px 20px; margin-bottom: 25px; font-weight: bold; font-size: 14px; text-align: center; }
        .alert-danger-custom { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; border-radius: 15px; padding: 12px 20px; margin-bottom: 25px; font-weight: bold; font-size: 14px; text-align: center; }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Aplicar Bonificaciones <img src="img/agregar.png" class="icon5"></h2>

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
            int bonoId = Integer.parseInt(request.getParameter("bono_id"));
            
            ps = con.prepareStatement("select sueldo_base from salarios_base where persona_id = ? order by id desc limit 1");
            ps.setInt(1, personaId);
            rs = ps.executeQuery();
            double sueldoBase = rs.next() ? rs.getDouble("sueldo_base") : 0;
            rs.close(); ps.close();

            ps = con.prepareStatement("select tipo, valor from tipos_bonificacion where id = ?");
            ps.setInt(1, bonoId);
            rs = ps.executeQuery();
            if (rs.next()) {
                double monto = "porcentaje".equals(rs.getString("tipo")) ? (sueldoBase * rs.getDouble("valor") / 100.0) : rs.getDouble("valor");
                
                // VALIDACIÓN: No permitir montos negativos
                if (monto < 0) {
                    mensaje = "Error: El monto de la bonificación no puede ser negativo.";
                    tipoMensaje = "danger";
                } else {
                    ps = con.prepareStatement("insert into bonos_persona (persona_id, bono_id, mes, anio, monto_aplicado) values (?, ?, ?, ?, ?)");
                    ps.setInt(1, personaId); ps.setInt(2, bonoId); ps.setInt(3, mesPeriodo); ps.setInt(4, anioPeriodo); ps.setDouble(5, monto);
                    ps.executeUpdate();
                    mensaje = "¡Bonificación aplicada correctamente!";
                    tipoMensaje = "exito";
                }
            }
            ps.close();
        } else if ("eliminar".equals(accion)) {
            ps = con.prepareStatement("delete from bonos_persona where id = ?");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            ps.close();
            mensaje = "¡Bonificación eliminada correctamente!";
            tipoMensaje = "exito";
        }
    }
%>

<% if (mensaje != null) { %>
    <% if ("exito".equals(tipoMensaje)) { %>
        <div class="alert-success-custom" role="alert"><%= mensaje %></div>
    <% } else { %>
        <div class="alert-danger-custom" role="alert"><%= mensaje %></div>
    <% } %>
<% } %>

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
            <label>Bonificación</label>
            <select name="bono_id" class="custom-select" required>
                <option value="">Seleccionar bonificación...</option>
                <%
                st = con.createStatement();
                rs = st.executeQuery("select id, nombre, tipo, valor from tipos_bonificacion order by id desc");
                while (rs.next()) { %>
                    <option value="<%= rs.getInt("id") %>"><%= rs.getString("nombre") %> (<%= "porcentaje".equals(rs.getString("tipo")) ? rs.getDouble("valor")+"%" : "Gs. "+guarani.format(rs.getDouble("valor")) %>)</option>
                <% } rs.close(); st.close(); %>
            </select>
        </div>
        <div class="col-md-2 mb-3 d-flex align-items-end">
            <button type="submit" class="btn-guardar">Aplicar</button>
        </div>
    </div>
</form>

<div class="table-responsive">
    <table>
        <thead>
            <tr>
                <th>Persona</th>
                <th>Bonificación</th>
                <th>Monto</th>
                <th>Acción</th>
            </tr>
        </thead>
        <tbody>
        <%
            rs = con.createStatement().executeQuery("select bp.id, p.nombre, b.nombre as bono_nombre, bp.monto_aplicado from bonos_persona bp join personas p on bp.persona_id = p.id join tipos_bonificacion b on bp.bono_id = b.id where bp.mes = "+mesPeriodo+" and bp.anio = "+anioPeriodo+" order by bp.id desc");
            boolean hay = false;
            while (rs.next()) { hay = true; %>
            <tr>
                <td><strong><%= rs.getString("nombre") %></strong></td>
                <td><%= rs.getString("bono_nombre") %></td>
                <td style="color: #00e676; font-weight: bold;">Gs. <%= guarani.format(rs.getDouble("monto_aplicado")) %></td>
                <td>
                    <form method="post" onsubmit="return confirm('¿Eliminar?');" style="margin:0;">
                        <input type="hidden" name="accion" value="eliminar">
                        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                        <button type="submit" class="btn-eliminar">Eliminar</button>
                    </form>
                </td>
            </tr>
            <% } if (!hay) { %><tr><td colspan="4" class="sin-registros">No hay bonificaciones para el periodo actual.</td></tr><% } %>
        </tbody>
    </table>
</div>

<div class="boton-centro"><a href="admin.jsp" class="btn-volver">Volver al Inicio</a></div>

<%
} catch (Exception e) { out.println("<div class='alert-danger-custom'>Error: " + e.getMessage() + "</div>");
} finally {
    try { if (rs != null) rs.close(); if (st != null) st.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
}
%>
</div>
</body>
</html>