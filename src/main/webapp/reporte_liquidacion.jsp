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
response.setHeader("Content-Disposition", "attachment; filename=liquidacion_mensual_detallada.pdf");

Document documento = new Document(PageSize.A4);
PdfWriter.getInstance(documento, response.getOutputStream());
documento.open();

Font tituloFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
Font subtituloFont = new Font(Font.FontFamily.HELVETICA, 12, Font.NORMAL);
Font seccionFont = new Font(Font.FontFamily.HELVETICA, 13, Font.BOLD);
Font textoFont = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL);

int mesSeleccionado = LocalDate.now().getMonthValue();
int anioSeleccionado = LocalDate.now().getYear();

try {
    if (request.getParameter("mes") != null && !request.getParameter("mes").trim().equals("")) {
        mesSeleccionado = Integer.parseInt(request.getParameter("mes"));
    }
    if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals("")) {
        anioSeleccionado = Integer.parseInt(request.getParameter("anio"));
    }
} catch (Exception e) {
}

String nombreMes = "";
switch (mesSeleccionado) {
    case 1: nombreMes = "Enero"; break;
    case 2: nombreMes = "Febrero"; break;
    case 3: nombreMes = "Marzo"; break;
    case 4: nombreMes = "Abril"; break;
    case 5: nombreMes = "Mayo"; break;
    case 6: nombreMes = "Junio"; break;
    case 7: nombreMes = "Julio"; break;
    case 8: nombreMes = "Agosto"; break;
    case 9: nombreMes = "Septiembre"; break;
    case 10: nombreMes = "Octubre"; break;
    case 11: nombreMes = "Noviembre"; break;
    case 12: nombreMes = "Diciembre"; break;
}

Paragraph empresa = new Paragraph("EMPRESA / INSTITUCIÓN", tituloFont);
empresa.setAlignment(Element.ALIGN_CENTER);
documento.add(empresa);

Paragraph sistema = new Paragraph("Sistema Web Biométrico de Control de Asistencia y Gestión Salarial", subtituloFont);
sistema.setAlignment(Element.ALIGN_CENTER);
documento.add(sistema);

Paragraph periodo = new Paragraph("Liquidación mensual detallada - " + nombreMes + " " + anioSeleccionado + "\n\n", subtituloFont);
periodo.setAlignment(Element.ALIGN_CENTER);
documento.add(periodo);

Connection con = null;
PreparedStatement psPersonas = null;
PreparedStatement psSueldo = null;
PreparedStatement psDescuentos = null;
PreparedStatement psDetalle = null;
PreparedStatement psAsistencias = null;
PreparedStatement psMotivoAusencia = null;
PreparedStatement psMotivoTardanza = null;
ResultSet rsPersonas = null;
ResultSet rsSueldo = null;
ResultSet rsDescuentos = null;
ResultSet rsDetalle = null;
ResultSet rsAsistencias = null;
ResultSet rsMotivoAusencia = null;
ResultSet rsMotivoTardanza = null;

DecimalFormat guarani = new DecimalFormat("###,###,###");

