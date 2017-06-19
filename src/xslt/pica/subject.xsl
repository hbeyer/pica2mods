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

    <xsl:variable name="subject-label">
      <xsl:choose>
        <xsl:when test="$subject-type = 'p'">
          <xsl:choose>
            <xsl:when test="pica:subfield[@code = '8']">
              <xsl:value-of select="pica:subfield[@code = '8'][1]"/>
            </xsl:when>
            <xsl:when test="pica:subfield[@code = 'a' or @code = 'd']">
              <xsl:value-of select="pica:subfield[@code = 'a']"/>
              <xsl:if test="pica:subfield[@code = 'a'] and pica:subfield[@code = 'd']">, </xsl:if>
              <xsl:value-of select="pica:subfield[@code = 'd']"/>
            </xsl:when>
            <xsl:when test="pica:subfield[@code = 'P']">
              <xsl:value-of select="pica:subfield[@code = 'P']"/>
            </xsl:when>
            <xsl:otherwise>N.N.</xsl:otherwise>
          </xsl:choose>
          <xsl:if test="pica:subfield[@code = 'l']">
            <xsl:value-of select="concat(' &lt;', pica:subfield[@code = 'l'][1], '&gt;')"/>
          </xsl:if>
          <xsl:if test="pica:subfield[@code = 'h']">
            <xsl:value-of select="concat(', ', pica:subfield[@code = 'h'][1])"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="pica:subfield[@code = 'a']"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$subject-label">

      <xsl:call-template name="subject">
        <xsl:with-param name="subject-value-uri">
          <xsl:if test="pica:subfield[@code='0']">
            <xsl:text>http://d-nb.info/</xsl:text><xsl:value-of select="pica:subfield[@code='0']"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="subject" select="$subject-label"/>
        <xsl:with-param name="subject-type">
          <xsl:choose>
            <xsl:when test="$subject-type = 'g'">geographic</xsl:when>
            <xsl:otherwise>topic</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>

    </xsl:if>

  </xsl:template>

</xsl:transform>
