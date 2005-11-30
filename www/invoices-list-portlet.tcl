
set row_list {invoice_nr {} title {} description {} total_amount {} paid_amount {} recipient {} creation_user {} creation_date {} due_date {} action {}}

set organization_id [lindex \
			 [application_data_link::get_linked \
			      -from_object_id [dotlrn_community::get_community_id_from_url -url [ad_conn url]] \
			      -to_object_type organization \
			     ] \
			 0 \
			]


set user_id [ad_conn user_id]

set project_manager_ids ""

set community_id [dotlrn_community::get_community_id_from_url]
set base_url "[dotlrn_community::get_community_url $community_id]invoices"

if {[empty_string_p $community_id]} {


    db_foreach get_community_ids {      select (group_id) as community_id 
      from group_distinct_member_map gd , dotlrn_communities dc 
      where gd.member_id = :user_id 
      AND gd.group_id = dc.community_id} {

	  set node "[site_node::get  -url "[dotlrn_community::get_community_url $community_id]project-manager" ]"
    
	  array set node_info $node

	  lappend project_manager_ids $node_info(package_id)
      }

} else {

    set node "[site_node::get -url "[dotlrn_community::get_community_url $community_id]project-manager" ]"
    
    array set node_info $node

    set project_manager_ids $node_info(package_id)

}