<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0">

  <!-- Sprache -->
  <xsl:template match="pica:datafield[@tag='010@']" mode="misc">
    <xsl:call-template name="language">
      <xsl:with-param name="language-code" select="pica:subfield[@code='a']"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Beschreibung -->
  <xsl:template match="pica:datafield[@tag='034D' or @tag='034I' or @tag='034K' or @tag='034M' or @tag='037A']">
    <xsl:call-template name="description">
      <xsl:with-param name="description" select="pica:subfield[@code='a']"/>
    </xsl:call-template>
  </xsl:template>

  <!-- AAD Genre -->
  <xsl:template match="pica:datafield[@tag='044S']" mode="misc">
    <xsl:call-template name="genre">
      <!-- !! Seit 05/2011 undokumentierte Ausgabe von unAPI & Co, anstelle der Expansion $8 -->
      <xsl:with-param name="genre" select="pica:subfield[@code='a']"/>
      <xsl:with-param name="genre-authority" select="'aad'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Zugang zur Ressource -->
  <xsl:template match="pica:datafield[@tag='209A'][pica:subfield[@code = 'x'] = '00']" mode="misc">
    <xsl:call-template name="location">
      <xsl:with-param name="location-shelf" select="pica:subfield[@code='a']"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Gesamtheit der Sekundärausgabe in Vorlageform; hier: Zugehörigkeit zu Projekt -->
  <xsl:template match="pica:datafield[@tag='036L']" mode="misc">
    <xsl:if test="pica:subfield[@code='a']">
      <xsl:call-template name="related">
        <xsl:with-param name="related-type" select="'series'"/>
        <xsl:with-param name="related-title" select="pica:subfield[@code='a']"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:transform>
