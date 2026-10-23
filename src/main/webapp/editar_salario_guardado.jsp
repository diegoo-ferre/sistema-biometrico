<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial de Salarios</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { margin: 0; min-height: 100vh; font-family: Arial, sans-serif; background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); display: flex; align-items: center; justify-content: center; padding: 30px 15px; color: white; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 25px; color: white; width: 98%; max-width: 1450px; box-shadow: 0 10px 40px rgba(0,0,0,0.9); }
        h2 { text-align: center; font-size: 32px; margin-bottom: 25px; font-weight: bold; }
        
        .filtro-box { margin-bottom: 20px; }
        .filtro-box input { width: 100%; max-width: 300px; padding: 10px 15px; border-radius: 20px; border: none; background: rgba(255,255,255,0.1); color: white; outline: none; }
        .filtro-box input:focus { background: rgba(255,255,255,0.15); }

        table { width: 100%; color: white; border-collapse: collapse; margin-top: 20px; background: rgba(255,255,255,0.03); border-radius: 15px; overflow: hidden; }
        th, td { padding: 15px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.08); vertical-align: middle; }
        th { background: rgba(255,255,255,0.08); font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        tr:hover td { background: rgba(255,255,255,0.04); }

        .btn-accion { padding: 8px 15px; border-radius: 20px; border: none; color: white !important; font-weight: bold; cursor: pointer; transition: transform 0.3s ease; text-decoration: none !important; display: inline-block; font-size: 14px; }
        .btn-accion:hover { transform: scale(1.05); color: white !important; text-decoration: none; }
        .btn-edit { background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-eliminar { background: linear-gradient(35deg, #f74040, #f50404); border: none; cursor: pointer; padding: 8px 15px; font-weight: bold; border-radius: 20px; color: white; transition: transform 0.2s; font-size: 14px; }
        .btn-eliminar:hover { transform: scale(1.05); color: white; }
        
        .btn-volver { background: linear-gradient(35deg, #f74040, #f50404); border: none; border-radius: 30px; padding: 12px 30px; font-weight: bold; color: white; display: inline-block; text-decoration: none; transition: 0.3s; text-align: center; }
        .btn-volver:hover { color: white; text-decoration: none; transform: scale(1.03); }

        .boton-centro { text-align: center; margin-top: 30px; }
        .sin-registros { text-align: center; padding: 20px; color: #d0d8df; }
        .mensaje { margin-bottom: 20px; }
        .icon6 { filter: brightness(0) invert(1); width: 32px; vertical-align: middle; margin-left: 5px; }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Historial de Salarios <img src="img/historial-de-transacciones.png" class="icon6"></h2>

    <div class="filtro-box">
        <input type="text" id="filtroInput" onkeyup="filtrarTabla()" placeholder="🔍 Buscar por nombre...">
    </div>

<%
Connection con = null;
Statement st = null;
ResultSet rs = null;
DecimalFormat df = new DecimalFormat("#,###"); 

try {
    Class.forName("org.postgresql.Driver");
    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
    con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");
    st = con.createStatement();
    
    rs = st.executeQuery(
        "SELECT s.id, p.nombre, p.ci, s.sueldo_final, s.fecha_registro " +
        "FROM salarios s " +
        "LEFT JOIN personas p ON s.persona_id = p.id " +
        "ORDER BY s.id DESC"
    );
    
    SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>

    <div class="table-responsive">
        <table id="tablaHistorial">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>CI</th>
                    <th>Sueldo Final</th>
                    <th>Fecha</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
<%
boolean hay = false;
while(rs.next()){
    hay = true;
    Timestamp fecha = rs.getTimestamp("fecha_registro");
    String nombrePersona = rs.getString("nombre");
    String ciPersona = rs.getString("ci");
%>
                <tr>
                    <td><%= rs.getInt("id") %></td>
                    <td><strong><%= (nombrePersona != null) ? nombrePersona : "---" %></strong></td>
                    <td><%= (ciPersona != null) ? ciPersona : "---" %></td>
                    <td style="color: #00e676; font-weight: bold;">Gs. <%= df.format(rs.getDouble("sueldo_final")).replace(',', '.') %></td>
                    <td><%= fecha != null ? formato.format(fecha) : "" %></td>
                    <td>
                        <div style="display:flex; gap:10px; justify-content:center; align-items:center;">
                            <a href="editar_historial.jsp?id=<%= rs.getInt("id") %>" class="btn-accion btn-edit">Editar</a>
                            <form method="post" action="eliminar_historial.jsp" onsubmit="return confirm('¿Seguro de eliminar?');" style="margin:0;">
                                <input type="hidden" name="idEliminar" value="<%= rs.getInt("id") %>">
                                <button type="submit" class="btn-eliminar">Eliminar</button>
                            </form>
                        </div>
                    </td>
                </tr>
<% }
if(!hay){ %> <tr><td colspan="6" class="sin-registros">No hay registros.</td></tr> <% } %>
            </tbody>
        </table>
    </div>

<% } catch(Exception e){ out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>"); } 
finally { if(rs!=null) rs.close(); if(st!=null) st.close(); if(con!=null) con.close(); } %>

    <div class="boton-centro">
        <a href="admin.jsp" class="btn-volver">Volver al Inicio</a>
    </div>
</div>

<script>
    function filtrarTabla() {
        let input = document.getElementById("filtroInput").value.toUpperCase();
        let tr = document.getElementById("tablaHistorial").getElementsByTagName("tr");
        for (let i = 1; i < tr.length; i++) {
            let td = tr[i].getElementsByTagName("td")[1];
            tr[i].style.display = (td && td.textContent.toUpperCase().indexOf(input) > -1) ? "" : "none";
        }
    }
</script>
</body>
</html>