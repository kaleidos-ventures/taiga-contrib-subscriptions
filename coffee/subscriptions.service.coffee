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
# File: subscription.service.coffee
###

module = angular.module('subscriptions')

class SubscriptionsService
    @.$inject = ["$tgHttp", "$tgConfig"]

    constructor: (@http, @config) ->
        @.myPlan = null
        @.publicPlans = null
        @.perSeatPlan = null

    getSubscriptionsAPIURL: ->
        return @config.get("subscriptionsAPI", "http://localhost:5000/api/v1/")

    getAPIURL: ->
        return @config.get("api", "http://localhost:8000/api/v1/")

    loadUserPlan: ->
        @.getMyPlan().then (response) =>
            @.myPlan = response

    contact: (message) ->
        url = "#{@.getSubscriptionsAPIURL()}contact"

        return @http.post(url, {message: message})

    getMyPlan: ->
        url = "#{@.getSubscriptionsAPIURL()}my-subscription"

        return @http.get(url, {}).then (response) ->
            return response.data

    fetchPublicPlans: ->
        url = "#{@.getSubscriptionsAPIURL()}my-public-plans"

        return @http.get(url, {}).then (response) => @.publicPlans = response.data

    cancelMyPlan: () =>
        url = "#{@.getAPIURL()}delete-owned-projects"

        return @http.post(url).then (response) =>
            url = "#{@.getSubscriptionsAPIURL()}my-subscription/cancel"

            return @http.post(url).then (response) =>
                @.myPlan = response

    selectMyPlan: (data) =>
        url = "#{@.getSubscriptionsAPIURL()}my-subscription/change"

        return @http.post(url, data).then (response) =>
            @.myPlan = response

    getMyPerSeatPlan: () ->
        url = "#{@.getSubscriptionsAPIURL()}my-plan-per-seat"

        return @http.get(url).then (response) =>
            @.perSeatPlan = response.data

    setMyPerSeatPlanNotifyLimit: (notify_limit) ->
        url = "#{@.getSubscriptionsAPIURL()}my-plan-per-seat-notify-limit"

        return @http.post(url, {notify_limit: notify_limit})

    removeUserFromMyProjects: (userId) ->
        url = "#{@.getAPIURL()}memberships/remove_user_from_all_my_projects"

        return @http.post(url, {user: userId, private_only: true})

module.service("ContribSubscriptionsService", SubscriptionsService)
