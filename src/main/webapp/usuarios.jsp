<%@ page import="java.sql.*" %>
<%
String rol = (String) session.getAttribute("rol");

if (rol == null || !"admin".equals(rol)) {
    response.sendRedirect("index.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Usuarios</title>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">

<style>
body {
    background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a);
    color: white;
    font-family: Arial;
}

.container {
    margin-top: 40px;
    background: rgba(10,15,25,0.9);
    padding: 30px;
    border-radius: 20px;
}

.table {
    color: white;
}
</style>
</head>

<body>

<div class="container">

<h2>Gestión de Usuarios</h2>


<!-- TABLA -->
<table class="table table-dark table-bordered">

<tr>
    <th>ID</th>
    <th>Usuario</th>
    <th>Rol</th>
    <th>Acciones</th>
</tr>

<%
Class.forName("org.postgresql.Driver");

Connection con = DriverManager.getConnection(
    "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require",
    "neondb_owner",
    "npg_6rt8OdayAHcm"
);

Statement st = con.createStatement();
ResultSet rs = st.executeQuery("SELECT * FROM usuarios ORDER BY id");

while(rs.next()) {
%>
%>

<tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getString("usuario") %></td>
    <td><%= rs.getString("rol") %></td>

    <td>

        <a href="UsuarioServlet?accion=eliminar&id=<%= rs.getInt("id") %>" 
           class="btn btn-danger btn-sm">
           Eliminar
        </a>

    </td>
</tr>

<%
}
con.close();
%>

</table>

</div>

</body>
</html>