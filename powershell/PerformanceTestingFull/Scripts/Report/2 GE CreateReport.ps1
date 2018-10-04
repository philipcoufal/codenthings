$sw = [Diagnostics.Stopwatch]::StartNew()

[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

$scriptpath = Split-Path -parent $MyInvocation.MyCommand.Definition

$savepath="G:\Performance\DOCTemplate\Performance Testing Report v0.1.docx"
$word=new-object -ComObject "Word.Application"
##$doc=$word.documents.Add()
$doc = $word.Documents.Open("$scriptpath\Performance Template.docx")
##$word.Visible=$False
$selection=$word.Selection

# import configuration data
$config = (Get-Content Config.JSON) -join "`n" | ConvertFrom-Json

# import json report
$report = (Get-Content ReportExport.JSON) -join "`n" | ConvertFrom-Json
##$models = $report.values | Group-Object {$_.model}

$lcolors = @(15764545, 4306172, 671968, 9593861, 12566463, 6896410, 8578047) # BrightPastel color palette for chart series

$chartnum = 1


###########################################################
# create chart counter and servers above tolerance
Function CreateChart($model, $counter, $cdata) {
    write-host "Creating chart..."
    write-host $model.name " " $counter.name

    # chart object
    $chart1 = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $chart1.Width = 680
    $chart1.Height = 400
    $chart1.BackColor = [System.Drawing.Color]::WhiteSmoke
    $chart1.BackGradientStyle = [System.Windows.Forms.DataVisualization.Charting.GradientStyle]::LeftRight;
    $chart1.BorderlineColor = [System.Drawing.Color]::DimGray;
    $chart1.BorderlineDashStyle = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Solid;
 
    # title 
    $ctitle = "(" +$model.name+ ") " +$counter.name
    [void]$chart1.Titles.Add($ctitle)
    $chart1.Titles[0].Font = "Arial,13pt"
    $chart1.Titles[0].Alignment = "topLeft"
 
    # chart area 
    $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $chartarea.Name = "ChartArea1"
    ##$chartarea.AxisY.Title = "%"
    ##$chartarea.AxisX.Title = "Time"

    for ($t=0; $t -lt $cdata.length; $t++) {
        $maxval += $cdata[$t].max
    }

    ##$chartarea.AxisY.Interval = 100
    ##if ($counter.name -like '*Network Interface*') { $chartarea.AxisX.Interval = 20 }else{ $chartarea.AxisX.Interval = 5 }
    $xInterval = [Math]::Round($model.csamples / 8) 
    ##write-host "xInterval = " $xInterval
    $chartarea.AxisX.Interval = $xInterval

    $chartarea.BackColor = [System.Drawing.Color]::Transparent;
    $chart1.ChartAreas.Add($chartarea)
 
    # legend 
    $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $legend.name = "Legend1"
    $chart1.Legends.Add($legend)
    $legend.Alignment = [System.Drawing.StringAlignment]::Center
    $legend.Docking = [System.Windows.Forms.DataVisualization.Charting.Docking]::Bottom
  
    # data series
    for ($t=0; $t -lt $cdata.length; $t++) {
        # get counter data from the blg
        # read perfmon data for this counter and server
        $cpath = $model.dir+ "\" +$cdata[$t].server+ "\Performance Counter.blg"
        ##$cpath = $model.dir+ "\relogged\" +$cdata[$t].server+ "_" +$model.name+ ".blg"
         
        $cname = "\\*\"+$counter.name
        if (($counter.name -like "*Datenträger*") -or ($counter.name -like "*Netzwerk*")) { $cname = "\\*\"+$counter.name.Replace("*", $cdata[$t].instance) }
        $stime = [datetime]$model.stime
        $etime = [datetime]$model.etime

        ##Write-Host $server.name $tol $server.type
        $data = Import-Counter -Path $cpath -StartTime $stime -EndTime $etime -Counter $cname
        ##$data = Import-Counter -Path $cpath -Counter $cname
        $d = $data | Select-Object -Expand countersamples | where status -eq 0

        $seriesName = $cdata[$t].server
        if (($cdata[$t].instance) -and ($cdata[$t].instance -ne $null)) { 
            $seriesName += " (" +$cdata[$t].instance+ ")"
        }

        [void]$chart1.Series.Add($seriesName)
        $chart1.Series[$seriesName].ChartType = "Line"
        $chart1.Series[$seriesName].BorderWidth  = 3
        $chart1.Series[$seriesName].IsVisibleInLegend = $true
        $chart1.Series[$seriesName].chartarea = "ChartArea1"
        $chart1.Series[$seriesName].Legend = "Legend1"
        ##$chart1.Series[$server.name].color = "#62B5CC"

        for ($i=1; $i -le $d.count -1; $i++) {
            $time = Get-Date $d[$i].TimeStamp -format T
            $value = $d[$i].CookedValue
            $chart1.Series[$seriesName].Points.addxy($time, ($value)) | Out-Null
        }
        $chartarea[0].AxisX.LabelStyle.Angle = -45
    }

    # save chart
    $chart1.SaveImage("$scriptpath\SummaryImages\"+$chartnum+"_"+$model.name+"-"+$counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")+".png","png")
    ##$chart1.SaveImage("$scriptpath\ReportImages\"+$chartnum+"_"+$model.name+"-"+$tdata[0].server.name+"-"+$counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")+".png","png")
    
}


###########################################################
# start document
$selection.InsertNewPage()
$selection.Style="Heading 1"
$selection.TypeText("Performance Reports")
$selection.TypeParagraph()

###########################################################
# start new section
$selection.Style="Heading 2"
$selection.TypeText("Performance Summary")
$selection.TypeParagraph()
$selection.Style="Normal"
$selection.TypeParagraph()



###########################################################
# create headings and tables for summary section
foreach ($model in $report.models) {    # foreach ($model in $models) { 
    write-host "---" $model.name
    $selection.Style="Heading 3"
    $selection.TypeText($model.name)
    $selection.TypeParagraph()
    $selection.Style="Normal"
    $selection.TypeParagraph()

    ##$counters = $model.group | Group-Object {$_.counter}
    
    foreach ($counter in $model.counters | Where-Object {$_.name -like "*Prozessorzeit*" -or $_.name -like "*Verfügbare MB*" -or $_.name -like "*Leerlaufzeit*" -or $_.name -like "*Gesamtanzahl Bytes*"}) {   ##foreach ($counter in $counters) {
        if ($counter.values) {
            Write-Host "--" $counter.name
            $selection.Style="Heading 4"
            $counterInfo = $config.counters | where name -eq $counter.name
            $selection.TypeText($counter.name+ " (" +$counterInfo.tol.desc+ ")")
            $selection.TypeParagraph()
            $selection.Style="Normal"
            $selection.TypeParagraph()
            $selection.Style="No Spacing"

            $rows = $counter.values.Length + 1   ##$rows = $counter.group.count 
            $cols = 4
            $range = $selection.Range
            $table = $doc.Tables.add($range,$rows,$cols)
            ##total table width is 470
            $table.Columns | ForEach-Object {$_.Width = 82}
            $table.Columns | Where-Object {$_.Index -eq 1} | ForEach-Object {$_.Width = 224}
            $table.Style = "Table Grid"
            $table.ApplyStyleHeadingRows = $true
            $table.Style = "Medium Shading 1 - Accent 1"
            $table.cell(1,1).range.text = "Server & Instance"
            $table.cell(1,2).range.text = "Avg"
            $table.cell(1,3).range.text = "Min"
            $table.cell(1,4).range.text = "Max"

            $rcount = 1


            foreach ($row in $counter.values) {    ##foreach ($row in $counter.group) {
                $rcount++
                Write-Host $row.server "-" $row.instance "-" $row.avg "-" $row.min "-" $row.max
                $desc = $config.servers | where name -eq $row.server | % {$_.desc}
                $rowTitle = $row.server
                if (($counter.name -like "*Datenträger*") -or ($counter.name -like "*Netzwerk*") -or ($counter.name -like "*Prozess(*")) { $rowTitle += "(" +$row.instance+ ")" }
                $rowTitle += " (" +$desc+ ") "
                ##$selection.TypeText($rowtitle+ " " +$row.avg+ " " +$row.min+ " " +$row.max)
                ##$selection.TypeParagraph()

                $table.cell($rcount,1).range.text = $rowTitle
                ##$table.cell($rcount,1).Shading.BackgroundPatternColor = -16777216
                ##$table.cell($rcount,1).range.font.color = $lcolors[$i]

                $serverInfo = $config.servers | where name -eq $row.server
                $tol = $counterInfo.tol.$($serverInfo.type)
                if (($counter.name -like "*Kontextwechsel*") -or ($counter.name -like "*Prozessor-Warteschlangenlänge*")) { $tol = [int]::Parse($tol) * [int]::Parse($serverInfo.cpus) }
                write-host $tol

                # format avg value
                if ($row.avg -lt 1000) {
                    $table.cell($rcount,2).range.text = [Math]::Round($row.avg, 2)
                }else{
                    $table.cell($rcount,2).range.text = '{0:N0}' -f [Math]::Round($row.avg)
                }
                # if avg above tolerance
                if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                    if ($row.avg -gt $tol) { $table.cell($rcount,2).Shading.BackgroundPatternColor = 65535 }
                }
                if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                    if ($row.avg -lt $tol) { $table.cell($rcount,2).Shading.BackgroundPatternColor = 65535 }
                }
                
                # format min value
                if ($row.min -lt 1000) {
                    $table.cell($rcount,3).range.text = [Math]::Round($row.min, 2)
                }else{
                    $table.cell($rcount,3).range.text = '{0:N0}' -f [Math]::Round($row.min)
                }
                # if min above tolerance
                if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                    if ($row.min -gt $tol) { $table.cell($rcount,3).Shading.BackgroundPatternColor = 65535 }
                }
                if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                    if ($row.min -lt $tol) { $table.cell($rcount,3).Shading.BackgroundPatternColor = 65535 }
                }

                # format max value
                if ($row.max -lt 1000) {
                    $table.cell($rcount,4).range.text = [Math]::Round($row.max, 2)
                }else{
                    $table.cell($rcount,4).range.text = '{0:N0}' -f [Math]::Round($row.max)
                }
                # if max above tolerance
                if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                    if ($row.max -gt $tol) { $table.cell($rcount,4).Shading.BackgroundPatternColor = 65535 }
                }
                if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                    if ($row.max -lt $tol) { $table.cell($rcount,4).Shading.BackgroundPatternColor = 65535 }
                }

            
            }

            $table = $selection.EndKey(6)
            ##$selection.TypeParagraph()
            $selection.Style="Caption"
            $selection.TypeText($model.name+ " - " +$counter.name+ " (" +$counterInfo.tol.desc+ ")")
            ##$selection.TypeParagraph()

            # insert chart for each server
            ##foreach ($server in $counter.values | Group-Object {$_.server}) {
                ##write-host "Adding chart..."
                ##$selection.TypeParagraph()
                ##$selection.InlineShapes.AddPicture("$scriptpath\ReportImages\"+$rchartnum+"_"+$model.name+"_"+$server.name+"_"+$counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")+".png") | Out-Null
                ##$selection.TypeParagraph()
            ##}

            foreach ($rchart in $counter.values | Group-Object {$_.chartnum}) {
                write-host "Adding chart..."
                write-host $rchart.name
                write-host $model.name
                write-host $rchart.group[0].server
                write-host $counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")
                $selection.TypeParagraph()
                $selection.InlineShapes.AddPicture("$scriptpath\ReportImages\"+$rchart.name+"_"+$model.name+"_"+$rchart.group[0].server+"_"+$counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")+".png") | Out-Null
                ##$selection.TypeParagraph()
            }

            $selection.InsertNewPage()
        }
    }
    ##$selection.InsertNewPage()
   
}


