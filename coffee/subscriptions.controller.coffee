module = angular.module('subscriptions')

class SubscriptionsAdmin
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService",
        "$translate",
        "tgLoader"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @translate, @tgLoader) ->
        pluginName = "Subscriptions - User Profile - Taiga" # i18n
        @.sectionName = "Upgrade Plan"

        title = pluginName
        description = @.sectionName
        @appMetaService.setAll(title, description)

        @tgLoader.start()
        promise = @subscriptionsService.getMyRecommendedPlan()

        promise.then(@.onSuccess.bind(this))

    onSuccess: (response) ->
        @.yourRecommendedPlan = response
        if !@.yourRecommendedPlan
            console.log 'history'
            @.plan = "paid"
            promise = @subscriptionsService.getMyPlan()
            promise.then(@._paidPlan.bind(this))
        else if @.yourRecommendedPlan.recommended_plan.amount_month == 0
            console.log 'zero'
            @.plan = "zero"
            promise = @subscriptionsService.getMyPlan()
            promise.then(@._paidPlan.bind(this))
        else
            @.plan = "recommended"
            promise = @subscriptionsService.getMyRecommendedPlan()
            promise.then(@._recommendPlan.bind(this))

    getTemplateUrl: () ->
        return "compile-modules/taiga-contrib-subscriptions/partials/subscriptions-"+@.plan+".html"

    _recommendPlan: (response) ->
        console.log response
        @tgLoader.pageLoaded()
        @.myRecommendedPlan = response

    _paidPlan: (response) ->
        console.log response
        @tgLoader.pageLoaded()
        @.myPlan = response

module.controller("ContribSubscriptionsController", SubscriptionsAdmin)
