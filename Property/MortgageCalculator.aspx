﻿<%@ Page Title="" Language="C#" MasterPageFile="~/PropertyNew.Master" AutoEventWireup="true"
    CodeBehind="MortgageCalculator.aspx.cs" Inherits="Property.MortgageCalculator" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
            <style >
                .smpc-div {
                    background-color: #f9f9f9;
                    border: 1px solid #cccccc;
                    padding: 15px;
                }
                .smpc-error {
                    font-family: Verdana, Arial, Helvetica, sans-serif;
                    font-size: 10px;
                    color: #ca0000;
                }
                .smpc-monthlypayment {
                    margin-top: 15px;
                    font-size: 24px;
                    color: #ca0000;
                }
                .smpc-friendlyreminder {
                    display: none;
                }
            </style>
            <script type="text/javascript">
                function validNumber(fieldinput) {
                    var unicode = fieldinput.charCode ? fieldinput.charCode : fieldinput.keyCode;
                    if ((unicode != 8) && (unicode != 46)) {
                        if (unicode < 48 || unicode > 57) 
                            return false; 
                    }
                }
                function myPayment() {
                    document.getElementById('loanError').innerHTML = '';
                    document.getElementById('yearsError').innerHTML = '';
                    document.getElementById('rateError').innerHTML = '';
                    if ((document.getElementById('loan').value === null) || (document.getElementById('loan').value.length === 0) || (isNaN(document.getElementById('loan').value) === true)) {
                        document.getElementById('monthlyPayment').innerHTML = 'Please enter the missing information.';
                        document.getElementById('loanError').innerHTML = 'Numeric value required. Example: 165000';
                    } else if ((document.getElementById('years').value === null) || (document.getElementById('years').value.length === 0) || (isNaN(document.getElementById('years').value) === true)) {
                        document.getElementById('monthlyPayment').innerHTML = 'Please enter the missing information.';
                        document.getElementById('yearsError').innerHTML = 'Numeric value required. Example: 30';
                    } else if ((document.getElementById('rate').value === null) || (document.getElementById('rate').value.length === 0) || (isNaN(document.getElementById('rate').value) === true)) {
                        document.getElementById('monthlyPayment').innerHTML = 'Please enter the missing information.';
                        document.getElementById('rateError').innerHTML = 'Numeric value required. Example: 5.25';
                    } else {
                        var loanprincipal = document.getElementById('loan').value;
                        var months = document.getElementById('years').value * 12;
                        var interest = document.getElementById('rate').value / 1200;
                        document.getElementById('monthlyPayment').innerHTML = 'Your monthly mortgage payment will be ' + '$' + (loanprincipal * interest / (1 - (Math.pow(1 / (1 + interest), months)))).toFixed(2) + '.';
                        document.getElementById('friendlyReminder').style.display = 'block';
                    }
                }
                function myPaymentReset() {
                    document.getElementById('monthlyPayment').innerHTML = 'Values reset';
                    document.getElementById('friendlyReminder').style.display = 'none';
                    document.getElementById('loanError').innerHTML = '';
                    document.getElementById('yearsError').innerHTML = '';
                    document.getElementById('rateError').innerHTML = '';
                    document.getElementById('loan').value = null;
                    document.getElementById('years').value = null;
                    document.getElementById('rate').value = null;
                }
            </script>
    <div class="inner_calculator">
        <div class="free_nw_cls_bg">
            <div class="col-md-2 col-sm-2"></div>
            <div class="col-md-8 col-sm-8">
                <div class="calc_inner_cls">
                    <div class="mortgge_clc">
                        <h4>Mortgage Payment Calculator</h4>
                        <p>
                            Want to know how much and how often your mortgage payments will be? Use this calculator to compare options and find one that's right for you.
                        </p>
                    </div>
                    <div class="smpc-div">
                        <p>
                            How much will you be borrowing?<br>
                            <input type="text" onkeypress="return validNumber(event)" name="loan" id="loan" size="10" />
                            <span class="smpc-error" id="loanError"></span>
                        </p>
                        <p>
                            What will be the term of this mortgage (in years)?<br>
                            <input type="text" onkeypress="return validNumber(event)" name="years" id="years" size="5" />
                            <span class="smpc-error" id="yearsError"></span>
                        </p>
                        <p>
                            What will be the interest rate?<br>
                            <input type="text" onkeypress="return validNumber(event)" name="rate" id="rate" size="5" />
                            <span class="smpc-error" id="rateError"></span>
                        </p>

                        <p style="font-weight: bold; color: #3f6f55;">Calculation Notes</p>
                        <p>To calculate an amount for you, we've assumed the interest rate is fixed over the entire amortization period. In fact, interest is usually renegotiated at the end of each mortgage term, when rates may be higher or lower. Other options, such as a variable interest rate, can also result in a different payment amount. For more information, contact your mortgage professional.</p>
                        <input type="button" onclick="return myPayment()" value="Calculate" />
                        <input type="button" onclick="    return myPaymentReset()" value="Reset" />
                        <small>Instructions: Enter numbers and decimal points. No commas or other characters.</small>
                        <p class="smpc-monthlypayment" id="monthlyPayment"></p>
                        <p class="smpc-friendlyreminder" id="friendlyReminder">This is your principal + interest payment, or in other words, what you send to the bank each month. But remember, you will also have to budget for homeowners insurance, real estate taxes, and if you are unable to afford a 20% down payment, Private Mortgage Insurance (PMI). These additional costs could increase your monthly outlay by as much 50%, sometimes more.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-2 col-sm-2"></div>
</div>
        <script type="text/javascript" src="http://www.cmhc.ca/js/jquery-cmhc.js"></script>
        <script type="text/javascript" src="http://www.cmhc.ca/js/jquery/iframe-resizer/js/iframeResizer.min.js"></script>
        <script type="text/javascript">$('iframe').iFrameResize();</script>
    </div>
</asp:Content>
