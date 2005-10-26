set required_param_list [list]
set optional_param_list [list orderby elements base_url package_id organization_id page]
set optional_unset_list [list status_id]

foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
	if {[empty_string_p [set $optional_unset]]} {
	    unset $optional_unset
	}
    }
}

if {![info exists format]} {
    set format "normal"
}
if {![info exists page_size]} {
    set page_size "25"
}

if {[empty_string_p $package_id]} {
    set package_id [apm_package_id_from_key "invoices"]
}

if {[empty_string_p $base_url]} {
    set base_url [apm_package_url_from_id $package_id]
}

foreach element $elements {
    append row_list "$element {}\n"
}

set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]

if {$dotlrn_club_id > 0} {
    set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]]
}

#set package_id [ad_conn package_id]
set date_format [lc_get formbuilder_date_format]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"

if {[exists_and_not_null organization_id]} {
    set price_list_id [iv::price_list::get_list_id -organization_id $organization_id]
    set actions [list "[_ invoices.iv_offer_New]" [export_vars -base "${base_url}offer-ae" {organization_id}] "[_ invoices.iv_offer_New2]" "[_ invoices.iv_invoice_2]" [export_vars -base "${base_url}invoice-list" {organization_id}] "[_ invoices.iv_invoice_2]" "[_ invoices.iv_price_list]" [export_vars -base "${base_url}price_list" {{list_id $price_list_id}}] "[_ invoices.iv_display_price_list]"]
    if {[exists_and_not_null pm_base_url]} {
	lappend actions "[_ project-manager.Projects]" $pm_base_url "[_ project-manager.Projects]"
    }
} else {
    set actions ""
}

template::list::create \
    -name iv_offer \
    -key offer_id \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -elements {
	offer_nr {
	    label {[_ invoices.iv_offer_offer_nr]}
	}
        title {
	    label {[_ invoices.iv_offer_1]}
	    display_template {<a href="@iv_offer.title_link@">@iv_offer.title@</a>}
        }
        description {
	    label {[_ invoices.iv_offer_Description]}
        }
        amount_total {
	    label {[_ invoices.iv_offer_amount_total]}
	    display_template {@iv_offer.amount_total@ @iv_offer.currency@}
        }
	creation_user {
	    label {[_ invoices.iv_offer_creation_user]}
	    display_template {<a href="@iv_offer.creator_link@">@iv_offer.first_names@ @iv_offer.last_name@</a>}
	}
	creation_date {
	    label {[_ invoices.iv_offer_creation_date]}
	}
	finish_date {
	    label {[_ invoices.iv_offer_finish_date]}
	}
	accepted_date {
	    label {[_ invoices.iv_offer_accepted_date]}
	}
        action {
	    display_template {<if @iv_offer.accepted_date@ nil><a href="@iv_offer.edit_link@">#invoices.Edit#</a>&nbsp;<a href="@iv_offer.delete_link@">#invoices.Delete#</a></if>}
	}
    } -actions $actions -sub_class narrow \
    -page_size_variable_p 1 \
    -page_size $page_size \
    -page_flush_p 0 \
    -page_query_name iv_offer_paginated \
    -filters {
        organization_id {
            where_clause {t.organization_id = :organization_id}
        }
	status)id {
	    where_clause { 1 = 1 }
	}
    } \
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


db_multirow -extend {creator_link edit_link delete_link title_link} iv_offer iv_offer {} {

    # Ugly hack. We should find out which contact package is linked
    # aso. asf.
    set creator_link "/contacts/$creation_user"
    set edit_link [export_vars -base "${base_url}offer-ae" {offer_id}]
    set title_link [export_vars -base "${base_url}offer-ae" {offer_id {mode display}}]
    set delete_link [export_vars -base "${base_url}offer-delete" {offer_id}]
}
