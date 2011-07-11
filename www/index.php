
<!-- This is the project specific website template -->
<!-- It can be changed as liked or replaced by other content -->

<?php

$domain=ereg_replace('[^\.]*\.(.*)$','\1',$_SERVER['HTTP_HOST']);
$group_name=ereg_replace('([^\.]*)\..*$','\1',$_SERVER['HTTP_HOST']);
$themeroot='http://r-forge.r-project.org/themes/rforge/';

echo '<?xml version="1.0" encoding="UTF-8"?>';
?>
<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en   ">

  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title><?php echo $group_name; ?></title>
	<link href="<?php echo $themeroot; ?>styles/estilo1.css" rel="stylesheet" type="text/css" />
  </head>

<body>

<!-- R-Forge Logo -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr><td>
<a href="http://r-forge.r-project.org/"><img src="http://<?php echo $themeroot; ?>/images/logo.png" border="0" alt="R-Forge Logo" /> </a> </td> </tr>
</table>


<!-- get project title  -->
<!-- own website starts here, the following may be changed as you like -->

<?php if ($handle=fopen('http://'.$domain.'/export/projtitl.php?group_name='.$group_name,'r')){
$contents = '';
while (!feof($handle)) {
	$contents .= fread($handle, 8192);
}
fclose($handle);
echo $contents; } ?>

<!-- end of project description -->

<center><h1>Qhull in R</h1></center>
<br>
<p>
The geometry package intents to implement several geometry functions available in Octave and Matlab and
the like, available in <a href="http://web.archive.org/web/20080218222024/http://www.r-project.org/">R</a>. It merely ports those functions to R and makes available the qhull library (which also underlies the corresponding Matlab and Octave functions).
Currently only part of the qhull library is accessible and no specific class for a Delaunay triangulation is specified.
<p>
The geometry package also implements a simple technique to refine a given mesh and generate high quality meshes and surface triangulations. A description of the technique and a number of examples can be found at the site of its inventors <a href="http://web.archive.org/web/20080218222024/http://www-math.mit.edu/~persson/mesh/">Per-Olof Persson and Gilbert Strang</a>.
<p>
The Qhull library is documented online at <a href="http://web.archive.org/web/20080218222024/http://www.qhull.org/">www.qhull.org</a>

<p>
A <a href="http://web.archive.org/web/20080218222024/http://cran.at.r-project.org/src/contrib/geometry_0.0-2.tar.gz">gzipped tar-ball</a> with the sources, and a pre-compiled binary distribution for windows can be downloaded from CRAN. All original qhull sources are included in the distribution. The distribution is subject to <a href="http://web.archive.org/web/20080218222024/http://www.qhull.org/COPYING.txt">this license</a>. The non-qhull sources are subject to the GPL version 2 or higher. 

<br>
<h2>Using the Qhull options</h2>
<p>Qhull provides many options that you can use to your advantage. For instance you may request the volume of a convex hull and its surface area by specifying the 'FS' option. Currently the output is written to the console window, and cannot be accessed programmatically. However, Qhull has the option TO <em>filename</em> which can be used to write the output to a file which can then be parsed into R again. For instance, if you want to compute the volume of a convex hull of a set of points, if you have a matrix with 3 columns,

<span style="color:red;font-family: Courier;font-size: 10pt;"><br/>&gt; ps <- matrix(rnorm(30),,3);</span> <br/>

say, that might be something like

<span style="color:red;font-family: Courier;font-size: 10pt;"><br/>&gt; x = convhulln(ps,"FS TO 'bla.txt'"); # use of the 'TO filename' option</span><br/>

This command created the text file 'bla.txt' that contains the requested output (i.e. the output specified by the Qhull options). For the Qhull option FS this is the following: [<a href="http://web.archive.org/web/20080218222024/http://www.qhull.org/html/qh-optf.htm#FS">from the doc</a>] "The first line consists of the number of integers ("0"). The second line consists of the number of reals ("2"), followed by the total facet area, and the total volume. Later versions of Qhull may produce additional integers or reals."
You can then parse the text in the file according to your needs; in your case it will be something like

<span style="color:red;font-family: Courier;font-size: 10pt;"><br/>&gt; qh.outp <- scan('bla.txt ');
<br/>&gt; volume <- qh.outp[3];</span></br>

