<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0">

  <!-- RSWK Schlagwörter GND
       ===
       Subfield $9 :: Seit 05/2011 in der unAPI-Ausgabe enthaltene Subfelder anstelle der Expansion
  -->
  <xsl:template match="pica:datafield[@tag='044K' and pica:subfield[@code='9']]" mode="subject-gnd">
    <xsl:variable name="subject-type" select="substring(pica:subfield[@code='M'], 2, 1)"/>

    <xsl:call-template name="subject">
      <xsl:with-param name="subject-value-uri">
        <xsl:if test="pica:subfield[@code='0']">
          <xsl:text>http://d-nb.info/</xsl:text><xsl:value-of select="pica:subfield[@code='0']"/>
        </xsl:if>
      </xsl:with-param>
      <xsl:with-param name="subject" select="pica:subfield[@code='a']"/>
      <xsl:with-param name="subject-type">
        <xsl:choose>
          <xsl:when test="$subject-type = 'g'">geographic</xsl:when>
          <xsl:otherwise>topic</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>

  </xsl:template>

</xsl:transform>
