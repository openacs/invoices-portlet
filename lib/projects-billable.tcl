set optional_param_list [list orderby elements base_url package_id]
set optional_unset_list [list organization_id]

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

foreach element $elements {
    append row_list "$element {}\n"
}

if {![info exists format]} {
    set format "normal"
}
if {![info exists orderby]} {
    set orderby ""
}
if {![info exists page_size]} {
    set page_size "25"
}

if {[empty_string_p $package_id]} {
    set package_id [apm_package_id_from_key invoices]
}

if {[empty_string_p $base_url]} {
    set base_url [apm_package_url_from_id [apm_package_id_from_key invoices]]
}

set p_closed_id [pm::project::default_status_closed]
set t_closed_id [pm::task::default_status_closed]
set date_format [lc_get formbuilder_date_format]
set timestamp_format "$date_format [lc_get formbuilder_time_format]"

set contacts_p [apm_package_installed_p contacts]
if { $contacts_p } {
    set contacts_url [apm_package_url_from_key contacts]
}

set actions [list "[_ invoices.iv_invoice_New]" "${base_url}invoice-ae" "[_ invoices.iv_invoice_New2]" ]
set bulk_id_list [list organization_id]

template::list::create \
    -name projects \
    -key project_id \
    -no_data "[_ invoices.None]" \
    -selected_format $format \
    -pass_properties {currency} \
    -elements {
	project_id {
	    label {[_ invoices.iv_invoice_project_id]}
	}
        name {
	    label {[_ invoices.Customer]}
	    display_template {<a href="@projects.project_link@">@projects.name@</a>}
        }
        title {
	    label {[_ invoices.iv_invoice_project_title]}
	    display_template {<a href="@projects.project_link@">@projects.title@</a>}
        }
        description {
	    label {[_ invoices.iv_invoice_project_descr]}
        }
	recipient {
	    label {[_ invoices.iv_invoice_recipient]}
	    display_template "@projects.recipient;noquote@"
	}
        amount_open {
	    label {[_ invoices.iv_invoice_amount_open]}
	    display_template {@projects.amount_open@ @projects.currency@}
        }
	count_total {
	    label {[_ invoices.iv_invoice_count_total]}
	}
	count_billed {
	    label {[_ invoices.iv_invoice_count_billed]}
	}
	creation_date {
	    label {[_ invoices.iv_invoice_closed_date]}
	}
    } -bulk_actions $actions \
    -bulk_action_export_vars $bulk_id_list \
    -sub_class narrow \
    -filters {
        organization_id {
            where_clause {sub.organization_id = :organization_id}
        }
    } \
    -formats {
	normal {
	    label "[_ invoices.Table]"
	    layout table
	    row "checkbox {} $row_list"
	}
	csv {
	    label "[_ invoices.CSV]"
	    output csv
	    page_size 0
	    row $row_list
	}
    }


db_multirow -extend {project_link currency} projects projects_to_bill {} {
    set amount_open [format "%.2f" $amount_open]
    set dotlrn_club_id [lindex [application_data_link::get_linked -from_object_id $organization_id -to_object_type "dotlrn_club"] 0]
    set pm_base_url [apm_package_url_from_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]]
    set currency [iv::price_list::get_currency -organization_id $organization_id]
    set project_link [export_vars -base "${pm_base_url}one" {{project_item_id $project_id}}]
    set currency [iv::price_list::get_currency -organization_id $organization_id]
    if { $contacts_p } {
	set recipient "<a href=\"[contact::url -party_id $recipient_id]\">[contact::name -party_id $recipient_id]</a>"
    } else {
	set recipient [person::name -person_id $recipient_id]
    }
}
