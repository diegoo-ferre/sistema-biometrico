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
        body {
            margin: 0;
            min-height: 100vh;
            background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
            font-family: Arial, sans-serif;
            color: white;
            padding: 30px 15px;
        }

        .contenedor {
            max-width: 1250px;
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

        .btn-guardar {
            background: linear-gradient(45deg, #6c5ce7, #a29bfe);
            border: none;
            border-radius: 25px;
            padding: 12px 24px;
            color: white;
            font-weight: bold;
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

        .btn-eliminar {
            background: linear-gradient(45deg, #d63031, #ff7675);
            border: none;
            border-radius: 20px;
            padding: 8px 18px;
            color: white;
            font-weight: bold;
        }

        table {
            width: 100%;
            margin-top: 30px;
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

        .mensaje {
            margin-bottom: 20px;
        }

        .sin-registros {
            text-align: center;
            padding: 20px;
            color: #d0d8df;
        }

        .boton-centro {
            text-align: center;
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Aplicar Descuentos</h2>

<%
Connection con = null;
PreparedStatement ps = null;
PreparedStatement ps2 = null;
Statement st = null;
ResultSet rs = null;
ResultSet rs2 = null;
String mensaje = null;

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
            String personaIdStr = request.getParameter("persona_id");
            String motivoIdStr = request.getParameter("motivo_id");
            String mesStr = request.getParameter("mes");
            String anioStr = request.getParameter("anio");

            if (personaIdStr != null && motivoIdStr != null && mesStr != null && anioStr != null &&
                !personaIdStr.trim().equals("") && !motivoIdStr.trim().equals("") &&
                !mesStr.trim().equals("") && !anioStr.trim().equals("")) {

                int personaId = Integer.parseInt(personaIdStr);
                int motivoId = Integer.parseInt(motivoIdStr);
                int mes = Integer.parseInt(mesStr);
                int anio = Integer.parseInt(anioStr);

                double sueldoBase = 0;
                String tipo = "";
                double valor = 0;
                double montoAplicado = 0;

                ps = con.prepareStatement(
                    "select sueldo_base from salarios_base where persona_id = ? order by id desc limit 1"
                );
                ps.setInt(1, personaId);
                rs = ps.executeQuery();

                if (rs.next()) {
                    sueldoBase = rs.getDouble("sueldo_base");
                }
                rs.close();
                ps.close();

                ps = con.prepareStatement(
                    "select tipo, valor from motivos_descuento where id = ? and activo = true"
                );
                ps.setInt(1, motivoId);
                rs = ps.executeQuery();

                if (rs.next()) {
                    tipo = rs.getString("tipo");
                    valor = rs.getDouble("valor");
                }
                rs.close();
                ps.close();

                if (sueldoBase <= 0) {
                    mensaje = "la persona seleccionada no tiene sueldo base asignado.";
                } else {
                    if ("porcentaje".equals(tipo)) {
                        montoAplicado = sueldoBase * valor / 100.0;
                    } else {
                        montoAplicado = valor;
                    }

                    ps = con.prepareStatement(
                        "insert into descuentos_persona (persona_id, motivo_id, mes, anio, monto_aplicado) values (?, ?, ?, ?, ?)"
                    );
                    ps.setInt(1, personaId);
                    ps.setInt(2, motivoId);
                    ps.setInt(3, mes);
                    ps.setInt(4, anio);
                    ps.setDouble(5, montoAplicado);
                    ps.executeUpdate();
                    ps.close();

                    mensaje = "descuento aplicado correctamente.";
                }
            }
        }

        if ("eliminar".equals(accion)) {
            int id = Integer.parseInt(request.getParameter("id"));

            ps = con.prepareStatement("delete from descuentos_persona where id = ?");
            ps.setInt(1, id);
            ps.executeUpdate();
            ps.close();

            mensaje = "descuento eliminado correctamente.";
        }
    }
%>

<% if (mensaje != null) { %>
    <div class="alert alert-info mensaje"><%= mensaje %></div>
<% } %>

    <form method="post">
        <input type="hidden" name="accion" value="guardar">

        <div class="row">
            <div class="col-md-3 mb-3">
                <label>Persona</label>
                <select name="persona_id" class="custom-select" required>
                    <option value="">Seleccionar</option>
                    <%
                    st = con.createStatement();
                    rs = st.executeQuery("select id, nombre, ci from personas order by nombre asc");
                    while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("id") %>">
                            <%= rs.getString("nombre") %> - CI: <%= rs.getString("ci") %>
                        </option>
                    <%
                    }
                    rs.close();
                    st.close();
                    %>
                </select>
            </div>

            <div class="col-md-3 mb-3">
                <label>Motivo</label>
                <select name="motivo_id" class="custom-select" required>
                    <option value="">Seleccionar</option>
                    <%
                    st = con.createStatement();
                    rs = st.executeQuery("select id, motivo, tipo, valor from motivos_descuento where activo = true order by id desc");
                    while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("id") %>">
                            <%= rs.getString("motivo") %>
                            -
                            <% if ("porcentaje".equals(rs.getString("tipo"))) { %>
                                <%= rs.getDouble("valor") %>%
                            <% } else { %>
                                Gs. <%= guarani.format(rs.getDouble("valor")).replace(',', '.') %>
                            <% } %>
                        </option>
                    <%
                    }
                    rs.close();
                    st.close();
                    %>
                </select>
            </div>

            <div class="col-md-2 mb-3">
                <label>Mes</label>
                <select name="mes" class="custom-select" required>
                    <% for (int i = 1; i <= 12; i++) { %>
                        <option value="<%= i %>"><%= i %></option>
                    <% } %>
                </select>
            </div>

            <div class="col-md-2 mb-3">
                <label>Año</label>
                <select name="anio" class="custom-select" required>
                    <%
                    int anioActual = java.time.LocalDate.now().getYear();
                    for (int i = anioActual - 2; i <= anioActual + 2; i++) {
                    %>
                        <option value="<%= i %>" <%= i == anioActual ? "selected" : "" %>><%= i %></option>
                    <%
                    }
                    %>
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
                <th>ID</th>
                <th>Persona</th>
                <th>CI</th>
                <th>Motivo</th>
                <th>Mes</th>
                <th>Año</th>
                <th>Monto aplicado</th>
                <th>Acción</th>
            </tr>
        </thead>
        <tbody>

<%
    st = con.createStatement();
    rs = st.executeQuery(
        "select dp.id, dp.mes, dp.anio, dp.monto_aplicado, p.nombre, p.ci, m.motivo " +
        "from descuentos_persona dp " +
        "join personas p on dp.persona_id = p.id " +
        "join motivos_descuento m on dp.motivo_id = m.id " +
        "order by dp.id desc"
    );

    boolean hay = false;

    while (rs.next()) {
        hay = true;
%>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("nombre") %></td>
                <td><%= rs.getString("ci") %></td>
                <td><%= rs.getString("motivo") %></td>
                <td><%= rs.getInt("mes") %></td>
                <td><%= rs.getInt("anio") %></td>
                <td>Gs. <%= guarani.format(rs.getDouble("monto_aplicado")).replace(',', '.') %></td>
                <td>
                    <form method="post" onsubmit="return confirm('¿Eliminar este descuento?');" style="margin:0;">
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
            <tr>
                <td colspan="8" class="sin-registros">no hay descuentos aplicados.</td>
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
    try { if (rs2 != null) rs2.close(); } catch (Exception e) {}
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (st != null) st.close(); } catch (Exception e) {}
    try { if (ps2 != null) ps2.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

    <div class="boton-centro">
        <a href="index.jsp" class="btn-volver">Volver al inicio</a>
    </div>
</div>

</body>
</html>