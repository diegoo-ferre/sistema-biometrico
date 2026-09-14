<%@ page language="java" contentType="application/pdf; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.itextpdf.text.*" %>
<%@ page import="com.itextpdf.text.pdf.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.io.IOException" %>

<%!
    // Método auxiliar en Java para convertir números a letras en Guaraníes de forma automática
    private String convertirANumerosLetras(double monto) {
        long entero = (long) monto;
        if (entero == 0) return "CERO GUARANIES";
        
        String enLetras = convertir(entero);
        return enLetras.trim() + " GUARANIES";
    }

    private String convertir(long n) {
        if (n == 0) return "";
        if (n < 0) return "MENOS " + convertir(-n);
        if (n < 20) {
            String[] unidades = {"", "UN", "DOS", "TRES", "CUATRO", "CINCO", "SEIS", "SIETE", "OCHO", "NUEVE", "DIEZ", "ONCE", "DOCE", "TRECE", "CATORCE", "QUINCE", "DIECISEIS", "DIECISIETE", "DIECIOCHO", "DIECINUEVE"};
            return unidades[(int)n] + " ";
        }
        if (n < 100) {
            String[] decenas = {"", "", "VEINTE", "TREINTA", "CUARENTA", "CINCUENTA", "SESENTA", "SETENTA", "OCHENTA", "NOVENTA"};
            long d = n / 10;
            long r = n % 10;
            if (d == 2 && r > 0) {
                String[] veintes = {"", "VEINTIUN", "VEINTIDOS", "VEINTITRES", "VEINTICUATRO", "VEINTICINCO", "VEINTISEIS", "VEINTISIETE", "VEINTIOCHO", "VEINTINUEVE"};
                return veintes[(int)r] + " ";
            }
            return decenas[(int)d] + (r > 0 ? " Y " + convertir(r) : " ");
        }
        if (n < 1000) {
            long c = n / 100;
            long r = n % 100;
            if (c == 1 && r == 0) return "CIEN ";
            String[] centenas = {"", "CIENTO", "DOSCIENTOS", "TRESCIENTOS", "CUATROCIENTOS", "QUINIENTOS", "SEISCIENTOS", "SETECIENTOS", "OCHOCIENTOS", "NOVECIENTOS"};
            return centenas[(int)c] + " " + convertir(r);
        }
        if (n < 1000000) {
            long miles = n / 1000;
            long r = n % 1000;
            String s = (miles == 1) ? "MIL " : convertir(miles) + "MIL ";
            return s + convertir(r);
        }
        if (n < 1000000000) {
            long millones = n / 1000000;
            long r = n % 1000000;
            String s = (millones == 1) ? "UN MILLON " : convertir(millones) + "MILLONES ";
            return s + convertir(r);
        }
        long milesMillones = n / 1000000000;
        long r = n % 1000000000;
        return convertir(milesMillones) + "MIL " + convertir(r);
    }
%>

<%
// Limpiamos el buffer de respuesta para evitar conflictos con el flujo binario del PDF
try {
    out.clear();
    out = pageContext.pushBody();
} catch (Exception ignored) {}

