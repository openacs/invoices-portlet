<?xml version="1.0"?>
<!DOCTYPE queryset PUBLIC "-//OpenACS//DTD XQL 1.0//EN" "http://www.thecodemill.biz/repository/xql.dtd">
<!-- packages/invoices-portlet/www/invoices-list-portlet.xql -->
<!-- @author Bjoern Kiesbye (bjoern_kiesbye@web.de) -->
<!-- @creation-date 2005-06-17 -->
<!-- @arch-tag: c9059d56-b0fb-4851-848c-3aba988b8714 -->
<!-- @cvs-id $Id$ -->

<queryset>
  

<fullquery name="get_community_ids">      
      <querytext>
      select (group_id) as community_id 
      from group_distinct_member_map gd , dotlrn_communities dc 
      where gd.member_id = :user_id 
      AND gd.group_id = dc.community_id
      </querytext>
</fullquery>  
</queryset>