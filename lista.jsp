<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Lista de Personas</title>
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
            padding: 40px 35px;
            border-radius: 25px;
            color: white;
            box-shadow: 0 10px 40px rgba(0,0,0,0.9);
            width: 98%;
            max-width: 1300px;
            text-align: center;
        }

        h2 {
            margin-bottom: 20px;
            font-weight: bold;
        }

        table {
            width: 100%;
            border-radius: 10px;
            overflow: hidden;
        }

        th {
            background: #0b1f2a;
            color: white;
            padding: 12px;
            text-align: center;
        }

        td {
            background: rgba(255,255,255,0.05);
            padding: 10px;
            color: #d0d8df;
            text-align: center;
            vertical-align: middle;
        }

        tr:hover td {
            background: rgba(0, 198, 255, 0.1);
        }

        .btn-custom {
            border-radius: 30px;
            padding: 10px 25px;
            font-weight: bold;
            border: none;
        }

        .btn-volver {
            background: linear-gradient(45deg, #28a745, #5eff8a);
            color: white;
            margin-top: 20px;
        }

        .btn-eliminar {
            background: linear-gradient(45deg, #dc3545, #ff6b81);
            color: white;
            padding: 8px 18px;
        }

        .acciones-form {
            margin: 0;
        }

        .mensaje {
            margin-bottom: 20px;
        }

        .foto-mini {
            width: 80px;
            height: 60px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.15);
            margin: 2px;
        }
    </style>
</head>
<body>

<div class="contenedor">
    <h2>Personas Registradas</h2>

<%
    String mensaje = null;
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Statement st = null;

    try {
        Class.forName("org.postgresql.Driver");
        con = DriverManager.getConnection(
            "jdbc:postgresql://127.0.0.1:5432/biometrico",
            "postgres",
            "1234"
        );

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String idEliminar = request.getParameter("idEliminar");

            if (idEliminar != null && !idEliminar.trim().equals("")) {
                ps = con.prepareStatement("DELETE FROM personas WHERE id = ?");
                ps.setInt(1, Integer.parseInt(idEliminar));
                ps.executeUpdate();
                ps.close();
                mensaje = "Registro eliminado correctamente.";
            }
        }

        if (mensaje != null) {
%>
            <div class="alert alert-success mensaje"><%= mensaje %></div>
<%
        }
%>

    <table>
        <tr>
            <th>ID</th>
            <th>Nombre</th>
            <th>CI</th>
            <th>Fecha de registro</th>
            <th>Fotos</th>
            <th>Acción</th>
        </tr>

<%
        st = con.createStatement();
        rs = st.executeQuery("SELECT * FROM personas ORDER BY id DESC");

        while(rs.next()){
            Timestamp fecha = rs.getTimestamp("fecha_registro");
            SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("nombre") %></td>
            <td><%= rs.getString("ci") %></td>
            <td><%= fecha != null ? formato.format(fecha) : "" %></td>
            <td>
                <% for (int i = 1; i <= 5; i++) {
                    String foto = rs.getString("foto" + i);
                    if (foto != null && !foto.trim().equals("")) { %>
                        <img src="<%= foto %>" class="foto-mini">
                <% } } %>
            </td>
            <td>
                <form method="post" class="acciones-form" onsubmit="return confirm('¿Seguro que querés eliminar este registro?');">
                    <input type="hidden" name="idEliminar" value="<%= rs.getInt("id") %>">
                    <button type="submit" class="btn btn-eliminar btn-custom">Eliminar</button>
                </form>
            </td>
        </tr>
<%
        }

    } catch(Exception e){
%>
    <div class="alert alert-danger mensaje">
        Error: <%= e.getMessage() %>
    </div>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (st != null) st.close(); } catch(Exception e) {}
        try { if (ps != null) ps.close(); } catch(Exception e) {}
        try { if (con != null) con.close(); } catch(Exception e) {}
    }
%>
    </table>

    <a href="index.jsp" class="btn btn-volver btn-custom">Volver al inicio</a>
</div>

</body>
</html>