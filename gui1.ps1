Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Hello World!"
$Form.Size = New-Object System.Drawing.Size(640,480)
$Form.FormBorderStyle = "Fixed3D"

$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Wprowadź tekst:"
$Label.Size = New-Object System.Drawing.Size(100,25)
$Label.Location = New-Object System.Drawing.Size(15,15)

$Label.Font = New-Object System.Drawing.Font("SegoeUI",8.25,[System.Drawing.FontStyle]::Bold)
$Label.ForeColor = [System.Drawing.Color]::Red

$Form.Controls.Add($Label)

$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Text = "Wprowadź tekst"
$TextBox.Size = New-Object System.Drawing.Size(120,25)
$TextBox.Location = New-Object System.Drawing.Size(115,11)

$Form.Controls.Add($TextBox)

$Button = New-Object System.Windows.Forms.Button
$Button.Text = "OK"
$Button.Size = New-Object System.Drawing.Size(100,25)
$Button.Location = New-Object System.Drawing.Size(55,40)

$Button.Add_Click({
    [System.Windows.Forms.MessageBox]::Show($TextBox.Text, "Tytuł", "OK", "Information")
})

$Form.Controls.Add($Button)

$Form.ShowDialog()
