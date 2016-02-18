###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: subscriptions.service.spec.coffee
###

describe "SubscriptionsService", ->
    subscriptionsService = null
    provide = null
    mocks = {}

    _mockHttp = () ->
        mocks.http = {
            get: sinon.stub(),
            post: sinon.stub()
        }
        provide.value "$tgHttp", mocks.http

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockHttp()

            return null

    _inject = (callback) ->
        inject (_ContribSubscriptionsService_) ->
            subscriptionsService = _ContribSubscriptionsService_

    beforeEach ->
        module "subscriptions"
        _mocks()
        _inject()

    it "set user recommended plan", (done) ->
        test = {response: true}
        subscriptionsService.getMyPlan = sinon.stub()
        subscriptionsService.getMyPlan.promise().resolve(test)
        subscriptionsService.loadUserPlan().then () ->
            expect(subscriptionsService.myPlan).to.be.eql(test)
            done()

    it "if user has no recommended plan", (done) ->
        subscriptionsService.loadUserPlan = sinon.stub()
        subscriptionsService.loadUserPlan.promise().resolve()

        subscriptionsService.setRecommendedPlan().then () ->
            expect(subscriptionsService.loadUserPlan).have.been.called
            done()

    it "if recommended plan set as user plan", (done) ->
        test = 'test'
        subscriptionsService.setRecommendedPlan(test).then () ->
            expect(subscriptionsService.myRecommendedPlan).to.be.equal(test)
            done()

    it "get user recommended plans", (done) ->
        test = {data: true}
        mocks.http.get.withArgs("http://localhost:5000/api/v1/my-recommended-plan", {}).promise().resolve(test)

        subscriptionsService.setRecommendedPlan = sinon.stub()
        subscriptionsService.fetchMyPlans().then () ->
            expect(subscriptionsService.setRecommendedPlan).have.been.calledWith(true)
            done()

    it "get user current plan", (done) ->
        test = {data: true}

        mocks.http.get.withArgs("http://localhost:5000/api/v1/my-subscription", {}).promise().resolve(test)

        subscriptionsService.getMyPlan().then (test) ->
            expect(test).to.be.equal(true)
            done()

    it "get public plans", (done) ->
        test = {data: true}
        mocks.http.get.withArgs("http://localhost:5000/api/v1/my-public-plans", {}).promise().resolve(test)

        subscriptionsService.fetchPublicPlans().then (test) ->
            expect(subscriptionsService.publicPlans).to.be.equal(true)
            done()

    it "select a plan", () ->
        data = {data: true}

        subscriptionsService.selectMyPlan(data)
        expect(mocks.http.post).calledWith("http://localhost:5000/api/v1/my-subscription/change", data)
