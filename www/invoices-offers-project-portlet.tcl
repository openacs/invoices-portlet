set row_list {title {} project_contact {} finish_date {} offer_nr {} amount_total {} creation_user {} creation_date {} action {}}

set user_id [ad_conn user_id]
set community_id [dotlrn_community::get_community_id_from_url]
set package_id [apm_package_id_from_key invoices]
set organization_id [lindex [application_data_link::get_linked -from_object_id $community_id -to_object_type "organization"] 0]

