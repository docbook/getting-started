<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:f="http://docbook.org/ns/docbook/functions"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:t="http://docbook.org/ns/docbook/templates"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="#all"
                version="3.0">

<!--
<xsl:import href="https://cdn.docbook.org/release/xsltng/current/xslt/docbook.xsl"/>
-->
<xsl:import href="../../../xslTNG/build/xslt/docbook.xsl"/>

<xsl:variable name="info" select="doc('../build/info.xml')/*"/>

<xsl:template match="processing-instruction('weblog-index')" mode="m:docbook">
  <xsl:variable name="max"
                select="xs:integer((f:pi(.,'max'),30)[1])"/>

  <xsl:variable name="skip"
                select="$info/db:weblog[db:bibliomisc[@role='index']='false']"/>

  <xsl:if test="not(empty($info/db:weblog except $skip))">
    <div class="weblogindex">
      <xsl:for-each select="$info/db:weblog except $skip[position() &lt;= $max]">
        <xsl:sort select="db:pubdate" order="descending"/>

        <div class="post">
          <div class="title">
            <xsl:value-of select="db:title"/>
          </div>
          <div class="pudate">
            <xsl:value-of select="format-dateTime(xs:dateTime(db:pubdate),
                                                  '[D01] [MNn,*-3] [Y0001]')"/>
          </div>
          <div class="abstract">
            <xsl:apply-templates select="db:abstract/node()"/>
          </div>
        </div>
      </xsl:for-each>
    </div>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
