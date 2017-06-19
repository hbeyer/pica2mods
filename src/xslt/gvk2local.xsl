<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0" 
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0">
  <xsl:output method="xml" indent="no"/>
  <xsl:strip-space elements="*"/>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
   
  <xsl:template match="pica:datafield[@tag = '101@' and pica:subfield[@code = 'a'] != '50']"/>
  <xsl:template match="pica:datafield[contains('12', substring(@tag, 1, 1)) and preceding::pica:datafield[@tag = '101@'][1][pica:subfield[@code = 'a'] != '50']]">
    <xsl:if test="@tag = '101@'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  
</xsl:transform>
