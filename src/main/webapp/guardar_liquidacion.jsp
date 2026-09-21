<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;
DecimalFormat guarani = new DecimalFormat("###,###,###");

String buscar = request.getParameter("buscar");
if (buscar == null) buscar = "";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial de Salarios</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { margin: 0; min-height: 100vh; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); font-family: Arial, sans-serif; color: white; padding: 30px 15px; }
        .contenedor { max-width: 1200px; margin: auto; background: rgba(10, 15, 25, 0.88); padding: 35px; border-radius: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; margin-bottom: 30px; font-size: 32px; font-weight: bold; }
        .periodo-info { text-align: center; margin-bottom: 25px; padding: 20px; background: rgba(255,255,255,0.05); border-radius: 20px; font-size: 18px; border: 1px solid rgba(255,255,255,0.1); }
        table { width: 100%; color: white; border-collapse: collapse; background: rgba(0,0,0,0.2); border-radius: 15px; overflow: hidden; margin-top: 20px; }
        th, td { text-align: center; padding: 15px; border: 1px solid rgba(255,255,255,0.08); vertical-align: middle !important; }
        th { background: rgba(255,255,255,0.08); }
        
        .btn-editar { background: linear-gradient(40deg, #4225a3, #000738); border: none; color: white; padding: 8px 20px; border-radius: 15px; font-weight: bold; text-decoration: none; display: inline-block; margin-bottom: 5px; }
        .btn-editar:hover { color: white; text-decoration: none; opacity: 0.9; }
        
        .btn-eliminar { background: linear-gradient(40deg, #e74c3c, #c0392b); border: none; color: white; padding: 8px 20px; border-radius: 15px; font-weight: bold; text-decoration: none; display: inline-block; margin-bottom: 5px; cursor: pointer; }
        .btn-eliminar:hover { color: white; text-decoration: none; opacity: 0.9; }

        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; color: white; padding: 12px 24px; border-radius: 15px; text-decoration: none; display: inline-block; margin-top: 25px; font-weight: bold; }
        .btn-volver:hover { color: white; text-decoration: none; }
        
        .boton-centro { text-align: center; }
        .final { color: #00e676; font-weight: bold; }
        
        .form-control-buscador { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: white; border-radius: 15px; padding: 10px 20px; }
        .form-control-buscador:focus { background: rgba(255,255,255,0.1); color: white; border-color: rgba(255,255,255,0.3); box-shadow: none; }
        .form-control-buscador::placeholder { color: #b0bec5; }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>salarios guardados <i class="fas fa-file-invoice-dollar ms-2"></i></h2>



    <table id="tablaSalarios">
        <thead>
            <tr>
                <th>id</th>
                <th>nombre</th>
                <th>ci</th>
                <th>sueldo final</th>
                <th>fecha</th>
                
            </tr>
        </thead>
        <tbody>
        <%
        try {
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
            con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");

            String sql = "SELECT s.id, p.nombre, p.ci, s.sueldo_final, s.fecha_registro " +
                         "FROM salarios s " +
                         "JOIN personas p ON s.persona_id = p.id " +
                         "ORDER BY s.id DESC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            boolean hayRegistros = false;

            while (rs.next()) {
                hayRegistros = true;
                int id = rs.getInt("id");
                String nombre = rs.getString("nombre");
                String ci = rs.getString("ci");
                double sueldoFinal = rs.getDouble("sueldo_final");
                Timestamp fecha = rs.getTimestamp("fecha_registro");
        %>
            <tr>
                <td><%= id %></td>
                <td class="nombre-persona"><%= (nombre != null) ? nombre : "---" %></td>
                <td><%= (ci != null) ? ci : "---" %></td>
                <td class="final">Gs. <%= guarani.format(sueldoFinal) %></td>
                <td><%= (fecha != null) ? fecha.toString().substring(0, 19) : "---" %></td>
                
            </tr>
        <%
            }
            if (!hayRegistros) {
        %>
            <tr>
                <td colspan="6" class="text-center text-muted py-4">No se encontraron registros en el historial.</td>
            </tr>
        <%
            }
        } catch (Exception e) {
        %>
            <tr>
                <td colspan="6" class="text-danger text-center">Error al cargar datos: <%= e.getMessage() %></td>
            </tr>
        <%
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
        %>
        </tbody>
    </table>
    
    <div class="boton-centro"><a href="admin.jsp" class="btn-volver">Volver al inicio</a></div>
</div>

<script>
function filtrarTabla() {
    let input = document.getElementById("buscadorInput");
    let filtro = input.value.toLowerCase();
    let tabla = document.getElementById("tablaSalarios");
    let filas = tabla.getElementsByTagName("tr");

    for (let i = 1; i < filas.length; i++) {
        let celdaNombre = filas[i].getElementsByClassName("nombre-persona")[0];
        if (celdaNombre) {
            let textoNombre = celdaNombre.textContent || celdaNombre.innerText;
            if (textoNombre.toLowerCase().indexOf(filtro) > -1) {
                filas[i].style.display = "";
            } else {
                filas[i].style.display = "none";
            }
        }
    }
}
</script>

</body>
</html>