namespace sujith.cds;

using {
    sujith.db.master,
    sujith.db.transaction
} from './dataModel';

context CDSViews {
    define view ![POWorkList] as
        select from transaction.purchaseorder {
            key PO_ID                             as ![PurchaseOrderID],
            key Items.PO_ITEM_POS                 as ![ItemPosition],
                PARTNER_GUID.BP_ID                as ![PartnerId],
                PARTNER_GUID.COMPANY_NAME         as ![CompanyName],
                GROSS_AMOUNT                      as ![GrossAmount],
                NET_AMOUNT                        as ![NetAmount],
                TAX_AMOUNT                        as ![TaxAmount],
                CURRENCY                          as ![CurrencyCode],
                OVERALL_STATUS                    as ![OverallStatus],
                Items.PRODUCT_GUID.PRODUCT_ID     as ![ProductId],
                Items.PRODUCT_GUID.DESCRIPTION    as ![ProductDescription],
                PARTNER_GUID.ADDRESS_GUID.CITY    as ![City],
                PARTNER_GUID.ADDRESS_GUID.COUNTRY as ![Country]
        }

    define view ![ProductValueHelp] as
        select from master.product {
            @EndUserText.label: [
                {
                    langauge: 'EN',
                    text    : 'English Product ID'
                },
                {
                    langauge: 'DE',
                    text    : 'German Product ID'
                }
            ]

            PRODUCT_ID  as ![ProductId],
            @EndUserText.label: [
                {
                    langauge: 'EN',
                    text    : 'English Product Description'
                },
                {
                    langauge: 'DE',
                    text    : 'German Product Description'
                }
            ]
            DESCRIPTION as ![Description]
        }

    define view ![ItemView] as
        select from transaction.poitems {
            key PARENT_KEY.PARTNER_GUID.NODE_KEY as ![CustomerId],
            key PRODUCT_GUID.NODE_KEY            as ![ProductId],
            CURRENCY                         as ![CurrencyCode],
            GROSS_AMOUNT                     as ![GrossAmount],
            NET_AMOUNT                       as ![NetAmount],
            TAX_AMOUNT                       as ![TaxAmount],
            PARENT_KEY.OVERALL_STATUS        as ![Status]
        }

    define view ![ProductView] as

        select from master.product
        // Mixin  is the key word to define loose couling
        // which will never load data from the base entity but will only load the data from the base entity when it is required

        mixin {
            // view on view
            PO_ORDER : Association to many ItemView
                           on PO_ORDER.ProductId = $projection.ProductId;
        }
        into {
            NODE_KEY                           as ![ProductId],
            DESCRIPTION                        as ![Description],
            CATEGORY                           as ![Category],
            PRICE                              as ![Price],
            SUPPLIER_GUID.BP_ID                as ![SupplierId],
            SUPPLIER_GUID.COMPANY_NAME         as ![CompanyName],
            SUPPLIER_GUID.ADDRESS_GUID.COUNTRY as ![Country],

            // expose the association to the view @ run time. load the data on demand
            PO_ORDER                           as ![To_Item]
        };

    define view CProductValueView as
        select from ProductView {
            ProductId,
            Country,
            round(
                sum(To_Item.GrossAmount), 2
            )                    as ![TotalAmount],
            To_Item.CurrencyCode as ![CurrencyCode]
        }
        group by
            ProductId,
            Country,
            To_Item.CurrencyCode
}