###########################################################
# start next section
$selection.InsertNewPage()
$selection.Style="Heading 2"
$selection.TypeText("Performance Issues")
$selection.TypeParagraph()
$selection.Style="Normal"
$selection.TypeParagraph()



###########################################################
# create headings and tables for counters above tolerance
foreach ($model in $report.models) {   ##foreach ($model in $models) {
    write-host "---" $model.name
    $selection.Style="Heading 3"
    $selection.TypeText($model.name)
    $selection.TypeParagraph()
    $selection.Style="Normal"
    $selection.TypeParagraph()

    ##$counters = $model.group | Group-Object {$_.counter}
    
    foreach ($counter in $model.counters) {   ##foreach ($counter in $counters) {
        $counterInfo = $config.counters | where name -eq $counter.name

        $tdata = @()
        
        foreach ($row in $counter.values) {   ##foreach ($row in $counter.group) {
            $serverInfo = $config.servers | where name -eq $row.server
            $tol = $counterInfo.tol.$($serverInfo.type)
            if (($counter.name -like "*Kontextwechsel*") -or ($counter.name -like "*Prozessor-Warteschlangenlänge*")) { $tol = [int]::Parse($tol) * [int]::Parse($serverInfo.cpus) }
            # if max above tolerance set $aboveTol to true
            if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                if ($row.max -gt $tol) { 
                    $tdata += $row
                }
            }
            if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                if ($row.max -lt $tol) { 
                    $tdata += $row
                }
            }
        }

        if ($tdata) {
           

            Write-Host "--" $counter.name
            $selection.Style="Heading 4"
            $selection.TypeText($counter.name+ " (" +$counterInfo.tol.desc+ ")")
            $selection.TypeParagraph()
            $selection.Style="Normal"
            $selection.TypeParagraph()
            $selection.Style="No Spacing"

            Write-Host "Creating table..."
            $rows = $tdata.length + 1
            $cols = 4
            $range = $selection.Range
            $table = $doc.Tables.add($range,$rows,$cols)
            ##total table width is 470
            $table.Columns | ForEach-Object {$_.Width = 80}
            $table.Columns | Where-Object {$_.Index -eq 1} | ForEach-Object {$_.Width = 230}
            $table.Style = "Table Grid"
            $table.ApplyStyleHeadingRows = $true
            $table.Style = "Medium Shading 1 - Accent 1"
            $table.cell(1,1).range.text = "Server & Instance"
            $table.cell(1,2).range.text = "Avg"
            $table.cell(1,3).range.text = "Min"
            $table.cell(1,4).range.text = "Max"

            $rcount = 1

            foreach ($row in $tdata) {
                $rcount++
                Write-Host $row.server "-" $row.instance "-" $row.avg "-" $row.min "-" $row.max
                $desc = $config.servers | where name -eq $row.server | % {$_.desc}
                $rowTitle = $row.server
                if (($counter.name -like "*Datenträger*") -or ($counter.name -like "*Netzwerk*") -or ($counter.name -like "*Prozess(*")) { $rowTitle += "(" +$row.instance+ ")" }
                $rowTitle += " (" +$desc+ ") "
                ##$selection.TypeText($rowtitle+ " " +$row.avg+ " " +$row.min+ " " +$row.max)
                ##$selection.TypeParagraph()

                $table.cell($rcount,1).range.text = $rowTitle
                ##$table.cell($rcount,1).Shading.BackgroundPatternColor = -16777216
                ##$table.cell($rcount,1).range.font.color = $lcolors[$i]

                $serverInfo = $config.servers | where name -eq $row.server
                $tol = $counterInfo.tol.$($serverInfo.type)
                if (($counter.name -like "*Kontextwechsel*") -or ($counter.name -like "*Prozessor-Warteschlangenlänge*")) { $tol = [int]::Parse($tol) * [int]::Parse($serverInfo.cpus) }
                write-host $tol

                # format avg value
                if ($row.avg -lt 1000) {
                    $table.cell($rcount,2).range.text = [Math]::Round($row.avg, 2)
                }else{
                    $table.cell($rcount,2).range.text = '{0:N0}' -f [Math]::Round($row.avg)
                }
                # if avg above tolerance
                if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                    if ($row.avg -gt $tol) { $table.cell($rcount,2).Shading.BackgroundPatternColor = 65535 }
                }
                if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                    if ($row.avg -lt $tol) { $table.cell($rcount,2).Shading.BackgroundPatternColor = 65535 }
                }
                
                # format min value
                if ($row.min -lt 1000) {
                    $table.cell($rcount,3).range.text = [Math]::Round($row.min, 2)
                }else{
                    $table.cell($rcount,3).range.text = '{0:N0}' -f [Math]::Round($row.min)
                }
                # if min above tolerance
                if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                    if ($row.min -gt $tol) { $table.cell($rcount,3).Shading.BackgroundPatternColor = 65535 }
                }
                if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                    if ($row.min -lt $tol) { $table.cell($rcount,3).Shading.BackgroundPatternColor = 65535 }
                }

                # format max value
                if ($row.max -lt 1000) {
                    $table.cell($rcount,4).range.text = [Math]::Round($row.max, 2)
                }else{
                    $table.cell($rcount,4).range.text = '{0:N0}' -f [Math]::Round($row.max)
                }
                # if max above tolerance
                if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                    if ($row.max -gt $tol) { $table.cell($rcount,4).Shading.BackgroundPatternColor = 65535 }
                }
                if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                    if ($row.max -lt $tol) { $table.cell($rcount,4).Shading.BackgroundPatternColor = 65535 }
                }

            
            }
            $table = $selection.EndKey(6)
            write-host "Table complete!"
            ##$selection.TypeParagraph()
            $selection.Style="Caption"
            $selection.TypeText($model.name+ " - " +$counter.name+ " (" +$counterInfo.tol.desc+ ")")
            ##$selection.TypeParagraph()

            $cdata = @()
            ##for ($c=1; $c -lt $tdata.length + 1; $c++) {
            foreach ($server in $tdata | Group-Object {$_.server}) {
                $cdata += $server.group
                ##if ($c % 4 -eq 0) {
                    
                    # create chart
                    write-host $server.group
                    CreateChart $model $counter $cdata
                    write-host "Saving chart..."
                    ##Start-Sleep -s 2

                    # add chart to word doc
                    write-host "Adding chart..."
                    $selection.TypeParagraph()
                    $selection.InlineShapes.AddPicture("$scriptpath\SummaryImages\"+$chartnum+"_"+$model.name+"-"+$counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")+".png") | Out-Null
                    ##$selection.TypeParagraph()

                    $chartnum++
                    $cdata = @()
                ##}
            }
            $selection.InsertNewPage()
        }

    }
    ##$selection.TypeParagraph()
    ##$selection.InsertNewPage()
 
}

