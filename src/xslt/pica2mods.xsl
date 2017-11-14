<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="2.0"
               exclude-result-prefixes="#all"
               xpath-default-namespace="info:srw/schema/5/picaXML-v1.0"
               xmlns:mods="http://www.loc.gov/mods/v3"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0"
               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:skos="http://www.w3.org/2004/02/skos/core#"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" indent="yes" encoding="utf-8"/>

  <xsl:template match="record">
    <xsl:variable name="type" select="pica:type(.)"/>
    <mods:mods>

      <xsl:choose>
        <xsl:when test="$type = 'j'">
          <xsl:copy-of select="mods:titleInfo(datafield[@tag = '021B'], ())"/>
        </xsl:when>
        <!-- Dieser Fall ist noch nicht abgedeckt! Titel steht im übergeordneten Datensatz! -->
        <xsl:when test="$type = 'f' and not(datafield[@tag = '021A']) and datafield[@tag = '036D']"/>
        <xsl:when test="datafield[@tag = '021A']">
          <xsl:copy-of select="mods:titleInfo(datafield[@tag = '021A'], ())"/>
        </xsl:when>
      </xsl:choose>

      <xsl:apply-templates/>

      <!-- Physische Beschreibung -->
      <xsl:if test="datafield[@tag = '034D' or @tag = '034I' or @tag = '034M']">
        <mods:physicalDescription>
          <xsl:for-each select="datafield[@tag = '034D' or @tag = '034I' or @tag = '034M']">
            <mods:extent>
              <xsl:value-of select="subfield[@code = 'a']" separator="; "/>
            </mods:extent>
          </xsl:for-each>
        </mods:physicalDescription>
      </xsl:if>

      <!-- Erstveröffentlichung -->
      <xsl:if test="datafield[@tag = '011@' or @tag = '033A']">
        <mods:originInfo>
          <xsl:if test="datafield[@tag = '033A']">
            <xsl:for-each select="distinct-values(datafield[@tag = '033A']/subfield[@code = 'p'])">
              <mods:place>
                <mods:placeTerm type="text">
                  <xsl:value-of select="."/>
                </mods:placeTerm>
              </mods:place>
            </xsl:for-each>
            <xsl:for-each select="distinct-values(datafield[@tag = '033A']/subfield[@code = 'n'])">
              <mods:publisher>
                <xsl:value-of select="."/>
              </mods:publisher>
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="datafield[@tag = '011@']/subfield[@code = 'a']">
            <mods:dateIssued keyDate="yes" encoding="iso8601">
              <xsl:value-of select="datafield[@tag = '011@']/subfield[@code = 'a'][1]"/>
            </mods:dateIssued>
          </xsl:if>
        </mods:originInfo>
      </xsl:if>

      <!-- Digitalisat und Vorlage -->
      <xsl:if test="datafield[@tag = '009A']">
        <mods:originInfo>
          <xsl:if test="datafield[@tag = '011B']/subfield[@code = 'a']">
            <mods:dateCaptured encoding="iso8601">
              <xsl:value-of select="datafield[@tag = '011B']/subfield[@code = 'a'][1]"/>
            </mods:dateCaptured>
          </xsl:if>
          <mods:publisher>
            <xsl:value-of select="datafield[@tag = '009A']/subfield[@code = 'c'][1]"/>
          </mods:publisher>
          <mods:edition>[Electronic ed.]</mods:edition>
        </mods:originInfo>
        <xsl:if test="datafield[@tag = '009A']/subfield[@code = 'a']">
          <mods:relatedItem type="original">
            <mods:location>
              <mods:physicalLocation authority="marcorg">DE-23</mods:physicalLocation>
              <mods:shelfLocator>
                <xsl:value-of select="datafield[@tag = '009A']/subfield[@code = 'a'][1]"/>
              </mods:shelfLocator>
            </mods:location>
          </mods:relatedItem>
        </xsl:if>
      </xsl:if>

      <xsl:apply-templates select="datafield[@tag = '039D']"/>

      <!-- Informationen über den Datensatz -->
      <mods:recordInfo>
        <mods:recordIdentifier source="DE-23">
          <xsl:value-of select="datafield[@tag = '003@']/subfield[@code = '0'][1]"/>
        </mods:recordIdentifier>
        <mods:recordOrigin xml:lang="en" >Converted from PICA using a local XSL transformation script</mods:recordOrigin>
        <mods:recordContentSource authority="marcorg" >DE-23</mods:recordContentSource>
      </mods:recordInfo>
    </mods:mods>
  </xsl:template>

  <!-- Signatur -->
  <xsl:template match="datafield[@tag = '209A']">
    <xsl:if test="subfield[@code = 'd'] != 'z'">
      <mods:location>
        <mods:physicalLocation authority="marcorg">DE-23</mods:physicalLocation>
        <mods:shelfLocator>
          <xsl:value-of select="subfield[@code = 'a']"/>
        </mods:shelfLocator>
      </mods:location>
    </xsl:if>
  </xsl:template>

  <!-- Identifikatoren -->
  <xsl:template match="datafield[@tag = '004U']/subfield[@code = '0']">
    <mods:identifier type="urn"><xsl:value-of select="."/></mods:identifier>
  </xsl:template>

  <xsl:template match="datafield[@tag = '007P']/subfield[@code = '0']">
    <mods:identifier type="fingerprint"><xsl:value-of select="."/></mods:identifier>
  </xsl:template>

  <xsl:template match="datafield[@tag = '004A']/subfield[@code = 'A' or @code = '0']">
    <mods:identifier type="isbn"><xsl:value-of select="."/></mods:identifier>
  </xsl:template>

  <xsl:template match="datafield[@tag = '006M']/subfield[@code = '0']">
    <mods:identifier type="vd18"><xsl:value-of select="substring-after(., 'VD18 ')"/></mods:identifier>
  </xsl:template>

  <xsl:template match="datafield[@tag = '007S']/subfield[@code = '0']">
    <xsl:choose>
      <xsl:when test="starts-with(., 'VD17 ') and not(../datafield[@tag = '006W'])">
        <mods:identifier type="vd17"><xsl:value-of select="substring-after(., 'VD17 ')"/></mods:identifier>
      </xsl:when>
      <xsl:when test="starts-with(., 'VD16 ')">
        <mods:identifier type="vd16"><xsl:value-of select="substring-after(., 'VD16 ')"/></mods:identifier>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="datafield[@tag = '009P'][@occurrence = '03']/subfield[@code = 'a']">
    <xsl:if test="starts-with(., 'http://diglib.hab.de')">
      <mods:identifier type="purl"><xsl:value-of select="."/></mods:identifier>
    </xsl:if>
  </xsl:template>

  <!-- Personen -->
  <!-- Verfasser -->
  <xsl:template match="datafield[@tag = '028A' or @tag = '028B']">
    <xsl:copy-of select="mods:person(., 'aut')"/>
  </xsl:template>

  <!-- Drucker, Verleger, oder Buchhändler bei alten Drucken -->
  <xsl:template match="datafield[@tag='033J']">
    <xsl:copy-of select="mods:person(., 'prt')"/>
  </xsl:template>

  <!-- Gefeierte Person -->
  <xsl:template match="datafield[@tag='028F']">
    <xsl:copy-of select="mods:person(., 'hnf')"/>
  </xsl:template>

  <!-- Sonstige nicht beteiligte Personen -->
  <xsl:template match="datafield[@tag='028G']">
    <xsl:copy-of select="mods:person(., 'asn')"/>
  </xsl:template>

  <!-- Konkurrenzverfasser -->
  <xsl:template match="datafield[@tag='028M']">
    <xsl:copy-of select="mods:person(., 'oth')"/>
  </xsl:template>

  <!-- Widmungsempfänger -->
  <xsl:template match="datafield[@tag='028L'][not(@occurrence)]">
    <xsl:copy-of select="mods:person(., 'dte')"/>
  </xsl:template>

  <!-- Zensor -->
  <xsl:template match="datafield[@tag='028L'][@occurrence = '01']">
    <xsl:copy-of select="mods:person(., 'cns')"/>
  </xsl:template>

  <!-- literarische/künstlerische/musikalische Beiträger -->
  <xsl:template match="datafield[@tag='028L'][@occurrence = '02']">
    <xsl:copy-of select="mods:person(., 'clb')"/>
  </xsl:template>

  <!-- Sonstige beteiligte Personen -->
  <xsl:template match="datafield[@tag='028C' or @tag='028D']">
    <xsl:copy-of select="mods:person(., 'oth')"/>
  </xsl:template>

  <!-- Sonstige nichtbeteiligte bzw. im Sachtitel genannte Personen -->
  <xsl:template match="datafield[@tag='028L'][@occurrence = '03']">
    <xsl:copy-of select="mods:person(., 'asn')"/>
  </xsl:template>

  <xsl:function name="mods:person" as="element(mods:name)">
    <xsl:param name="field" as="element(datafield)"/>
    <xsl:param name="role"  as="xsd:string"/>
    <mods:name type="{if (starts-with($field/subfield[@code = 'M'], 'Tb')) then 'corporate' else 'personal'}">
      <xsl:if test="$field/subfield[@code = '0'][starts-with(., 'gnd/')]">
        <xsl:attribute name="valueURI" select="concat('http://d-nb.info/', $field/subfield[@code = '0'][starts-with(., 'gnd/')][1])"/>
      </xsl:if>
      <xsl:if test="$field/subfield[@code = 'a']">
        <mods:namePart type="family">
          <xsl:value-of select="$field/subfield[@code = 'a'][1]"/>
        </mods:namePart>
      </xsl:if>
      <xsl:if test="$field/subfield[@code = 'd']">
        <mods:namePart type="given">
          <xsl:value-of select="$field/subfield[@code = 'd'][1]"/>
        </mods:namePart>
      </xsl:if>
      <xsl:if test="$field/subfield[@code = 'h']">
        <mods:namePart type="date">
          <xsl:value-of select="$field/subfield[@code = 'h'][1]"/>
        </mods:namePart>
      </xsl:if>
      <xsl:if test="$field/subfield[@code = 'l']">
        <mods:namePart type="termsOfAddress">
          <xsl:value-of select="$field/subfield[@code = 'l'][1]"/>
        </mods:namePart>
      </xsl:if>
      <mods:displayForm>
        <xsl:choose>
          <xsl:when test="$field/subfield[@code = '8']">
            <xsl:value-of select="$field/subfield[@code = '8'][1]"/>
          </xsl:when>
          <xsl:when test="$field/subfield[@code = 'a' or @code = 'd']">
            <xsl:value-of select="($field/subfield[@code = 'a'][1], $field/subfield[@code = 'd'][1])"
                          separator=", "/>
          </xsl:when>
          <xsl:when test="$field/subfield[@code = 'P']">
            <xsl:value-of select="$field/subfield[@code = 'P']"/>
          </xsl:when>
          <xsl:otherwise>N.N.</xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$field/subfield[@code = 'l']">
          <xsl:value-of select="concat(' &lt;', $field/subfield[@code = 'l'][1], '&gt;')"/>
        </xsl:if>
        <xsl:if test="$field/subfield[@code = 'h']">
          <xsl:value-of select="concat(', ', $field/subfield[@code = 'h'][1])"/>
        </xsl:if>
      </mods:displayForm>
      <mods:role>
        <mods:roleTerm authority="marcrelator" type="code" valueURI="http://id.loc.gov/vocabulary/relators/{$role}">
          <xsl:value-of select="$role"/>
        </mods:roleTerm>
      </mods:role>
    </mods:name>
  </xsl:function>

  <!-- Titel -->
  <!-- Einheitssachtitel -->
  <xsl:template match="datafield[@tag = '022A'][@occurrence = '01']">
    <xsl:copy-of select="mods:titleInfo(., 'uniform')"/>
  </xsl:template>

  <!-- Weitere Sachtitel -->
  <xsl:template match="datafield[@tag = '027A']">
    <xsl:copy-of select="mods:titleInfo(., 'alternative')"/>
  </xsl:template>

  <!-- Titel in Bandsätzen und Aufsätzen (für die Anzeige usw.) -->
  <xsl:template match="datafield[@tag = '027D']">
    <xsl:copy-of select="mods:titleInfo(., 'alternative')"/>
  </xsl:template>

  <!-- Normierter Zeitschriftenkurztitel b- und d-Sätze -->
  <xsl:template match="datafield[@tag = '026C']">
    <xsl:variable name="type" select="pica:type(..)"/>
    <xsl:if test="$type = 'b' or $type = 'd'">
      <xsl:copy-of select="mods:titleInfo(., 'abbreviated')"/>
    </xsl:if>
  </xsl:template>

  <xsl:function name="mods:titleInfo" as="element(mods:titleInfo)">
    <xsl:param name="datafield" as="element()"/>
    <xsl:param name="mods:type" as="xsd:string?" />
    <mods:titleInfo>
      <xsl:if test="$mods:type"><xsl:attribute name="type" select="$mods:type"/></xsl:if>
      <xsl:choose>
        <xsl:when test="contains($datafield/subfield[@code = 'a'], '@')">
          <mods:nonSort><xsl:value-of select="substring-before($datafield/subfield[@code = 'a'], '@')"/></mods:nonSort>
          <mods:title><xsl:value-of select="substring-after($datafield/subfield[@code = 'a'], '@')"/></mods:title>
        </xsl:when>
        <xsl:otherwise>
          <mods:title><xsl:value-of select="$datafield/subfield[@code = 'a']"/></mods:title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$datafield/subfield[@code = 'd']">
        <mods:subTitle><xsl:value-of select="$datafield/subfield[@code = 'd']"/></mods:subTitle>
      </xsl:if>
    </mods:titleInfo>
  </xsl:function>

  <!-- RSWK Schlagwörter -->
  <xsl:template match="datafield[@tag = '044K'][subfield[@code = '0'][starts-with(., 'gnd/')]]">
    <xsl:variable name="content">
      <xsl:choose>
        <xsl:when test="starts-with(subfield[@code = 'M'], 'Tp') or starts-with(subfield[@code = 'M'], 'Tb')">
          <xsl:value-of select="mods:person(., 'oth')//mods:displayForm"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="subfield[@code = 'a'][1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="normalize-space($content)">
      <mods:subject authority="gnd">
        <mods:topic valueURI="http://d-nb.info/{subfield[@code = '0'][starts-with(., 'gnd/')]}">
          <xsl:value-of select="$content"/>
        </mods:topic>
      </mods:subject>
    </xsl:if>
  </xsl:template>

  <xsl:template match="datafield[@tag = '044K'][subfield[@code = 'a']]" priority="-1">
    <mods:subject>
      <mods:topic>
        <xsl:value-of select="subfield[@code = 'a']"/>
      </mods:topic>
    </mods:subject>
  </xsl:template>

  <!-- AAD Gattungsbegriffe -->
  <xsl:template match="datafield[@tag = '044S']">
    <mods:genre authority="aad">
      <xsl:value-of select="subfield[@code = 'a'][1]"/>
    </mods:genre>
  </xsl:template>

  <!-- Fachgruppen der Sammlung Deutscher Drucke -->
  <xsl:template match="datafield[@tag = '145Z']/subfield[@code = 'a'][matches(., '^\d\d$')]">
    <xsl:variable name="valueURI" select="concat('http://uri.hab.de/vocab/sdd-fachgruppen#fg', .)"/>
    <xsl:variable name="concept" select="skos:resolve-concept($valueURI)"/>
    <mods:classification authorityURI="http://uri.hab.de/vocab/sdd-fachgruppen" valueURI="{$valueURI}" displayLabel="SDD Fachgruppen">
      <xsl:value-of select="skos:resolve-label($concept, 'de')"/>
    </mods:classification>
  </xsl:template>

  <!-- Klassifikation der Barocknachrichten -->
  <xsl:template match="datafield[@tag = '145Z']/subfield[@code = 'a'][matches(., '^BAROCK \d\d -')]">
    <xsl:variable name="valueURI" select="concat('http://uri.hab.de/vocab/barock#b', tokenize(., ' ')[2])"/>
    <mods:classification authorityURI="http://uri.hab.de/vocab/barock" valueURI="{$valueURI}" displayLabel="BAROCK Klassifikation">
      <xsl:value-of select="substring-after(., ' - ')"/>
    </mods:classification>
  </xsl:template>

  <!-- Sprachcodes -->
  <xsl:template match="datafield[@tag = '010@']">
    <mods:language>
      <xsl:for-each select="subfield[@code = 'a']">
        <mods:languageTerm type="code" authority="iso639-2b">
          <xsl:value-of select="."/>
        </mods:languageTerm>
      </xsl:for-each>
    </mods:language>
  </xsl:template>

  <!-- Bemerkung -->
  <xsl:template match="datafield[@tag='037A']">
    <mods:note><xsl:value-of select="subfield[@code='a']" separator="; "/></mods:note>
  </xsl:template>

  <!-- Horizontale Verknüpfungen -->
  <xsl:template match="datafield[@tag = '039D']">
    <mods:relatedItem>
      <xsl:choose>
        <xsl:when test="subfield[@code = 'c'] = ('Online-Ausg.', 'Druckausg.')">
          <xsl:attribute name="type">otherFormat</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <mods:recordInfo>
        <mods:recordIdentifier>
          <xsl:value-of select="(subfield[@code = 'C'], subfield[@code = '6'])"/>
        </mods:recordIdentifier>
      </mods:recordInfo>
    </mods:relatedItem>
  </xsl:template>

  <xsl:function name="pica:type" as="xsd:string">
    <xsl:param name="record" as="element(record)"/>
    <xsl:value-of select="substring($record/datafield[@tag = '002@']/subfield[@code = '0'], 2, 1)"/>
  </xsl:function>

  <xsl:function name="skos:resolve-label" as="element(skos:prefLabel)">
    <xsl:param name="entity" as="element()"/>
    <xsl:param name="language" as="xsd:string"/>
    <xsl:copy-of select="($entity/skos:prefLabel[@xml:lang = $language], $entity/skos:prefLabel[@xml:lang != $language])[1]"/>
  </xsl:function>

  <xsl:function name="skos:resolve-concept" as="element(skos:Concept)">
    <xsl:param name="uri" as="xsd:string"/>
    <xsl:variable name="documentUri" as="xsd:string" select="if (contains($uri, '#')) then substring-before($uri, '#') else $uri"/>
    <xsl:copy-of select="document($documentUri)//skos:Concept[@rdf:about = $uri]"/>
  </xsl:function>

  <xsl:template match="text()"/>

</xsl:transform>
