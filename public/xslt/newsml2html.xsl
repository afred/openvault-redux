<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:newsml="http://iptc.org/std/nar/2006-10-01/"
        xmlns:smil="http://www.w3.org/2001/SMIL20/Language">

<xsl:template match="/">
<div class="log">
	<xsl:apply-templates select="//newsml:partMeta"/>
<xsl:text> </xsl:text>
</div>
</xsl:template>

<xsl:template match="newsml:partMeta">
<p>
<xsl:attribute name="xml:id"><xsl:value-of select="@partid" /></xsl:attribute>
	<xsl:apply-templates select="newsml:timeDelim" />
	<xsl:apply-templates select="newsml:description" />
</p>
</xsl:template>

<xsl:template match="newsml:timeDelim">
<b><xsl:value-of select="@start" />: </b>
</xsl:template>

<xsl:template match="newsml:description">
	<xsl:value-of select="." />
</xsl:template>

 <xsl:template match="text()" />
</xsl:stylesheet>