$selection.InsertNewPage()
$selection.Style="Heading 2"
$selection.TypeText("Performance Report")
$selection.TypeParagraph()
$selection.Style="Normal"
$selection.TypeParagraph()


$chartnum = 1



###########################################################
# create headings and tables for all counters with activity
foreach ($model in $report.models) {    ##foreach ($model in $models) { 
    write-host "---" $model.name
    $selection.Style="Heading 3"
    $selection.TypeText($model.name)
    $selection.TypeParagraph()
    $selection.Style="Normal"
    $selection.TypeParagraph()

    ##$counters = $model.group | Group-Object {$_.counter}
    
    foreach ($counter in $model.counters) {   ##foreach ($counter in $counters) {
        if ($counter.values) {
            Write-Host "--" $counter.name
            $selection.Style="Heading 4"
            $counterInfo = $config.counters | where name -eq $counter.name
            $selection.TypeText($counter.name+ " (" +$counterInfo.tol.desc+ ")")
            $selection.TypeParagraph()
            $selection.Style="Normal"
            $selection.TypeParagraph()
            $selection.Style="No Spacing"

            $rows = $counter.values.Length + 1   ##$rows = $counter.group.count 
            $cols = 4
            $range = $selection.Range
            $table = $doc.Tables.add($range,$rows,$cols)
            # total table width is 470
            $table.Columns | ForEach-Object {$_.Width = 80}
            $table.Columns | Where-Object {$_.Index -eq 1} | ForEach-Object {$_.Width = 230}
            $table.Style = "Table Grid"
            $table.ApplyStyleHeadingRows = $true
            $table.Style = "Medium Shading 1 - Accent 1"
            $table.cell(1,1).range.text = "Server & Instance"
            $table.cell(1,2).range.text = "Avg"
            $table.cell(1,3).range.text = "Min"
            $table.cell(1,4).range.text = "Max"

            $rcount = 1


            foreach ($row in $counter.values) {    ##foreach ($row in $counter.group) {
                $rcount++
                Write-Host $row.server "-" $row.instance "-" $row.avg "-" $row.min "-" $row.max
                $desc = $config.servers | where name -eq $row.server | % {$_.desc}
                $rowTitle = $row.server
                if (($counter.name -like "*Datenträger*") -or ($counter.name -like "*Netzwerk*") -or ($counter.name -like "*Prozess(*")) { $rowTitle += "(" +$row.instance+ ")" }
                $rowTitle += " (" +$desc+ ") "
                ##$selection.TypeText($rowtitle+ " " +$row.avg+ " " +$row.min+ " " +$row.max)
                ##$selection.TypeParagraph()

                $table.cell($rcount,1).range.text = $rowTitle
                ##$table.cell($rcount,1).Shading.BackgroundPatternColor = -16777216
                ##$table.cell($rcount,1).range.font.color = $lcolors[$i]

                $serverInfo = $config.servers | where name -eq $row.server
                $tol = $counterInfo.tol.$($serverInfo.type)
                if (($counter.name -like "*Kontextwechsel*") -or ($counter.name -like "*Prozessor-Warteschlangenlänge*")) { $tol = [int]::Parse($tol) * [int]::Parse($serverInfo.cpus) }
                write-host $tol

                # format avg value
                if ($row.avg -lt 1000) {
                    $table.cell($rcount,2).range.text = [Math]::Round($row.avg, 2)
                }else{
                    $table.cell($rcount,2).range.text = '{0:N0}' -f [Math]::Round($row.avg)
                }
                # if avg above tolerance
                if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                    if ($row.avg -gt $tol) { $table.cell($rcount,2).Shading.BackgroundPatternColor = 65535 }
                }
                if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                    if ($row.avg -lt $tol) { $table.cell($rcount,2).Shading.BackgroundPatternColor = 65535 }
                }
                
                # format min value
                if ($row.min -lt 1000) {
                    $table.cell($rcount,3).range.text = [Math]::Round($row.min, 2)
                }else{
                    $table.cell($rcount,3).range.text = '{0:N0}' -f [Math]::Round($row.min)
                }
                # if min above tolerance
                if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                    if ($row.min -gt $tol) { $table.cell($rcount,3).Shading.BackgroundPatternColor = 65535 }
                }
                if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                    if ($row.min -lt $tol) { $table.cell($rcount,3).Shading.BackgroundPatternColor = 65535 }
                }

                # format max value
                if ($row.max -lt 1000) {
                    $table.cell($rcount,4).range.text = [Math]::Round($row.max, 2)
                }else{
                    $table.cell($rcount,4).range.text = '{0:N0}' -f [Math]::Round($row.max)
                }
                # if max above tolerance
                if (($counterInfo.tol.opr -eq "<") -and ($tol -ne "baseline")) { 
                    if ($row.max -gt $tol) { $table.cell($rcount,4).Shading.BackgroundPatternColor = 65535 }
                }
                if (($counterInfo.tol.opr -eq ">") -and ($tol -ne "baseline")) { 
                    if ($row.max -lt $tol) { $table.cell($rcount,4).Shading.BackgroundPatternColor = 65535 }
                }

            
            }

            $table = $selection.EndKey(6)
            ##$selection.TypeParagraph()
            $selection.Style="Caption"
            $selection.TypeText($model.name+ " - " +$counter.name+ " (" +$counterInfo.tol.desc+ ")")
            ##$selection.TypeParagraph()

            # insert chart for each server
            ##foreach ($server in $counter.values | Group-Object {$_.server}) {
                ##write-host "Adding chart..."
                ##$selection.TypeParagraph()
                ##$selection.InlineShapes.AddPicture("$scriptpath\ReportImages\"+$rchartnum+"_"+$model.name+"_"+$server.name+"_"+$counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")+".png") | Out-Null
                ##$selection.TypeParagraph()
            ##}

            foreach ($rchart in $counter.values | Group-Object {$_.chartnum}) {
                write-host "Adding chart..."
                $selection.TypeParagraph()
                write-host $rchart.name
                write-host $model.name
                write-host $rchart.group[0].server
                write-host $counter
                $selection.InlineShapes.AddPicture("$scriptpath\ReportImages\"+$rchart.name+"_"+$model.name+"_"+$rchart.group[0].server+"_"+$counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")+".png") | Out-Null
                ##$selection.TypeParagraph()
            }

            $selection.InsertNewPage()
        }
    }
    ##$selection.InsertNewPage()
   
}



$doc.SaveAs([ref]$savepath)
$doc.Close()
$word.quit()


$sw.Stop()
$sw.Elapsed