// Verificamos si hay sesión activa
if (session.getAttribute("usuario") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Obtenemos los parámetros enviados por la URL (compatibles con id o persona_id)
String personaIdStr = request.getParameter("persona_id");
if (personaIdStr == null) {
    personaIdStr = request.getParameter("id");
}

String mesStr = request.getParameter("mes");
String anioStr = request.getParameter("anio");

if (personaIdStr == null) {
    response.setContentType("text/html; charset=UTF-8");
    out.println("<h3>Error: Falta el parámetro de la persona.</h3>");
    return;
}

int personaId = Integer.parseInt(personaIdStr);
int mesSeleccionado = 0;
int anioSeleccionado = 0;

Connection con = null;
DecimalFormat guarani = new DecimalFormat("###,###,###");

String nombreEmpleado = "";
String ciEmpleado = "";
double sueldoBase = 0;
double totalDescuentos = 0;
double totalBonos = 0;
double sueldoFinal = 0;
String fechaCierre = "No definida";
String sueldoFinalEnLetras = "";

try {
    Class.forName("org.postgresql.Driver");
    con = DriverManager.getConnection("jdbc:postgresql://ep-ancient-haze-aca057wp-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require", "neondb_owner", "npg_6rt8OdayAHcm");
    
    // Si no se pasaron mes y año por parámetros, obtenemos el periodo activo actual de la BD
    if (mesStr == null || anioStr == null) {
        PreparedStatement psPerActivo = con.prepareStatement("SELECT mes, anio, fecha_cierre FROM periodo_activo LIMIT 1");
        ResultSet rsPerActivo = psPerActivo.executeQuery();
        if (rsPerActivo.next()) {
            mesSeleccionado = rsPerActivo.getInt("mes");
            anioSeleccionado = rsPerActivo.getInt("anio");
            if(rsPerActivo.getDate("fecha_cierre") != null) fechaCierre = rsPerActivo.getDate("fecha_cierre").toString();
        }
    } else {
        mesSeleccionado = Integer.parseInt(mesStr);
        anioSeleccionado = Integer.parseInt(anioStr);
        
        // Obtener fecha de cierre del periodo específico solicitado
        PreparedStatement psPeriodo = con.prepareStatement("SELECT fecha_cierre FROM periodo_activo WHERE mes = ? AND anio = ? LIMIT 1");
        psPeriodo.setInt(1, mesSeleccionado);
        psPeriodo.setInt(2, anioSeleccionado);
        ResultSet rsPeriodo = psPeriodo.executeQuery();
        if (rsPeriodo.next() && rsPeriodo.getDate("fecha_cierre") != null) {
            fechaCierre = rsPeriodo.getDate("fecha_cierre").toString();
        }
    }

    // Obtener datos de la persona
    PreparedStatement psPersona = con.prepareStatement("SELECT nombre, ci FROM personas WHERE id = ?");
    psPersona.setInt(1, personaId);
    ResultSet rsPersona = psPersona.executeQuery();
    if (rsPersona.next()) {
        nombreEmpleado = rsPersona.getString("nombre");
        ciEmpleado = rsPersona.getString("ci");
        if(ciEmpleado == null) ciEmpleado = "No registrado";
    }

    // Obtener sueldo base
    PreparedStatement psSueldo = con.prepareStatement("SELECT sueldo_base FROM salarios_base WHERE persona_id = ? ORDER BY id DESC LIMIT 1");
    psSueldo.setInt(1, personaId);
    ResultSet rsSueldo = psSueldo.executeQuery();
    if (rsSueldo.next()) {
        sueldoBase = rsSueldo.getDouble("sueldo_base");
    }

    // Obtener total de descuentos
    PreparedStatement psDesc = con.prepareStatement("SELECT SUM(monto_aplicado) AS total FROM descuentos_persona WHERE persona_id = ? AND mes = ? AND anio = ?");
    psDesc.setInt(1, personaId);
    psDesc.setInt(2, mesSeleccionado);
    psDesc.setInt(3, anioSeleccionado);
    ResultSet rsD = psDesc.executeQuery();
    if (rsD.next()) {
        totalDescuentos = rsD.getDouble("total");
    }

    // Obtener total de bonos
    PreparedStatement psBon = con.prepareStatement("SELECT SUM(monto_aplicado) AS total FROM bonos_persona WHERE persona_id = ? AND mes = ? AND anio = ?");
    psBon.setInt(1, personaId);
    psBon.setInt(2, mesSeleccionado);
    psBon.setInt(3, anioSeleccionado);
    ResultSet rsB = psBon.executeQuery();
    if (rsB.next()) {
        totalBonos = rsB.getDouble("total");
    }

    sueldoFinal = sueldoBase + totalBonos - totalDescuentos;

    // Convertir el monto total automáticamente a letras
    sueldoFinalEnLetras = convertirANumerosLetras(sueldoFinal);

    // Configuramos la respuesta HTTP como PDF
    response.setContentType("application/pdf");
    response.setHeader("Content-Disposition", "inline; filename=Liquidacion_" + nombreEmpleado.replaceAll(" ", "_") + ".pdf");

    Document documento = new Document(PageSize.A4, 30, 30, 30, 30);
    PdfWriter.getInstance(documento, response.getOutputStream());
    documento.open();

    // Fuentes estilo recibo
    Font fSub = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.DARK_GRAY);
    Font fBold = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD, BaseColor.BLACK);
    Font fNormal = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, BaseColor.BLACK);
    Font fSmall = new Font(Font.FontFamily.HELVETICA, 8, Font.NORMAL, BaseColor.DARK_GRAY);
    Font fLogoName = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.BLACK);

   // --- ENCABEZADO TIPO BOLETA CON LOGO Y NOMBRE ---
    PdfPTable headerTable = new PdfPTable(2);
    headerTable.setWidthPercentage(100);
    headerTable.setWidths(new float[]{60f, 40f});

    PdfPCell cLogo = new PdfPCell();
    cLogo.setBorder(Rectangle.NO_BORDER);
    cLogo.setHorizontalAlignment(Element.ALIGN_LEFT); 
    cLogo.setPaddingLeft(0); 
    
    try {
        String rutaReal = request.getServletContext().getRealPath("/img/logo2.png");
        Image logo = Image.getInstance(rutaReal);
        logo.scaleToFit(100, 100); 
        cLogo.addElement(logo);
    } catch (Exception e) {
        // Fallback en caso de error de ruta
    }
    
    // Texto debajo del logo
    Paragraph pNombreLogo = new Paragraph("  DIF-SENTINEL", fLogoName);
    pNombreLogo.setSpacingBefore(2);
    cLogo.addElement(pNombreLogo);
    
    headerTable.addCell(cLogo);

    PdfPCell cTipo = new PdfPCell(new Phrase("LIQUIDACIÓN DE SALARIOS", fSub));
    cTipo.setHorizontalAlignment(Element.ALIGN_RIGHT);
    cTipo.setVerticalAlignment(Element.ALIGN_MIDDLE);
    cTipo.setBorder(Rectangle.NO_BORDER);
    headerTable.addCell(cTipo);
    
    documento.add(headerTable);

    // --- DATOS DEL FUNCIONARIO ---
    PdfPTable infoTable = new PdfPTable(4);
    infoTable.setWidthPercentage(100);
    infoTable.setWidths(new float[]{20f, 50f, 15f, 15f});
    infoTable.setSpacingBefore(10);

    PdfPCell hLeg = new PdfPCell(new Phrase("LEGAJO / C.I.", fBold));
    hLeg.setPadding(5);
    infoTable.addCell(hLeg);

    PdfPCell hNom = new PdfPCell(new Phrase("APELLIDO Y NOMBRE", fBold));
    hNom.setPadding(5);
    infoTable.addCell(hNom);

    PdfPCell hCat = new PdfPCell(new Phrase("CATEGORÍA", fBold));
    hCat.setPadding(5);
    infoTable.addCell(hCat);

    PdfPCell hPer = new PdfPCell(new Phrase("PERIODO DE PAGO", fBold));
    hPer.setPadding(5);
    infoTable.addCell(hPer);

    PdfPCell dLeg = new PdfPCell(new Phrase(ciEmpleado, fNormal));
    dLeg.setPadding(5);
    infoTable.addCell(dLeg);

    PdfPCell dNom = new PdfPCell(new Phrase(nombreEmpleado.toUpperCase(), fNormal));
    dNom.setPadding(5);
    infoTable.addCell(dNom);

    PdfPCell dCat = new PdfPCell(new Phrase("Funcionario", fNormal));
    dCat.setPadding(5);
    infoTable.addCell(dCat);

    PdfPCell dPer = new PdfPCell(new Phrase(mesSeleccionado + " / " + anioSeleccionado, fNormal));
    dPer.setPadding(5);
    infoTable.addCell(dPer);

    documento.add(infoTable);

    // --- TABLA DETALLE DE CONCEPTOS ---
    PdfPTable detailTable = new PdfPTable(4);
    detailTable.setWidthPercentage(100);
    detailTable.setWidths(new float[]{15f, 55f, 15f, 15f});
    detailTable.setSpacingBefore(10);

    PdfPCell dc1 = new PdfPCell(new Phrase("CANT.", fBold));
    dc1.setHorizontalAlignment(Element.ALIGN_CENTER);
    dc1.setPadding(6);
    detailTable.addCell(dc1);

    PdfPCell dc2 = new PdfPCell(new Phrase("CONCEPTO", fBold));
    dc2.setPadding(6);
    detailTable.addCell(dc2);

    PdfPCell dc3 = new PdfPCell(new Phrase("HABERES", fBold));
    dc3.setHorizontalAlignment(Element.ALIGN_RIGHT);
    dc3.setPadding(6);
    detailTable.addCell(dc3);

    PdfPCell dc4 = new PdfPCell(new Phrase("DESCUENTOS", fBold));
    dc4.setHorizontalAlignment(Element.ALIGN_RIGHT);
    dc4.setPadding(6);
    detailTable.addCell(dc4);

    // 1. Fila de Sueldo Base (Haber fijo)
    detailTable.addCell(new PdfPCell(new Phrase("1,00", fNormal)));
    detailTable.addCell(new PdfPCell(new Phrase("SUELDO BASE", fNormal)));
    
    PdfPCell sbVal = new PdfPCell(new Phrase(guarani.format(sueldoBase), fNormal));
    sbVal.setHorizontalAlignment(Element.ALIGN_RIGHT);
    detailTable.addCell(sbVal);
    
    detailTable.addCell(new PdfPCell(new Phrase("", fNormal)));

    // 2. Consultar y agregar Bonos y Descuentos dinámicos
    Statement stDet = con.createStatement();
    ResultSet rsDet = stDet.executeQuery(
        "SELECT m.motivo AS nombre, dp.monto_aplicado, 'DESC' AS tipo FROM descuentos_persona dp JOIN motivos_descuento m ON dp.motivo_id = m.id WHERE dp.persona_id = " + personaId + " AND dp.mes = " + mesSeleccionado + " AND dp.anio = " + anioSeleccionado + 
        " UNION ALL " +
        "SELECT t.nombre, bp.monto_aplicado, 'BONO' AS tipo FROM bonos_persona bp JOIN tipos_bonificacion t ON bp.bono_id = t.id WHERE bp.persona_id = " + personaId + " AND bp.mes = " + mesSeleccionado + " AND bp.anio = " + anioSeleccionado
    );

    while (rsDet.next()) {
        String concepto = rsDet.getString("nombre");
        String tipoMov = rsDet.getString("tipo");
        double monto = rsDet.getDouble("monto_aplicado");

        detailTable.addCell(new PdfPCell(new Phrase("1,00", fNormal)));
        detailTable.addCell(new PdfPCell(new Phrase(concepto.toUpperCase(), fNormal)));

        PdfPCell cHab = new PdfPCell(new Phrase(tipoMov.equals("BONO") ? guarani.format(monto) : "", fNormal));
        cHab.setHorizontalAlignment(Element.ALIGN_RIGHT);
        detailTable.addCell(cHab);

        PdfPCell cDes = new PdfPCell(new Phrase(tipoMov.equals("DESC") ? guarani.format(monto) : "", fNormal));
        cDes.setHorizontalAlignment(Element.ALIGN_RIGHT);
        detailTable.addCell(cDes);
    }

    // Rellenar filas vacías para dar apariencia de recibo impreso preformateado
    for (int i = 0; i < 4; i++) {
        detailTable.addCell(new PdfPCell(new Phrase(" ", fNormal)));
        detailTable.addCell(new PdfPCell(new Phrase(" ", fNormal)));
        detailTable.addCell(new PdfPCell(new Phrase(" ", fNormal)));
        detailTable.addCell(new PdfPCell(new Phrase(" ", fNormal)));
    }

    // --- FILA DE TOTALES ---
    PdfPCell tLabel = new PdfPCell(new Phrase("TOTALES", fBold));
    tLabel.setColspan(2);
    tLabel.setHorizontalAlignment(Element.ALIGN_RIGHT);
    tLabel.setPadding(6);
    detailTable.addCell(tLabel);

    double totalHaberesGeneral = sueldoBase + totalBonos;
    PdfPCell tHab = new PdfPCell(new Phrase(guarani.format(totalHaberesGeneral), fBold));
    tHab.setHorizontalAlignment(Element.ALIGN_RIGHT);
    tHab.setPadding(6);
    detailTable.addCell(tHab);

    PdfPCell tDes = new PdfPCell(new Phrase(guarani.format(totalDescuentos), fBold));
    tDes.setHorizontalAlignment(Element.ALIGN_RIGHT);
    tDes.setPadding(6);
    detailTable.addCell(tDes);

    // --- NUEVA FILA: TOTAL A COBRAR EN LETRAS ---
    PdfPCell tLetras = new PdfPCell(new Phrase("Total a cobrar (en letras): " + sueldoFinalEnLetras, fSmall));
    tLetras.setColspan(4);
    tLetras.setPadding(6);
    detailTable.addCell(tLetras);

    documento.add(detailTable);

    // --- NETO A COBRAR Y FIRMAS ---
    PdfPTable footerTable = new PdfPTable(2);
    footerTable.setWidthPercentage(100);
    footerTable.setWidths(new float[]{60f, 40f});
    footerTable.setSpacingBefore(0);

    // Celda Izquierda: Firma y Periodo
    PdfPCell cFirma = new PdfPCell();
    cFirma.setBorder(Rectangle.LEFT | Rectangle.BOTTOM | Rectangle.RIGHT);
    cFirma.setPadding(10);
    cFirma.addElement(new Paragraph("\n\n---------------------------------------------------------", fNormal));
    cFirma.addElement(new Paragraph("FIRMA", fBold));
    cFirma.addElement(new Paragraph("Doc. Identidad: " + ciEmpleado, fSmall));
    cFirma.addElement(new Paragraph("Correspondiente al mes: " + mesSeleccionado + " / " + anioSeleccionado, fSmall));
    footerTable.addCell(cFirma);

    // Celda Derecha: Neto a Cobrar
    PdfPCell cNeto = new PdfPCell();
    cNeto.setBorder(Rectangle.BOTTOM | Rectangle.RIGHT);
    cNeto.setPadding(5);
    cNeto.setHorizontalAlignment(Element.ALIGN_CENTER);
    cNeto.addElement(new Paragraph("NETO A COBRAR Gs.", fBold));
    Paragraph pSueldoFinal = new Paragraph(guarani.format(sueldoFinal), new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, BaseColor.BLACK));
    pSueldoFinal.setAlignment(Element.ALIGN_CENTER);
    cNeto.addElement(pSueldoFinal);
    footerTable.addCell(cNeto);

    documento.add(footerTable);

    documento.close();

} catch (Exception e) {
    try {
        if (!response.isCommitted()) {
            response.reset();
            response.setContentType("text/html; charset=UTF-8");
            java.io.PrintWriter pw = response.getWriter();
            pw.println("<h3>Error al generar el PDF de liquidación:</h3>");
            pw.println("<pre style='color:red;'>");
            e.printStackTrace(pw);
            pw.println("</pre>");
        }
    } catch (Exception ex) {
        ex.printStackTrace();
    }
} finally {
    if (con != null) {
        try { con.close(); } catch (SQLException ignored) {}
    }
}
%>
