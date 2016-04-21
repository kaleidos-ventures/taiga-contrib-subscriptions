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
# File: lighbox-plans.controller.spec.coffee
###

describe "ContribLbPlans", ->
    provide = null
    controller = null
    mocks = {}

    _mockContribSubscriptionsService = () ->
        mocks.contribSubscriptionsService = {
            selectMyPlan: sinon.stub(),
            fetchMyPlans: sinon.stub()
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
            closeAll: sinon.stub()
        }
        provide.value "lightboxService", mocks.lightboxService

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }
        provide.value "$tgConfirm", mocks.tgConfirm


    _mockCurrentUserService = () ->
        mocks.currentUserService = {
            getUser: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUserService

    _paymentsService = () ->
        mocks.paymentsService = {
            start: sinon.stub()
        }
        provide.value "ContribPaymentsService", mocks.paymentsService

    _mockTgTranslate = () ->
        mocks.tgTranslate = {
            instant: sinon.stub()
        }
        provide.value "$translate", mocks.tgTranslate

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockContribSubscriptionsService()
            _mockTgLoader()
            _mockTgConfirm()
            _mockLightboxService()
            _mockCurrentUserService()
            _paymentsService()
            _mockTgTranslate()

            return null

    beforeEach ->
        module "subscriptions"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "select an invalid Plan", () ->
        lbPlansCtrl = controller "ContribLbPlansController"
        project = {}

        lbPlansCtrl.selectPLan(project)
        expect(lbPlansCtrl.selectPlanInterval).to.be.equal('month')
        expect(lbPlansCtrl.selectedPlan).to.be.equal('invalid')
        expect(lbPlansCtrl.invalidPlan).to.be.eql(project)

    it "select a valid month Plan", () ->
        lbPlansCtrl = controller "ContribLbPlansController"
        project = {
            is_applicable: true
        }

        mocks.contribSubscriptionsService.myPlan = {
            current_plan: {
                name: 'plan month',
                interval: 'month'
            }
        }

        lbPlansCtrl.selectPLan(project)
        expect(lbPlansCtrl.selectPlanInterval).to.be.equal('month')
        expect(lbPlansCtrl.selectedPlan).to.be.equal('valid')
        expect(lbPlansCtrl.validPlan).to.be.eql(project)

    it "select same plan monthly", () ->
        lbPlansCtrl = controller "ContribLbPlansController"
        project = {
            is_applicable: true
            name: 'Sprout'
        }

        mocks.contribSubscriptionsService.myPlan = {
            interval: 'month',
            current_plan: {
                name: 'Sprout'
            }
        }

        lbPlansCtrl.selectPLan(project)
        expect(lbPlansCtrl.selectedPlan).to.be.equal('valid')
        expect(lbPlansCtrl.validPlan).to.be.eql(project)
        expect(lbPlansCtrl.invalidInterval).to.be.equal('month')
        expect(lbPlansCtrl.selectPlanInterval).to.be.equal('year')

    it "select same plan yearly", () ->
        lbPlansCtrl = controller "ContribLbPlansController"
        project = {
            is_applicable: true
            name: 'Sprout'
        }

        mocks.contribSubscriptionsService.myPlan = {
            interval: 'year',
            current_plan: {
                name: 'Sprout'
            }
        }

        lbPlansCtrl.selectPLan(project)
        expect(lbPlansCtrl.selectedPlan).to.be.equal('valid')
        expect(lbPlansCtrl.validPlan).to.be.eql(project)
        expect(lbPlansCtrl.invalidInterval).to.be.equal('year')
        expect(lbPlansCtrl.selectPlanInterval).to.be.equal('month')

    it "back to plans", () ->
        lbPlansCtrl = controller "ContribLbPlansController"

        lbPlansCtrl.backToPLans()
        expect(lbPlansCtrl.selectedPlan).to.be.equal(false)

    it "bought a plan", (done) ->
        lbPlansCtrl = controller "ContribLbPlansController"
        plan = {test: true}

        mocks.contribSubscriptionsService.selectMyPlan.withArgs(plan).promise().resolve()

        lbPlansCtrl._onSuccessSelectPlan = sinon.stub()

        lbPlansCtrl._onSuccessBuyPlan(plan).then () ->
            expect(mocks.lightboxService.closeAll).has.been.called
            expect(mocks.tgLoader.start).has.been.called
            expect(lbPlansCtrl._onSuccessSelectPlan).has.been.called
            done()

    it "buy a Plan", () ->
        lbPlansCtrl = controller "ContribLbPlansController"
        lbPlansCtrl.validPlan = {
            name: 'name',
            amount: '100'
        }
        lbPlansCtrl.selectPlanInterval = {
            data: 'data'
        }
        lbPlansCtrl.myPlan = {
            customer_id: 'patata'
        }

        lbPlansCtrl._onSuccessBuyPlan = sinon.stub()

        mocks.currentUserService.getUser.returns(Immutable.fromJS({
            email: 'test@test.es',
            full_name: 'full name'
        }))

        lbPlansCtrl.buyPlan()
        expect(lbPlansCtrl.loadingPayments).to.be.equal(true)
        mocks.paymentsService.start.yieldTo('onLoad');
        expect(lbPlansCtrl.loadingPayments).to.be.equal(false)
        mocks.paymentsService.start.yieldTo('onSuccess');
        expect(lbPlansCtrl._onSuccessBuyPlan).to.be.called


    it "bought a Plan success", (done) ->
        promise = mocks.contribSubscriptionsService.fetchMyPlans.promise().resolve()
        lbPlansCtrl = controller "ContribLbPlansController"
        message = mocks.tgTranslate.instant.returns('Test')

        lbPlansCtrl._onSuccessSelectPlan().then () ->
            expect(mocks.tgConfirm.notify).has.been.calledWith('success', 'Test', '', 5000)
            expect(mocks.tgLoader.pageLoaded).has.been.called
            done()
