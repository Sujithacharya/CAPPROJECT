//consume reference of my DB tables
using { sujith.cds } from '../db/CDSViews';

service CDSService @(path:'CDSService') {

    entity ProductSet as projection on cds.CDSViews.ProductView{
        *, 
        // never persisted in the database 
        virtual soldCount : Int16 
    };
    entity ItemsSet as projection on cds.CDSViews.ItemView;

}

