'######################################################################################
'
'
'    Copyright (C) 2009  Ömer Lütfü Cunbul & Erdal Mutlu
'
'    This program is free software; you can redistribute it and/or modify
'    it under the terms of the GNU General Public License as published by
'    the Free Software Foundation; either version 2 of the License, or
'    (at your option) any later version.
'
'    This program is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY; without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'    GNU General Public License for more details.
'
'    You should have received a copy of the GNU General Public License
'    along with this program; if not, write to the Free Software
'    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
'
'
'######################################################################################
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(Form1))
        Me.DataGridView1 = New System.Windows.Forms.DataGridView
        Me.Title = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.pDate = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.Status = New System.Windows.Forms.DataGridViewTextBoxColumn
        Me.S_Icon = New System.Windows.Forms.NotifyIcon(Me.components)
        Me.M_Menu = New System.Windows.Forms.ContextMenuStrip(Me.components)
        Me.M_Baslik = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripMenuItemPreferences = New System.Windows.Forms.ToolStripMenuItem
        Me.ToolStripMenuItemClose = New System.Windows.Forms.ToolStripMenuItem
        Me.S_Menu = New System.Windows.Forms.ContextMenuStrip(Me.components)
        Me.TextBox1 = New System.Windows.Forms.TextBox
        Me.TextBox2 = New System.Windows.Forms.TextBox
        Me.Label2 = New System.Windows.Forms.Label
        Me.Label3 = New System.Windows.Forms.Label
        Me.Timer1 = New System.Windows.Forms.Timer(Me.components)
        Me.PictureBox1 = New System.Windows.Forms.PictureBox
        CType(Me.DataGridView1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.M_Menu.SuspendLayout()
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'DataGridView1
        '
        Me.DataGridView1.AllowDrop = True
        Me.DataGridView1.AllowUserToOrderColumns = True
        Me.DataGridView1.AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode.AllCells
        Me.DataGridView1.AutoSizeRowsMode = System.Windows.Forms.DataGridViewAutoSizeRowsMode.AllCells
        Me.DataGridView1.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.Title, Me.pDate, Me.Status})
        Me.DataGridView1.Location = New System.Drawing.Point(15, 100)
        Me.DataGridView1.Name = "DataGridView1"
        Me.DataGridView1.RowTemplate.Resizable = System.Windows.Forms.DataGridViewTriState.[True]
        Me.DataGridView1.Size = New System.Drawing.Size(550, 311)
        Me.DataGridView1.TabIndex = 0
        Me.DataGridView1.TabStop = False
        '
        'Title
        '
        Me.Title.HeaderText = "Title"
        Me.Title.Name = "Title"
        Me.Title.Width = 52
        '
        'pDate
        '
        Me.pDate.HeaderText = "Time"
        Me.pDate.Name = "pDate"
        Me.pDate.Width = 55
        '
        'Status
        '
        Me.Status.HeaderText = "Status"
        Me.Status.Name = "Status"
        Me.Status.Width = 62
        '
        'S_Icon
        '
        Me.S_Icon.ContextMenuStrip = Me.M_Menu
        Me.S_Icon.Icon = CType(resources.GetObject("S_Icon.Icon"), System.Drawing.Icon)
        Me.S_Icon.Text = "SisIYA"
        Me.S_Icon.Visible = True
        '
        'M_Menu
        '
        Me.M_Menu.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.M_Baslik, Me.ToolStripMenuItemPreferences, Me.ToolStripMenuItemClose})
        Me.M_Menu.Name = "M_Menu"
        Me.M_Menu.Size = New System.Drawing.Size(116, 70)
        Me.M_Menu.Text = "SisIYA"
        '
        'M_Baslik
        '
        Me.M_Baslik.BackColor = System.Drawing.Color.DarkBlue
        Me.M_Baslik.ForeColor = System.Drawing.Color.White
        Me.M_Baslik.Name = "M_Baslik"
        Me.M_Baslik.Size = New System.Drawing.Size(115, 22)
        Me.M_Baslik.Text = "SisIYA"
        '
        'ToolStripMenuItemPreferences
        '
        Me.ToolStripMenuItemPreferences.Name = "ToolStripMenuItemPreferences"
        Me.ToolStripMenuItemPreferences.Size = New System.Drawing.Size(115, 22)
        Me.ToolStripMenuItemPreferences.Text = "Open"
        '
        'ToolStripMenuItemClose
        '
        Me.ToolStripMenuItemClose.Name = "ToolStripMenuItemClose"
        Me.ToolStripMenuItemClose.Size = New System.Drawing.Size(115, 22)
        Me.ToolStripMenuItemClose.Text = "Close"
        '
        'S_Menu
        '
        Me.S_Menu.Font = New System.Drawing.Font("Tahoma", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(162, Byte))
        Me.S_Menu.Name = "S_Menu"
        Me.S_Menu.RenderMode = System.Windows.Forms.ToolStripRenderMode.Professional
        Me.S_Menu.Size = New System.Drawing.Size(61, 4)
        Me.S_Menu.Text = "SisIYA"
        '
        'TextBox1
        '
        Me.TextBox1.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(162, Byte))
        Me.TextBox1.ForeColor = System.Drawing.Color.ForestGreen
        Me.TextBox1.Location = New System.Drawing.Point(334, 12)
        Me.TextBox1.Name = "TextBox1"
        Me.TextBox1.Size = New System.Drawing.Size(217, 20)
        Me.TextBox1.TabIndex = 3
        Me.TextBox1.TabStop = False
        Me.TextBox1.Text = "http://sisiya.sisiya.net"
        Me.TextBox1.Visible = False
        '
        'TextBox2
        '
        Me.TextBox2.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(162, Byte))
        Me.TextBox2.ForeColor = System.Drawing.Color.OrangeRed
        Me.TextBox2.Location = New System.Drawing.Point(334, 55)
        Me.TextBox2.Name = "TextBox2"
        Me.TextBox2.Size = New System.Drawing.Size(217, 20)
        Me.TextBox2.TabIndex = 4
        Me.TextBox2.TabStop = False
        Me.TextBox2.Text = "sisiya_rss.xml"
        Me.TextBox2.Visible = False
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(162, Byte))
        Me.Label2.ForeColor = System.Drawing.Color.ForestGreen
        Me.Label2.Location = New System.Drawing.Point(251, 15)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(77, 13)
        Me.Label2.TabIndex = 5
        Me.Label2.Text = "Sisiya URL: "
        Me.Label2.Visible = False
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(162, Byte))
        Me.Label3.ForeColor = System.Drawing.Color.OrangeRed
        Me.Label3.Location = New System.Drawing.Point(228, 58)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(100, 13)
        Me.Label3.TabIndex = 6
        Me.Label3.Text = "RSS File Name: "
        Me.Label3.Visible = False
        '
        'Timer1
        '
        Me.Timer1.Interval = 5000
        '
        'PictureBox1
        '
        Me.PictureBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None
        Me.PictureBox1.Image = SisIYA.My.Resources.Resources.sisiya_k()
        Me.PictureBox1.Location = New System.Drawing.Point(15, 12)
        Me.PictureBox1.Name = "PictureBox1"
        Me.PictureBox1.Size = New System.Drawing.Size(190, 71)
        Me.PictureBox1.TabIndex = 7
        Me.PictureBox1.TabStop = False
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(582, 431)
        Me.ContextMenuStrip = Me.S_Menu
        Me.Controls.Add(Me.DataGridView1)
        Me.Controls.Add(Me.TextBox1)
        Me.Controls.Add(Me.PictureBox1)
        Me.Controls.Add(Me.TextBox2)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.Label2)
        Me.ForeColor = System.Drawing.Color.Brown
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.MaximizeBox = False
        Me.Name = "Form1"
        Me.Text = "SisIYA Client GUI"
        CType(Me.DataGridView1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.M_Menu.ResumeLayout(False)
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents DataGridView1 As System.Windows.Forms.DataGridView
    Friend WithEvents S_Icon As System.Windows.Forms.NotifyIcon
    Friend WithEvents S_Menu As System.Windows.Forms.ContextMenuStrip
    Friend WithEvents M_Menu As System.Windows.Forms.ContextMenuStrip
    Friend WithEvents ToolStripMenuItemClose As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents ToolStripMenuItemPreferences As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents TextBox1 As System.Windows.Forms.TextBox
    Friend WithEvents TextBox2 As System.Windows.Forms.TextBox
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Timer1 As System.Windows.Forms.Timer
    Friend WithEvents M_Baslik As System.Windows.Forms.ToolStripMenuItem
    Friend WithEvents PictureBox1 As System.Windows.Forms.PictureBox
    Friend WithEvents Title As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents pDate As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents Status As System.Windows.Forms.DataGridViewTextBoxColumn

End Class
