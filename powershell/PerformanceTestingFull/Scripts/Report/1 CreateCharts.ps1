$sw = [Diagnostics.Stopwatch]::StartNew()

[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
$scriptpath = Split-Path -parent $MyInvocation.MyCommand.Definition
$config = (Get-Content Config.JSON) -join "`n" | ConvertFrom-Json    # import configuration data
$report = @{models=@()}    # create array to store all data that will be exported as json at the end

$chartnum = 1

Function CreateChart($model, $counter, $cdata) {
    write-host $counter.name "(" $cdata[0].opr $cdata[0].tol $txt ")"   # display counter and baseline for current server type

    # create chart object
    $chart1 = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $chart1.Width = 680
    $chart1.Height = 400
    $chart1.BackColor = [System.Drawing.Color]::WhiteSmoke
    $chart1.BackGradientStyle = [System.Windows.Forms.DataVisualization.Charting.GradientStyle]::LeftRight;
    $chart1.BorderlineColor = [System.Drawing.Color]::DimGray;
    $chart1.BorderlineDashStyle = [System.Windows.Forms.DataVisualization.Charting.ChartDashStyle]::Solid;
 
    # create chart title
    $ctitle = "(" +$model.name+ ") "
    if (($cdata.length -eq 1) -or ($cdata[0].server.name -eq $cdata[1].server.name)) { $ctitle += $cdata[0].server.name+ "\" }  # if the chart data is for one server, add the server name to the chart title
    if ($cdata[0].tol -eq 'baseline') {   # if this is a baseline chart, don't include the tolerance
        $ctitle += $counter.name+" ("+ $cdata[0].tol +")"
    }else{
        $ctitle += $counter.name+" ("+ $cdata[0].opr + " " + $cdata[0].tol + $txt+")"
    }

    # add the chart title
    [void]$chart1.Titles.Add($ctitle)
    $chart1.Titles[0].Font = "Arial,13pt"
    $chart1.Titles[0].Alignment = "topLeft"
 
    # creat chart area
    $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $chartarea.Name = "ChartArea1"
    ##$chartarea.AxisY.Title = "%"
    ##$chartarea.AxisX.Title = "Time"

    # the following section is not currently being used
    ##for ($t=0; $t -lt $cdata.length; $t++) { $maxval += $cdata[$t].max }  # determine maximum value
    ##if ($maxval -eq 0) { $chartarea.AxisY.Interval = 1 }   # if the maximum value is 0 set the Y interval to 1

    # set X interval based on couter type - not currenlty being used
    ##if ($counter.name -like '*Network Interface*') { $chartarea.AxisX.Interval = 20 }else{ $chartarea.AxisX.Interval = 5 }

    $xInterval = [Math]::Round($cdata[0].sdata.count / 8) 
    ##write-host "xInterval = " $xInterval
    $chartarea.AxisX.Interval = $xInterval

    $chartarea.BackColor = [System.Drawing.Color]::Transparent;
    $chart1.ChartAreas.Add($chartarea)
 
    # create chart legend
    $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $legend.name = "Legend1"
    $chart1.Legends.Add($legend)
    $legend.Alignment = [System.Drawing.StringAlignment]::Center
    $legend.Docking = [System.Windows.Forms.DataVisualization.Charting.Docking]::Bottom
  
    # create data series
    for ($t=0; $t -lt $cdata.length; $t++) {
        $seriesName = ""
        if ($cdata[$t].cntrinst.name) { 
            if (($cdata.length -gt 1) -and ($cdata[0].server.name -ne $cdata[1].server.name)) { $seriesName += $cdata[$t].server.name+ " " }
            if ($counter -like "*Process*") { 
                $seriesName += $cdata[$t].cntrinst.name.split("(").split(")")[1]
            }else{
                $seriesName += $cdata[$t].cntrinst.name
            }
        }else{
            $seriesName += $cdata[$t].server.name
        }
        [void]$chart1.Series.Add($seriesName)
        $chart1.Series[$seriesName].ChartType = "Line"
        $chart1.Series[$seriesName].BorderWidth  = 3
        $chart1.Series[$seriesName].IsVisibleInLegend = $true
        $chart1.Series[$seriesName].chartarea = "ChartArea1"
        $chart1.Series[$seriesName].Legend = "Legend1"
        ##$chart1.Series[$server.name].color = "#62B5CC"

        for ($i=1; $i -le $cdata[$t].sdata.count -1; $i++) {
            $time = Get-Date $cdata[$t].sdata[$i].TimeStamp -format T
            $value = $cdata[$t].sdata[$i].CookedValue
            $chart1.Series[$seriesName].Points.addxy($time, ($value)) | Out-Null
        }
        $chartarea[0].AxisX.LabelStyle.Angle = -45
    }

    # save chart
    $chart1.SaveImage("$scriptpath\ReportImages\"+$chartnum+"_"+$model.name+"_"+$cdata[0].server.name+"_"+$counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")+".png","png")
    ##$chart1.SaveImage("$scriptpath\ReportImages\"+$chartnum+"_"+$model.name+"-"+$cdata[0].server.name+"-"+$counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")+".png","png")

} # end CreateChart function

$mrow = 0


# loop through all models
foreach ($model in $config.models) {
    write-host $model.name "-" $model.stime "-" $model.etime "-" $model.dir  # display model info
    $report.models += @{name=$model.name; stime=$model.stime; etime=$model.etime; dir=$model.dir}   # add the current model to the $report.models array
    $report.models[$mrow].counters = @()   # create the counters array for the current model
    $crow = 0

    # create charts for all counters except disk and network
    foreach ($counter in $config.counters | Where-Object {$_.name -notlike "*Physical*"}  | Where-Object {$_.name -notlike "*Network*"}  | Where-Object {$_.name -notlike "*Process(*"}) { 
        $count = 0
        $prevstype = ''
        write-host `n"--" $model.name "-" $counter.name "--"
        $report.models[$mrow].counters += @{name=$counter.name; tol=$counter.tol}  # add current counter to the counter array for the current model
        $report.models[$mrow].counters[$crow].values = @()  # create the values array for the current counter and model
        $cdata = @()  #create empty array for chart data
        
        foreach ($server in $config.servers) {
            $tol = $counter.tol.$($server.type)  # get counter tolerance by server type
            $opr = $counter.tol.opr
            $txt = $counter.tol.txt
            $desc = $server.desc

            # keep track of the previous server type so charts can be kept separate
            if ($prevstype -eq '') {
                $prevstype = $server.type
            }
            
            if ($tol) {
                write-host "Getting data for " $server.name -foreground "Green"
                $cpath = $model.dir+ "\" +$server.name+ "\Performance Counter.blg"  
                $cname = "\\*\"+$counter.name
                $stime = [datetime]$model.stime
                $etime = [datetime]$model.etime
                
                # import data for current counter and server
                # $data = Import-Counter -Path $cpath -Counter $cname
                # use the following format if blgs have not been relogged 
                $data = Import-Counter -Path $cpath -StartTime $stime -EndTime $etime -Counter $cname

                # verify that data was found and write the sample count to $report
                if ($data) { 
                    write-host "Success! " $data.count -foreground "Green"
                    if (!$report.models[$mrow].csamples) {$report.models[$mrow].csamples = $data.count}
                }

                # expand the countersammples object and calculate avg, min & max
                $d = $data | Select-Object -Expand countersamples | where status -eq 0
                $avg = $d[2..($d.Count-1)].cookedvalue | Measure-Object -Average | Select-Object -ExpandProperty Average
                $min = $d[2..($d.Count-1)].cookedvalue | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
                $max = $d[2..($d.Count-1)].cookedvalue | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

                $count++

                # if the max value is greater than 0, add the counter data to the report
                if ($max -gt 0) {
                    $cdata += @{server=$server; sdata=$d; opr=$opr; tol=$tol; max=$max}                   
                    $report.models[$mrow].counters[$crow].values += @{chartnum=$chartnum;server=$server.name;instance=$d[0].instancename;avg=$avg;min=$min;max=$max}
                    
                    # optionally create a json file for this counter and server, including all sample data
                    ##$counterName = $counter.name.Replace("\"," ").Replace("/"," ").Replace(":","")
                    ##$fileName = $model.name + "_" +$server.name+ "_" +$counterName
                    ##@{chartnum=$chartnum;model=$model.name;server=$server.name;counter=$counter.name;instance=$d[0].instancename;avg=$avg; min=$min; max=$max; sdata=$d | Select-Object timestamp, cookedvalue} | ConvertTo-Json -Depth 4 | Out-File ".\json\$fileName.json"
                }

                # create chart
                ##if ($count -eq 2) {   # uncomment if the chart should contain multiple servers
                
                    # create chart if there's data
                    if ($cdata.Length -eq 4) {   
                        write-host "Creating chart..." $cdata.Length -foreground "Green"
                        CreateChart $model $counter $cdata
                        $chartnum++
                        $cdata = @()
                    }
                
                    ##$count = 0
                ##}

            } # end if ($tol)

            $prevstype = $server.type

        } # end foreach $server
        
        # create chart if there's data
        if ($cdata.Length -gt 0) {   
            write-host "Creating chart..." $cdata.Length -foreground "Green"
            CreateChart $model $counter $cdata
            $chartnum++
        }

        $crow++

    } # end foreach $counter


    # create charts for physical disk counters
    foreach ($counter in $config.counters | Where-Object {$_.name -like "*Physical*"}) {
        write-host `n"--" $model.name "-" $counter.name "--"
        $report.models[$mrow].counters += @{name=$counter.name; tol=$counter.tol}   # add current counter to the counter array for the current model
        $report.models[$mrow].counters[$crow].values = @()   # create the values array for the current counter and model
        $cdata = @()  #create empty array for table data
        $scount = 1
        
        foreach ($server in $config.servers) {
            $scount++
            $tol = $counter.tol.$($server.type)   # get counter tolerance by server type
            $opr = $counter.tol.opr
            $txt = $counter.tol.txt
            $desc = $server.desc
                
            if ($tol) {
                write-host "Getting data for " $server.name -foreground "Green"
                $cpath = $model.dir+ "\" +$server.name+ "\Performance Counter.blg"
                $cname = "\\*\"+$counter.name
                $stime = [datetime]$model.stime
                $etime = [datetime]$model.etime
                
                # import data for current counter and server
                ##$data = Import-Counter -Path $cpath -Counter $cname
                # use the following format if blgs have not been relogged 
                $data = Import-Counter -Path $cpath -StartTime $stime -EndTime $etime -Counter $cname

                # verify that data was found and write the sample count to $report
                if ($data) { 
                    write-host "Success! " $data.count -foreground "Green"
                    if (!$report.models[$mrow].csamples) {$report.models[$mrow].csamples = $data.count}
                }

                # expand the countersammples object
                $d = $data | Select-Object -Expand countersamples | where status -eq 0

                # group samples by counter instance
                $instances = $d | where-object {$_.instancename -ne "_total"} | Group-Object instancename

                foreach ($cntrinst in $instances) {

                    # remove bogus 0 value
                    write-host "Check for bogus 0 value..." -foreground "Green"
                    if ($cntrinst.group[0].CookedValue -eq 0) {
                        $cntrinst.group.RemoveAt(0)
                        write-host "Found! New value is " $cntrinst.group[0].CookedValue -foreground "Green"
                    }

                    # calculate avg, min & max
                    $avg = $cntrinst.group | % {$_.cookedvalue} | Measure-Object -Average | Select-Object -ExpandProperty Average
                    $min = $cntrinst.group | % {$_.cookedvalue} | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
                    $max = $cntrinst.group | % {$_.cookedvalue} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
                    
                    # if the max value is greater than 0, add the counter data to the report
                    if ($max -gt 0) {  
                        $sdata = $cntrinst.group
                        $cdata += @{server=$server; tol=$tol; opr=$opr; cntrinst=$cntrinst; sdata=$sdata}
                        $report.models[$mrow].counters[$crow].values += @{chartnum=$chartnum;server=$server.name;instance=$cntrinst.name;avg=$avg; min=$min; max=$max}
                        
                        # optionally create a json file for this counter and server, including all sample data
                        ##$instanceName = $cntrinst.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")
                        ##$counterName = $counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*",$instanceName)
                        ##$fileName = $model.name + "_" +$server.name+ "_" +$counterName
                        #@{chartnum=$chartnum;model=$model.name;server=$server.name;counter=$counter.name;instance=$cntrinst.name;avg=$avg; min=$min; max=$max; sdata=$d | Select-Object timestamp, cookedvalue} | ConvertTo-Json -Depth 4 | Out-File ".\json\$fileName.json"
                    }
                } # end foreach $cntrinst

            } # end if $tol

            # create chart if there's data
            if ($cdata.Length -gt 0) {                    
                    write-host "Creating chart..." -foreground "Green"
                    CreateChart $model $counter $cdata
                    $chartnum++
                    $cdata = @()
            }

        } # end foreach $server

        $crow++

    } # end foreach $counter


    #create network charts
    foreach ($counter in $config.counters | Where-Object {$_.name -like "*Network*"}) {
        write-host `n"--" $model.name "-" $counter.name "--"
        $report.models[$mrow].counters += @{name=$counter.name; tol=$counter.tol}   # add current counter to the counter array for the current model
        $report.models[$mrow].counters[$crow].values = @()
        $cdata = @()  #create empty array for table data
        $scount = 1
        
        foreach ($server in $config.servers) {
            $scount++
            $tol = $counter.tol.$($server.type)   # get counter tolerance by server type
            $opr = $counter.tol.opr
            $txt = $counter.tol.txt
            $desc = $server.desc
            
            if ($tol) {
                write-host "Getting data for " $server.name -foreground "Green"
                $cpath = $model.dir+ "\" +$server.name+ "\Performance Counter.blg"
                $cname = "\\*\"+$counter.name
                $stime = [datetime]$model.stime
                $etime = [datetime]$model.etime

                # import data for current counter and server
                ##$data = Import-Counter -Path $cpath -Counter $cname
                # use the following format if blgs have not been relogged 
                $data = Import-Counter -Path $cpath -StartTime $stime -EndTime $etime -Counter $cname

                # verify that data was found and write the sample count to $report
                if ($data) { 
                    write-host "Success! " $data.count -foreground "Green"
                    if (!$report.models[$mrow].csamples) {$report.models[$mrow].csamples = $data.count}
                }
                
                # expand the countersammples object
                $d = $data | Select-Object -Expand countersamples | where status -eq 0

                # group samples by counter instance
                $instances = $d | Group-Object instancename

                foreach ($cntrinst in $instances) {

                    #remove bogus 0 value
                    if ($cntrinst.group[0].CookedValue -eq 0) {
                        $cntrinst.group.RemoveAt(0)
                        write-host "Found bogus 0 value! New value is " $cntrinst.group[0].CookedValue -foreground "Green"
                    }

                    # calculate avg, min & max
                    $avg = $cntrinst.group | % {$_.cookedvalue} | Measure-Object -Average | Select-Object -ExpandProperty Average
                    $min = $cntrinst.group | % {$_.cookedvalue} | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
                    $max = $cntrinst.group | % {$_.cookedvalue} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
                    
                    # if the max value is greater than 0, add the counter data to the report
                    if ($max -gt 0) {  
                        $sdata = $cntrinst.group
                        $cdata += @{server=$server; tol=$tol; opr=$opr; cntrinst=$cntrinst; sdata=$sdata}
                        $report.models[$mrow].counters[$crow].values += @{chartnum=$chartnum;server=$server.name;instance=$cntrinst.name;avg=$avg; min=$min; max=$max}
                    
                        # optionally create a json file for this counter and server, including all sample data
                        ##$instanceName = $cntrinst.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*","")
                        ##$counterName = $counter.name.Replace("\"," ").Replace("/"," ").Replace(":","").Replace("*",$instanceName)
                        ##$fileName = $model.name + "_" +$server.name+ "_" +$counterName
                        ##@{chartnum=$chartnum;model=$model.name;server=$server.name;counter=$counter.name;instance=$cntrinst.name;avg=$avg; min=$min; max=$max; sdata=$d | Select-Object timestamp, cookedvalue} | ConvertTo-Json -Depth 4 | Out-File ".\json\$fileName.json"
                    }

                } # end foreach $cntrinst

            } # end if $tol

            if ($cdata.Length -gt 0) {                
                write-host "Creating chart..." -foreground "Green"
                CreateChart $model $counter $cdata
                $chartnum++
                $cdata = @()
            }
        } # end foreach $server

        $crow++
        
    } # end foreach $counter

    $mrow++

} # end foreach $model

$report | ConvertTo-Json -Depth 7 | Out-File ".\ReportExport.json"

$sw.Stop()
$sw.Elapsed
