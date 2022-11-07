<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:ext="http://docbook.org/extensions/xslt"
                xmlns:f="http://docbook.org/extensions/getting-started"
                xmlns:m="http://docbook.org/ns/docbook/modes"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:v="http://docbook.org/ns/docbook/variables"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="3.0">


<xsl:variable name="v:templates" as="document-node()">
  <xsl:document>
    <db:book xmlns:tmp="http://docbook.org/ns/docbook/templates">
      <header>
        <tmp:apply-templates select="db:title">
          <h1><tmp:content/></h1>
        </tmp:apply-templates>
        <tmp:apply-templates select="db:subtitle">
          <h2><tmp:content/></h2>
        </tmp:apply-templates>
        <tmp:apply-templates select="db:author">
          <div class="author">
            <h3><tmp:content/></h3>
          </div>
        </tmp:apply-templates>
        <tmp:apply-templates select="db:pubdate">
          <p class="pubdate"><tmp:content/></p>
        </tmp:apply-templates>
        <tmp:apply-templates select="db:legalnotice"/>
        <tmp:apply-templates select="db:abstract"/>
        <tmp:apply-templates select="db:copyright"/>
        <details>
          <summary>Revision history</summary>
          <tmp:apply-templates select="db:revhistory"/>
        </details>
      </header>
    </db:book>
  </xsl:document>
</xsl:variable>

<xsl:template match="db:caption" mode="m:docbook">
  <!-- If the caption turns out to be completely empty, discard it. -->
  <xsl:variable name="caption">
    <xsl:next-match/>
  </xsl:variable>

  <xsl:if test="normalize-space(string($caption)) != ''">
    <xsl:sequence select="$caption"/>
  </xsl:if>
</xsl:template>

<xsl:template match="processing-instruction('image-metadata-details')"
              mode="m:docbook">

  <xsl:variable name="uris" select="ancestor::db:mediaobject//@fileref ! string(.)"/>
  <!-- prefer jpg over other types, they have the most metadata usually -->
  <xsl:variable name="uri"
                select="resolve-uri(($uris[ends-with(., '.jpg')],
                                     $uris[ends-with(., '.jpeg')],
                                     $uris[not(ends-with(., '.svg'))],
                                     $uris)[1], base-uri(.))"/>

  <xsl:message select="'Extracting metadata from ' || $uri"/>

  <xsl:variable name="properties" as="map(xs:string, xs:anyAtomicType)"
                use-when="function-available('ext:image-metadata')">
    <xsl:sequence select="ext:image-metadata($uri)"/>
  </xsl:variable>
  <xsl:variable name="properties" as="map(xs:string, xs:anyAtomicType)"
                use-when="not(function-available('ext:image-metadata'))">
    <xsl:message select="'Image metadata extension function is not available.'"/>
    <xsl:sequence select="map {}"/>
  </xsl:variable>

  <!-- These properties work for this particular image, YMMV. -->
  <xsl:variable name="camera" as="xs:string?" select="$properties?model"/>

  <xsl:variable name="date" as="xs:dateTime?"
                select="if (map:get($properties, 'date/time-digitized')
                                    castable as xs:dateTime)
                        then xs:dateTime(map:get($properties, 'date/time-digitized'))
                        else ()"/>
  <xsl:variable name="location" as="xs:string?"
                select="f:reverse-geocode($properties)"/>

  <xsl:if test="exists($camera) or exists($date) or exists($location)">
    <xsl:sequence select="'Taken'"/>
    <xsl:if test="exists($camera)">
      <xsl:sequence select="' with the ' || $camera"/>
    </xsl:if>
    <xsl:if test="exists($date)">
      <xsl:sequence select="' on ' || format-dateTime($date, '[D01] [MNn,*-3] [Y0001]')"/>
    </xsl:if>
    <xsl:if test="exists($location)">
      <xsl:sequence select="' in ' || $location"/>
    </xsl:if>
    <xsl:sequence select="."/>
  </xsl:if>
</xsl:template>

<xsl:function name="f:reverse-geocode" as="xs:string?">
  <xsl:param name="properties" as="map(*)"/>
  <xsl:if test="$properties?gps-latitude and $properties?gps-longitude">
    <xsl:variable name="lat" select="f:gps($properties?gps-latitude)"/>
    <xsl:variable name="long" select="f:gps($properties?gps-longitude)"/>
    <xsl:if test="exists($lat) and exists($long)">
      <xsl:try>
        <xsl:variable name="geocode"
                      select="doc('https://nominatim.openstreetmap.org/reverse?lat='
                                  || $lat || '&amp;lon=' || $long)"/>
        <xsl:variable name="city" select="$geocode/reversegeocode/addressparts/city"/>
        <xsl:variable name="country" select="$geocode/reversegeocode/addressparts/country"/>
        <xsl:variable name="state" select="$geocode/reversegeocode/addressparts/state"/>
        <xsl:choose>
          <xsl:when test="$country = 'United States'">
            <xsl:sequence select="$city || ', ' || $state || ', ' || $country"/>
          </xsl:when>
          <xsl:when test="$city and $country">
            <xsl:sequence select="$city || ', ' || $country"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="()"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:catch errors="*">
          <xsl:sequence select="()"/>
        </xsl:catch>
      </xsl:try>
    </xsl:if>
  </xsl:if>
</xsl:function>

<xsl:function name="f:gps" as="xs:double?">
  <xsl:param name="dms" as="xs:string?"/>
  <xsl:if test="exists($dms)">
    <!-- expecting something like 51° 36' 48.07 -->
    <xsl:try>
      <xsl:variable name="part"
                    select="tokenize($dms, '[\s°''&quot;]+') ! xs:double(.)"/>
      <xsl:sequence select="(abs($part[1]) + ($part[2] div 60.0) + ($part[3] div 3600.0))
                             * (if ($part[1] lt 0) then -1 else +1)"/>
      <xsl:catch errors="*">
        <xsl:message select="'Failed to parse GPS DMS: ' || $dms"/>
        <xsl:sequence select="()"/>
      </xsl:catch>
    </xsl:try>
  </xsl:if>
</xsl:function>

</xsl:stylesheet>
