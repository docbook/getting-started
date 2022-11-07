<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:db="http://docbook.org/ns/docbook"
                exclude-result-prefixes="#all"
                version="3.0">

<xsl:output method="xml" encoding="utf-8" indent="yes"
            omit-xml-declaration="yes"/>

<xsl:mode on-no-match="shallow-copy"/>

<xsl:template match="/">
  <xsl:apply-templates select="/*/db:info">
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:info">
  <xsl:element name="weblog" namespace="{namespace-uri(.)}">
    <xsl:attribute name="file" select="substring-after(base-uri(.), '/weblog/')"/>
    <xsl:apply-templates select="@*, node()"/>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
