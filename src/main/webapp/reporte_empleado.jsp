<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.time.*" %>
<%@ page import="com.itextpdf.text.*" %>
<%@ page import="com.itextpdf.text.pdf.*" %>

<%
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

response.setContentType("application/pdf");
response.setHeader("Content-Disposition", "attachment; filename=liquidacion_empleado.pdf");

Document documento = new Document(PageSize.A4, 30, 30, 30, 30);
PdfWriter.getInstance(documento, response.getOutputStream());
documento.open();

Font tituloFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
Font textoFont = new Font(Font.FontFamily.HELVETICA, 12, Font.NORMAL);

String personaIdStr = request.getParameter("persona_id");
int mesSeleccionado = Integer.parseInt(request.getParameter("mes"));
int anioSeleccionado = Integer.parseInt(request.getParameter("anio"));

if (personaIdStr == null || personaIdStr.trim().equals("")) {
    documento.add(new Paragraph("persona no válida", textoFont));
    documento.close();
    return;
}

int personaId = Integer.parseInt(personaIdStr);
DecimalFormat guarani = new DecimalFormat("###,###,###");

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("org.postgresql.Driver");

 String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);

    ps = con.prepareStatement("select nombre, ci from personas where id = ?");
    ps.setInt(1, personaId);
    rs = ps.executeQuery();

    String nombre = "";
    String ci = "";

    if (rs.next()) {
        nombre = rs.getString("nombre");
        ci = rs.getString("ci");
    }
    rs.close();
    ps.close();

    documento.add(new Paragraph("EMPRESA / INSTITUCIÓN", tituloFont));
    documento.add(new Paragraph("Liquidación individual\n\n", tituloFont));
    documento.add(new Paragraph("Nombre: " + nombre, textoFont));
    documento.add(new Paragraph("CI: " + ci, textoFont));
    documento.add(new Paragraph("Periodo: " + mesSeleccionado + "/" + anioSeleccionado + "\n", textoFont));

    double sueldoBase = 0;
    ps = con.prepareStatement("select sueldo_base from salarios_base where persona_id = ? order by id desc limit 1");
    ps.setInt(1, personaId);
    rs = ps.executeQuery();
    if (rs.next()) {
        sueldoBase = rs.getDouble("sueldo_base");
    }
    rs.close();
    ps.close();

    documento.add(new Paragraph("Sueldo base: Gs. " + guarani.format(sueldoBase).replace(',', '.'), textoFont));

    ps = con.prepareStatement(
        "select m.motivo, dp.monto_aplicado " +
        "from descuentos_persona dp join motivos_descuento m on dp.motivo_id = m.id " +
        "where dp.persona_id = ? and dp.mes = ? and dp.anio = ? order by dp.id desc"
    );
    ps.setInt(1, personaId);
    ps.setInt(2, mesSeleccionado);
    ps.setInt(3, anioSeleccionado);
    rs = ps.executeQuery();

    double total = 0;
    documento.add(new Paragraph("\nDescuentos aplicados:", textoFont));

    while (rs.next()) {
        double monto = rs.getDouble("monto_aplicado");
        total += monto;
        documento.add(new Paragraph("- " + rs.getString("motivo") + ": Gs. " + guarani.format(monto).replace(',', '.'), textoFont));
    }
    rs.close();
    ps.close();

    double salarioFinal = sueldoBase - total;
    if (salarioFinal < 0) salarioFinal = 0;

    documento.add(new Paragraph("\nTotal descuentos: Gs. " + guarani.format(total).replace(',', '.'), textoFont));
    documento.add(new Paragraph("Salario final: Gs. " + guarani.format(salarioFinal).replace(',', '.'), textoFont));

} catch (Exception e) {
    documento.add(new Paragraph("Error: " + e.getMessage(), textoFont));
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}

documento.close();
%>