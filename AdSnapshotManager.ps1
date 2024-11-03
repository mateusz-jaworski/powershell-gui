Add-Type -AssemblyName System.Windows.Forms

Function Form
{
#Form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "AD Snapshot Manager"
$Form.Size = New-Object System.Drawing.Size(685,300)

#GroupBox
$groupbox = New-Object System.Windows.Forms.GroupBox
$groupbox.Location = New-Object System.Drawing.Size(10,10)
$groupbox.Size = New-Object System.Drawing.Size(650,200)
$groupbox.Text = "List Snapshots:"
$form.Controls.Add($groupbox)

    #GridView list snapshots
    $gridview = New-Object System.Windows.Forms.DataGridView
    $gridview.Location = New-Object System.Drawing.Size(10,20)
    $gridview.Size = New-Object System.Drawing.Size(630,170)
    $gridview.ReadOnly = $true
    $gridview.AllowUserToAddRows = $false
    $gridview.AllowUserToDeleteRows = $false
    $gridview.RowHeadersVisible = $false
    $gridview.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect

    $gridview.ColumnCount = 4
    $gridview.ColumnHeadersVisible = $true
    $gridview.Columns[0].Name = "Snapshot time"
    $gridview.Columns[0].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::DisplayedCells 
    $gridview.Columns[1].Name = "GUID"
    $gridview.Columns[1].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::DisplayedCells 
    $gridview.Columns[2].Name = "Is Mounted"
    $gridview.Columns[2].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::DisplayedCells 
    $gridview.Columns[3].Name = "Path"
    $gridview.Columns[3].AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill 

    $list = Invoke-Command -ScriptBlock { cmd.exe '/c ntdsutil snapshot "list all" quit quit' }
    $list_mounted =  Invoke-Command -ScriptBlock { cmd.exe '/c ntdsutil snapshot "list mounted" quit quit' }

    $list_output = @()

    ForEach($line in $list)
    {
        $list_output += $line | Select-String -SimpleMatch "/"
    }

    ForEach($snap in $list_output)
    {
        #$snap_no = $snap.ToString().SubString(1,$snap.ToString().indexOf(":")-1)
        $snap_date = [datetime]::ParseExact(($snap.ToString().Split(" ") | Select -Index 2), 'yyyy/MM/dd:HH:mm', $null)
        $snap_guid = $snap.ToString().SubString($snap.ToString().indexOf("{"),$snap.ToString().indexOf("}")-$snap.ToString().indexOf("{")+1)

        if($list_mounted | Select-String -SimpleMatch $snap_guid )
        { 
            $mounted = $true
            $search = $list_mounted | Select-String -SimpleMatch $snap_guid -Context 1 
    
            $snap_path = $search.Context.PostContext | Out-String
            $snap_path = ($snap_path).SubString(($snap_path).IndexOf("} ")+2,($snap_path).IndexOf("$\")-($snap_path).IndexOf("} "))
        }
        else 
        {
            $mounted = $false 
        }

        $gridview.Rows.Add($snap_date.ToString('dd.MM.yyyy HH:mm'),$snap_guid,$mounted,$snap_path)
        Clear-Variable snap_path
    }

    $groupbox.Controls.Add($gridview)

$Createbutton = New-Object System.Windows.Forms.Button
$Createbutton.Location = New-Object System.Drawing.Size(10,220)
$Createbutton.Size = New-Object System.Drawing.Size(100,25)
$Createbutton.Text = "Create"
$Createbutton.Add_Click({ $create =  Invoke-Command -ScriptBlock { cmd.exe '/c ntdsutil snapshot "Activate Instance NTDS" create quit quit' }
    [System.Windows.Forms.MessageBox]::Show(($create | Select-String -SimpleMatch "{"))})
$Form.Controls.Add($Createbutton)

$removebutton = New-Object System.Windows.Forms.Button
$removebutton.Location = New-Object System.Drawing.Size(120,220)
$removebutton.Size = New-Object System.Drawing.Size(100,25)
$removebutton.Text = "Remove"
$removebutton.Add_Click({$command = '/c ntdsutil snapshot "delete ' + $gridview.CurrentRow.Cells["GUID"].Value + '" quit quit"'
    $remove = Invoke-Command -ScriptBlock { cmd.exe $command}
    [System.Windows.Forms.MessageBox]::Show(($remove | Select-String -SimpleMatch "{")[1])
})
$Form.Controls.Add($removebutton)

$mountbutton = New-Object System.Windows.Forms.Button
$mountbutton.Location = New-Object System.Drawing.Size(230,220)
$mountbutton.Size = New-Object System.Drawing.Size(100,25)
$mountbutton.Text = "Mount"
$mountbutton.Add_Click({
    if($gridview.CurrentRow.Cells["Is Mounted"].Value -like "False")
    {
        $command = '/c ntdsutil snapshot "mount ' + $gridview.CurrentRow.Cells["GUID"].Value + '" quit quit"'
        $mount = Invoke-Command -ScriptBlock { cmd.exe $command}
        [System.Windows.Forms.MessageBox]::Show(($mount | Select-String -SimpleMatch "{")[1])
    }
    else
    {
        [System.Windows.Forms.MessageBox]::Show("Snapshot already mounted")   
    }
})
$Form.Controls.Add($mountbutton)

$unmountbutton = New-Object System.Windows.Forms.Button
$unmountbutton.Location = New-Object System.Drawing.Size(340,220)
$unmountbutton.Size = New-Object System.Drawing.Size(100,25)
$unmountbutton.Text = "Unmount"
$unmountbutton.Add_Click({
    if($gridview.CurrentRow.Cells["Is Mounted"].Value -like "True")
    {
        $command = '/c ntdsutil snapshot "unmount ' + $gridview.CurrentRow.Cells["GUID"].Value + '" quit quit"'
        $unmount = Invoke-Command -ScriptBlock { cmd.exe $command}
        [System.Windows.Forms.MessageBox]::Show(($unmount | Select-String -SimpleMatch "{")[1])
    }
    else
    {
        [System.Windows.Forms.MessageBox]::Show("Snapshot didn't mounted")   
    }})
$Form.Controls.Add($unmountbutton)

$refreshbutton = New-Object System.Windows.Forms.Button
$refreshbutton.Location = New-Object System.Drawing.Size(450,220)
$refreshbutton.Size = New-Object System.Drawing.Size(100,25)
$refreshbutton.Text = "Refresh"
$refreshbutton.Add_Click({
    $form.Dispose()
    $Form.Close()
    Form
    })
$Form.Controls.Add($refreshbutton)

$exitbutton = New-Object System.Windows.Forms.Button
$exitbutton.Location = New-Object System.Drawing.Size(560,220)
$exitbutton.Size = New-Object System.Drawing.Size(100,25)
$exitbutton.Text = "Exit"
$exitbutton.Add_Click({$Form.Close()})
$Form.Controls.Add($exitbutton)

$Form.ShowDialog()
}

Form