try {
    Class.forName("org.postgresql.Driver");

   String url = "jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require";
                String user = "neondb_owner";
                String pass = "npg_6rt8OdayAHcm";

                con = DriverManager.getConnection(url, user, pass);
    double valorAusencia = 0;
    String tipoAusencia = "";
    double valorTardanza = 0;
    String tipoTardanza = "";

    psMotivoAusencia = con.prepareStatement(
        "select tipo, valor from motivos_descuento where lower(motivo) = 'ausencia' and activo = true order by id desc limit 1"
    );
    rsMotivoAusencia = psMotivoAusencia.executeQuery();
    if (rsMotivoAusencia.next()) {
        tipoAusencia = rsMotivoAusencia.getString("tipo");
        valorAusencia = rsMotivoAusencia.getDouble("valor");
    }
    rsMotivoAusencia.close();
    psMotivoAusencia.close();

    psMotivoTardanza = con.prepareStatement(
        "select tipo, valor from motivos_descuento where lower(motivo) = 'tardanza' and activo = true order by id desc limit 1"
    );
    rsMotivoTardanza = psMotivoTardanza.executeQuery();
    if (rsMotivoTardanza.next()) {
        tipoTardanza = rsMotivoTardanza.getString("tipo");
        valorTardanza = rsMotivoTardanza.getDouble("valor");
    }
    rsMotivoTardanza.close();
    psMotivoTardanza.close();

    psPersonas = con.prepareStatement("select id, nombre, ci from personas order by nombre asc");
    rsPersonas = psPersonas.executeQuery();

    while (rsPersonas.next()) {
        int personaId = rsPersonas.getInt("id");
        String nombre = rsPersonas.getString("nombre");
        String ci = rsPersonas.getString("ci");

        double sueldoBase = 0;
        double totalDescuentosManual = 0;
        double descuentoAusenciaAuto = 0;
        double descuentoTardanzaAuto = 0;
        double totalDescuentos = 0;
        double salarioFinal = 0;
        int diasCompletos = 0;
        int tardanzas = 0;
        int diasLaborales = 0;
        int ausencias = 0;

        StringBuilder detalle = new StringBuilder();

        psSueldo = con.prepareStatement(
            "select sueldo_base from salarios_base where persona_id = ? order by id desc limit 1"
        );
        psSueldo.setInt(1, personaId);
        rsSueldo = psSueldo.executeQuery();

        if (rsSueldo.next()) {
            sueldoBase = rsSueldo.getDouble("sueldo_base");
        }
        rsSueldo.close();
        psSueldo.close();

        if (sueldoBase <= 0) {
            continue;
        }

        psDescuentos = con.prepareStatement(
            "select coalesce(sum(monto_aplicado),0) as total from descuentos_persona where persona_id = ? and mes = ? and anio = ?"
        );
        psDescuentos.setInt(1, personaId);
        psDescuentos.setInt(2, mesSeleccionado);
        psDescuentos.setInt(3, anioSeleccionado);
        rsDescuentos = psDescuentos.executeQuery();

        if (rsDescuentos.next()) {
            totalDescuentosManual = rsDescuentos.getDouble("total");
        }
        rsDescuentos.close();
        psDescuentos.close();

        psDetalle = con.prepareStatement(
            "select m.motivo, dp.monto_aplicado " +
            "from descuentos_persona dp " +
            "join motivos_descuento m on dp.motivo_id = m.id " +
            "where dp.persona_id = ? and dp.mes = ? and dp.anio = ? " +
            "order by dp.id desc"
        );
        psDetalle.setInt(1, personaId);
        psDetalle.setInt(2, mesSeleccionado);
        psDetalle.setInt(3, anioSeleccionado);
        rsDetalle = psDetalle.executeQuery();

        while (rsDetalle.next()) {
            detalle.append("- ")
                   .append(rsDetalle.getString("motivo"))
                   .append(": Gs. ")
                   .append(guarani.format(rsDetalle.getDouble("monto_aplicado")).replace(',', '.'))
                   .append("\n");
        }
        rsDetalle.close();
        psDetalle.close();

        LocalDate inicioMes = LocalDate.of(anioSeleccionado, mesSeleccionado, 1);
        LocalDate finMes = inicioMes.withDayOfMonth(inicioMes.lengthOfMonth());

        LocalDate fecha = inicioMes;
        while (!fecha.isAfter(finMes)) {
            DayOfWeek dia = fecha.getDayOfWeek();
            if (dia != DayOfWeek.SATURDAY && dia != DayOfWeek.SUNDAY) {
                diasLaborales++;
            }
            fecha = fecha.plusDays(1);
        }

        psAsistencias = con.prepareStatement(
            "select " +
            "count(case when hora_entrada is not null and hora_salida is not null then 1 end) as dias_completos, " +
            "count(case when minutos_tardanza > 0 then 1 end) as tardanzas " +
            "from asistencias " +
            "where persona_id = ? and extract(month from fecha) = ? and extract(year from fecha) = ?"
        );
        psAsistencias.setInt(1, personaId);
        psAsistencias.setInt(2, mesSeleccionado);
        psAsistencias.setInt(3, anioSeleccionado);
        rsAsistencias = psAsistencias.executeQuery();

        if (rsAsistencias.next()) {
            diasCompletos = rsAsistencias.getInt("dias_completos");
            tardanzas = rsAsistencias.getInt("tardanzas");
        }
        rsAsistencias.close();
        psAsistencias.close();

        ausencias = diasLaborales - diasCompletos;
        if (ausencias < 0) ausencias = 0;

        if ("porcentaje".equals(tipoAusencia)) {
            descuentoAusenciaAuto = (sueldoBase * valorAusencia / 100.0) * ausencias;
        } else if ("fijo".equals(tipoAusencia)) {
            descuentoAusenciaAuto = valorAusencia * ausencias;
        }

        if ("porcentaje".equals(tipoTardanza)) {
            descuentoTardanzaAuto = (sueldoBase * valorTardanza / 100.0) * tardanzas;
        } else if ("fijo".equals(tipoTardanza)) {
            descuentoTardanzaAuto = valorTardanza * tardanzas;
        }

        if (ausencias > 0) {
            detalle.append("- Ausencias automáticas (")
                   .append(ausencias)
                   .append("): Gs. ")
                   .append(guarani.format(descuentoAusenciaAuto).replace(',', '.'))
                   .append("\n");
        }

        if (tardanzas > 0) {
            detalle.append("- Tardanzas automáticas (")
                   .append(tardanzas)
                   .append("): Gs. ")
                   .append(guarani.format(descuentoTardanzaAuto).replace(',', '.'))
                   .append("\n");
        }

        totalDescuentos = totalDescuentosManual + descuentoAusenciaAuto + descuentoTardanzaAuto;
        salarioFinal = sueldoBase - totalDescuentos;
        if (salarioFinal < 0) salarioFinal = 0;

        Paragraph bloque = new Paragraph();
        bloque.add(new Paragraph("Empleado: " + nombre + " | CI: " + ci, seccionFont));
        bloque.add(new Paragraph("Sueldo base: Gs. " + guarani.format(sueldoBase).replace(',', '.'), textoFont));
        bloque.add(new Paragraph("Ausencias: " + ausencias + " | Tardanzas: " + tardanzas, textoFont));
        bloque.add(new Paragraph("Total descuentos: Gs. " + guarani.format(totalDescuentos).replace(',', '.'), textoFont));
        bloque.add(new Paragraph("Salario final: Gs. " + guarani.format(salarioFinal).replace(',', '.'), textoFont));
        bloque.add(new Paragraph("Detalle de descuentos:\n" + (detalle.length() > 0 ? detalle.toString() : "Sin descuentos aplicados"), textoFont));
        bloque.add(new Paragraph("------------------------------------------------------------\n", textoFont));

        documento.add(bloque);
    }

} catch (Exception e) {
    documento.add(new Paragraph("Error: " + e.getMessage(), textoFont));
} finally {
    try { if (rsMotivoAusencia != null) rsMotivoAusencia.close(); } catch (Exception e) {}
    try { if (psMotivoAusencia != null) psMotivoAusencia.close(); } catch (Exception e) {}
    try { if (rsMotivoTardanza != null) rsMotivoTardanza.close(); } catch (Exception e) {}
    try { if (psMotivoTardanza != null) psMotivoTardanza.close(); } catch (Exception e) {}
    try { if (rsAsistencias != null) rsAsistencias.close(); } catch (Exception e) {}
    try { if (psAsistencias != null) psAsistencias.close(); } catch (Exception e) {}
    try { if (rsDetalle != null) rsDetalle.close(); } catch (Exception e) {}
    try { if (psDetalle != null) psDetalle.close(); } catch (Exception e) {}
    try { if (rsDescuentos != null) rsDescuentos.close(); } catch (Exception e) {}
    try { if (psDescuentos != null) psDescuentos.close(); } catch (Exception e) {}
    try { if (rsSueldo != null) rsSueldo.close(); } catch (Exception e) {}
    try { if (psSueldo != null) psSueldo.close(); } catch (Exception e) {}
    try { if (rsPersonas != null) rsPersonas.close(); } catch (Exception e) {}
    try { if (psPersonas != null) psPersonas.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}

documento.close();
%>