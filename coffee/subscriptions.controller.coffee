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
        promise = @subscriptionsService.getMyPlan()

        promise.then(@.onSuccess.bind(this))

    onSuccess: (response) ->
        @.yourPlan = response.current_plan.amount_month
        if @.yourPlan != 0
            @.plan = "recommended"
            promise = @subscriptionsService.getMyRecommendedPlan()
            promise.then(@._recommendPlan.bind(this))
        else
            @.plan = "plan"
            @._paidPlan(response)

    getTemplateUrl: () ->
        return "compile-modules/taiga-contrib-subscriptions/partials/subscriptions-"+@.plan+".html"

    _recommendPlan: (response) ->
        @tgLoader.pageLoaded()
        @.myRecommendedPlan = response

    _paidPlan: (response) ->
        @tgLoader.pageLoaded()
        @.myPlan = response

module.controller("ContribSubscriptionsController", SubscriptionsAdmin)
