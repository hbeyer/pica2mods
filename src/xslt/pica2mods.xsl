<xsl:transform version="1.0"
               exclude-result-prefixes="pica owl rdf skos"
               xmlns:mods="http://www.loc.gov/mods/v3"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0"
               xmlns:owl="http://www.w3.org/2002/07/owl#"
               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:skos="http://www.w3.org/2004/02/skos/core#"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="proxyBaseUrl">http://uri.hab.de/instance/proxy/opac-de-23/record/</xsl:variable>

  <xsl:template match="pica:record">

    <mods:mods>
      <xsl:call-template name="mods:titleInfo"/>
      <xsl:call-template name="mods:physicalDescription"/>

      <xsl:call-template name="mods:originInfo"/>
      <xsl:call-template name="mods:dateCaptured"/>

      <xsl:apply-templates/>

      <xsl:call-template name="mods:recordInfo"/>

    </mods:mods>
  </xsl:template>

  <!-- Bemerkung -->
  <xsl:template match="pica:datafield[@tag = '037A']/pica:subfield[@code = 'a']">
    <mods:note><xsl:value-of select="."/></mods:note>
  </xsl:template>

  <!-- Sprachcodes -->
  <xsl:template match="pica:datafield[@tag = '010@']">
    <mods:language>
      <xsl:for-each select="pica:subfield[@code = 'a']">
        <mods:languageTerm type="code" authority="iso639-2b">
          <xsl:value-of select="."/>
        </mods:languageTerm>
      </xsl:for-each>
    </mods:language>
  </xsl:template>

  <!-- RSWK Schlagwörter -->
  <xsl:template match="pica:datafield[@tag = '044K']">
    <mods:subject authority="gnd">
      <mods:topic>
        <xsl:call-template name="add-proxy-valueURI"/>
        <xsl:choose>
          <xsl:when test="pica:subfield[@code = '8']">
            <xsl:value-of select="pica:subfield[@code = '8']"/>
          </xsl:when>
          <xsl:when test="pica:subfield[@code = 'a']">
            <xsl:value-of select="pica:subfield[@code = 'a']"/>
          </xsl:when>
        </xsl:choose>
      </mods:topic>
    </mods:subject>
  </xsl:template>

  <!-- Basisklassifikation -->
  <xsl:template match="pica:datafield[@tag = '045Q']">
    <mods:classification authority="bkl">
      <xsl:call-template name="add-proxy-valueURI"/>
      <xsl:choose>
        <xsl:when test="pica:subfield[@code = '8']">
          <xsl:value-of select="pica:subfield[@code = '8']"/>
        </xsl:when>
        <xsl:when test="pica:subfield[@code = 'a']">
          <xsl:value-of select="pica:subfield[@code = 'a']"/>
        </xsl:when>
      </xsl:choose>
    </mods:classification>
  </xsl:template>

  <!-- Klassifikation der Barocknachrichten -->
  <xsl:template match="pica:datafield[@tag = '145Z']/pica:subfield[@code = 'a'][starts-with(., 'BAROCK')]">
    <xsl:variable name="valueURI" select="normalize-space(substring-after(substring-before(., ' - '), 'BAROCK '))"/>
    <mods:classification authorityURI="http://uri.hab.de/vocab/barock" valueURI="http://uri.hab.de/vocab/barock#b{$valueURI}" displayLabel="BAROCK Klassifikation">
      <xsl:value-of select="substring-after(., ' - ')"/>
    </mods:classification>
  </xsl:template>

  <!-- Fachgruppen der Sammlung Deutscher Drucke -->
  <xsl:template match="pica:datafield[@tag = '145Z']/pica:subfield[@code = 'a'][translate(., '0123456789', '00000000') = '00']">
    <xsl:variable name="authorityURI">http://uri.hab.de/vocab/sdd-fachgruppen</xsl:variable>
    <xsl:variable name="valueURI" select="concat($authorityURI, '#fg', .)"/>
    <xsl:variable name="value" select="document(concat($authorityURI, '.rdf'))//*[@rdf:about = $valueURI]/skos:prefLabel[1]"/>
    <mods:classification authorityURI="{$authorityURI}" valueURI="{$valueURI}" displayLabel="SDD Fachgruppen">
      <xsl:choose>
        <xsl:when test="$value">
          <xsl:value-of select="$value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </mods:classification>
  </xsl:template>

  <!-- AAD Gattungsbegriffe -->
  <xsl:template match="pica:datafield[@tag = '044S']">
    <mods:genre authority="aad">
      <xsl:call-template name="add-proxy-valueURI"/>
      <xsl:choose>
        <xsl:when test="pica:subfield[@code = '8']">
          <xsl:value-of select="pica:subfield[@code = '8']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="pica:subfield[@code = 'a']"/>
        </xsl:otherwise>
      </xsl:choose>
    </mods:genre>
  </xsl:template>

  <!-- Signatur und Standort -->
  <xsl:template match="pica:datafield[@tag = '209A']">
    <xsl:if test="pica:subfield[@code = 'd'] != 'z'">
      <mods:location>
        <mods:physicalLocation authority="marcorg">DE-23</mods:physicalLocation>
        <mods:shelfLocator>
          <xsl:value-of select="pica:subfield[@code = 'a']"/>
        </mods:shelfLocator>
      </mods:location>
    </xsl:if>
  </xsl:template>

  <!-- Identifier -->
  <xsl:template match="pica:datafield[@tag = '009P'][@occurrence = '03']/pica:subfield[@code = 'a']">
    <xsl:if test="starts-with(., 'http://diglib.hab.de')">
      <mods:identifier type="purl"><xsl:value-of select="."/></mods:identifier>
    </xsl:if>
  </xsl:template>

  <xsl:template match="pica:datafield[@tag = '004U']/pica:subfield[@code = '0']">
    <mods:identifier type="urn"><xsl:value-of select="."/></mods:identifier>
  </xsl:template>

  <xsl:template match="pica:datafield[@tag = '007P']/pica:subfield[@code = '0']">
    <mods:identifier type="fingerprint"><xsl:value-of select="."/></mods:identifier>
  </xsl:template>

  <xsl:template match="pica:datafield[@tag = '004A']/pica:subfield[@code = 'A' or @code = '0']">
    <mods:identifier type="isbn"><xsl:value-of select="."/></mods:identifier>
  </xsl:template>

  <xsl:template match="pica:datafield[@tag = '006M']/pica:subfield[@code = '0']">
    <mods:identifier type="vd18"><xsl:value-of select="substring-after(., 'VD18 ')"/></mods:identifier>
  </xsl:template>

  <xsl:template match="pica:datafield[@tag = '007S']/pica:subfield[@code = '0']">
    <xsl:choose>
      <xsl:when test="starts-with(., 'VD17 ') and not(../pica:datafield[@tag = '006W'])">
        <mods:identifier type="vd17"><xsl:value-of select="substring-after(., 'VD17 ')"/></mods:identifier>
      </xsl:when>
      <xsl:when test="starts-with(., 'VD16 ')">
        <mods:identifier type="vd16"><xsl:value-of select="substring-after(., 'VD16 ')"/></mods:identifier>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Personen -->
  <!-- Verfasser -->
  <xsl:template match="pica:datafield[@tag = '028A' or @tag = '028B']">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'aut'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Drucker, Verleger, oder Buchhändler bei alten Drucken -->
  <xsl:template match="pica:datafield[@tag = '033J']">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'prt'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Gefeierte Person -->
  <xsl:template match="pica:datafield[@tag = '028F']">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'hnf'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Sonstige nicht beteiligte Personen -->
  <xsl:template match="pica:datafield[@tag='028G']">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'asn'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Konkurrenzverfasser -->
  <xsl:template match="pica:datafield[@tag = '028M']">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'oth'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Widmungsempfänger -->
  <xsl:template match="pica:datafield[@tag = '028L'][not(@occurrence)]">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'dte'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Zensor -->
  <xsl:template match="pica:datafield[@tag = '028L'][@occurrence = '01']">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'cns'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- literarische/künstlerische/musikalische Beiträger -->
  <xsl:template match="pica:datafield[@tag = '028L'][@occurrence = '02']">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'clb'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Sonstige beteiligte Personen -->
  <xsl:template match="pica:datafield[@tag = '028C' or @tag='028D']">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'oth'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Sonstige nichtbeteiligte bzw. im Sachtitel genannte Personen -->
  <xsl:template match="pica:datafield[@tag = '028L'][@occurrence = '03']">
    <xsl:call-template name="mods:person">
      <xsl:with-param name="personRole" select="'asn'"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="mods:titleInfo">
    <xsl:variable name="recordType" select="substring(pica:datafield[@tag = '002@']/pica:subfield[@code = '0'], 2, 1)"/>

    <xsl:choose>
      <xsl:when test="$recordType = 'j'">
        <xsl:call-template name="make-titleInfo">
          <xsl:with-param name="titleField" select="pica:datafield[@tag = '021B']"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Dieser Fall ist noch nicht abgedeckt! Titel steht im übergeordneten Datensatz! -->
      <xsl:when test="$recordType = 'f' and not(pica:datafield[@tag = '021A']) and pica:datafield[@tag = '036D']"/>
      <xsl:when test="pica:datafield[@tag = '021A']">
        <xsl:call-template name="make-titleInfo">
          <xsl:with-param name="titleField" select="pica:datafield[@tag = '021A']"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>

    <!-- Einheitssachtitel -->
    <xsl:if test="pica:datafield[@tag = '022A'][@occurrence = '01']">
      <xsl:call-template name="make-titleInfo">
        <xsl:with-param name="titleField" select="pica:datafield[@tag = '022A'][@occurrence = '01']"/>
        <xsl:with-param name="titleType">uniform</xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <!-- Weitere Sachtitel -->
    <xsl:if test="pica:datafield[@tag = '027A']">
      <xsl:call-template name="make-titleInfo">
        <xsl:with-param name="titleField" select="pica:datafield[@tag = '027A']"/>
        <xsl:with-param name="titleType">alternative</xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <!-- Titel in Bandsätzen und Aufsätzen (für die Anzeige usw.) -->
    <xsl:if test="$recordType != 's' and pica:datafield[@tag = '027D']">
      <xsl:call-template name="make-titleInfo">
        <xsl:with-param name="titleField" select="pica:datafield[@tag = '027D']"/>
        <xsl:with-param name="titleType">alternative</xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <!-- Normierter Zeitschriftenkurztitel b- und d-Sätze -->
    <xsl:if test="pica:datafield[@tag = '026C'] and ($recordType = 'b' or $recordType = 'd')">
      <xsl:call-template name="make-titleInfo">
        <xsl:with-param name="titleField" select="pica:datafield[@tag = '026C']"/>
        <xsl:with-param name="titleType">abbreviated</xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <!-- Enthaltende Zeitschrift -->
    <xsl:if test="$recordType = 's' and pica:datafield[@tag = '027D']">
      <mods:relatedItem type="host">
        <mods:titleInfo>
          <mods:title>
            <xsl:value-of select="pica:datafield[@tag = '027D']/pica:subfield[@code = 'a']"/>
          </mods:title>
        </mods:titleInfo>
        <xsl:for-each select="pica:datafield[@tag = '027D']/pica:subfield[@code = '0']">
          <mods:identifier type="issn"><xsl:value-of select="."/></mods:identifier>
        </xsl:for-each>
        <xsl:if test="pica:datafield[@tag = '027D']/pica:subfield[@code = 'p']">
          <mods:originInfo>
            <xsl:for-each select="pica:datafield[@tag = '027D']/pica:subfield[@code = 'p']">
              <xsl:if test="not(preceding::pica:subfield[@code = 'p'][parent::pica:datafield[@tag = '027D']] = current())">
                <mods:place>
                  <mods:placeTerm type="text">
                    <xsl:value-of select="."/>
                  </mods:placeTerm>
                </mods:place>
              </xsl:if>
            </xsl:for-each>
          </mods:originInfo>
        </xsl:if>
      </mods:relatedItem>
    </xsl:if>
    
  </xsl:template>

  <xsl:template name="make-titleInfo">
    <xsl:param name="titleField"/>
    <xsl:param name="titleType"/>
    <mods:titleInfo>
      <xsl:if test="$titleType">
        <xsl:attribute name="type">
          <xsl:value-of select="$titleType"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="contains($titleField/pica:subfield[@code = 'a'], '@')">
          <xsl:if test="substring-before($titleField/pica:subfield[@code = 'a'], '@')">
            <mods:nonSort>
              <xsl:value-of select="substring-before($titleField/pica:subfield[@code = 'a'], '@')"/>
            </mods:nonSort>
          </xsl:if>
          <mods:title>
            <xsl:value-of select="substring-after($titleField/pica:subfield[@code = 'a'], '@')"/>
          </mods:title>
        </xsl:when>
        <xsl:otherwise>
          <mods:title>
            <xsl:value-of select="$titleField/pica:subfield[@code = 'a']"/>
          </mods:title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$titleField/pica:subfield[@code = 'd']">
        <mods:subTitle><xsl:value-of select="$titleField/pica:subfield[@code = 'd']"/></mods:subTitle>
      </xsl:if>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template name="mods:originInfo">
    <!-- Erstveröffentlichung -->
    <xsl:if test="pica:datafield[@tag = '011@' or @tag = '033A']">
      <mods:originInfo>
        <xsl:if test="pica:datafield[@tag = '033A']">
          <xsl:for-each select="pica:datafield[@tag = '033A']/pica:subfield[@code = 'p']">
            <xsl:if test="not(preceding::pica:subfield[@code = 'p'][parent::pica:datafield[@tag = '033A']] = current())">
              <mods:place>
                <mods:placeTerm type="text">
                  <xsl:value-of select="."/>
                </mods:placeTerm>
              </mods:place>
            </xsl:if>
          </xsl:for-each>
          <xsl:for-each select="pica:datafield[@tag = '033A']/pica:subfield[@code = 'n']">
            <xsl:if test="not(preceding::pica:subfield[@code = 'n'][parent::pica:datafield[@tag = '033A']] = current())">
              <mods:publisher>
                <xsl:value-of select="."/>
              </mods:publisher>
            </xsl:if>
          </xsl:for-each>
        </xsl:if>
        <xsl:if test="pica:datafield[@tag = '011@']/pica:subfield[@code = 'a']">
          <mods:dateIssued keyDate="yes" encoding="iso8601">
            <xsl:choose>
              <xsl:when test="pica:datafield[@tag = '011@']/pica:subfield[@code = 'r']">
                <xsl:value-of select="pica:datafield[@tag = '011@']/pica:subfield[@code = 'r']"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="pica:datafield[@tag = '011@']/pica:subfield[@code = 'a']"/>
              </xsl:otherwise>
            </xsl:choose>
          </mods:dateIssued>
        </xsl:if>
      </mods:originInfo>
    </xsl:if>
  </xsl:template>

  <!-- Digitalisat und Vorlage -->
  <xsl:template name="mods:dateCaptured">
    <xsl:if test="pica:datafield[@tag = '009A']">
      <mods:originInfo>
        <xsl:if test="pica:datafield[@tag = '011B']/pica:subfield[@code = 'a']">
          <mods:dateCaptured encoding="iso8601">
            <xsl:value-of select="pica:datafield[@tag = '011B']/pica:subfield[@code = 'a'][1]"/>
          </mods:dateCaptured>
        </xsl:if>
        <mods:publisher>
          <xsl:value-of select="pica:datafield[@tag = '009A']/pica:subfield[@code = 'c'][1]"/>
        </mods:publisher>
        <mods:edition>[Electronic ed.]</mods:edition>
      </mods:originInfo>
      <xsl:if test="pica:datafield[@tag = '009A']/pica:subfield[@code = 'a']">
        <mods:relatedItem type="original">
          <mods:location>
            <mods:physicalLocation authority="marcorg">DE-23</mods:physicalLocation>
            <mods:shelfLocator>
              <xsl:value-of select="pica:datafield[@tag = '009A']/pica:subfield[@code = 'a'][1]"/>
            </mods:shelfLocator>
          </mods:location>
        </mods:relatedItem>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mods:physicalDescription">
    <!-- Physische Beschreibung -->
    <xsl:if test="pica:datafield[@tag = '034D' or @tag = '034I' or @tag = '034M']">
      <mods:physicalDescription>
        <xsl:for-each select="pica:datafield[@tag = '034D' or @tag = '034I' or @tag = '034M']/pica:subfield[@code = 'a']">
          <mods:extent>
            <xsl:value-of select="."/>
          </mods:extent>
        </xsl:for-each>
      </mods:physicalDescription>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mods:person">
    <xsl:param name="personRole"/>

    <mods:name>
      <xsl:if test="pica:subfield[@code = '9']">
        <xsl:call-template name="add-proxy-valueURI"/>
        <xsl:choose>
          <xsl:when test="document(concat($proxyBaseUrl, pica:subfield[@code = '9'], '.xml'))/pica:record/pica:datafield[@tag = '002@'][starts-with(pica:subfield[@code = '0'], 'Tp')]">
            <xsl:attribute name="type">personal</xsl:attribute>
          </xsl:when>
          <xsl:when test="document(concat($proxyBaseUrl, pica:subfield[@code = '9'], '.xml'))/pica:record/pica:datafield[@tag = '002@'][starts-with(pica:subfield[@code = '0'], 'Tb')]">
            <xsl:attribute name="type">corporate</xsl:attribute>
          </xsl:when>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="pica:subfield[@code = 'a']">
        <mods:namePart type="family">
          <xsl:value-of select="pica:subfield[@code = 'a']"/>
        </mods:namePart>
      </xsl:if>
      <xsl:if test="pica:subfield[@code = 'd']">
        <mods:namePart type="given">
          <xsl:value-of select="pica:subfield[@code = 'd']"/>
        </mods:namePart>
      </xsl:if>
      <xsl:if test="pica:subfield[@code = 'h']">
        <mods:namePart type="date">
          <xsl:value-of select="pica:subfield[@code = 'h']"/>
        </mods:namePart>
      </xsl:if>
      <xsl:if test="pica:subfield[@code = 'l']">
        <mods:namePart type="termsOfAddress">
          <xsl:value-of select="pica:subfield[@code = 'l']"/>
        </mods:namePart>
      </xsl:if>
      <mods:displayForm>
        <xsl:choose>
          <xsl:when test="pica:subfield[@code = '8']">
            <xsl:value-of select="pica:subfield[@code = '8']"/>
          </xsl:when>
          <xsl:when test="pica:subfield[@code = 'a'] and pica:subfield[@code = 'd']">
            <xsl:value-of select="concat(pica:subfield[@code = 'd'], ', ', pica:subfield[@code = 'a'])"/>
          </xsl:when>
          <xsl:when test="pica:subfield[@code = 'a'] or pica:subfield[@code = 'd']">
            <xsl:value-of select="concat(pica:subfield[@code = 'a'], pica:subfield[@code = 'd'])"/>
          </xsl:when>
        </xsl:choose>
      </mods:displayForm>
      <mods:role>
        <mods:roleTerm authority="marcrelator" type="code" valueURI="http://id.loc.gov/vocabulary/relators/{$personRole}">
          <xsl:value-of select="$personRole"/>
        </mods:roleTerm>
      </mods:role>
    </mods:name>

  </xsl:template>

  <xsl:template name="mods:recordInfo">
    <mods:recordInfo>
      <mods:recordIdentifier source="DE-23">
        <xsl:value-of select="pica:datafield[@tag = '003@']/pica:subfield[@code = '0']"/>
      </mods:recordIdentifier>
      <mods:recordOrigin xml:lang="en" >Converted from PICA using a local XSL transformation script</mods:recordOrigin>
      <mods:recordContentSource authority="marcorg">DE-23</mods:recordContentSource>
    </mods:recordInfo>
  </xsl:template>

  <xsl:template name="add-proxy-valueURI">
    <xsl:if test="pica:subfield[@code = '9']">
      <xsl:variable name="valueURI">
        <xsl:choose>
          <xsl:when test="document(concat($proxyBaseUrl, pica:subfield[@code = '9'], '.rdf'))/rdf:RDF/*/owl:sameAs[starts-with(@rdf:resource, 'http://d-nb.info/gnd')]">
            <xsl:value-of select="document(concat($proxyBaseUrl, pica:subfield[@code = '9'], '.rdf'))/rdf:RDF/*/owl:sameAs[starts-with(@rdf:resource, 'http://d-nb.info/gnd')]/@rdf:resource"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($proxyBaseUrl, pica:subfield[@code = '9'])"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="valueURI">
        <xsl:value-of select="$valueURI"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:transform>
