
set row_list {offer_nr {} title {} description {} amount_total {} creation_user {} creation_date {} finish_date {} action {}}



set user_id [ad_conn user_id]
set community_id [dotlrn_community::get_community_id_from_url]
set package_id [apm_package_id_from_key invoices]

if {[empty_string_p $community_id]} {


    db_foreach get_community_ids {      select (group_id) as community_id 
      from group_distinct_member_map gd , dotlrn_communities dc 
      where gd.member_id = :user_id 
      AND gd.group_id = dc.community_id} {

	  set node "[site_node::get  -url "[dotlrn_community::get_community_url $community_id]project-manager" ]"
    
	  array set node_info $node

	  lappend project_manager_ids $node_info(package_id)
      }
    set organization_id ""

} else {

    set node "[site_node::get -url "[dotlrn_community::get_community_url $community_id]project-manager" ]"
    set organization_id [lindex [application_data_link::get_linked -from_object_id $community_id -to_object_type "organization"] 0]
    
    array set node_info $node

    set project_manager_ids $node_info(package_id)

}