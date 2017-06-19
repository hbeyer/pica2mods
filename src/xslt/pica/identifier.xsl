<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0">

  <!-- URN -->
  <xsl:template match="pica:datafield[@tag='004U']" mode="identifier">
    <xsl:call-template name="identifier">
      <xsl:with-param name="identifier" select="pica:subfield[@code='0']"/>
      <xsl:with-param name="identifier-type" select="'urn'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- URI generisch oder PURL Diglib -->
  <xsl:template match="pica:datafield[@tag='009P' and @occurrence='03']" mode="identifier">
    <xsl:choose>
      <xsl:when test="pica:subfield[@code='g']">
        <xsl:call-template name="identifier">
          <xsl:with-param name="identifier" select="pica:subfield[@code='g']"/>
          <xsl:with-param name="identifier-type">
            <xsl:choose>
              <xsl:when test="starts-with(pica:subfield[@code='g'], 'urn:')">urn</xsl:when>
              <xsl:otherwise>uri</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="pica:subfield[@code='a'] and starts-with(pica:subfield[@code='a'], 'http://diglib.hab.de')">
        <xsl:call-template name="identifier">
          <xsl:with-param name="identifier-type" select="'purl'"/>
          <xsl:with-param name="identifier">
	    <xsl:value-of select="pica:subfield[@code='a']"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Fingerprint -->
  <xsl:template match="pica:datafield[@tag='007P']" mode="identifier">
    <xsl:call-template name="identifier">
      <xsl:with-param name="identifier" select="pica:subfield[@code='0']"/>
      <xsl:with-param name="identifier-type" select="'fingerprint'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ISBN -->
  <xsl:template match="pica:datafield[@tag='004A']" mode="identifier">
    <xsl:call-template name="identifier">
      <xsl:with-param name="identifier">
        <xsl:choose>
          <xsl:when test="pica:subfield[@code='A']"><xsl:value-of select="pica:subfield[@code='A']"/></xsl:when>
          <xsl:when test="pica:subfield[@code='0']"><xsl:value-of select="pica:subfield[@code='0']"/></xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="identifier-type" select="'isbn'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Bibliographische Zitate -->
  <xsl:template match="pica:datafield[@tag='007S']" mode="identifier">
    <xsl:if test="not(pica:subfield[@code='S'])">
      <xsl:choose>
        <xsl:when test="starts-with(pica:subfield[@code='0'], 'VD17 ')">
          <xsl:call-template name="identifier">
            <xsl:with-param name="identifier" select="substring-after(pica:subfield[@code='0'], 'VD17 ')"/>
            <xsl:with-param name="identifier-type" select="'vd17'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="starts-with(pica:subfield[@code='0'], 'VD16 ')">
          <xsl:call-template name="identifier">
            <xsl:with-param name="identifier" select="substring-after(pica:subfield[@code='0'], 'VD16 ')"/>
            <xsl:with-param name="identifier-type" select="'vd16'"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:transform>
