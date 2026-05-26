<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Historial de Salarios</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px 15px;
        }

        .contenedor {
            background: rgba(10, 15, 25, 0.85);
            padding: 40px;
            border-radius: 25px;
            color: white;
            width: 98%;
            max-width: 1450px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
        }

        h2 {
            text-align: center;
            font-size: 38px;
            margin-bottom: 25px;
            font-weight: bold;
        }

        table {
            width: 100%;
            color: white;
            border-collapse: collapse;
            margin-top: 20px;
            background: rgba(255,255,255,0.03);
            border-radius: 15px;
            overflow: hidden;
        }

        th, td {
            padding: 12px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.08);
            vertical-align: middle;
        }

        th {
            background: rgba(255,255,255,0.1);
        }

        tr:hover td {
            background: rgba(255,255,255,0.05);
        }

        .btn-volver {
            margin-top: 20px;
            border-radius: 25px;
            padding: 12px 26px;
            font-size: 16px;
            font-weight: bold;
        }

        .btn-eliminar, .btn-editar {
            border-radius: 20px;
            padding: 8px 18px;
            font-weight: bold;
            margin: 3px 0;
        }

        .boton-centro {
            text-align: center;
        }

        .sin-registros {
            text-align: center;
            padding: 20px;
            color: #d0d8df;
        }

        .mensaje {
            margin-bottom: 20px;
        }

        .acciones-form {
            margin: 0;
        }
    </style>
</head>
<body>

<div class="contenedor">
<h2>Historial de Salarios</h2>

<%
Connection con = null;
Statement st = null;
PreparedStatement ps = null;
ResultSet rs = null;
String mensaje = null;

try {
    Class.forName("org.postgresql.Driver");

    String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String idEliminar = request.getParameter("idEliminar");

        if (idEliminar != null && !idEliminar.trim().equals("")) {
            ps = con.prepareStatement("delete from salarios where id = ?");
            ps.setInt(1, Integer.parseInt(idEliminar));
            ps.executeUpdate();
            ps.close();
            mensaje = "salario eliminado correctamente.";
        }
    }

    String sql = "select s.*, p.nombre, p.ci from salarios s join personas p on s.persona_id = p.id order by s.id desc";

    st = con.createStatement();
    rs = st.executeQuery(sql);

    SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

    if (mensaje != null) {
%>
    <div class="alert alert-success mensaje"><%= mensaje %></div>
<%
    }
%>

<table>
    <thead>
        <tr>
            <th>id</th>
            <th>nombre</th>
            <th>ci</th>
            <th>sueldo base</th>
            <th>%</th>
            <th>motivo</th>
            <th>descuento</th>
            <th>sueldo final</th>
            <th>fecha</th>
            <th>acción</th>
        </tr>
    </thead>
    <tbody>

<%
boolean hay = false;

while(rs.next()){
    hay = true;
    Timestamp fecha = rs.getTimestamp("fecha_registro");
%>

<tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("nombre") %></td>
    <td><%= rs.getString("ci") %></td>
    <td><%= rs.getDouble("sueldo_base") %></td>
    <td><%= rs.getDouble("porcentaje_descuento") %> %</td>
    <td><%= rs.getString("motivo_descuento") %></td>
    <td><%= rs.getDouble("monto_descuento") %></td>
    <td><%= rs.getDouble("sueldo_final") %></td>
    <td><%= fecha != null ? formato.format(fecha) : "" %></td>
    <td>
        <a href="editar_salario_guardado.jsp?id=<%= rs.getInt("id") %>" class="btn btn-warning btn-editar">editar</a>

        <form method="post" class="acciones-form" onsubmit="return confirm('¿estás seguro de eliminar este salario?');">
            <input type="hidden" name="idEliminar" value="<%= rs.getInt("id") %>">
            <button type="submit" class="btn btn-danger btn-eliminar">eliminar</button>
        </form>
    </td>
</tr>

<%
}

if(!hay){
%>
<tr>
    <td colspan="10" class="sin-registros">no hay registros.</td>
</tr>
<%
}
%>

    </tbody>
</table>

<%
} catch(Exception e){
%>
<div class="alert alert-danger mensaje">
    Error: <%= e.getMessage() %>
</div>
<%
} finally {
    try { if(rs!=null) rs.close(); } catch(Exception e){}
    try { if(st!=null) st.close(); } catch(Exception e){}
    try { if(ps!=null) ps.close(); } catch(Exception e){}
    try { if(con!=null) con.close(); } catch(Exception e){}
}
%>

<div class="boton-centro">
    <a href="salarios.jsp" class="btn btn-success btn-volver">Volver</a>
</div>

</div>

</body>
</html>