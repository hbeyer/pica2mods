<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0"
               xmlns:hab="http://diglib.hab.de/wdb">

  <!-- Erstveröffentlichung
       ===
       Match 003@ stellt sicher, dass das Template genau einmal für den Datensatz angewendet wird. Nach
       dem Match die benötigten Angaben selektieren und das Template für die Formatierung aufrufen.
  -->
  <xsl:template match="pica:datafield[@tag='003@']" mode="publication">
    <xsl:variable name="publication-date" select="translate(../pica:datafield[@tag='011@']/pica:subfield[@code='a'], '[]', '')"/>
    <xsl:variable name="publication-publisher" select="translate(../pica:datafield[@tag='033A']/pica:subfield[@code='n'], '[]', '')"/>
    <xsl:variable name="publication-place" select="translate(../pica:datafield[@tag='033A']/pica:subfield[@code='p'], '[]', '')"/>
    <xsl:if test="concat($publication-date, $publication-publisher, $publication-place) != ''">
      <xsl:call-template name="publication">
        <xsl:with-param name="publication-date" select="$publication-date"/>
        <xsl:with-param name="publication-date-type" select="'dateIssued'"/>
        <xsl:with-param name="publication-place" select="$publication-place"/>
        <xsl:with-param name="publication-publisher">
          <xsl:call-template name="hab:normalize-publisher">
            <xsl:with-param name="string-or-list" select="$publication-publisher"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Angaben zur Veröffentlichung normalisieren -->
  <xsl:template name="hab:normalize-publisher">
    <xsl:param name="string-or-list" select="''"/>
    <xsl:choose>
      <xsl:when test="string($string-or-list)!=$string-or-list">
        <xsl:for-each select="$string-or-list">
          <xsl:value-of select="."/>
          <xsl:if test="not(position()=last())"><xsl:text>; </xsl:text></xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string-or-list"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Datum der Digitalisierung -->
  <xsl:template match="pica:datafield[@tag='009A']" mode="publication">
    <xsl:call-template name="publication">
      <xsl:with-param name="publication-date" select="../pica:datafield[@tag='011B']/pica:subfield[@code='a']"/>
      <xsl:with-param name="publication-date-type" select="'dateCaptured'"/>
      <xsl:with-param name="publication-publisher" select="pica:subfield[@code='c']"/>
        <xsl:with-param name="publication-edition">
          <xsl:if test="starts-with(../pica:datafield[@tag='002@']/pica:subfield[@code='0'], 'O')">[Electronic ed.]</xsl:if>
        </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:transform>
