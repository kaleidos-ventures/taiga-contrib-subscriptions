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

        return @http.post(url, data)

module.service("ContribSubscriptionsService", SubscriptionsService)
