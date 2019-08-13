###
# Copyright (C) 2014-2019 Taiga Agile LLC
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

    _mockConfig = () ->
        mocks.config = {
            get: sinon.stub()
        }
        provide.value "$tgConfig", mocks.config


    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockHttp()
            _mockConfig()

            return null

    _inject = (callback) ->
        inject (_ContribSubscriptionsService_) ->
            subscriptionsService = _ContribSubscriptionsService_

    beforeEach ->
        module "subscriptions"
        _mocks()
        _inject()
        mocks.config.get.withArgs("subscriptionsAPI", "http://localhost:5000/api/v1/").returns("http://localhost:5000/api/v1/")

    it "set user recommended plan", (done) ->
        test = {response: true}
        subscriptionsService.getMyPlan = sinon.stub()
        subscriptionsService.getMyPlan.promise().resolve(test)
        subscriptionsService.loadUserPlan().then () ->
            expect(subscriptionsService.myPlan).to.be.eql(test)
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

    it "select a plan", (done) ->
        data = {}

        mocks.http.post.withArgs("http://localhost:5000/api/v1/my-subscription/change").promise().resolve(data)

        subscriptionsService.selectMyPlan(data).then () ->
            expect(subscriptionsService.myPlan).to.be.eql(data)
            done()

    it "create subscription", (done) ->
        data = {"https://demo-account.quadernoapp.com/checkout/session/8ccf3fdc42b85800188b113b81d3e4212ef094b"}

        mocks.http.post.withArgs("http://localhost:5000/api/v1/my-subscription/create").promise().resolve(data)

        subscriptionsService.createSubscription({}).then () ->
            expect(subscriptionsService.currentSession).to.be.eql(data)
            done()
