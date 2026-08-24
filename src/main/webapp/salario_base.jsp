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
    <title>Asignación de Sueldo Base</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 1350px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 38px; font-weight: bold; }
        
        /* Estilos del filtro */
        .filtro-box { margin-bottom: 20px; }
        .filtro-box input { width: 100%; max-width: 300px; padding: 10px 15px; border-radius: 20px; border: none; background: rgba(255,255,255,0.1); color: white; outline: none; }

        table { width: 100%; margin-top: 25px; color: white; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { text-align: center; padding: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); }
        tr:hover td { background: rgba(255,255,255,0.04); }
        
        .form-control { border-radius: 15px; padding: 10px; min-width: 150px; }
        .btn-guardar { background: linear-gradient(35deg, #4225a3, #000738); border: none; border-radius: 20px; padding: 8px 18px; color: white; font-weight: bold; }
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 25px; padding: 12px 26px; color: white; font-weight: bold; text-decoration: none; display: inline-block; margin-top: 25px; }
        .btn-volver:hover { color: white; text-decoration: none; }
        .mensaje { margin-bottom: 20px; }
        .sin-registros { text-align: center; padding: 20px; color: #d0d8df; }
        .boton-centro { text-align: center; }
        .sueldo-cargado { color: #00e676; font-weight: bold; }
        .sueldo-vacio { color: #ff5252; font-weight: bold; }
        .icon3 { filter: brightness(0) invert(1); }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Asignación de Sueldo Base <img src="img/guarani.png" class="icon3"></h2>

    <div class="filtro-box">
        <input type="text" id="filtroInput" onkeyup="filtrarTabla()" placeholder="🔍 Buscar por nombre...">
    </div>

<%
Connection con = null;
PreparedStatement ps = null;
Statement st = null;
ResultSet rs = null;
String mensaje = null;
DecimalFormat guarani = new DecimalFormat("###,###,###");

try {
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
    con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String personaIdStr = request.getParameter("persona_id");
        String sueldoBaseStr = request.getParameter("sueldo_base");

        if (personaIdStr != null && sueldoBaseStr != null && !personaIdStr.trim().equals("") && !sueldoBaseStr.trim().equals("")) {
            int personaId = Integer.parseInt(personaIdStr);
            double sueldoBase = Double.parseDouble(sueldoBaseStr);

            if (sueldoBase > 0) {
                ps = con.prepareStatement("insert into salarios_base (persona_id, sueldo_base) values (?, ?)");
                ps.setInt(1, personaId);
                ps.setDouble(2, sueldoBase);
                ps.executeUpdate();
                ps.close();
                mensaje = "Sueldo base guardado correctamente.";
            } else {
                mensaje = "El sueldo base debe ser mayor que 0.";
            }
        }
    }
%>

<% if (mensaje != null) { %>
    <div class="alert alert-info mensaje"><%= mensaje %></div>
<% } %>

    <table id="tablaSueldos">
        <thead>
            <tr>
                <th>id</th>
                <th>nombre</th>
                <th>ci</th>
                <th>último sueldo base</th>
                <th>nuevo sueldo base</th>
                <th>acción</th>
            </tr>
        </thead>
        <tbody>
<%
    st = con.createStatement();
    rs = st.executeQuery(
        "select p.id, p.nombre, p.ci, " +
        "(select sb.sueldo_base from salarios_base sb where sb.persona_id = p.id order by sb.id desc limit 1) as sueldo_actual " +
        "from personas p order by p.id desc"
    );

    boolean hay = false;
    while (rs.next()) {
        hay = true;
        int personaId = rs.getInt("id");
        String nombre = rs.getString("nombre");
        String ci = rs.getString("ci");
        Object sueldoObj = rs.getObject("sueldo_actual");
%>
            <tr>
                <td><%= personaId %></td>
                <td><%= nombre %></td>
                <td><%= ci %></td>
                <td>
                    <% if (sueldoObj != null) { %>
                        <span class="sueldo-cargado">
                            Gs. <%= guarani.format(rs.getDouble("sueldo_actual")).replace(',', '.') %>
                        </span>
                    <% } else { %>
                        <span class="sueldo-vacio">sin sueldo asignado</span>
                    <% } %>
                </td>
                <td>
                    <form method="post" style="margin:0; display: flex; justify-content: center;">
                        <input type="hidden" name="persona_id" value="<%= personaId %>">
                        <input type="number" step="0.01" min="1" name="sueldo_base" class="form-control" required>
                </td>
                <td>
                        <button type="submit" class="btn-guardar">Guardar</button>
                    </form>
                </td>
            </tr>
<%  } 
    if (!hay) { %>
            <tr><td colspan="6" class="sin-registros">No hay personas registradas.</td></tr>
<%  } rs.close(); %>
        </tbody>
    </table>

<% } catch (Exception e) { %>
    <div class="alert alert-danger">Error: <%= e.getMessage() %></div>
<% } finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (st != null) st.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
} %>

    <div class="boton-centro">
        <a href="admin.jsp" class="btn-volver">Volver al inicio</a>
    </div>
</div>

<script>
    function filtrarTabla() {
        let input = document.getElementById("filtroInput").value.toUpperCase();
        let table = document.getElementById("tablaSueldos");
        let tr = table.getElementsByTagName("tr");
        for (let i = 1; i < tr.length; i++) {
            let td = tr[i].getElementsByTagName("td")[1]; 
            if (td) {
                let txtValue = td.textContent || td.innerText;
                tr[i].style.display = (txtValue.toUpperCase().indexOf(input) > -1) ? "" : "none";
            }
        }
    }
</script>

</body>
</html>