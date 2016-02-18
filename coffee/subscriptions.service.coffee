module = angular.module('subscriptions')

class SubscriptionsService
    @.$inject = ["$tgHttp"]

    constructor: (@http) ->
        @.myRecommendedPlan = null
        @.myPlan = null
        @.publicPlans = null

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
        url = "http://localhost:5000/api/v1/my-recommended-plan"

        return @http.get(url, {}).then (response) => @.setRecommendedPlan(response.data)

    getMyPlan: ->
        url = "http://localhost:5000/api/v1/my-subscription"

        return @http.get(url, {}).then (response) ->
            return response.data

    fetchPublicPlans: ->
        url = "http://localhost:5000/api/v1/my-public-plans"

        return @http.get(url, {}).then (response) => @.publicPlans = response.data

    selectMyPlan: (data) ->
        url = "http://localhost:5000/api/v1/my-subscription/change"

        return @http.post(url, data)

module.service("ContribSubscriptionsService", SubscriptionsService)
