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
'tekst dosyayı okumak için
Imports System.IO

'xml dosyayı okumak için
'Imports System.Xml

'windows formlarını almak için
Imports System.Windows.Forms

'Registry yi okumak için - Sisiya Monitor için (Bundan sonra "Monitor" yazacak. 
Imports Microsoft.Win32

' date time özelliklerini kullanmak için
Imports System.Globalization




Public Class Form1

    ' ----------------------------------------------------------------------------------------- 
    'formda bir adet notifyicon (adı: S_Icon) 
    ' 2 adet contextmenustript (adları: S_Menu; sol klik için, M_Menu; sağ klik için)
    ' 1 adet Timer (adı: Timer1)
    ' 2 adet TextBox (TextBox1: xml dosyanın path'ı, TextBox2: xml dosyanın adı için) ve bunların label'leri
    ' Bir adet resim (logo) 
    ' Bir adet datagridview var.
    '--------------------------------------------------------------------------------------------

    'Link'ini açtığımız menü adımı bilgisini taşımak için değişken oluşturuyoruz.
    Dim yyyy As String

    'her node'a ait değerleri alacağımız bir dizi
    Dim arr(10, 100) As String

    'tray icon a bağlı menü sadece menü isimlerini taşıyor linki alabilmek için bu değişkeni kullanıyoruz.
    Dim zzzz As String

    'döngü için
    Dim zz As Integer
    Dim x As Integer
    Dim kk As Integer

    ' Xml linki 
    Dim Xml_file As String

    ' hata ve uyarı gibi imajları taşıyacağımız resim değişkeni
    Dim s_ As Image

    '------------------------------------ Monitor
    Dim file_list() As String
    Dim sis_events As String

    Dim sisiya_path As String
    Dim xxx As Integer
    Dim y As Integer
    Dim ayrac As String
    Dim dosya_basligi As String

    '-------------------------------------

    Dim ekran As Boolean = False

    'form açılış

    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

 
        'configurasyon dosyasını tanımlıyoruz.
        Dim oRead As System.IO.StreamReader
        Dim conf_file As String
        Dim Path1 As String
        Path1 = Application.UserAppDataPath

        ' MsgBox(Path1)
        conf_file = Path1 & "\sisiya_client_gui.conf"

        Timer1.Stop()
        
        'configurasyon dosyasının yolunu kontrol ediyoruz.
        If Dir(conf_file) = "" Then MsgBox("Please add configuration file 'sisiya_client_gui.conf' to: " & Path1 & "!") : Me.Show() : GoTo sonu

        'configurasyon dosyasını okuyoruz: burada xml dosya linki ve adını tanımlıyoruz: textbox içine. Textbox1 ve Texbox2 deki değerlerin unutulmaması için bunları textboxlardan ayrılırken kaydetmiş olmalıyız. Bakınız 'Sub TextBox1_Leave' ve 'Sub TextBox1_Leave'.
        oRead = IO.File.OpenText(conf_file)
        TextBox1.Text = oRead.ReadLine()
        TextBox2.Text = oRead.ReadLine()
        dosya_basligi = oRead.ReadLine()
        ayrac = oRead.ReadLine()
        oRead.Close()


        'Zamanlanmış görevi yani ana akışı çalıştırıyoruz.
        Timer1.Start()

sonu:

        'task bar icon sağ klik menü için (M_menu) resimleri tanımlıyoruz. Diğerleri form içinden girildi.
        M_Baslik.Image = My.Resources.Resources.sisiya_client_gui_18
        ToolStripMenuItemPreferences.Image = My.Resources.Resources.sisiya_client_gui_21
        ToolStripMenuItemClose.Image = My.Resources.Resources.back32


    End Sub

    'Addhandler ile gönderilen task bar icon sol klik menü için linkleri tanımlıyoruz. 
    Private Sub MenuItem_gotClicked(ByVal sender As Object, ByVal e As System.EventArgs)
        ' sender = the clicked menuitem (but more generally 'typed' as Object)
        ' let's make sender easier to use by 'strongly' typing it so you can access 
        ' the ToolStripMenuItem's properties directly:

        'sender değerini alıyoruz.
        Dim zClickedMenuItem As ToolStripMenuItem = sender

        ' arr dizisinde birinci kolon ad (icon'daki sol menüde görünen) için link olarak 2. kolonu tanımlıyoruz.
        ' MsgBox(sender.ToString)
        'başlık için
        If sender.ToString = TextBox1.Text Then zzzz = TextBox1.Text : GoTo sona

        'değerler için
        For xx = 1 To x
            If arr(1, xx) = sender.ToString Then zzzz = arr(2, xx) : GoTo sona
        Next

