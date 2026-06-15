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
    <title>Motivos de Descuento</title>
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
            max-width: 1200px;
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

        .form-control, .custom-select {
            border-radius: 15px;
            padding: 12px;
        }

        .btn-custom {
            border: none;
            border-radius: 25px;
            padding: 12px 25px;
            font-weight: bold;
            color: white;
            transition: 0.3s;
        }

        .btn-guardar {
            background: linear-gradient(45deg, #00b894, #00cec9);
        }

        .btn-volver {
            background: linear-gradient(45deg, #0984e3, #74b9ff);
        }

        .btn-eliminar {
            background: linear-gradient(45deg, #d63031, #ff7675);
            border: none;
            border-radius: 20px;
            padding: 8px 18px;
            color: white;
            font-weight: bold;
        }

        .btn-custom:hover {
            transform: scale(1.03);
        }

        table {
            width: 100%;
            margin-top: 30px;
            color: white;
        }

        th, td {
            text-align: center;
            padding: 12px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }

        th {
            background: rgba(255,255,255,0.08);
        }

        .activo {
            color: #00e676;
            font-weight: bold;
        }

        .inactivo {
            color: #ff5252;
            font-weight: bold;
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Motivos de Descuento</h2>

<%
Connection con = null;
PreparedStatement ps = null;
Statement st = null;
ResultSet rs = null;
String mensaje = null;

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

                mensaje = "motivo guardado correctamente.";
            }
        }

        if ("eliminar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("id"));

            ps = con.prepareStatement("delete from motivos_descuento where id = ?");
            ps.setInt(1, id);
            ps.executeUpdate();
            ps.close();

            mensaje = "motivo eliminado correctamente.";
        }
    }
%>

<% if (mensaje != null) { %>
    <div class="alert alert-success"><%= mensaje %></div>
<% } %>

    <form method="post">
        <input type="hidden" name="accion" value="guardar">

        <div class="row">
            <div class="col-md-4 mb-3">
                <label>Motivo</label>
                <input type="text" name="motivo" class="form-control" required>
            </div>

            <div class="col-md-4 mb-3">
                <label>Tipo</label>
                <select name="tipo" class="custom-select" required>
                    <option value="">Seleccionar</option>
                    <option value="fijo">Monto fijo</option>
                    <option value="porcentaje">Porcentaje</option>
                </select>
            </div>

            <div class="col-md-4 mb-3">
                <label>Valor</label>
                <input type="number" step="0.01" name="valor" class="form-control" required>
            </div>
        </div>

        <div class="text-center mt-3">
            <button type="submit" class="btn-custom btn-guardar">Guardar motivo</button>
        </div>
    </form>

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

    while (rs.next()) {
%>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("motivo") %></td>
                <td><%= rs.getString("tipo") %></td>
                <td>
                    <% if ("porcentaje".equals(rs.getString("tipo"))) { %>
                        <%= rs.getDouble("valor") %>%
                    <% } else { %>
                        Gs. <%= rs.getDouble("valor") %>
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
                    <form method="post" onsubmit="return confirm('¿Eliminar este motivo?');">
                        <input type="hidden" name="accion" value="eliminar">
                        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                        <button type="submit" class="btn-eliminar">Eliminar</button>
                    </form>
                </td>
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
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (st != null) st.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

    <div class="text-center mt-4">
        <a href="admin.jsp" class="btn-custom btn-volver">Volver al inicio</a>
    </div>
</div>

</body>
</html>