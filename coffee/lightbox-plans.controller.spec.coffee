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

describe.only "ContribLbPlans", ->
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

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockContribSubscriptionsService()
            _mockTgLoader()
            _mockTgConfirm()
            _mockLightboxService()

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

    it "select a valid Plan", () ->
        lbPlansCtrl = controller "ContribLbPlansController"
        project = {is_applicable: true}

        lbPlansCtrl.selectPLan(project)
        expect(lbPlansCtrl.selectPlanInterval).to.be.equal('month')
        expect(lbPlansCtrl.selectedPlan).to.be.equal('valid')
        expect(lbPlansCtrl.validPlan).to.be.eql(project)

    it "back to plans", () ->
        lbPlansCtrl = controller "ContribLbPlansController"

        lbPlansCtrl.backToPLans()
        expect(lbPlansCtrl.selectedPlan).to.be.equal(false)

    it "bought a Plan", (done) ->
        promise = mocks.contribSubscriptionsService.fetchMyPlans.promise().resolve()
        lbPlansCtrl = controller "ContribLbPlansController"

        lbPlansCtrl._successBuyPlan().then () ->
            expect(mocks.lightboxService.closeAll).has.been.called
            expect(mocks.tgConfirm.notify).has.been.calledWith('success', 'OK, te has suscrito al plan correctamente', '', 5000)
            expect(mocks.tgLoader.pageLoaded).has.been.called
            done()
