<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:exf="http://exproc.org/standard/functions"
                exclude-inline-prefixes="cx exf"
                name="main">
<p:input port="parameters" kind="parameter"/>
<p:output port="result"/>
<p:serialization port="result" indent="true"/>

<p:import href="recursive-directory-listing.xpl"/>

<p:option name="src" required="true"/>

<cx:recursive-directory-list>
  <p:with-option name="path" select="concat('../', $src)"/>
</cx:recursive-directory-list>

<p:for-each name="loop">
  <p:iteration-source select="//c:file"/>
  <p:load>
    <p:with-option name="href"
                   select="resolve-uri(/*/@name, base-uri(.))"/>
  </p:load>
  <p:add-attribute match="/db:article/db:info"
                   attribute-name="file">
    <p:with-option name="attribute-value"
                   select="concat('src/',
                                  substring-after(
                                     resolve-uri(/*/@name, base-uri(.)),
                                     '/src/'))">
      <p:pipe step="loop" port="current"/>
    </p:with-option>
  </p:add-attribute>
</p:for-each>

<p:identity>
  <p:input port="source" select="/db:article/db:info"/>
</p:identity>

<p:wrap-sequence wrapper="article-info"
                 wrapper-namespace="http://docbook.org/ns/docbook"/>

</p:declare-step>
