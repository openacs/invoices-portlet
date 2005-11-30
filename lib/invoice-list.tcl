if {![info exists format]} {
    set format "normal"
}
if {![info exists orderby]} {
    set orderby ""
}
if {![info exists page_size]} {
    set page_size "25"
}

if {![info exists base_url]} {
    set base_url [apm_package_url_from_id $package_id]
}

foreach optional_param {organization_id row_list} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]
set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]]


# Using the the same instance of invoices
set package_id [apm_package_id_from_key invoices]

set community_id [dotlrn_community::get_community_id]
set date_format [lc_get formbuilder_date_format]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"


set actions [list "[_ invoices.iv_invoice_New]" [export_vars -base ${base_url}/invoice-add {organization_id}] "[_ invoices.iv_invoice_New2]" "[_ invoices.iv_invoice_credit_New]" [export_vars -base ${base_url}/invoice-credit {organization_id}] "[_ invoices.iv_invoice_credit_New2]" "[_ invoices.iv_offer_2]" [export_vars -base ${base_url}/offer-list {organization_id}] "[_ invoices.iv_offer_2]" "[_ invoices.projects]" $pm_base_url "[_ invoices.projects]"]

template::list::create \
    -name iv_invoice \
    -key invoice_id \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -elements {
	invoice_nr {
	    label {[_ invoices.iv_invoice_invoice_nr]}
	}
        title {
	    label {[_ invoices.iv_invoice_1]}
	    link_url_eval {[export_vars -base "${base_url}/invoice-ae" {invoice_id {mode display}}]}
        }
        description {
	    label {[_ invoices.iv_invoice_Description]}
        }
        total_amount {
	    label {[_ invoices.iv_invoice_total_amount]}
	    display_template {@iv_invoice.total_amount@ @iv_invoice.currency@}
        }
        paid_amount {
	    label {[_ invoices.iv_invoice_paid_amount]}
	    display_template {<if @iv_invoice.paid_currency@ not nil>@iv_invoice.paid_amount@ @iv_invoice.paid_currency@</if>}
        }
	recipient {
	    label "[_ invoices.iv_invoice_recipient]"
	    display_template "@iv_invoice.recipient;noquote@"
	}
	creation_user {
	    label {[_ invoices.iv_invoice_creation_user]}
	    display_template {<a href="@iv_invoice.creator_link@">@iv_invoice.first_names@ @iv_invoice.last_name@</if>}
	}
	creation_date {
	    label {[_ invoices.iv_invoice_creation_date]}
	}
	due_date {
	    label {[_ invoices.iv_invoice_due_date]}
	}
        action {
	    display_template {<if @iv_invoice.cancelled_p@ eq f><a href="@iv_invoice.edit_link@">#invoices.Edit#</a>&nbsp;<a href="@iv_invoice.cancel_link@">#invoices.Cancel#</a></if><if @paid_currency@ nil>&nbsp;<a href="@iv_invoice.delete_link@">#invoices.Delete#</a></if>
	    }
	}
    } -actions $actions -sub_class narrow \
    -page_size_variable_p 1 \
    -page_size $page_size \
    -page_flush_p 0 \
    -pass_properties {base_url $base_url} \
    -page_query_name iv_invoice_paginated \
    -filters {organization_id {}} \
    -formats {
	normal {
	    label "[_ invoices.Table]"
	    layout table
	    row $row_list
	}
	csv {
	    label "[_ invoices.CSV]"
	    output csv
	    page_size 0
	    row $row_list
	}
    }


set contacts_p [apm_package_installed_p contacts]

db_multirow -extend {creator_link edit_link cancel_link delete_link recipient} iv_invoice iv_invoice {} {
    # Ugly hack. We should find out which contact package is linked
    set creator_link "/contacts/$creation_user"
    set edit_link [export_vars -base "${base_url}/invoice-ae" {invoice_id}]
    set cancel_link [export_vars -base "${base_url}/invoice-cancellation" {organization_id {parent_id $invoice_rev_id}}]
    set delete_link [export_vars -base "${base_url}/invoice-delete" {invoice_id}]
    if {[empty_string_p $total_amount]} {
	set total_amount 0
    }
    set total_amount [format "%.2f" $total_amount]
    if {![empty_string_p $paid_amount]} {
	set paid_amount [format "%.2f" $paid_amount]
    }
    if { $contacts_p } {
	set recipient "<a href=\"[contact::url -party_id $recipient_id]\">[contact::name -party_id $recipient_id]</a>"
    } else {
	set recipient [person::name -person_id $recipient_id]
    }
}
