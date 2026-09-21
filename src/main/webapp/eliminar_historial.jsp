<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 1. Obtener el ID enviado por el formulario
    String idEliminar = request.getParameter("idEliminar");

    if (idEliminar != null && !idEliminar.isEmpty()) {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            // 2. Conectar a la base de datos
           // Reemplaza el bloque de conexión en eliminar_historial.jsp por este:
Class.forName("org.postgresql.Driver");
con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");

            // 3. Preparar y ejecutar la eliminación
            String sql = "DELETE FROM salarios WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(idEliminar));
            ps.executeUpdate();

            // 4. Redirigir de vuelta al historial con éxito
            response.sendRedirect("editar_salario_guardado.jsp?mensaje=Eliminado correctamente");

        } catch (Exception e) {
            out.println("Error al eliminar: " + e.getMessage());
        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    } else {
        // Si no vino un ID válido, volver atrás
        response.sendRedirect("historial_salarios.jsp");
    }
%>