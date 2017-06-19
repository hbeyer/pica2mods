<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0"
               xmlns:hab="http://diglib.hab.de/wdb">

  <!-- Liste üblicher Rollen -->
  <hab:roleterms>
    <hab:roleterm pica="Adressat" label="Recipient" marc="rcp"/>
    <hab:roleterm pica="angebl. Hrsg." label="Other" marc="oth"/> <!-- keine Entsprechung im zvdd MODS Anwendungsprofil 1.0 -->
    <hab:roleterm pica="mutmassl. Hrsg." label="Other" marc="oth"/> <!-- keine Entsprechung im zvdd MODS Anwendungsprofil 1.0 -->
    <hab:roleterm pica="Komm." label="Commentator" marc="cwt"/>
    <hab:roleterm pica="Stecher" label="Engraver" marc="egr"/>
    <hab:roleterm pica="angebl. Übers." label="Other" marc="oth"/> <!-- keine Entsprechung im zvdd MODS Anwendungsprofil 1.0 -->
    <hab:roleterm pica="mutmassl. Übers." label="Other" marc="oth"/> <!-- keine Entsprechung im zvdd MODS Anwendungsprofil 1.0 -->
    <hab:roleterm pica="angebl. Verf." label="Dubious author" marc="dub"/>
    <hab:roleterm pica="mutmassl. Verf." label="Attributed name" marc="att"/>
    <hab:roleterm pica="Verstorb." label="Other" marc="oth"/> <!-- keine Entsprechung im zvdd MODS Anwendungsprofil 1.0 -->
    <hab:roleterm pica="Zeichner" label="Illustrator" marc="ill"/>
    <hab:roleterm pica="Widmungsempfänger" label="Dedicatee" marc="dte"/>
    <!-- RAK-WB §185,2 -->
    <hab:roleterm pica="Bearb." label="Other" marc="oth"/>
    <hab:roleterm pica="Begr." label="Antecedent" marc="ant"/>
    <hab:roleterm pica="Hrsg." label="Editor" marc="edt"/>
    <hab:roleterm pica="Ill." label="Illustrator" marc="ill"/>
    <hab:roleterm pica="Komp." label="Composer" marc="cmp"/>
    <hab:roleterm pica="Mitarb." label="Contributor" marc="ctb"/>
    <hab:roleterm pica="Red." label="Compiler" marc="com"/>
    <hab:roleterm pica="Übers." label="Translator" marc="trl"/>
    <hab:roleterm label="Associated name" marc="asn"/>
    <hab:roleterm label="Printer" marc="prt"/>
  </hab:roleterms>

  <!-- Name für formatierendes Template normalisieren -->
  <xsl:template name="pica:person">
    <xsl:param name="person-role" select="'oth'"/>
    <xsl:variable name="person-name-family" select="pica:subfield[@code='a'][1]"/>
    <xsl:variable name="person-name-given" select="pica:subfield[@code='d'][1]"/>
    <xsl:variable name="person-name-prefix" select="pica:subfield[@code='c'][1]"/>
    <xsl:variable name="person-name-byname" select="pica:subfield[@code='l'][1]"/>
    <xsl:variable name="person-name-personal" select="pica:subfield[@code='P' or @code='5'][1]"/>
    <xsl:variable name="person-name-display">
      <xsl:choose>
        <xsl:when test="pica:subfield[@code='8']"><xsl:value-of select="pica:subfield[@code='8']"/></xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$person-name-given and $person-name-family">
              <xsl:value-of select="$person-name-family"/>, <xsl:value-of select="$person-name-given"/>
              <xsl:text/>
              <xsl:if test="$person-name-byname"> &lt;<xsl:value-of select="$person-name-byname"/>&gt;</xsl:if>
              <xsl:text/>
            </xsl:when>
            <xsl:when test="not($person-name-given) and not($person-name-family)">
              <xsl:value-of select="$person-name-personal"/>
              <xsl:text/>
              <xsl:if test="$person-name-byname"> &lt;<xsl:value-of select="$person-name-byname"/>&gt;</xsl:if>
              <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$person-name-family"/><xsl:value-of select="$person-name-given"/>
              <xsl:text/>
              <xsl:if test="$person-name-byname"> &lt;<xsl:value-of select="$person-name-byname"/>&gt;</xsl:if>
              <xsl:text/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="person-type">
      <xsl:choose>
        <xsl:when test="pica:subfield[@code = '9'] and substring(pica:subfield[@code='M'], 2, 1) = 'b'">
          <xsl:text>corporate</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>personal</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$person-name-display != ''">
      <xsl:call-template name="person">
        <xsl:with-param name="person-name-family" select="$person-name-family"/>
        <xsl:with-param name="person-name-given" select="$person-name-given"/>
        <xsl:with-param name="person-name-prefix" select="$person-name-prefix"/>
        <xsl:with-param name="person-name-byname" select="$person-name-byname"/>
        <xsl:with-param name="person-name-personal" select="$person-name-personal"/>
        <xsl:with-param name="person-name-display" select="$person-name-display"/>
        <xsl:with-param name="person-role" select="$person-role"/>
        <!-- !! Seit 05/2011 undokumentierte Ausgabe von unAPI & Co, anstelle der Expansion $8 -->
        <xsl:with-param name="person-value-uri">
          <xsl:if test="pica:subfield[@code='0']">
            <xsl:text>http://d-nb.info/</xsl:text><xsl:value-of select="pica:subfield[@code='0']"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="person-type" select="$person-type"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Verfasser -->
  <xsl:template match="pica:datafield[@tag='028A' or @tag='028B']" mode="person">
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'aut'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Drucker, Verleger, oder Buchhändler bei alten Drucken -->
  <xsl:template match="pica:datafield[@tag='033J']" mode="person">
    <!-- !! Seit 05/2011 undokumentierte Ausgabe von unAPI & Co, anstelle der Expansion $8 -->
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'prt'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Gefeierte Person -->
  <xsl:template match="pica:datafield[@tag='028F']" mode="person">
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'hnf'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Sonstige nicht beteiligte Personen -->
  <xsl:template match="pica:datafield[@tag='028G']" mode="person">
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'asn'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Konkurrenzverfasser -->
  <xsl:template match="pica:datafield[@tag='028M']" mode="person">
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'oth'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Widmungsempfänger -->
  <xsl:template match="pica:datafield[@tag='028L' and not(@occurrence)]" mode="person">
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'dte'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Zensor -->
  <xsl:template match="pica:datafield[@tag='028L' and @occurrence='01']" mode="person">
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'cns'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- literarische/künstlerische/musikalische Beiträger -->
  <xsl:template match="pica:datafield[@tag='028L' and @occurrence='02']" mode="person">
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'clb'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Sonstige beteiligte Personen -->
  <xsl:template match="pica:datafield[@tag='028C' or @tag='028D']" mode="person">
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'oth'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Sonstige nichtbeteiligte bzw. im Sachtitel genannte Personen -->
  <xsl:template match="pica:datafield[@tag='028L' and @occurrence='03']" mode="person">
    <xsl:call-template name="pica:person">
      <xsl:with-param name="person-role" select="'asn'"/>
    </xsl:call-template>
  </xsl:template>

</xsl:transform>
