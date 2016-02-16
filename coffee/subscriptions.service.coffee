module = angular.module('subscriptions')

class SubscriptionsService
    @.$inject = ["$tgHttp"]

    constructor: (@http) ->

    getMyRecommendedPlan: ->
        url = "http://localhost:5000/api/v1/my-recommended-plan"

        return @http.get(url, {}).then (response) ->
            return response.data

    getMyPlan: ->
        url = "http://localhost:5000/api/v1/my-subscription"

        return @http.get(url, {}).then (response) ->
            return response.data

    getPublicPlans: ->
        url = "http://localhost:5000/api/v1/my-public-plans"

        return @http.get(url, {}).then (response) ->
            return response.data

    selectMyPlan: (data) ->
        url = "http://localhost:5000/api/v1/my-subscription/change"

        return @http.post(url, data).then (response) ->
            return response.data

module.service("ContribSubscriptionsService", SubscriptionsService)
