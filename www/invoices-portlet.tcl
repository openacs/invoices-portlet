# packages/invoices-portlet/www/invoices-portlet.tcl

set row_list { title {} name {} description {}  creation_date {} amount_open {} count_total {} count_billed {} }

set community_id [dotlrn_community::get_community_id_from_url]
set base_url "[dotlrn_community::get_community_url $community_id]"

set organization_id [lindex \
			 [application_data_link::get_linked \
			      -from_object_id [dotlrn_community::get_community_id_from_url -url [ad_conn url]] \
			      -to_object_type organization \
			     ] \
			 0 \
			]
