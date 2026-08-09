const cds = require('@sap/cds');

module.exports = class MyService extends cds.ApplicationService {
  init() {
    this.on('sujith', async (req) => {
      console.log('On sujith', req.data);
      const myName = req.data.name;

      return `Welcome to CAPM Server Hello ${myName} !` 
    })

    return super.init()
  }
}
