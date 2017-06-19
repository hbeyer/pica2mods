<?xml version="1.0" encoding="utf-8"?>
<xsl:transform version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:pica="info:srw/schema/5/picaXML-v1.0">

  <!-- j-Sätze
       ===
       "Die Kategorie 4004 [sc. 021B] kommt ausschließlich in j-Sätzen vor" (01KatRicht/4004.pdf, 08/2012)
  -->
  <xsl:template match="pica:datafield[@tag='021B']" mode="title">
    <xsl:call-template name="title">
      <xsl:with-param name="title" select="pica:subfield[@code='a'][1]"/>
      <xsl:with-param name="subtitle" select="pica:subfield[@code='d'][1]"/>
    </xsl:call-template>
  </xsl:template>

  <!-- f-Sätze ohne 021A
       ===
       Titel rekursiv über die übergeordneten Gesamtheit ermitteln
  -->
  <xsl:template match="pica:datafield[@tag='036D']" mode="title">
    <xsl:if test="not(../pica:datafield[@tag='021A'])">
      <xsl:variable name="superior" select="document(concat($unapi-template, pica:subfield[@code='9']))"/>
      <xsl:apply-templates select="$superior/pica:record" mode="title"/>
    </xsl:if>
  </xsl:template>

  <!-- Der Rest -->
  <xsl:template match="pica:datafield[@tag='021A']" mode="title">
    <xsl:variable name="record-type" select="substring(../pica:datafield[@tag='002@']/pica:subfield[@code='0'], 2, 1)"/>
    <xsl:if test="$record-type != 'j'">
      <xsl:call-template name="title">
        <xsl:with-param name="title">
          <xsl:choose>
            <xsl:when test="$record-type = 'f' and ../pica:datafield[@tag='036C']/pica:subfield[@code='a']">
              <xsl:value-of select="../pica:datafield[@tag='036C']/pica:subfield[@code='a']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="pica:subfield[@code='a']"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="subtitle" select="pica:subfield[@code='d']"/>
        <xsl:with-param name="author-statement" select="pica:subfield[@code='h']"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Weitere Sachtitel -->
  <xsl:template match="pica:datafield[@tag='027A']" mode="title">
    <xsl:call-template name="title">
      <xsl:with-param name="title" select="pica:subfield[@code='a'][1]"/>
      <xsl:with-param name="type" select="'alternative'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Ansetzungssachtitel -->
  <xsl:template match="pica:datafield[@tag='025@']" mode="title">
    <xsl:if test="pica:subfield[@code='a'][1]">
      <xsl:call-template name="title">
        <xsl:with-param name="title" select="pica:subfield[@code='a'][1]"/>
        <xsl:with-param name="type" select="'alternative'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Einheitssachtitel -->
  <xsl:template match="pica:datafield[@tag='022A' and @occurrence='01']" mode="title">
    <xsl:call-template name="title">
      <xsl:with-param name="title" select="pica:subfield[@code='a'][1]"/>
      <xsl:with-param name="type" select="'uniform'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Normierter Zeitschriftenkurztitel b- und d-Sätze -->
  <xsl:template match="pica:datafield[@tag='026C']" mode="title">
    <xsl:if test="contains('bd', substring(../pica:datafield[@tag='002@']/pica:subfield[@code='0'], 2, 1))">
      <xsl:call-template name="title">
        <xsl:with-param name="title" select="pica:subfield[@code='a'][1]"/>
        <xsl:with-param name="type" select="'abbreviated'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Titel in Bandsätzen und Aufsätzen (für die Anzeige usw.) -->
  <xsl:template match="pica:datafield[@tag='027D']" mode="title">
    <xsl:call-template name="title">
      <xsl:with-param name="title" select="pica:subfield[@code='a'][1]"/>
      <xsl:with-param name="subtitle" select="pica:subfield[@code='d'][1]"/>
      <xsl:with-param name="author-statement" select="pica:subfield[@code='h']"/>
    </xsl:call-template>
  </xsl:template>
</xsl:transform>
