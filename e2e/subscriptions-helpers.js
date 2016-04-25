var utils = require('../../../../../e2e/utils');

module.exports.changeLb = function() {
    var lbPlans;

    return {
        open: () => {
            $('.e2e-change-plan').click();

            lbPlans = $('tg-lb-plans');

            return utils.lightbox.open(lbPlans);
        },
        select: (row) => {
            return lbPlans.$$('.e2e-plan').get(row).click();
        },
        continue: async () => {
            lbPlans.$$('.e2e-accept-plan').click();

            browser.wait(() => {
                return $('.quaderno_checkout_app').isPresent();
            }, 15000);

            //animation
            return browser.sleep(1000);
        },
        creditCard: async (number, date, control) => {
            await browser.switchTo().frame(0);

            await browser.driver.findElement(by.id('card_number')).sendKeys(number.split(' ')[0]);
            await browser.driver.findElement(by.id('card_number')).sendKeys(number.split(' ')[1]);
            await browser.driver.findElement(by.id('card_number')).sendKeys(number.split(' ')[2]);
            await browser.driver.findElement(by.id('card_number')).sendKeys(number.split(' ')[3]);

            await browser.driver.findElement(by.id('expiration_date')).sendKeys(date.split('/')[0]);
            await browser.driver.findElement(by.id('expiration_date')).sendKeys(date.split('/')[1]);

            await browser.driver.findElement(by.id('cvv')).sendKeys(control);

            await browser.driver.findElement(by.id('submit-button')).click();

            await browser.switchTo().defaultContent();

            return browser.wait(async () => {
                return !await $('.quaderno_checkout_app').isDisplayed();
            }, 15000);
        }
    };
};

module.exports.billingDetail = function() {
    var lb;

    return {
        open: async () => {
            $('.e2e-see-billing-data').click();

            await browser.wait(() => {
                return $('.quaderno_billing_app').isPresent();
            }, 15000);

            //animation
            return browser.sleep(2000);
        },
        close: async () => {
            await browser.switchTo().frame(0);

            browser.driver.findElement(by.css('.close a')).click();

            await browser.switchTo().defaultContent();

            return browser.wait(async () => {
                return !await $('.quaderno_billing_app').isDisplayed();
            }, 15000);
        }
    };
};

module.exports.changePaymentDetails = function() {
    var lb;

    return {
        open: async () => {
            $('.e2e-change-payment-data').click();

            await browser.wait(() => {
                return $('.stripe_checkout_app').isPresent();
            }, 15000);

            //animation
            return browser.sleep(1000);
        },
        fill: async (email, number, date, control) => {
            await browser.switchTo().frame(0);

            await browser.driver.findElement(by.id('email')).sendKeys(email);

            await browser.driver.findElement(by.id('card_number')).sendKeys(number.split(' ')[0]);
            await browser.driver.findElement(by.id('card_number')).sendKeys(number.split(' ')[1]);
            await browser.driver.findElement(by.id('card_number')).sendKeys(number.split(' ')[2]);
            await browser.driver.findElement(by.id('card_number')).sendKeys(number.split(' ')[3]);

            await browser.driver.findElement(by.id('cc-exp')).sendKeys(date.split('/')[0]);
            await browser.driver.findElement(by.id('cc-exp')).sendKeys(date.split('/')[1]);

            await browser.driver.findElement(by.id('cc-csc')).sendKeys(control);

            await browser.driver.findElement(by.id('submitButton')).click();

            await browser.switchTo().defaultContent();

            return browser.wait(async () => {
                return !await $('.stripe_checkout_app').isPresent();
            }, 15000);
        }
    };
};