<h2>Wish list for future releases</h2>
<ul>
   <li> port __vonoroi__.cc
   <li> get rid of output to console in convhulln (specifying NULL as standard output
handle gives wrong result)
   <li> more self explaining interface for qhull options (?)
   <li> quiet error output
   <li> Implement in C/Fortran
   <li> Translate other functions of the matlab mesh package of
  Per-Olof Persson (http://www-math.mit.edu/~persson/mesh/)
   <li> n-D interpolation with Delaunay triangulation

</ul>

<h2>Contribute</h2>
If you have ideas for functions, or functions you made and think would be of
value to include in the geometry package (take into account that the package is called <code>geometry</code> and
restricts itself to functions directly related to computational geometry), you can e-mail me:
<code>rgrasman&nbsp;â�¢atâ�¢&nbsp;uva&nbsp;â�¢dotâ�¢&nbsp;nl</code>, or you can fill out the form below.
<br>
<!--center>
<form action="http://home.tiscali.nl/cgi-bin/mailform"
      method="POST"
      onsubmit="javascript:return(validmail());">
<input type="hidden" name="LINK" value="http://users.fmg.uva.nl/rgrasman/requestsent.html">
<script language="javascript">
    var INPUThiddenUSER
    = '<INPUT type="hidden" value="grasman' + String.fromCharCode(64) + 'psy.uva.nl" name="USER">\n'
      + '<input type="hidden" value="' + document.cookie + '" name="identity">'
   document.write(INPUThiddenUSER) ;
</script>
<table>
<tr><td>&nbsp;
<tr>
    <td> Sender: <td> <input type="text" size="65">
<tr>
    <td valign="top"> Comments: <td> <textarea rows="15" cols="50"> </textarea>
<tr>
    <td><td><input type="submit" value="submit">
</table>
</form>
</center-->

<br>

<style type='text/css'>
 /* met dit stylesheet is de opmaak van de vragen gemakkelijk aan te passen */

 .vraag            { border-style:none; border-width: 0px; border-color: black; margin: 2px;} /* bepaald de overall opmaak, inclusief de rand*/
 .vraagwrapper     { };                                                                        /* omsluit de vraag, nuttig voor bijvoorbeeld een tweede rand */
 .vraagrow1        { vertical-align : top; text-align: left;}                                  /* bepaald opmaak van de vraag tekst*/
 .vraagresponsen   { text-align: left;}                                                        /* opmaak van de respons-regel */
 .vraagtable       { border-style: none; }                                                     /* opmaak van de table (iedere vraag staat in een table) */
 .SQWtd            { height: 1em; }                                                            /* opmaak van alle table-cellen van de respons-regel */
 .SQWtextarea      { font-family: verdana; }                                                   /* opmaak van het invoerveld bij open vragen */
 .SQWtext          { border-style: solid; }                                                    /* opmaak van het invoerveld bij 'text' vragen */
 .SQWradio         { border-style: solid; }                                                    /* opmaak van het invoerveld bij 'Likert' vragen */
 .SQWcheckbox      { border-style: solid; }                                                    /* opmaak van het invoerveld bij 'check' vragen */
 .submitButton     { border-style: none; font-size: 8pt;}                                      /* bepaald opmaak van de submit-button */
</style>


<center>
<div style="border: solid 1px silver;width:60%;font-family:verdana;">
<FORM id=deVragen style="WIDTH: 100%" name=deVragen action=http://web.archive.org/web/20080218222024/http://www2.fmg.uva.nl/FMGweb/scripts/formMail.cfm method=post>


<!-- ================== vraag ============== --> 
<div class=vraagwrapper>
<INPUT type=hidden size=130 name=vraag1q>
<DIV class=vraag title="" contentEditable=false>
<CENTER>
<TABLE class=vraagtable width="100%" border=0>

<TBODY>
<TR class=vraagrow1>
<TD></TD>
<TD colSpan=3></TD></TR>
<TR class=vraagresponsen>
<TD>&nbsp;</TD>
<TD class=SQWtd id=SQWtdCell1vraag1>
<P>Your name: </P>
<P>Your e-mail:&nbsp;</P>
<P>Subject: </P></TD>
<TD class=SQWtd id=SQWtdCell2vraag1></TD>
<TD class=SQWtd id=SQWtdCell3vraag1>
<P>
<INPUT class=SQWtext style="WIDTH: 333px; HEIGHT: 22px" size=44 name=vraag1></P>

<P>
<INPUT class=SQWtext style="WIDTH: 333px; HEIGHT: 22px" size=44 name=vraag1></P>
<P>
<INPUT class=SQWtext style="WIDTH: 332px; HEIGHT: 22px" size=45 name=vraag1 value="suggestions geometry package"></P></TD></TR></TBODY></TABLE></CENTER></DIV>



</DIV>


<!-- ================== vraag ============== --> 
<div class=vraagwrapper>
<INPUT type=hidden size=130 value=Message: name=vraag2q>
<DIV class=vraag title="" contentEditable=false>
<CENTER>
<TABLE class=vraagtable width="100%" border=0>
<TBODY>

<TR class=vraagrow1>
<TD></TD>
<TD>Message:</TD></TR>
<TR class=vraagresponsen>
<TD>&nbsp;</TD>
<TD>
<TEXTAREA class=SQWtextarea style="WIDTH: 589px; HEIGHT: 189px" name=vraag2 rows=10 cols=69 value="NA"> </TEXTAREA></TD></TR></TBODY></TABLE></CENTER></DIV>



</DIV>
<INPUT class=submitButton type=submit value=submit name=submitButton>
<INPUT type=hidden value=rgrasman name=ontvanger>
<INPUT type=hidden value=http://users.fmg.uva.nl/rgrasman/requestsent.html name=redirect>
<INPUT type=hidden value="Rqhull response" name=MAILSUBJECT></FORM>

</div>
</center>

<p> The <strong>project summary page</strong> you can find <a href="http://<?php echo $domain; ?>/projects/<?php echo $group_name; ?>/"><strong>here</strong></a>. </p>

</body>
</html>
