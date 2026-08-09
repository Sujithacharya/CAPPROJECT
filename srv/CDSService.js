const cds = require('@sap/cds');
const { SELECT, func } = require('@sap/cds/lib/ql/cds-ql');

module.exports = class CDSService extends cds.ApplicationService {
  init() {

    const { ProductSet, ItemsSet } = cds.entities('CDSService')

    this.before(['CREATE', 'UPDATE'], ProductSet, async (req) => {
      console.log('Before CREATE/UPDATE ProductSet', req.data)
    });


    this.after('READ', ProductSet, async (productSet, req) => {

      const aProductIds = productSet.map(d => d.ProductId);

      const aOrderCount = await SELECT.from(ItemsSet)
        .columns('ProductId', { func: 'count', as: 'soldCount' })
        .where({ 'ProductId': { in: aProductIds } })
        .groupBy('ProductId');

      for (let index = 0; index < productSet.length; index++) {
        const element = productSet[index];
        const oFoundRecord = aOrderCount.find(d => d.ProductId == element.ProductId);
        element.soldCount = oFoundRecord ? oFoundRecord.soldCount : 0;
      }

      console.log('After READ ProductSet', productSet)
    });

    this.before(['CREATE', 'UPDATE'], ItemsSet, async (req) => {
      console.log('Before CREATE/UPDATE ItemsSet', req.data)
    })
    this.after('READ', ItemsSet, async (itemsSet, req) => {
      console.log('After READ ItemsSet', itemsSet)
    })


    return super.init()
  }
}
