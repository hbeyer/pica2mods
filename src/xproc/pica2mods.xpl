<p:pipeline version="1.0" xmlns:p="http://www.w3.org/ns/xproc">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    Transform the PICA+ record on port <var>source</var> to a MODS record and validate the result.
  </p:documentation>

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="../xslt/pica2mods.xsl"/>
    </p:input>
  </p:xslt>

  <p:validate-with-xml-schema assert-valid="true">
    <p:input port="schema">
      <p:document href="../schema/mods.xsd"/>
    </p:input>
  </p:validate-with-xml-schema>

</p:pipeline>
