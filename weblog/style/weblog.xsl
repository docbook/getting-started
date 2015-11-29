<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="f xs"
                version="2.0">

<xsl:import href="http://docbook.github.com/release/latest/xslt/base/html/final-pass.xsl"/>

<xsl:variable name="info" select="doc('../build/info.xml')/*"/>

<xsl:template match="processing-instruction('weblog-index')">
  <xsl:variable name="max"
                select="xs:integer((f:pi-attribute(.,'max'),30)[1])"/>

  <xsl:variable name="skip"
                select="$info/db:info[db:bibliomisc[@role='index']='false']"/>

  <xsl:variable name="list" as="element(db:info)*">
    <xsl:for-each select="$info/db:info except $skip">
      <xsl:sort select="db:pubdate" order="descending"/>
      <xsl:copy-of select="."/>
    </xsl:for-each>
  </xsl:variable>

  <xsl:if test="not(empty($list))">
    <div class="weblogindex">
      <xsl:for-each select="$list[position() &lt;= $max]">
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
