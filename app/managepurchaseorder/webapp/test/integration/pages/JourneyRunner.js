sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"sujith/ui/managepurchaseorder/test/integration/pages/PurchaseOrderSetList.gen",
	"sujith/ui/managepurchaseorder/test/integration/pages/PurchaseOrderSetObjectPage.gen",
	"sujith/ui/managepurchaseorder/test/integration/pages/PurchaseItemsSetObjectPage.gen"
], function (JourneyRunner, PurchaseOrderSetListGenerated, PurchaseOrderSetObjectPageGenerated, PurchaseItemsSetObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('sujith/ui/managepurchaseorder') + '/test/flp.html#app-preview',
        pages: {
			onThePurchaseOrderSetListGenerated: PurchaseOrderSetListGenerated,
			onThePurchaseOrderSetObjectPageGenerated: PurchaseOrderSetObjectPageGenerated,
			onThePurchaseItemsSetObjectPageGenerated: PurchaseItemsSetObjectPageGenerated
        },
        async: true
    });

    return runner;
});

