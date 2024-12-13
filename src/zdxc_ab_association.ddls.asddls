@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Example for lose coupling'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDXC_AB_ASSOCIATION as select from ZDXC_AB_BPA( p_ctry : 'US' ) as bpa
///using association name starts with _ 
association of one to many zats_ab_so_hdr as _Salesorder
///using $projection refering to the field
on $projection.BpId = _Salesorder.buyer
{
   key bpa.BpId,
   bpa.BpRole,
   bpa.CompanyName,
   bpa.Street,
   bpa.Country,
   bpa.Region,
   bpa.City,
   //exposed association - dont apply the join upfront to load order data
   //Similar to interative report in abap AT LINE selection
   _Salesorder 
}
