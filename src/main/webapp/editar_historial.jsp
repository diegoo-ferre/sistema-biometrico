<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
String id = request.getParameter("id");
String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    try (Connection con = DriverManager.getConnection(url, "neondb_owner", "npg_6rt8OdayAHcm");
         PreparedStatement ps = con.prepareStatement("UPDATE salarios SET sueldo_final = ? WHERE id = ?")) {
        ps.setDouble(1, Double.parseDouble(request.getParameter("nuevoSueldo")));
        ps.setInt(2, Integer.parseInt(id));
        ps.executeUpdate();
        response.sendRedirect("editar_salario_guardado.jsp");
        return;
    }
}
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Salario</title>
    <style>
        body { background: linear-gradient(135deg, #02080f, #0b1f2a, #12384a); color: white; display:flex; justify-content:center; align-items:center; min-height:100vh; font-family: Arial, sans-serif; }
        .contenedor { background: rgba(10, 15, 25, 0.9); padding: 40px; border-radius: 30px; width: 100%; max-width: 400px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
        input { width: 100%; padding: 12px; margin: 10px 0; border-radius: 15px; border: none; background: rgba(255,255,255,0.05); color: white; text-align: center; }
.btn { 
    display: block; 
    width: 100%;            
    padding: 12px;           
    margin: 10px 0; 
    border: none; 
    border-radius: 30px; 
    color: white !important; 
    font-weight: bold; 
    text-decoration: none; 
    cursor: pointer; 
    transition: 0.3s; 
    text-align: center;     
    box-sizing: border-box;  
}        .btn-guardar { background: linear-gradient(30deg, #4225a3, #000738); }
        .btn-cancelar { background: linear-gradient(35deg, #f74040, #f50404); }
        .input-estilo {
    display: block;
    width: 100%;
    padding: 12px;
    margin: 10px 0;
    border: none;
    border-radius: 30px; 
    background: rgba(255,255,255,0.05);
    color: white;
    text-align: center;
    box-sizing: border-box; 
    font-size: 16px;
}
    </style>
</head>
<body>
    <div class="contenedor">
        <h2>Editar Monto</h2>
        <form method="post">
            <input type="number" step="0.01" name="nuevoSueldo" class="input-estilo" required placeholder="Nuevo Sueldo">            
            <button type="submit" class="btn btn-guardar">Guardar Cambios</button>
            <a href="editar_salario_guardado.jsp" class="btn btn-cancelar">Cancelar</a>
        </form>
    </div>
</body>
</html>