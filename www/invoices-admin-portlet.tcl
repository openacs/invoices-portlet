# packages/invoices-portlet/www/invoices-admin-portlet.tcl

ad_page_contract {
    
    Display the admin portlet.
    
    @author Bjoern Kiesbye (bjoern_kiesbye@web.de)
    @creation-date 2005-06-21
    @arch-tag: ed3ff5eb-dcf2-4cea-96cd-824aa89874f1
    @cvs-id $Id$
} {
    
} 

set admin_href "[dotlrn_community::get_community_url [dotlrn_community::get_community_id_from_url]]invoices/admin"