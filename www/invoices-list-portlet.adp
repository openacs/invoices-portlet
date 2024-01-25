<script src="/resources/acs-templating/calendar.js"></script>

<table width="100%">
<tr>
<td>
<form action="@current_url@">
  @export_vars;noquote@
  <table>
    <tr>
      <td>#invoices.iv_invoice_start_date# <input type=text name="start_date" size=12 value="@start_date@" id=sel1><input type='reset' value=' ... ' onclick="return showCalendar('sel1', 'y-m-d');"></td>
      <td>#invoices.iv_invoice_end_date# <input type=text name="end_date" size=12 value="@end_date@" id=sel2><input type='reset' value=' ... ' onclick="return showCalendar('sel2', 'y-m-d');"></td></td>
      <td><input type=submit name="submit" value="#invoices.ok#"></td>
    </tr>
    <if @clear_p;literal@ true>
      <tr>
        <td><a href="@clear_link@">#invoices.clear#</a></td>
      </tr>
    </if>
  </table>
</form>
</td>

<td align=right>
<form action="/invoices/invoice-search">
  <table>
    <tr>
      <td>#invoices.iv_invoice_invoice_nr# <input type=text name="invoice_nr" size=10></td>
      <td><input type=submit name="submit" value="#invoices.ok#"></td>
    </tr>
  </table>
</form>
</td>
</tr>
</table>

<include src="/packages/invoices/lib/invoice-list" row_list="@row_list@" organization_id="@organization_id@" base_url="@base_url@" page="@page@" orderby="@orderby@" page_num="@page_num@" start_date="@start_date@" end_date="@end_date@">
