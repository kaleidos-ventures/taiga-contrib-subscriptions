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
# File: subscription.service.coffee
###

module = angular.module('subscriptions')

class SubscriptionsService
    @.$inject = ["$tgHttp", "$tgConfig"]

    constructor: (@http, @config) ->
        @.myRecommendedPlan = null
        @.myPlan = null
        @.publicPlans = null

    getSubscriptionsAPIURL: ->
        return @config.get("subscriptionsAPI", "http://localhost:5000/api/v1/")

    loadUserPlan: ->
        @.getMyPlan().then (response) =>
            @.myPlan = response

    setRecommendedPlan: (recommendedPlan) ->
        return new Promise (resolve) =>
            if !recommendedPlan
                @.loadUserPlan().then(resolve)
            else
                @.myRecommendedPlan = recommendedPlan
                resolve()

    fetchMyPlans: ->
        url = "#{@.getSubscriptionsAPIURL()}my-recommended-plan"

        return @http.get(url, {}).then (response) => @.setRecommendedPlan(response.data)

    getMyPlan: ->
        url = "#{@.getSubscriptionsAPIURL()}my-subscription"

        return @http.get(url, {}).then (response) ->
            return response.data

    fetchPublicPlans: ->
        url = "#{@.getSubscriptionsAPIURL()}my-public-plans"

        return @http.get(url, {}).then (response) => @.publicPlans = response.data

    selectMyPlan: (data) ->
        url = "#{@.getSubscriptionsAPIURL()}my-subscription/change"

        return @http.post(url, data).then (response) =>
            @.myPlan = response

module.service("ContribSubscriptionsService", SubscriptionsService)
