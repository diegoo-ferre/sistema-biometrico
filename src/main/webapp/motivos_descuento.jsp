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
    <title>Motivos de Descuento</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
            font-family: Arial, sans-serif;
            color: white;
            padding: 30px 15px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .contenedor {
            max-width: 1200px;
            width: 100%;
            margin: auto;
            background: rgba(10, 15, 25, 0.9);
            padding: 40px;
            border-radius: 25px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        h2 {
            text-align: center;
            margin-bottom: 30px;
            font-size: 32px;
            font-weight: bold;
        }

        label {
            color: #dce6ef;
            font-size: 14px;
        }

        .form-control, .custom-select {
            background: rgba(255, 255, 255, 0.06);
            border: 1px solid rgba(255,255,255,0.1);
            color: white;
            border-radius: 15px;
            padding: 12px;
            height: auto;
        }

        .custom-select option {
            background: #030a12;
            color: white;
        }

        .form-control:focus, .custom-select:focus {
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border-color: #4225a3;
            box-shadow: none;
        }

        .btn-custom {
            border: none;
            border-radius: 30px;
            padding: 12px 25px;
            font-weight: bold;
            color: white;
            transition: 0.3s;
            cursor: pointer;
        }

        .btn-guardar {
            background: linear-gradient(30deg, #4225a3, #000738);
            width: 100%;
        }

        .btn-volver {
            background: linear-gradient(35deg, #f74040, #f50404);
            display: inline-block;
            text-decoration: none;
            border-radius: 30px;
            padding: 12px 30px;
        }

        .btn-volver:hover {
            color: white;
            text-decoration: none;
            transform: scale(1.03);
        }

        .btn-eliminar {
            background: linear-gradient(35deg, #f74040, #f50404);
            border: none;
            border-radius: 20px;
            padding: 8px 18px;
            color: white;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
            font-size: 13px;
        }

        .btn-custom:hover, .btn-eliminar:hover {
            transform: scale(1.05);
            color: white;
        }

        .table-responsive {
            margin-top: 30px;
        }

        table {
            width: 100%;
            color: white;
            border-collapse: collapse;
            background: rgba(255,255,255,0.03);
            border-radius: 15px;
            overflow: hidden;
        }

        th, td {
            text-align: center;
            padding: 15px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
            vertical-align: middle;
        }

        th {
            background: rgba(255,255,255,0.08);
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        tr:hover td {
            background: rgba(255,255,255,0.04);
        }

        .activo {
            color: #00e676;
            font-weight: bold;
        }

        .inactivo {
            color: #ff5252;
            font-weight: bold;
        }

        .icon4 {
            filter: brightness(0) invert(1);
            width: 32px;
            vertical-align: middle;
            margin-left: 5px;
        }

        .alert-success-custom {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
            border-radius: 15px;
            padding: 12px 20px;
            margin-bottom: 25px;
            font-weight: bold;
            font-size: 14px;
            text-align: center;
        }

        .alert-danger-custom {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            border-radius: 15px;
            padding: 12px 20px;
            margin-bottom: 25px;
            font-weight: bold;
            font-size: 14px;
            text-align: center;
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Motivos de Descuento <img src="img/eliminar.png" class="icon4"></h2>

<%
Connection con = null;
PreparedStatement ps = null;
Statement st = null;
ResultSet rs = null;
String mensaje = null;
String tipoMensaje = "exito";
DecimalFormat guarani = new DecimalFormat("###,###,###");

try {
    Class.forName("org.postgresql.Driver");

    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
    String user = "neondb_owner";
    String pass = "npg_6rt8OdayAHcm";

    con = DriverManager.getConnection(url, user, pass);

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        String accion = request.getParameter("accion");

        if ("guardar".equals(accion)) {
            String motivo = request.getParameter("motivo");
            String tipo = request.getParameter("tipo");
            String valorStr = request.getParameter("valor");

            if (motivo != null && tipo != null && valorStr != null) {
                double valor = Double.parseDouble(valorStr);

                ps = con.prepareStatement(
                    "insert into motivos_descuento (motivo, tipo, valor) values (?, ?, ?)"
                );
                ps.setString(1, motivo);
                ps.setString(2, tipo);
                ps.setDouble(3, valor);
                ps.executeUpdate();
                ps.close();

                mensaje = "¡Motivo guardado correctamente!";
                tipoMensaje = "exito";
            }
        }

        if ("eliminar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("id"));

            ps = con.prepareStatement("delete from motivos_descuento where id = ?");
            ps.setInt(1, id);
            ps.executeUpdate();
            ps.close();

            mensaje = "¡Motivo eliminado correctamente!";
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

    <form method="post">
        <input type="hidden" name="accion" value="guardar">

        <div class="row">
            <div class="col-md-4 mb-3">
                <label>Motivo</label>
                <input type="text" name="motivo" class="form-control" required placeholder="Ej. Tardanza">
            </div>

            <div class="col-md-4 mb-3">
                <label>Tipo</label>
                <select name="tipo" class="custom-select" required>
                    <option value="">Seleccionar...</option>
                    <option value="fijo">Monto fijo</option>
                    <option value="porcentaje">Porcentaje</option>
                </select>
            </div>

            <div class="col-md-4 mb-3">
                <label>Valor</label>
                <input type="number" step="0.01" name="valor" class="form-control" required placeholder="0.00">
            </div>
        </div>

        <div class="text-center mt-3">
            <button type="submit" class="btn-custom btn-guardar">Guardar Motivo</button>
        </div>
    </form>

    <div class="table-responsive">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Motivo</th>
                    <th>Tipo</th>
                    <th>Valor</th>
                    <th>Estado</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>

<%
    st = con.createStatement();
    rs = st.executeQuery("select * from motivos_descuento order by id desc");

    boolean hay = false;
    while (rs.next()) {
        hay = true;
        String tipoVal = rs.getString("tipo");
        double valNum = rs.getDouble("valor");
%>
                <tr>
                    <td><%= rs.getInt("id") %></td>
                    <td><strong><%= rs.getString("motivo") %></strong></td>
                    <td><%= tipoVal %></td>
                    <td>
                        <% if ("porcentaje".equals(tipoVal)) { %>
                            <%= guarani.format(valNum).replace(',', '.') %>%
                        <% } else { %>
                            Gs. <%= guarani.format(valNum).replace(',', '.') %>
                        <% } %>
                    </td>
                    <td>
                        <% if (rs.getBoolean("activo")) { %>
                            <span class="activo">Activo</span>
                        <% } else { %>
                            <span class="inactivo">Inactivo</span>
                        <% } %>
                    </td>
                    <td>
                        <form method="post" onsubmit="return confirm('¿Eliminar este motivo?');" style="margin:0;">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                            <button type="submit" class="btn-eliminar">Eliminar</button>
                        </form>
                    </td>
                </tr>
<%
    }
    if (!hay) {
%>
                <tr><td colspan="6" class="text-center text-muted py-4">No hay motivos de descuento registrados.</td></tr>
<%
    }
%>

            </tbody>
        </table>
    </div>

<%
} catch (Exception e) {
%>
    <div class="alert-danger-custom">
        Error: <%= e.getMessage() %>
    </div>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (st != null) st.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

    <div class="text-center mt-4">
        <a href="admin.jsp" class="btn-custom btn-volver">Volver al Inicio</a>
    </div>
</div>

</body>
</html>