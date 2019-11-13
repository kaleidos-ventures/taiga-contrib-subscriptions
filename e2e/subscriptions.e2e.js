var utils = require('../../../../../e2e/utils');
var subscriptionsHelper = require('./subscriptions-helpers');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('subscriptions', () => {
    before(async () => {
        await utils.common.logout();
        await utils.common.login('user5', '123123');

        browser.get(browser.params.glob.host + 'user-settings/contrib/subscriptions');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('subscription', 'index');
    });

    beforeEach(() => {
        browser.get(browser.params.glob.host + 'user-settings/contrib/subscriptions');

        return utils.common.waitLoader();
    });

    it('pay with stripe', async () => {
        let lb = subscriptionsHelper.changeLb();

        await lb.open();
        utils.common.takeScreenshot('subscription', 'select-plan');

        await lb.select(1);

        utils.common.takeScreenshot('subscription', 'detail-subscription');


        await lb.continue();
        utils.common.takeScreenshot('subscription', 'stripe');

        await lb.creditCard('4242 4242 4242 4242', '12/29', '123');

        let openNotification = await utils.notifications.success.open();

        expect(openNotification).to.be.true;

        await utils.notifications.success.close();
    });

    it('billing detail', async () => {
        let lb = subscriptionsHelper.billingDetail();

        await lb.open();

        await utils.common.takeScreenshot('subscription', 'billing');

        await lb.close();
    });

    it('change payment details', async () => {
        let lb = subscriptionsHelper.changePaymentDetails();

        await lb.open();

        await utils.common.takeScreenshot('subscription', 'change-payment');

        await lb.fill('xxx@xx.es', '4242 4242 4242 4242', '12/29', '123');

        let openNotification = await utils.notifications.success.open();

        expect(openNotification).to.be.true;

        await utils.notifications.success.close();
    });

    it('subscription payment error', async () => {
        let lb = subscriptionsHelper.changePaymentDetails();

        await lb.open();

        await utils.common.takeScreenshot('subscription', 'change-payment');

        await lb.fill('xxx@xx.es', '4242 4242 4242 4242', '12/29', '123');

        let openNotification = await utils.notifications.success.open();

        expect(openNotification).to.be.true;

        await utils.notifications.success.close();
    });

    it('subscription payment error', async () => {
        let lb = subscriptionsHelper.changePaymentDetails();

        await lb.open();

        await utils.common.takeScreenshot('subscription', 'change-payment');

        await lb.fill('xxx@xx.es', '4242 4242 4242 4242', '12/29', '123');

        let openNotification = await utils.notifications.success.open();

        expect(openNotification).to.be.true;

        await utils.notifications.success.close();
    });
});
