<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0">

  <!-- Klassifikation: LCC -->
  <xsl:template match="pica:datafield[@tag='045A']" mode="classification">
    <xsl:call-template name="classification">
      <xsl:with-param name="classification" select="pica:subfield[@code='a'][1]"/>
      <xsl:with-param name="classification-label" select="pica:subfield[@code='j'][1]"/>
      <xsl:with-param name="classification-authority" select="'lcc'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Klassifikation: DDC -->
  <xsl:template match="pica:datafield[@tag='045F']" mode="classification">
    <xsl:call-template name="classification">
      <xsl:with-param name="classification" select="pica:subfield[@code='a'][1]"/>
      <xsl:with-param name="classification-label" select="pica:subfield[@code='j'][1]"/>
      <xsl:with-param name="classification-authority" select="'ddc'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Klassifikation: NLM -->
  <xsl:template match="pica:datafield[@tag='045C']" mode="classification">
    <xsl:call-template name="classification">
      <xsl:with-param name="classification" select="pica:subfield[@code='a'][1]"/>
      <xsl:with-param name="classification-label" select="pica:subfield[@code='j'][1]"/>
      <xsl:with-param name="classification-authority" select="'nlm'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Klassifikation: BKL -->
  <xsl:template match="pica:datafield[@tag='045Q']" mode="classification">
    <xsl:call-template name="classification">
      <xsl:with-param name="classification" select="pica:subfield[@code='a'][1]"/>
      <xsl:with-param name="classification-label" select="pica:subfield[@code='j'][1]"/>
      <xsl:with-param name="classification-authority" select="'bkl'"/>
      <xsl:with-param name="classification-uri" select="concat('http://uri.gbv.de/terminology/bk/', pica:subfield[@code='a'])"/>
    </xsl:call-template>
  </xsl:template>

</xsl:transform>
