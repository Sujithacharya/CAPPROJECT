const cds = require('@sap/cds')

module.exports = class CatalogService extends cds.ApplicationService {
  init() {

    const { EmployeeSet, PurchaseOrderSet, PurchaseItemsSet } = cds.entities('CatalogService')

    this.before(['CREATE', 'UPDATE'], EmployeeSet, async (req) => {

      const salaryAmount = parseFloat(req.data.salaryAmount);

      // Generic handlers
      if (salaryAmount > 10000) {
        req.error(500, 'Salary Amount should not be greater than 10000')
      }
      console.log('Before CREATE/UPDATE EmployeeSet', req.data)
    });
    this.after('READ', EmployeeSet, async (employeeSet, req) => {
      console.log('After READ EmployeeSet', employeeSet)
    });
    this.before(['CREATE', 'UPDATE'], PurchaseOrderSet, async (req) => {
      console.log('Before CREATE/UPDATE PurchaseOrderSet', req.data)
    });
    this.after('READ', PurchaseOrderSet, async (purchaseOrderSet, req) => {
      console.log('After READ PurchaseOrderSet', purchaseOrderSet)
    });

    this.before('READ', PurchaseOrderSet, async (purchaseOrderSet, req) => {
      console.log('After READ PurchaseOrderSet', purchaseOrderSet)
    });
    this.before(['CREATE', 'UPDATE'], PurchaseItemsSet, async (req) => {
      console.log('Before CREATE/UPDATE PurchaseItemsSet', req.data)
    });
    this.after('READ', PurchaseItemsSet, async (purchaseItemsSet, req) => {
      console.log('After READ PurchaseItemsSet', purchaseItemsSet)
    });

    //Implementation for order defaults
    this.on('getDefaultValue', async (req, res) => {
      return {
        OVERALL_STATUS: 'N',
        LIFECYCLE_STATUS: 'N'
      }
    });


    // Generic handler to support my function implementation - always return data // Get
    this.on('getLargestOrder', async (req, res) => {
      try {
        const tx = cds.tx(req);
        // Using CDS ql language to make call to DB 
        const replay = await tx.read(PurchaseOrderSet).orderBy({
          "GROSS_AMOUNT": 'desc'
        }).limit(3);

        return replay;

      } catch (error) {
        req.error(500, 'Error :' + error.toString())
      }
    });

    //Implementation of Action
    this.on('boost', async (req) => {
      try {
        const sPrimaryKey = req.params[0];
        //start a Transaction to DB
        const tx = cds.tx(req);
        //CDS QL language to boost the Gross Amount
        await tx.update(PurchaseOrderSet).with({
          GROSS_AMOUNT: { '+=': 2000 },
          NOTE: 'Boosted!'
        }).where(sPrimaryKey);

        return await tx.read(PurchaseOrderSet).where(sPrimaryKey);
      } catch (error) {
        req.error(500, 'Error :' + error.toString())
      }
    });

    return super.init()
  }
}
