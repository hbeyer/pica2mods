<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:dc="http://purl.org/dc/elements/1.1/"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0">
  <xsl:output method="xml" indent="yes"/>

  <xsl:include href="pica/title.xsl"/>
  <xsl:include href="pica/identifier.xsl"/>
  <xsl:include href="pica/classification.xsl"/>
  <xsl:include href="pica/publication.xsl"/>
  <xsl:include href="pica/person.xsl"/>
  <xsl:include href="pica/misc.xsl"/>

  <xsl:param name="unapi-template" select="'http://katalog.hab.de/service/unapi?format=picaxml&amp;id=opac-de-23:ppn:'"/>

  <xsl:template match="pica:record">
    <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
               xmlns:dc="http://purl.org/dc/elements/1.1/"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
      <xsl:apply-templates mode="title"/>
      <xsl:apply-templates mode="identifier"/>
      <xsl:apply-templates mode="classification"/>
      <xsl:apply-templates mode="publication"/>
      <xsl:apply-templates mode="person"/>
      <xsl:apply-templates mode="misc"/>
    </oai_dc:dc>
  </xsl:template>

  <xsl:template name="title">
    <xsl:param name="title"/>
    <xsl:param name="subtitle"/>
    <xsl:param name="author-statement"/>
    <xsl:param name="type"/>
    <xsl:if test="$title != ''">
      <dc:title>
        <xsl:value-of select="translate($title, '@', '')"/>
        <xsl:if test="$subtitle != ''"><xsl:text> : </xsl:text><xsl:value-of select="$subtitle"/></xsl:if>
        <xsl:if test="$author-statement != ''"><xsl:text> / </xsl:text><xsl:value-of select="$author-statement"/></xsl:if>
      </dc:title>
    </xsl:if>
  </xsl:template>

  <xsl:template name="identifier">
    <xsl:param name="identifier"/>
    <xsl:param name="identifier-type"/>
    <dc:identifier>
      <xsl:if test="$identifier-type != 'url' and $identifier-type != 'urn' and $identifier-type != 'purl'">
        <xsl:text>(</xsl:text><xsl:value-of select="$identifier-type"/><xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:value-of select="$identifier"/>
    </dc:identifier>
  </xsl:template>

  <xsl:template name="classification">
    <xsl:param name="classification"/>
    <xsl:param name="classification-label"/>
    <xsl:param name="classification-authority"/>
    <xsl:param name="classification-uri"/>
    <dc:subject>
      <xsl:value-of select="$classification"/>
      <xsl:if test="$classification-label != ''"><xsl:text> </xsl:text><xsl:value-of select="$classification-label"/></xsl:if>
    </dc:subject>
  </xsl:template>

  <xsl:template name="description">
    <xsl:param name="description"/>
    <xsl:if test="$description != ''">
      <dc:description><xsl:value-of select="$description"/></dc:description>
    </xsl:if>
  </xsl:template>

  <xsl:template name="publication">
    <xsl:param name="publication-date"/>
    <xsl:param name="publication-date-type"/>
    <xsl:param name="publication-place"/>
    <xsl:param name="publication-publisher"/>
    <xsl:param name="publication-edition"/>
    <xsl:choose>
      <xsl:when test="$publication-edition = ''">
        <xsl:if test="$publication-date != ''">
          <dc:date>
            <xsl:value-of select="$publication-date"/>
          </dc:date>
        </xsl:if>
        <xsl:if test="($publication-publisher != '') or ($publication-place != '')">
          <dc:publisher>
            <xsl:value-of select="$publication-place"/>
            <xsl:if test="($publication-publisher != '') and ($publication-place != '')">
              <xsl:text> : </xsl:text>
            </xsl:if>
            <xsl:value-of select="$publication-publisher"/>
          </dc:publisher>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="person">
    <xsl:param name="person-role"/>
    <xsl:param name="person-value-uri"/>
    <xsl:param name="person-name-family"/>
    <xsl:param name="person-name-given"/>
    <xsl:param name="person-name-prefix"/>
    <xsl:param name="person-name-byname"/>
    <xsl:param name="person-name-personal"/>
    <xsl:param name="person-name-display" select="'N.N'"/>
    <xsl:choose>
      <xsl:when test="$person-role = 'aut'">
        <dc:creator><xsl:value-of select="$person-name-display"></xsl:value-of></dc:creator>
      </xsl:when>
      <xsl:otherwise>
        <dc:contributor><xsl:value-of select="$person-name-display"/></dc:contributor>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="language">
    <xsl:param name="language-code"/>
    <xsl:if test="$language-code != ''">
      <dc:language><xsl:value-of select="$language-code"/></dc:language>
    </xsl:if>
  </xsl:template>

  <xsl:template name="genre">
    <xsl:param name="genre"/>
    <xsl:param name="genre-authority"/>
    <xsl:if test="$genre != ''">
      <dc:subject>
        <xsl:value-of select="$genre"/>
      </dc:subject>
    </xsl:if>
  </xsl:template>

  <xsl:template name="related">
    <xsl:param name="related-title"/>
    <xsl:param name="related-type"/>
    <xsl:param name="related-record-identifier"/>
    <xsl:param name="related-label"/>
    <xsl:if test="$related-title != ''">
      <dc:relation><xsl:value-of select="$related-title"/></dc:relation>
    </xsl:if>
    <xsl:if test="$related-record-identifier">
      <dc:relation><xsl:value-of select="$related-record-identifier"/></dc:relation>
    </xsl:if>
  </xsl:template>

  <xsl:template name="location"/>

  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="title"/>
  <xsl:template match="text()" mode="identifier"/>
  <xsl:template match="text()" mode="classification"/>
  <xsl:template match="text()" mode="publication"/>
  <xsl:template match="text()" mode="subject-gnd"/>
  <xsl:template match="text()" mode="person"/>
  <xsl:template match="text()" mode="misc"/>

</xsl:transform>