sona:
        'linke basılınca bu linke gitmesini sağlıyoruz.
        '        System.Diagnostics.Process.Start(zzzz)

        'menüyü kapatıyoruz.
        S_Menu.Close()

    End Sub

    'TaskBar icon'a sol klikle basılınca ne yapılacağını tanımlıyoruz.
    Private Sub S_Icon_MouseClick(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles S_Icon.MouseClick

        'Burada sağ klik'i direkt notifyicon a contextmenustrip (M_Menu) bağlayarak hallediyoruz. Aşağıdaki yordam sadece sol için.

        'sol clik'e herbir basışta menüyü bir açıp bir kapaması için iki yordam kullanıyoruz. kk burada son basılışın ne olduğunu bize söylüyor.
        If e.Button = Windows.Forms.MouseButtons.Left And kk = 0 Then S_Menu.Show(MousePosition) : M_Menu.Close() : kk = 1 : GoTo atlama
        If e.Button = Windows.Forms.MouseButtons.Left And kk = 1 Then S_Menu.Close() : M_Menu.Close() : kk = 0

atlama:
        'Sağ klik e basınca sol menünün kapanmasını sağlıyoruz.
        If e.Button = Windows.Forms.MouseButtons.Right Then S_Menu.Close()

    End Sub

    ' taskbar icon a çift tıklayınca sisiyanın ana sayfasına gitmasini sağlıyoruz. 
    Private Sub S_Icon_MouseDoubleClick(ByVal sender As System.Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles S_Icon.MouseDoubleClick
        System.Diagnostics.Process.Start("http://www.sisiya.net")
    End Sub

    'sağ klik menüde kapatma (close) düğmesine basınca form bilgilerini normale döndürüp akışı durdurup formu yani programı kapatıyoruz.
    Private Sub ToolStripMenuItemClose_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ToolStripMenuItemClose.Click

        Me.WindowState = FormWindowState.Normal
        Me.Visible = True

        'icon program kapandıktan sonra da taskbar da kalıyor bu nedenle elle kapatıyoruz.
        S_Icon.Visible = False

        End

        Me.Close()


    End Sub

    'ana formu açıyoruz: sağ klik menüsünden
    Private Sub ToolStripMenuItemPreferences_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles ToolStripMenuItemPreferences.Click
        '        Timer1.Stop()
        'Me.DataGridView1.Width = 550
        'Me.DataGridView1.Height = 311
        ekran = True

        Me.Show()
        Me.WindowState = FormWindowState.Normal
    End Sub


    'Configure edebilmek için xml file path'ın ait textbox dan çıkınca bu değeri alıp bir text dosyaya yazıyoruz. Bir sonraki çalıştırışta böylelikle konfigürasyon bilgileri son şeklinde oluyor.
    Private Sub TextBox1_Leave(ByVal sender As Object, ByVal e As System.EventArgs) Handles TextBox1.Leave

        'önce timer'ı durudurup bir sonraki açılışta kısa sürede çalışmasını sağlamak için interval (ara) yı düşürüyoruz.
        Timer1.Stop()
        Timer1.Interval = 100

        'text dosyayı ve yolunu tanımlıyoruz.
        Dim output_file As String
        Dim Path1 As String
        Path1 = Application.StartupPath

        ' Text dosyayı yazmak için açoyoruz. 
        output_file = Path1 + "\sisiya_client_gui.conf"
        Dim oWrite As System.IO.StreamWriter

        'append değil üzerine yazarak text dosyayı kapatıyoruz.
        oWrite = IO.File.CreateText(output_file)
        oWrite.WriteLine(TextBox1.Text.ToString)
        oWrite.WriteLine(TextBox2.Text.ToString)
        oWrite.Close()

        'asıl yordam olan timer1'i çalıştırıyoruz.
        Timer1.Start()
    End Sub

    ' burada yapılan işlemler TextBox1 ile aynı
    Private Sub TextBox2_Leave(ByVal sender As Object, ByVal e As System.EventArgs) Handles TextBox2.Leave
        Dim output_file As String
        Dim Path1 As String
        Path1 = Application.StartupPath
        'MsgBox(Path1)

        output_file = Path1 + "\sisiya_client_gui.conf"
        Dim oWrite As System.IO.StreamWriter

        oWrite = IO.File.CreateText(output_file)
        oWrite.WriteLine(TextBox1.Text.ToString)
        oWrite.WriteLine(TextBox2.Text.ToString)
        oWrite.Close()

        Timer1.Start()

    End Sub
    'asıl yordam timer her çalıştığında aşağıdaki akışı takip ediyor.
    Private Sub Timer1_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Timer1.Tick

        'hata olursa bizi yorma çık
        '       On Error GoTo son

        '-------------------------------------- Monitor
        sisiya_path = get_path("SOFTWARE\\SisIYA_client_checks", "Path")
        '        MsgBox(sisiya_path)

        If sisiya_path = "" Then sisiya_path = "C:\Program Files\SisIYA_client_checks" : MsgBox("Yükleme bilgilerini kontrol ediniz... Can not find Registry Value.", MsgBoxStyle.Critical)
        sisiya_path = sisiya_path & "\systems"
        '--------------------------------------


        'formu gizle
        If ekran = False Then Me.Hide()

        'eski menü bilgilerini ve datagrid bilgilerini sil
        S_Menu.Items.Clear()
        DataGridView1.Rows.Clear()

        'xml'deki node'lar için string
        '        Dim str As String

        ' xml url'sini tanımlıyoruz.
        '        Xml_file = TextBox1.Text + "/" + TextBox2.Text

        'Const URLString As String = "http://sisiya.ics-group.com.tr/sisiya_rss.xml"

        'xml dokumanı tanımlıyoruz.
        '        Dim document As XmlDocument = New XmlDocument()

        'Dokumanı yüklüyoruz.
        '        document.Load(Xml_file)


        'her node'u alacağımız bir dizi
        '  Dim arr(5, 100) As String
        'xml node okuyucu
        '        Dim reader As XmlNodeReader = New XmlNodeReader(document)

        'döngüler için değişken
        '     Dim x As Integer : bunu class altında tüm sub lar için tanımladık
        '       Dim y As Integer


        'menu adımı tanımlıyoruz
        Dim zMI As ToolStripMenuItem

        '---------------------Monitor
        aktar()
        '----------------------

        '   Dim reader As XmlTextReader = New XmlTextReader(URLString)

        'değişkenleri sıfırlıyoruz.
        '        str = ""
        '        x = 0
        '        y = 0

        'XML dosyayı okuyoruz adım adım.
        '        Do While (reader.Read())

        ' Do some work here on the data.
        '            str = str & reader.Name & "= " & reader.Value & Chr(13)


        '          If reader.NodeType = XmlNodeType.Text Then
        'str= str &(reader.NodeType & " - " & reader.LocalName & " = " & reader.Value)
        ' End If
        '-->
        '       Str = ""

        'xml dosyadaki node tipine göre str'ye değer atıyoruz.
        '        Select Case reader.NodeType

        ' if Element, display its name

        '            Case XmlNodeType.Element
        ' increase tab depth
        '    Console.WriteLine("<" & reader.Name & ">")
        ' str = ("<" & reader.Name & ">")
        ' if empty element, decrease depth
        '        If reader.IsEmptyElement Then
        '      Console.WriteLine("Empty Element")
        '        Str = ("")
        '        Else : Str = ("<" & reader.Name & ">")
        '        End If

        '            Case XmlNodeType.Comment ' if Comment, display it
        '  Console.WriteLine("<!--" & reader.Value & "-->")
        '       Str = ("<!--" & reader.Value & "-->")

        '            Case XmlNodeType.Text ' if Text, display it
        '        If reader.IsEmptyElement Then
        '        Str = ""
        '        Else : Str = (reader.Value)
        '        End If
        '   Console.WriteLine(reader.Value)
        ' str = (reader.Value)
        ' if XML declaration, display it

        '            Case XmlNodeType.XmlDeclaration
        '  Console.WriteLine("<?" & reader.Name & " " & reader.Value & "?>")
        '       Str = ("<?" & reader.Name & " " & reader.Value & "?>")

        ' if EndElement, display it and decrement depth

        '            Case XmlNodeType.EndElement
        '      Console.WriteLine("</" & reader.Name & ">")
        '       Str = ("</" & reader.Name & ">")
        '
        '        End Select

        'bir önceki turdan gelen y değerine göre str değişkenini diziye atıyoruz.

        '        If y = 1 Then arr(y, x) = Str() : y = 0 'MsgBox(str)
        '        If y = 2 Then arr(y, x) = Str() : y = 0 'MsgBox(str)
        '        If y = 3 Then arr(y, x) = Str() : y = 0 'MsgBox(str)
        '        If y = 4 Then arr(y, x) = Str() : y = 0 'MsgBox(str)
        '        If y = 5 Then arr(y, x) = Str() : y = 0 'MsgBox(str)

        ' node tipine göre y değerini atıyoruz

        'bu bir üst node tüm diğer aşağıdaki nodelar bunun altında
        '        If Str() = "<item>" Then x = x + 1 'MsgBox(x)

        'alt nodeların adına göre y değerini atıyoruz. bu değer bir sonraki turda kullanılacak. üste bak.
        '        If Str() = "<title>" Then y = 1
        '        If Str() = "<link>" Then y = 2
        '        If Str() = "<description>" Then y = 3
        '        If Str() = "<pubDate>" Then y = 4
        '        If Str() = "<systemStatus>" Then y = 5

        '     MsgBox(str)
        '<--

        '        Loop


        ' Reading of the XML file has finished.
        '-----------------------------------------------------------
        Console.ReadLine() 'Pause
        '    MsgBox(str)

        'sol klik menüye kafamıza göre (burada path'ı) bir başlık satırı yazıyoruz.

        zMI = New ToolStripMenuItem()
        'zMI = New ToolStripMenuItem("S_Baslik")
        'zMI.Name = "S_Baslik"
        zMI.Text = TextBox1.Text.ToString    '"SisIYA (System Monitoring and Management Tools): www.sisiya.net "
        zMI.Image = My.Resources.Resources.sisiya_client_gui_18

        've bu satırı renklendiriyoruz.
        'MsgBox(zMI.Font.Underline)
        zMI.ForeColor = Color.White
        zMI.BackColor = Color.DarkBlue


        S_Menu.Items.Add(zMI)
        AddHandler zMI.Click, AddressOf MenuItem_gotClicked

        'dizi içindeki değerleri datagrid ve tray menu icon'a atıyoruz.
        For z = 1 To y

            'uyarinin ne zaman gelsdigini belirliyoruz    Monitor
            '-------------------------------------------------------

            Dim dateString() As String = {Mid(arr(5, z), 7, 2) & "." & Mid(arr(5, z), 5, 2) & "." & Mid(arr(5, z), 1, 4) & " " & Mid(arr(5, z), 9, 2) & ":" & Mid(arr(5, z), 11, 2)}
            Dim dateValue As Date
            dateValue = Date.Parse(dateString(0))

            Dim zaman_farki As Double
            zaman_farki = DateDiff(DateInterval.Minute, Now(), dateValue)
            zaman_farki = zaman_farki + arr(6, z)

            '--------------------------------------------------

            DataGridView1.Rows.Add(arr(7, z), (zaman_farki - arr(6, z)) * -1 & " minute ago!", arr(3, z))   'System.Math.Abs(zaman_farki) & " minute ago!"

            'ssol klik menüye atadağımız değişkenler için icon lar tanımlıyoruz.
            If arr(3, z) = "0" Then s_ = My.Resources.Resources.Info_26
            If arr(3, z) = "1" Then s_ = My.Resources.Resources.Ok_26
            If arr(3, z) = "2" Then s_ = My.Resources.Resources.Warn
            If arr(3, z) = "3" Then s_ = My.Resources.Resources.Error_26

            'Dim l_ As New EventHandler AddressOf ... bu çalışmadı 

            'zMI = New ToolStripMenuItem
            'zMI.Text = "I'm MenuItem" & zIndex.ToString("00")
            'zTS.Items.Add(zMI)
            'AddHandler zMI.Click, AddressOf MenuItem_gotClicked

            ' ------------------------------------------ eskimiş verileri almamak için if'i açınız 
            If zaman_farki > 0 Then              '    Monitor
                'işte burada sol klik menüye satırlar ekliyoruz.
                zMI = New ToolStripMenuItem
                zMI.Text = arr(7, z)  'Mid(arr(7, z), 1, 100)
                zMI.Image = s_

                S_Menu.Items.Add(zMI)
            End If           ' Monitor


            'Esas satır eklme komutu bu şekilde S_Menu.Items.Add(arr(3, z), s_, ) : (isim, icon, link) fakat linki çalışmadı

            'Menü'deki satıra basınca ne yapacağını söylüyoruz: 'sub MenuItem_gotClicked' e bak.
            AddHandler zMI.Click, AddressOf MenuItem_gotClicked

            'AddHandler S_Menu.Click, AddressOf MenuItem_gotClicked
            'AddHandler S_Menu.Items(arr(3, z)).Click, AddressOf MenuItem_gotClicked
            'AddHandler S_Menu.Click, Function (GetMenuitem_(ByVal l_ As String))

        Next

        'TrayIcon'daki icon un genel durum nasılsa ona göre değişmesini sağlıyoruz. Bir adet hata görse hemen çıkıp error icon'ını alıyor yoksa uyarı yoksa ok.
        'Önemli nokta tüm icon ve resimleri proje ana sayfasında resources bölümüne kaydettik.
        S_Icon.Icon = My.Resources.Resources.Ok_16
        For z = 1 To y
            'S_Icon.Icon = SisIYA.My.Resources.Resources.Ok_16
            If arr(3, z) = "3" Then S_Icon.Icon = My.Resources.Resources.Error_16 : GoTo sonnna
            If arr(3, z) = "2" Then S_Icon.Icon = My.Resources.Resources.ProgressWarn : GoTo sonnna
sonnna:
        Next

son:
        'zamanlamayı daha seyrek hale getiriyoruz. 60 saniye yani bir dakika = 60000 msaniye
        Timer1.Interval = 10000

    End Sub


    ' form yenide boyutlandırıldıüğında içindeki datagrid in ona eş büyüyüp küçülmesini sağlıyoruz. Bunun için datagrid özelliklerinde otosize otomatik olmamalı
    Private Sub Form1_ResizeEnd(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.ResizeEnd
        Me.DataGridView1.Width = Me.Width - 38
        Me.DataGridView1.Height = Me.Size.Height - 160
    End Sub

    'formun kapatma (X) düğmesine basılınca programın kapanmaması için taskbar da minimize olması için önceden tanımlıyoruz.
    Private Sub Form1_FormClosing(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosingEventArgs) Handles Me.FormClosing

        'What we will do here is trap the closing of the application and send the application    
        'to the system tray (or so it will appear, we will just make it invisible, re-showing        
        'it will be up to you and your notify icon)   
        'First minimize the form         
        Me.WindowState = FormWindowState.Minimized
        'Now make it invisible (make it look like it went into the system tray)        
        Me.Visible = False
        e.Cancel = True
        'nfi.Visible = True
        'MsgBox("Program has been minimized to the task bar.")

    End Sub

    ' Resme tıklanınca xml in ana sayfasına gitmesini sağlıyoruz.
    Private Sub PictureBox1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles PictureBox1.Click
        System.Diagnostics.Process.Start(TextBox1.Text.ToString)
    End Sub

    'sağ klik menüsünde baslık'a basınca tanıtım yapıyoruz
    Private Sub M_Baslik_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles M_Baslik.Click
        System.Diagnostics.Process.Start("http://www.sisiya.net")
    End Sub
    '-------------------------------------Monitor
    Function get_path(ByVal Reg_Key, ByVal Value_Name)

        Dim regVersion As RegistryKey
        regVersion = Registry.LocalMachine.OpenSubKey(Reg_Key, False)

        Dim intVersion As String = ""

        If (Not regVersion Is Nothing) Then
            intVersion = regVersion.GetValue(Value_Name, "C:\Program Files\SisIYA_client_checks")
            regVersion.Close()
        End If

        Return intVersion
    End Function
    '-------------------------------------Monitor


    Private Sub aktar()
        y = 0
        For Each foundFile As String In My.Computer.FileSystem.GetFiles(sisiya_path, FileIO.SearchOption.SearchAllSubDirectories, dosya_basligi & "*.txt")
            '            ListBox1.Items.Add(foundFile)

            Using MyReader As New Microsoft.VisualBasic.FileIO.TextFieldParser(foundFile)
                MyReader.TextFieldType = FileIO.FieldType.Delimited
                MyReader.SetDelimiters(ayrac)
                Dim currentRow As String()

                While Not MyReader.EndOfData

                    Try
                        currentRow = MyReader.ReadFields()
                        Dim currentField As String
                        xxx = 0
                        y = y + 1
                        For Each currentField In currentRow
                            xxx = xxx + 1
                            arr(xxx, y) = currentField
                            '                            MsgBox(currentField)
                        Next

                    Catch ex As Microsoft.VisualBasic.FileIO.MalformedLineException
                        MsgBox("Line " & ex.Message & "is not valid and will be skipped.")
                    End Try

                End While

            End Using

        Next
    End Sub

End Class



