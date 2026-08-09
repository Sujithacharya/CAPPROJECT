using {
     sujith.db.master,
     sujith.db.transaction
} from '../db/dataModel';

service CatalogService @(
     path    : 'CatalogService',
     requires: 'authenticated-user'
) {

     entity EmployeeSet @(

     restrict: [
          {
               grant: ['READ'],
               to   : 'Viewer',
               // Row level security - only allow users to see their own data
               where: 'bankName = $user.Spiderman'
          },
          {
               grant: [
                    'WRITE',
                    'DELETE'
               ],
               to   : 'Editor'
          }
     ])  as projection on master.employee;

     entity ProductSet         as projection on master.product;
     entity BusinessPartnerSet as projection on master.businesspartner;
     entity AddressSet         as projection on master.address;

     @readOnly
     entity StatusCode         as projection on master.StatusCode;


     entity PurchaseOrderSet @(
          ristrict                    : [
               {
                    grant: ['READ'],
                    to   : 'Viewer'
               },
               {
                    grant: [
                         'WRITE',
                         'DELETE'
                    ],
                    to   : 'Editor'
               }
          ],
          odata.draft.enabled         : true,
          Common.DefaultValuesFunction: 'getDefaultValue'
     )                         as
          projection on transaction.purchaseorder {
               *,
               case
                    when OVERALL_STATUS = 'P'
                         then 'Pending'
                    when OVERALL_STATUS = 'A'
                         then 'Approved'
                    when OVERALL_STATUS = 'X'
                         then 'Rejected'
                    when OVERALL_STATUS = 'D'
                         then 'Delivered'
                    else 'Unknown'
               end as OverallStatus : String(10),

               case
                    when OVERALL_STATUS = 'P'
                         then 2
                    when OVERALL_STATUS = 'A'
                         then 3
                    when OVERALL_STATUS = 'X'
                         then 1
                    when OVERALL_STATUS = 'D'
                         then 3
                    else 0
               end as ColourCode    : Integer
          }

          actions {
               //Side effect - a trigger to my action leads to a change of a field value in data
               //this force framework to make a GET call after action is triggred to load data
               //_anubhav is  variable that will contain the updated data coming from BE
               @cds.odata.bindingparameter.name: '_sideEffect'
               @Common.SideEffects             : {TargetProperties: [
                    '_sideEffect/GROSS_AMOUNT',
                    '_sideEffect/PO_ID'
               ]}
               //The system will pass the PO primary key  NODE KEY automatically into the input
               action boost() returns PurchaseOrderSet
          }

     entity PurchaseItemsSet   as projection on transaction.poitems;

     // Non Instance Bound bc they are not connected
     function getLargestOrder() returns array of PurchaseOrderSet;
     function getDefaultValue() returns PurchaseOrderSet;

}
