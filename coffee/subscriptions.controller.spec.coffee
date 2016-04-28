###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: subscriptions.controller.spec.coffee
###

describe "SubscriptionsAdmin", ->
    provide = null
    controller = null
    mocks = {}

    _mockTranslate = () ->
        mocks.translate = {
            instant: sinon.stub()
        }

        provide.value "$translate", mocks.translate

    _mockAppMetaService = () ->
        mocks.appMetaService = {
            setAll: sinon.stub()
        }

        provide.value "tgAppMetaService", mocks.appMetaService

    _mockContribSubscriptionsService = () ->
        mocks.contribSubscriptionsService = {
            fetchMyPlans: sinon.stub(),
            fetchPublicPlans: sinon.stub(),
            selectMyPlan: sinon.stub()
        }

        provide.value "ContribSubscriptionsService", mocks.contribSubscriptionsService

    _mockTgLoader = () ->
        mocks.tgLoader = {
            start: sinon.stub(),
            pageLoaded: sinon.stub()
        }

        provide.value "tgLoader", mocks.tgLoader

    _mockLightboxService = () ->
        mocks.lightboxService = {
            open: sinon.stub()
        }
        provide.value "lightboxService", mocks.lightboxService

    _paymentsService = () ->
        mocks.paymentsService = {
            changeData: sinon.stub()
            seeBilling: sinon.stub()
        }
        provide.value "ContribPaymentsService", mocks.paymentsService

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }
        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgTranslate = () ->
        mocks.tgTranslate = {
            instant: sinon.stub()
        }
        provide.value "$translate", mocks.tgTranslate

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockAppMetaService()
            _mockContribSubscriptionsService()
            _mockTgLoader()
            _mockLightboxService()
            _mockTranslate()
            _paymentsService()
            _mockTgConfirm()
            _mockTgTranslate()

            return null

    beforeEach ->
        module "subscriptions"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "load metas", () ->
        subscriptionsCtrl = controller "ContribSubscriptionsController"

        title = 'title'
        description = 'description'

        mocks.tgTranslate.instant.withArgs('SUBSCRIPTIONS.TITLE').returns(title)
        mocks.tgTranslate.instant.withArgs('SUBSCRIPTIONS.SECTION_NAME').returns(description)

        subscriptionsCtrl._loadMetas()
        expect(mocks.appMetaService.setAll).have.been.calledWith(title, description)

    it "load User Plans", (done) ->
        promise = mocks.contribSubscriptionsService.fetchMyPlans.promise()
        subscriptionsCtrl = controller "ContribSubscriptionsController"

        subscriptionsCtrl._loadPlans().then () ->
            expect(mocks.tgLoader.pageLoaded).have.been.called
            done()

        expect(mocks.tgLoader.start).have.been.called

        promise.resolve()

    it "get paid template URL", () ->
        subscriptionsCtrl = controller "ContribSubscriptionsController"
        url = "compile-modules/taiga-contrib-subscriptions/partials/subscriptions-paid.html"

        expect(subscriptionsCtrl.getTemplateUrl()).to.be.equal(url)

    it "get zero template URL", () ->
        subscriptionsCtrl = controller "ContribSubscriptionsController"
        subscriptionsCtrl.myRecommendedPlan = {
            recommended_plan: {
                    amount_month: 0
                }
        }
        url = "compile-modules/taiga-contrib-subscriptions/partials/subscriptions-zero.html"

        expect(subscriptionsCtrl.getTemplateUrl()).to.be.equal(url)

    it "get recommended template URL", () ->
        subscriptionsCtrl = controller "ContribSubscriptionsController"
        subscriptionsCtrl.myRecommendedPlan = {
            recommended_plan: {
                    amount_month: 300
                }
        }
        url = "compile-modules/taiga-contrib-subscriptions/partials/subscriptions-recommended.html"

        expect(subscriptionsCtrl.getTemplateUrl()).to.be.equal(url)

    it "upgrade Plan", (done) ->
        promise = mocks.contribSubscriptionsService.fetchPublicPlans.promise().resolve()
        subscriptionsCtrl = controller "ContribSubscriptionsController"

        subscriptionsCtrl._plansList = sinon.stub()

        subscriptionsCtrl.upgradePlan().then () ->
            expect(subscriptionsCtrl._plansList).have.been.called
            done()

        expect(subscriptionsCtrl.loading).to.be.equal(true)

    it "buy recommended Plan", (done) ->
        subscriptionsCtrl = controller "ContribSubscriptionsController"
        promise = mocks.contribSubscriptionsService.fetchPublicPlans.promise()

        subscriptionsCtrl.myRecommendedPlan = {
            recommended_plan: {
                    amount_month: 300
                }
        }

        subscriptionsCtrl.buyRecommendedPlan().then () ->
            expect(subscriptionsCtrl.loadingRecommendedPlan).to.be.equal(false)
            expect(subscriptionsCtrl.selectedPlan).to.be.equal('valid')
            expect(subscriptionsCtrl.selectPlanInterval).to.be.equal('month')
            expect(subscriptionsCtrl.validPlan).to.be.eql(subscriptionsCtrl.myRecommendedPlan.recommended_plan)
            expect(mocks.lightboxService.open).has.been.calledWith('tg-lb-plans')
            done()

        expect(subscriptionsCtrl.loadingRecommendedPlan).to.be.equal(true)
        promise.resolve()

    it "show Plans List", () ->
        subscriptionsCtrl = controller "ContribSubscriptionsController"

        subscriptionsCtrl._plansList()
        expect(subscriptionsCtrl.loading).to.be.equal(false)
        expect(mocks.lightboxService.open).has.been.calledWith('tg-lb-plans')

    it "change Payments Data", () ->
        subscriptionsCtrl = controller "ContribSubscriptionsController"

        subscriptionsCtrl._onSuccessChangePaymentsData = sinon.stub()

        subscriptionsCtrl.changePaymentsData()
        expect(mocks.paymentsService.changeData).has.been.called
        mocks.paymentsService.changeData.yieldTo('onSuccess');
        expect(subscriptionsCtrl._onSuccessChangePaymentsData).to.be.called

    it "changed Payments Data", (done) ->
        subscriptionsCtrl = controller "ContribSubscriptionsController"
        data = {test: true}

        mocks.contribSubscriptionsService.selectMyPlan.withArgs(data).promise().resolve()

        subscriptionsCtrl._onSuccessChangedData = sinon.stub()

        subscriptionsCtrl._onSuccessChangePaymentsData(data).then () ->
            expect(mocks.tgLoader.start).has.been.called
            expect(subscriptionsCtrl._onSuccessChangedData).to.be.called
            done()

    it "changed Taiga Data", (done) ->
        promise = mocks.contribSubscriptionsService.fetchMyPlans.promise().resolve()
        message = mocks.tgTranslate.instant.returns('Test')

        subscriptionsCtrl = controller "ContribSubscriptionsController"

        subscriptionsCtrl._onSuccessChangedData().then () ->
            expect(mocks.tgConfirm.notify).has.been.calledWith('success', 'Test', '', 5000)
            expect(mocks.tgLoader.pageLoaded).has.been.called
            done()

    it "see Billing details", () ->
        subscriptionsCtrl = controller "ContribSubscriptionsController"

        subscriptionsCtrl.myPlan = {
            secure_id: 'secure_id'
        }

        subscriptionsCtrl.seeBillingDetails()
        expect(mocks.paymentsService.seeBilling).has.been.calledWith(subscriptionsCtrl.myPlan)
