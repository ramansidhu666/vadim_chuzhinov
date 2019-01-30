﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using Property_cls;

namespace Property.Controls
{
    public partial class logo : System.Web.UI.UserControl
    {

        #region Global

        cls_Property clsobj = new cls_Property();

        #endregion Global

        #region Page Load

        protected void Page_Load(object sender, EventArgs e)
        {
            GetLogoImage();
        }

        #endregion Page Load

        #region Other Method

        protected void GetLogoImage()
        { 
            try
            {
                DataTable dt = clsobj.GetSiteSettings();
               
                if (dt.Rows.Count > 0)
                {
                    byte[] imagedata = (byte[])dt.Rows[0]["UploadLogo"];
                    if (imagedata.Length > 0)
                    {
                        Session["MyLogo"] = imagedata;
                        imgLogo.Visible = true;
                        imgLogo.ImageUrl = "~/ShowLogo.aspx";
                    }
                    else
                    {
                        imgLogo.Visible = false;
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        #endregion Other Method

    }
}