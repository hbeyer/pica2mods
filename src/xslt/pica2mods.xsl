<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               exclude-result-prefixes="pica"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:mods="http://www.loc.gov/mods/v3"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0">
  <xsl:output method="xml" indent="no"/>

  <xsl:include href="pica/title.xsl"/>
  <xsl:include href="pica/identifier.xsl"/>
  <xsl:include href="pica/classification.xsl"/>
  <xsl:include href="pica/publication.xsl"/>
  <xsl:include href="pica/subject.xsl"/>
  <xsl:include href="pica/person.xsl"/>
  <xsl:include href="pica/misc.xsl"/>

  <xsl:param name="unapi-template" select="'http://katalog.hab.de/service/unapi?format=picaxml&amp;id=opac-de-23:ppn:'"/>
  <xsl:param name="record-source" select="'DE-23'"/>

  <xsl:template match="pica:record">
    <xsl:variable name="record-type" select="substring(pica:datafield[@tag='002@']/pica:subfield[@code='0'], 2, 1)"/>
    <xsl:variable name="record-superior-id">
      <xsl:choose>
        <xsl:when test="$record-type = 'j'"><xsl:value-of select="pica:datafield[@tag='021A']/pica:subfield[@code='9']"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="pica:datafield[@tag='036D']/pica:subfield[@code='9']"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <mods:mods>
      <xsl:apply-templates mode="title"/>
      <xsl:apply-templates mode="identifier"/>
      <xsl:apply-templates mode="classification"/>
      <xsl:apply-templates mode="publication"/>
      <xsl:apply-templates mode="person"/>
      <xsl:apply-templates mode="misc"/>

      <xsl:if test="pica:datafield[@tag='044K' and starts-with(pica:subfield[@code='M'], 'T')]">
        <mods:subject authority="gnd">
          <xsl:apply-templates mode="subject-gnd"/>
        </mods:subject>
      </xsl:if>

      <xsl:if test="pica:datafield[@tag='034D' or @tag='034I' or @tag='034K' or @tag='034M']">
        <mods:physicalDescription>
          <xsl:apply-templates select="pica:datafield[@tag='034D' or @tag='034I' or @tag='034K' or @tag='034M']"/>
        </mods:physicalDescription>
      </xsl:if>

      <xsl:if test="$record-superior-id != ''">
        <xsl:variable name="record-superior" select="document(concat($unapi-template, $record-superior-id))"/>
        <mods:relatedItem type="host">
          <xsl:apply-templates mode="title" select="$record-superior/pica:record"/>
        </mods:relatedItem>
      </xsl:if>

      <xsl:if test="$record-type and contains('fF', $record-type)">
        <!-- Anwendungsprofil 2.0, MD5 baa01054127b5b1a19118caa2cf96558

             "Attribute: order enthält als Wert eine positive Zahl. Bei der Verwendung von mods:part
             ist das Attribut verpflichtend."

             Positive Zahl ist kein Problem. Eine positive Zahl die die Ordnung der Untergeordneten
             innerhalb der sortierten Aggregation der Übergeordneten repräsenitert - NOT. Ist nicht
             aus der Untergeordneten ablesbar.

        -->
        <mods:part order="1">
          <mods:detail type="volume">
            <mods:number>
              <!-- Sortierzählung verwenden wenn keine Vorlagezählung vorhanden -->
              <xsl:choose>
                <xsl:when test="pica:datafield[@tag='036D']/pica:subfield[@code='l']">
                  <xsl:value-of select="pica:datafield[@tag='036D']/pica:subfield[@code='l']"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="pica:datafield[@tag='036D']/pica:subfield[@code='X']"/>
                </xsl:otherwise>
              </xsl:choose>
            </mods:number>
          </mods:detail>
        </mods:part>
      </xsl:if>

      <mods:recordInfo>
        <mods:recordIdentifier source="DE-23"><xsl:value-of select="pica:datafield[@tag='003@']/pica:subfield[@code='0']"/></mods:recordIdentifier>
        <mods:recordOrigin xml:lang="en">Converted from PICA using a local XSL transformation script</mods:recordOrigin>
        <mods:recordContentSource authority="marcorg"><xsl:value-of select="$record-source"/></mods:recordContentSource>
      </mods:recordInfo>

    </mods:mods>
  </xsl:template>

  <xsl:template name="title">
    <xsl:param name="title"/>
    <xsl:param name="subtitle"/>
    <xsl:param name="author-statement"/>
    <xsl:param name="type"/>
    <xsl:element name="mods:titleInfo">
      <xsl:if test="$type != ''">
        <xsl:attribute name="type"><xsl:value-of select="$type"/></xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="contains($title, '@')">
          <xsl:variable name="mods:nonSort" select="normalize-space(substring-before($title, '@'))"/>
          <xsl:if test="$mods:nonSort != ''">
            <mods:nonSort><xsl:value-of select="normalize-space(substring-before($title, '@'))"/></mods:nonSort>
          </xsl:if>
          <mods:title><xsl:value-of select="substring-after($title, '@')"/></mods:title>
        </xsl:when>
        <xsl:otherwise>
          <mods:title><xsl:value-of select="$title"/></mods:title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$subtitle != ''">
        <mods:subTitle><xsl:value-of select="$subtitle"/></mods:subTitle>
      </xsl:if>
      </xsl:element>
  </xsl:template>

  <xsl:template name="identifier">
    <xsl:param name="identifier"/>
    <xsl:param name="identifier-type"/>
    <xsl:element name="mods:identifier">
      <xsl:if test="$identifier-type != ''">
        <xsl:attribute name="type"><xsl:value-of select="$identifier-type"/></xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$identifier"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="classification">
    <xsl:param name="classification"/>
    <xsl:param name="classification-label"/>
    <xsl:param name="classification-authority"/>
    <xsl:param name="classification-authority-uri"/>
    <xsl:param name="classification-uri"/>
    <xsl:element name="mods:classification">
      <xsl:if test="$classification-authority != ''">
        <xsl:attribute name="authority"><xsl:value-of select="$classification-authority"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="$classification-authority-uri != ''">
        <xsl:attribute name="authorityURI"><xsl:value-of select="$classification-authority-uri"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="$classification-uri != ''">
        <xsl:attribute name="valueURI"><xsl:value-of select="$classification-uri"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="$classification-label != ''">
        <xsl:attribute name="displayLabel"><xsl:value-of select="$classification-label"/></xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$classification"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="language">
    <xsl:param name="language-code"/>
    <xsl:for-each select="$language-code">
      <mods:language>
        <mods:languageTerm type="code" authority="iso639-2b"><xsl:value-of select="."/></mods:languageTerm>
      </mods:language>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="description">
    <xsl:param name="description"/>
    <mods:extent><xsl:value-of select="$description"/></mods:extent>
  </xsl:template>

  <xsl:template name="genre">
    <xsl:param name="genre"/>
    <xsl:param name="genre-authority"/>
    <xsl:element name="mods:genre">
      <xsl:if test="$genre-authority != ''">
        <xsl:attribute name="authority"><xsl:value-of select="$genre-authority"/></xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$genre"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="publication">
    <xsl:param name="publication-date"/>
    <xsl:param name="publication-date-type"/>
    <xsl:param name="publication-place"/>
    <xsl:param name="publication-publisher"/>
    <xsl:param name="publication-edition"/>
    <mods:originInfo>
      <xsl:if test="$publication-date != ''">
        <xsl:element name="mods:{$publication-date-type}">
          <xsl:if test="$publication-date-type = 'dateIssued'">
            <xsl:attribute name="keyDate">yes</xsl:attribute>
          </xsl:if>
          <xsl:attribute name="encoding">iso8601</xsl:attribute>
          <xsl:value-of select="$publication-date"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="$publication-place != ''">
        <mods:place>
          <mods:placeTerm type="text"><xsl:value-of select="$publication-place"/></mods:placeTerm>
        </mods:place>
      </xsl:if>
      <xsl:if test="$publication-publisher != ''">
        <mods:publisher><xsl:value-of select="$publication-publisher"/></mods:publisher>
      </xsl:if>
      <xsl:if test="$publication-edition != ''">
        <mods:edition><xsl:value-of select="$publication-edition"/></mods:edition>
      </xsl:if>
    </mods:originInfo>
  </xsl:template>

  <xsl:template name="location">
    <xsl:param name="location-shelf"/>
    <mods:location>
      <mods:physicalLocation authority="marcorg">DE-23</mods:physicalLocation>
      <xsl:if test="$location-shelf != ''">
        <mods:shelfLocator><xsl:value-of select="$location-shelf"/></mods:shelfLocator>
      </xsl:if>
    </mods:location>
  </xsl:template>

  <xsl:template name="related">
    <xsl:param name="related-type"/>
    <xsl:param name="related-title"/>
    <xsl:if test="$related-title">
      <xsl:element name="mods:relatedItem">
        <xsl:if test="$related-type">
          <xsl:attribute name="type"><xsl:value-of select="$related-type"/></xsl:attribute>
        </xsl:if>
        <mods:titleInfo>
          <mods:title><xsl:value-of select="$related-title"/></mods:title>
        </mods:titleInfo>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="subject">
    <xsl:param name="subject"/>
    <xsl:param name="subject-value-uri"/>
    <xsl:param name="subject-type"/>
    <xsl:element name="mods:{$subject-type}">
      <xsl:if test="$subject-value-uri != ''">
        <xsl:attribute name="valueURI"><xsl:value-of select="$subject-value-uri"/></xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$subject"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="person">
    <xsl:param name="person-role"/>
    <xsl:param name="person-value-uri"/>
    <xsl:param name="person-name-family"/>
    <xsl:param name="person-name-given"/>
    <xsl:param name="person-name-prefix"/>
    <xsl:param name="person-name-byname"/>
    <xsl:param name="person-name-personal"/>
    <xsl:param name="person-type"/>
    <xsl:param name="person-name-display" select="'N.N'"/>
    <xsl:element name="mods:name">
      <xsl:attribute name="type"><xsl:value-of select="$person-type"/></xsl:attribute>
      <xsl:if test="$person-value-uri != ''"><xsl:attribute name="valueURI"><xsl:value-of select="$person-value-uri"/></xsl:attribute></xsl:if>
      <xsl:if test="$person-type = 'personal'">
        <xsl:if test="$person-name-given != ''"><mods:namePart type="given"><xsl:value-of select="$person-name-given"/></mods:namePart></xsl:if>
        <xsl:if test="$person-name-family != ''"><mods:namePart type="family"><xsl:value-of select="$person-name-family"/></mods:namePart></xsl:if>
        <xsl:if test="$person-name-byname  != ''"><mods:namePart type="termsOfAddress"><xsl:value-of select="$person-name-byname"/></mods:namePart></xsl:if>
      </xsl:if>
      <mods:displayForm><xsl:value-of select="$person-name-display"/></mods:displayForm>
      <mods:role>
        <xsl:element name="mods:roleTerm">
          <xsl:attribute name="authority">marcrelator</xsl:attribute>
          <xsl:attribute name="type">code</xsl:attribute>
          <xsl:attribute name="valueURI">http://id.loc.gov/vocabulary/relators/<xsl:value-of select="$person-role"/></xsl:attribute>
          <xsl:value-of select="$person-role"/>
        </xsl:element>
      </mods:role>
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="title"/>
  <xsl:template match="text()" mode="identifier"/>
  <xsl:template match="text()" mode="classification"/>
  <xsl:template match="text()" mode="publication"/>
  <xsl:template match="text()" mode="subject-gnd"/>
  <xsl:template match="text()" mode="person"/>
  <xsl:template match="text()" mode="misc"/>

</xsl:transform>
