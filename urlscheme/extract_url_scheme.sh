#!/bin/bash

: << POD

=head1 NAME

extract_url_scheme - Extract URL schemes of iOS apps

=head1 RESPECT

http://d.hatena.ne.jp/don2don/20120315/1331812111

=cut
POD

# readonly now=$(date +%Y%m%d-%H%M%S)
# readonly outf=urlschemes-$now.html
readonly outf=index.html
readonly appLocation="$HOME/Music/iTunes/iTunes Music/Mobile Applications"

function greppl {
  local -r word="$1"
  local -r xml="$2"
  echo "$xml" | plutil -extract "$word" xml1 -o - - | grep 'string' | sed 's/<[^>]*>//g'
  # echo "$xml" | grep -A1 $word | tail -1 | sed 's/<[^>]*>//g' | perl -ple 's/\t//g'
}

function scanipafile {
  local -r ipafile="$1"

  local -r basepath="$(zipinfo -1 "$ipafile" | egrep '^Payload/[^/]+\.app/$')"
  local -r infoplistpath="${basepath}Info.plist"

  local -r plistxml=$(unzip -p "$ipafile" "$infoplistpath" | plutil -convert xml1 -o - -)

  # XXX: XML Parse
  # XXX: Magic Number
  local -r urlschemes=( $(echo "$plistxml" | grep -A5 CFBundleURLSchemes | grep -v CFBundleURLSchemes | sed 's/<[^>]*>//g') )
  # echo ${urlschemes[*]} 1>&2 # Debug

  local -r hrefs=( $(echo ${urlschemes[*]} | xargs -n1 -I{} echo "<a href={}:>{}</a><br>") )
  # echo ${hrefs[*]} 1>&2 # Debug

  # FIXME
  local appname
  local -r displayname="$(greppl CFBundleDisplayName "$plistxml")"
  if [[ -n $displayname ]] ; then
      appname="$displayname"
  else
      local -r name="$(greppl CFBundleName "$plistxml")"
      if [[ -n $name ]] ; then
          appname="$name"
          # echo $name 1>&2 # Debug
      else
          local -r exename="$(greppl CFBundleExecutable "$plistxml")"
          [[ -n $exename ]] && appname="$exename"
          # echo $exename 1>&2 # Debug
      fi
  fi

  local -r ipaname="$(basename "$ipafile")"
  # echo $ipaname 1>&2 # Debug
  echo "<tr><td class='status'>$appname</td><td class='status'>$ipaname</td><td class='status'>${hrefs[*]}</td></tr>"
}


cat << EOT > $outf
<!DOCTYPE html>
<html lang='ja'>
<head>
	<meta charset='UTF-8'>
	<style media="screen and (min-device-width: 641px)">
	body {
		background-color: darkseagreen;
		width: 90%;
	}	
	.title {
		font-size:120%;
		padding:10px 22px;
	}
	.sn {
		font-size:90%;
		padding:10px 5px;
		text-align:right;
	}
	.ta1 {
		width: 90%;
		margin-top:20px;
		margin-left:50px;
		margin-bottom:10px;
	}
	</style>
	<style media="only screen and (max-device-width: 640px)">
	body {
		background-color: lightpink;
		width: 98%;
	}
	.title {
		font-size:120%;
		padding:3px 5px;
	}
	.sn {
		font-size:90%;
		padding:5px 5px;
		text-align:right;
	}
	.ta1 {
		width: 98%;
		margin-top:5px;
		margin-left:5px;
		margin-bottom:5px;
	}
	</style>
	<style>
	.ta1 th {
		border-bottom:double 3px #666666;
		text-align:left;		
	}	
	.ta1 td {
		border-bottom:solid 1px #666666;
	}
	.ta1.status {
		text-align:center;
	}
	.ta1 th,.ta1 td {
		padding:10px 22px;
	}
</style>
<title>URL Scheme</title>
</head>
<body>
<!-- <p class="title"><b>URL Scheme</b></p> -->
<table class='ta1' cellspacing='0'>
<th>App Name</th><th>App filename</th><th>URL Scheme</th>
EOT

find "$appLocation" -iname '*.ipa' | while read ipafile ; do
  scanipafile "$ipafile" >> $outf
done

# find "$appLocation" -iname '*.ipa' -print0 | xargs -0 -n1 -I% scanipafile "%" >> $outf

cat << EOT >> $outf
</table>
</body></html>
EOT

